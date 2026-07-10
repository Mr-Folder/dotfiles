#!/usr/bin/env python3
"""Floating GTK overlay minimap of the current window's pane layout,
shown while a pane is zoomed.

Usage:
    pane-minimap-overlay.py --ensure   # start the daemon if not running, exit
    pane-minimap-overlay.py            # run as the daemon (foreground)
    pane-minimap-overlay.py --debug    # daemon mode with tick logging to stderr
"""
import fcntl
import os
import subprocess
import sys

LOCK_PATH = os.path.expanduser("~/.cache/tmux-minimap.lock")

OVERLAY_WIDTH = 100
MARGIN_RIGHT = 16    # px from the terminal window's right edge
TOP_OFFSET_FRAC = 0.08  # fraction of terminal height below its top edge

DEBUG = "--debug" in sys.argv[1:]


def log(msg):
    if DEBUG:
        print(msg, file=sys.stderr, flush=True)


class ParseError(Exception):
    pass


def parse_layout(layout: str):
    """Parse a tmux window_layout string (with leading checksum) into a
    list of leaves: (x, y, w, h, id) where id is the numeric pane id."""
    comma = layout.find(",")
    if comma == -1:
        raise ParseError("no checksum comma found")
    body = layout[comma + 1:]

    leaves = []
    idx = 0
    n = len(body)

    def parse_number():
        nonlocal idx
        start = idx
        while idx < n and body[idx].isdigit():
            idx += 1
        if idx == start:
            raise ParseError(f"expected number at {idx}")
        return int(body[start:idx])

    def expect(ch):
        nonlocal idx
        if idx >= n or body[idx] != ch:
            raise ParseError(f"expected {ch!r} at {idx}")
        idx += 1

    def parse_cell():
        nonlocal idx
        w = parse_number()
        expect("x")
        h = parse_number()
        expect(",")
        x = parse_number()
        expect(",")
        y = parse_number()
        if idx < n and body[idx] == ",":
            idx += 1
            pane_id = parse_number()
            leaves.append((x, y, w, h, pane_id))
        elif idx < n and body[idx] == "{":
            idx += 1
            parse_cell()
            while idx < n and body[idx] == ",":
                idx += 1
                parse_cell()
            expect("}")
        elif idx < n and body[idx] == "[":
            idx += 1
            parse_cell()
            while idx < n and body[idx] == ",":
                idx += 1
                parse_cell()
            expect("]")
        else:
            raise ParseError(f"unexpected char at {idx}")

    parse_cell()
    return leaves


def bounding_box(leaves):
    max_x = max(x + w for (x, y, w, h, pid) in leaves)
    max_y = max(y + h for (x, y, w, h, pid) in leaves)
    return max_x, max_y


# --------------------------------------------------------------------------
# --ensure mode: single-instance launcher
# --------------------------------------------------------------------------

def ensure_display():
    """Return a usable DISPLAY value, querying the tmux server's global
    environment if this process (e.g. run from a hook) lacks one."""
    if "DISPLAY" in os.environ:
        return os.environ["DISPLAY"]
    try:
        out = subprocess.check_output(
            ["tmux", "show-environment", "-g", "DISPLAY"], text=True
        ).strip()
        if out.startswith("DISPLAY="):
            return out.split("=", 1)[1]
    except Exception:
        pass
    return None


def do_ensure():
    display = ensure_display()
    if not display:
        return 0

    os.makedirs(os.path.dirname(LOCK_PATH), exist_ok=True)
    lock_fd = os.open(LOCK_PATH, os.O_CREAT | os.O_RDWR, 0o644)
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        # Another process holds the lock: daemon already running.
        os.close(lock_fd)
        return 0

    # We got the lock: no daemon is running. Release it here (the daemon
    # will reacquire and hold it) and spawn the daemon detached.
    fcntl.flock(lock_fd, fcntl.LOCK_UN)
    os.close(lock_fd)

    env = dict(os.environ)
    env["DISPLAY"] = display

    subprocess.Popen(
        [sys.executable, os.path.abspath(__file__)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        stdin=subprocess.DEVNULL,
        env=env,
        start_new_session=True,
    )
    return 0


# --------------------------------------------------------------------------
# daemon mode
# --------------------------------------------------------------------------

def run_daemon():
    os.makedirs(os.path.dirname(LOCK_PATH), exist_ok=True)
    lock_fd = os.open(LOCK_PATH, os.O_CREAT | os.O_RDWR, 0o644)
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        log("daemon: could not acquire lock, another daemon is running; exiting")
        return 0
    # Hold lock_fd open (and locked) for the lifetime of this process.

    import gi
    gi.require_version("Gtk", "3.0")
    gi.require_version("Wnck", "3.0")
    from gi.repository import Gtk, Gdk, GLib, Wnck
    import cairo

    class MinimapWindow(Gtk.Window):
        def __init__(self):
            super().__init__(type=Gtk.WindowType.TOPLEVEL)
            self.set_decorated(False)
            self.set_keep_above(True)
            self.stick()
            self.set_skip_taskbar_hint(True)
            self.set_skip_pager_hint(True)
            self.set_accept_focus(False)
            self.set_focus_on_map(False)
            self.set_type_hint(Gdk.WindowTypeHint.UTILITY)

            screen = self.get_screen()
            visual = screen.get_rgba_visual()
            self.has_rgba = visual is not None
            if visual is not None:
                self.set_visual(visual)
            self.set_app_paintable(True)

            self.rects = []       # list of (x0, y0, x1, y1, is_active) in pixel coords
            self.win_w = OVERLAY_WIDTH
            self.win_h = 60

            self.connect("draw", self.on_draw)
            self.connect("realize", self.on_realize)
            self.connect("show", self.on_show_event)

            self.set_default_size(self.win_w, self.win_h)

        def on_realize(self, *_a):
            self._apply_input_shape()

        def on_show_event(self, *_a):
            GLib.idle_add(self._apply_input_shape)

        def _apply_input_shape(self):
            win = self.get_window()
            if win is not None:
                win.input_shape_combine_region(cairo.Region(), 0, 0)

        def on_draw(self, widget, cr):
            alloc = widget.get_allocation()
            w, h = alloc.width, alloc.height

            if self.has_rgba:
                # Transparent background with a faint dark wash so the
                # outlines stay readable over text underneath.
                cr.save()
                cr.set_operator(cairo.OPERATOR_CLEAR)
                cr.paint()
                cr.restore()
                cr.set_source_rgba(0.0, 0.0, 0.0, 0.30)
                cr.rectangle(0, 0, w, h)
                cr.fill()
            else:
                # No compositing available: fall back to translucent dark
                # panel so we don't render an opaque black box.
                cr.set_source_rgba(0.08, 0.08, 0.08, 0.85)
                cr.rectangle(0, 0, w, h)
                cr.fill()

            for (x0, y0, x1, y1, is_active) in self.rects:
                rw = max(0.0, x1 - x0)
                rh = max(0.0, y1 - y0)

                # Every pane: thin outline over a dark casing stroke so it
                # stays visible on top of light text.
                cr.set_source_rgba(0.0, 0.0, 0.0, 0.65)
                cr.set_line_width(3.5)
                cr.rectangle(x0, y0, rw, rh)
                cr.stroke()
                cr.set_source_rgba(0.85, 0.85, 0.85, 0.85)
                cr.set_line_width(1.5)
                cr.rectangle(x0, y0, rw, rh)
                cr.stroke()

                if is_active:
                    # Active pane: red dot with dark ring at rect center.
                    cx = x0 + rw / 2
                    cy = y0 + rh / 2
                    cr.set_source_rgba(0.0, 0.0, 0.0, 0.65)
                    cr.arc(cx, cy, 5.0, 0, 2 * 3.141592653589793)
                    cr.fill()
                    cr.set_source_rgba(0.95, 0.2, 0.2, 1.0)
                    cr.arc(cx, cy, 3.5, 0, 2 * 3.141592653589793)
                    cr.fill()

            return False

        def compute_geometry(self, cell_w, cell_h):
            """Compute window pixel size from tmux window cell dims (W, H),
            using a cell aspect ratio of 1 wide x 2 tall."""
            width = OVERLAY_WIDTH
            if cell_w <= 0:
                cell_w = 1
            height = width * (cell_h * 2) / cell_w
            height = max(30, min(120, height))
            return width, int(round(height))

        def set_layout(self, leaves, cell_w, cell_h, active_id):
            width, height = self.compute_geometry(cell_w, cell_h)
            resized = (width != self.win_w or height != self.win_h)
            self.win_w = width
            self.win_h = height
            if resized:
                self.resize(width, height)

            margin = 6
            unit_w = cell_w
            unit_h = cell_h * 2
            avail_w = max(1, width - 2 * margin)
            avail_h = max(1, height - 2 * margin)
            if unit_w <= 0:
                unit_w = 1
            if unit_h <= 0:
                unit_h = 1
            scale = min(avail_w / unit_w, avail_h / unit_h)

            offset_x = margin + (avail_w - unit_w * scale) / 2
            offset_y = margin + (avail_h - unit_h * scale) / 2

            gap = 2
            rects = []
            for (x, y, w, h, pid) in leaves:
                px = x
                py = y * 2
                pw = w
                ph = h * 2

                rx0 = offset_x + px * scale + gap
                ry0 = offset_y + py * scale + gap
                rx1 = offset_x + (px + pw) * scale - gap
                ry1 = offset_y + (py + ph) * scale - gap

                is_active = (active_id is not None and pid == active_id)
                rects.append((rx0, ry0, rx1, ry1, is_active))

            self.rects = rects
            self.queue_draw()
            return resized

        def reposition(self, gx, gy, gw, gh):
            """Attach near the terminal window's top-right corner.
            (gx, gy, gw, gh) is the terminal's outer frame geometry from
            wnck."""
            win_w, _win_h = self.get_size()
            x = gx + gw - win_w - MARGIN_RIGHT
            y = gy + int(gh * TOP_OFFSET_FRAC)
            self.move(x, y)

    win = MinimapWindow()

    wnck_screen = Wnck.Screen.get_default()
    wnck_screen.force_update()

    state = {"fail_count": 0}

    def parse_active_pane_id(pane_id_str):
        try:
            return int(str(pane_id_str).lstrip("%"))
        except ValueError:
            return None

    def tick():
        # Only show while the kitty terminal window is focused; attach to it.
        active = wnck_screen.get_active_window()
        if active is None:
            log("hide: no active window")
            win.hide()
            return True
        cls = (active.get_class_group_name() or "") + " " + \
              (active.get_class_instance_name() or "")
        if "kitty" not in cls.lower():
            log(f"hide: active window not kitty (class={cls.strip()!r})")
            win.hide()
            return True
        term_geom = active.get_geometry()  # (x, y, w, h) outer frame

        try:
            clients_out = subprocess.check_output(
                ["tmux", "list-clients", "-F", "#{client_activity} #{session_name}"],
                text=True, stderr=subprocess.DEVNULL,
            ).strip()
        except Exception:
            clients_out = ""

        if not clients_out:
            state["fail_count"] += 1
            log("hide: no clients")
            win.hide()
            if state["fail_count"] >= 40:
                log("daemon: 40 consecutive failures, quitting")
                Gtk.main_quit()
            return True

        state["fail_count"] = 0

        lines = clients_out.split("\n")
        try:
            lines.sort(key=lambda l: int(l.split(" ", 1)[0]), reverse=True)
        except Exception:
            pass
        session_name = lines[0].split(" ", 1)[1] if lines else None
        if not session_name:
            log("hide: no session")
            win.hide()
            return True

        try:
            msg = subprocess.check_output(
                ["tmux", "display-message", "-p", "-t", session_name,
                 "#{window_zoomed_flag}\t#{pane_id}\t#{window_layout}"],
                text=True, stderr=subprocess.DEVNULL,
            ).strip("\n")
            zoomed, pane_id, layout = msg.split("\t")
        except Exception as e:
            log(f"hide: display-message failed: {e}")
            win.hide()
            return True

        if zoomed != "1":
            log("hide: not zoomed")
            win.hide()
            return True

        try:
            leaves = parse_layout(layout)
            if not leaves:
                raise ParseError("no leaves")
            cell_w, cell_h = bounding_box(leaves)
            active_id = parse_active_pane_id(pane_id)
        except Exception as e:
            log(f"hide: parse error: {e}")
            win.hide()
            return True

        win.set_layout(leaves, cell_w, cell_h, active_id)
        win.reposition(*term_geom)
        win.show_all()
        win._apply_input_shape()
        win.queue_draw()
        log(f"show: session={session_name} zoomed pane={pane_id} rects={len(leaves)}")
        return True

    GLib.timeout_add(250, tick)
    Gtk.main()
    return 0


def main(argv):
    if "--ensure" in argv:
        return do_ensure()
    return run_daemon()


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
