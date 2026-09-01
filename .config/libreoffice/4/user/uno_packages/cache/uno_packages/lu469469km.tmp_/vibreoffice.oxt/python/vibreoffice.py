from __future__ import annotations

import uno
import unohelper
import subprocess
import json
import os
import time
import traceback
from typing import Any

from com.sun.star.frame import XDispatchProvider, XDispatch
from com.sun.star.lang import XServiceInfo, XInitialization
from com.sun.star.awt import XKeyHandler
from com.sun.star.task import XJob
from com.sun.star.awt import KeyModifier

CTRL: int = KeyModifier.MOD1
ALT: int = KeyModifier.MOD2
SHIFT: int = KeyModifier.SHIFT
LOG_FILE: str = "/tmp/vibreoffice.log"

_mode: str = "normal"
_enabled: bool = False
_keybinds: dict[str, dict[str, str]] = {}
_key_buffer: str = ""
_count_buffer: str = ""
_original_title: str = ""
_handlers: list[tuple[Any, VibreofficeKeyHandler]] = []

KEYCODE_MAP: dict[int, str] = {
    1024: "Down",
    1025: "Up",
    1026: "Left",
    1027: "Right",
    1028: "Home",
    1029: "End",
    1030: "PageUp",
    1031: "PageDown",
    1280: "Enter",
    1281: "Escape",
    1282: "Tab",
    1283: "Backspace",
    1284: "Space",
    1285: "Insert",
    1286: "Delete",
    768: "F1",
    769: "F2",
    770: "F3",
    771: "F4",
    772: "F5",
    773: "F6",
    774: "F7",
    775: "F8",
    776: "F9",
    777: "F10",
    778: "F11",
    779: "F12",
}

ACTION_COMMANDS: dict[str, list[str]] = {
    "move_left": [".uno:GoLeft"],
    "move_down": [".uno:GoDown"],
    "move_up": [".uno:GoUp"],
    "move_right": [".uno:GoRight"],
    "word_forward": [".uno:GoToNextWord"],
    "word_backward": [".uno:GoToPrevWord"],
    "word_end": [".uno:GoRight", ".uno:GoToNextWord", ".uno:GoLeft"],
    "word_forward_big": [".uno:GoToNextWord"],
    "word_backward_big": [".uno:GoToPrevWord"],
    "word_end_big": [".uno:GoRight", ".uno:GoToNextWord", ".uno:GoLeft"],
    "para_start": [".uno:GoToStartOfPara"],
    "para_end": [".uno:GoToEndOfPara"],
    "para_up": [".uno:GoToPrevPara"],
    "para_down": [".uno:GoToNextPara"],
    "doc_start": [".uno:GoToStartOfDoc"],
    "doc_end": [".uno:GoToEndOfDoc"],
    "page_down": [".uno:PageDown"],
    "page_up": [".uno:PageUp"],
    "delete_char": [".uno:Delete"],
    "delete_para": [
        ".uno:GoToStartOfPara",
        ".uno:GoToEndOfParaSel",
        ".uno:GoRightSel",
        ".uno:Delete",
    ],
    "delete_to_para_end": [".uno:GoToEndOfParaSel", ".uno:Delete"],
    "delete_selection": [".uno:Delete"],
    "yank_para": [
        ".uno:GoToStartOfPara",
        ".uno:GoToEndOfParaSel",
        ".uno:Copy",
        ".uno:GoLeft",
    ],
    "yank_selection": [".uno:Copy"],
    "paste_after": [".uno:GoRight", ".uno:Paste"],
    "paste_before": [".uno:Paste"],
    "undo": [".uno:Undo"],
    "redo": [".uno:Redo"],
    "open_search": [".uno:SearchDialog"],
    "find_next": [".uno:DownSearch"],
    "find_prev": [".uno:UpSearch"],
    "join_para": [".uno:GoToEndOfPara", ".uno:Delete"],
    "enter_insert_after": [".uno:GoRight"],
    "enter_insert_line_end": [".uno:GoToEndOfPara"],
    "enter_insert_line_start": [".uno:GoToStartOfPara"],
    "open_below": [".uno:GoToEndOfPara", ".uno:InsertPara"],
    "open_above": [".uno:GoToStartOfPara", ".uno:InsertPara", ".uno:GoUp"],
    "enter_insert": [],
    "enter_visual": [],
    "enter_visual_line": [".uno:GoToStartOfPara", ".uno:GoToEndOfParaSel"],
    "change_to_para_end": [".uno:GoToEndOfParaSel", ".uno:Delete"],
    "change_para": [
        ".uno:GoToStartOfPara",
        ".uno:GoToEndOfParaSel",
        ".uno:GoRightSel",
        ".uno:Delete",
    ],
    "substitute_char": [".uno:Delete"],
    "indent": [".uno:IncrementIndent"],
    "outdent": [".uno:DecrementIndent"],
    "indent_selection": [".uno:IncrementIndent"],
    "outdent_selection": [".uno:DecrementIndent"],
    "select_left": [".uno:GoLeftSel"],
    "select_down": [".uno:GoDownSel"],
    "select_up": [".uno:GoUpSel"],
    "select_right": [".uno:GoRightSel"],
    "select_word_forward": [".uno:GoToNextWordSel"],
    "select_word_backward": [".uno:GoToPrevWordSel"],
    "select_word_end": [".uno:GoRightSel", ".uno:GoToNextWordSel", ".uno:GoLeftSel"],
    "select_para_start": [".uno:GoToStartOfParaSel"],
    "select_para_end": [".uno:GoToEndOfParaSel"],
    "select_para_up": [".uno:GoToPrevParaSel"],
    "select_para_down": [".uno:GoToNextParaSel"],
    "select_doc_start": [".uno:GoToStartOfDocSel"],
    "select_doc_end": [".uno:GoToEndOfDocSel"],
}

CURSOR_ACTIONS: dict[str, tuple[str, bool]] = {
    "move_left": ("goLeft", False),
    "move_right": ("goRight", False),
    "move_up": ("goUp", False),
    "move_down": ("goDown", False),
    "doc_start": ("gotoStart", False),
    "doc_end": ("gotoEnd", False),
    "select_left": ("goLeft", True),
    "select_right": ("goRight", True),
    "select_up": ("goUp", True),
    "select_down": ("goDown", True),
    "select_doc_start": ("gotoStart", True),
    "select_doc_end": ("gotoEnd", True),
}

REPEATABLE_ACTIONS: set[str] = {
    "move_left",
    "move_down",
    "move_up",
    "move_right",
    "word_forward",
    "word_backward",
    "word_end",
    "word_forward_big",
    "word_backward_big",
    "word_end_big",
    "para_up",
    "para_down",
    "delete_char",
    "select_left",
    "select_down",
    "select_up",
    "select_right",
    "select_word_forward",
    "select_word_backward",
    "select_word_end",
    "select_para_up",
    "select_para_down",
}

MODE_SWITCH_ACTIONS: set[str] = {
    "enter_insert",
    "enter_insert_after",
    "enter_insert_line_end",
    "enter_insert_line_start",
    "enter_normal",
    "enter_visual",
    "enter_visual_line",
    "open_below",
    "open_above",
    "change_to_para_end",
    "change_para",
    "substitute_char",
}

NORMAL_AFTER_ACTIONS: set[str] = {
    "delete_selection",
    "yank_selection",
}

MODE_FOR_ACTION: dict[str, str] = {
    "enter_insert": "insert",
    "enter_insert_after": "insert",
    "enter_insert_line_end": "insert",
    "enter_insert_line_start": "insert",
    "enter_normal": "normal",
    "enter_visual": "visual",
    "enter_visual_line": "visual_line",
    "open_below": "insert",
    "open_above": "insert",
    "change_to_para_end": "insert",
    "change_para": "insert",
    "substitute_char": "insert",
}


def _log(msg: object) -> None:
    try:
        with open(LOG_FILE, "a") as f:
            f.write("[%s] %s\n" % (time.strftime("%H:%M:%S"), str(msg)))
    except Exception:
        pass


def _bin_path() -> str:
    here: str = os.path.dirname(os.path.abspath(__file__))
    local: str = os.path.join(here, "..", "bin", "vibreoffice-keys")
    if os.path.isfile(local):
        if not os.access(local, os.X_OK):
            os.chmod(local, 0o755)
        return local
    return "vibreoffice-keys"


def _load_keybinds() -> None:
    global _keybinds
    if _keybinds:
        return
    try:
        result = subprocess.run(
            [_bin_path()],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            _log("keybinds error: " + result.stderr)
            return
        _keybinds = json.loads(result.stdout)
    except Exception:
        _log("load keybinds: " + traceback.format_exc())


def _get_desktop(ctx: Any) -> Any:
    smgr = ctx.ServiceManager
    return smgr.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)


def _get_frame(ctx: Any) -> Any:
    return _get_desktop(ctx).getCurrentFrame()


def _get_undo_count(ctx: Any) -> int | None:
    try:
        doc = _get_desktop(ctx).getCurrentComponent()
        if doc and hasattr(doc, "getUndoManager"):
            return len(doc.getUndoManager().getAllUndoActionTitles())
    except Exception:
        pass
    return None


def _cursor_move(ctx: Any, action: str, count: int, frame: Any = None) -> bool:
    if action not in CURSOR_ACTIONS:
        return False
    method_name: str
    expand: bool
    method_name, expand = CURSOR_ACTIONS[action]
    try:
        if frame is None:
            frame = _get_frame(ctx)
        cursor = frame.Controller.getViewCursor()
        if method_name in ("goLeft", "goRight", "goUp", "goDown"):
            getattr(cursor, method_name)(count, expand)
        else:
            getattr(cursor, method_name)(expand)
        return True
    except Exception:
        _log("cursor move FAILED: " + traceback.format_exc())
        return False


def _dispatch(ctx: Any, cmd: str, frame: Any = None) -> None:
    if frame is None:
        frame = _get_frame(ctx)
    if not frame:
        return
    smgr = ctx.ServiceManager
    helper = smgr.createInstanceWithContext("com.sun.star.frame.DispatchHelper", ctx)
    helper.executeDispatch(frame, cmd, "", 0, ())


def _word_end_move(ctx: Any, count: int, select: bool, frame: Any) -> None:
    if frame is None:
        frame = _get_frame(ctx)
    try:
        doc = _get_desktop(ctx).getCurrentComponent()
        text = doc.getText()
        vc = frame.Controller.getViewCursor()
        if select:
            tc = text.createTextCursorByRange(vc)
        else:
            tc = text.createTextCursorByRange(vc.getStart())
        for _ in range(count):
            tc.goRight(1, select)
            if not tc.gotoEndOfWord(select):
                tc.gotoEndOfParagraph(select)
                break
        frame.Controller.select(tc)
    except Exception:
        _log("word_end_move FAILED: " + traceback.format_exc())


def _execute_action(ctx: Any, action: str, count: int, frame: Any = None) -> None:
    if frame is None:
        frame = _get_frame(ctx)

    if action == "paste_after":
        try:
            cursor = frame.Controller.getViewCursor()
            if not cursor.isAtEndOfLine():
                cursor.goRight(1, False)
        except Exception:
            _dispatch(ctx, ".uno:GoRight", frame)
        _dispatch(ctx, ".uno:Paste", frame)
    elif action in ("word_end", "word_end_big"):
        _word_end_move(ctx, count, False, frame)
    elif action == "select_word_end":
        _word_end_move(ctx, count, True, frame)
    elif not _cursor_move(ctx, action, count, frame):
        commands: list[str] = ACTION_COMMANDS.get(action, [])
        if action in REPEATABLE_ACTIONS:
            for _ in range(count):
                for cmd in commands:
                    _dispatch(ctx, cmd, frame)
        else:
            for cmd in commands:
                _dispatch(ctx, cmd, frame)

    if action in MODE_SWITCH_ACTIONS:
        new_mode: str = MODE_FOR_ACTION[action]
        if _mode in ("visual", "visual_line") and new_mode == "normal":
            _cursor_move(ctx, "move_right", 1, frame)
            _cursor_move(ctx, "move_left", 1, frame)
        _set_mode(ctx, new_mode)
    elif action in NORMAL_AFTER_ACTIONS:
        _set_mode(ctx, "normal")


def _set_mode(ctx: Any, new_mode: str) -> None:
    global _mode
    _mode = new_mode
    _update_title(ctx)


def _update_title(ctx: Any) -> None:
    try:
        desktop = _get_desktop(ctx)
        doc = desktop.getCurrentComponent()
        if doc and hasattr(doc, "setTitle"):
            label: str = _mode.upper().replace("_", " ")
            doc.setTitle(_original_title + " [" + label + "]")
    except Exception:
        _log("update title: " + traceback.format_exc())


def _save_original_title(ctx: Any) -> None:
    global _original_title
    try:
        desktop = _get_desktop(ctx)
        doc = desktop.getCurrentComponent()
        if doc and hasattr(doc, "getTitle"):
            title: str = doc.getTitle()
            for suffix in (" [NORMAL]", " [INSERT]", " [VISUAL]", " [VISUAL LINE]"):
                if title.endswith(suffix):
                    title = title[: -len(suffix)]
                    break
            _original_title = title
    except Exception:
        _log("save title: " + traceback.format_exc())


def _restore_title(ctx: Any) -> None:
    try:
        desktop = _get_desktop(ctx)
        doc = desktop.getCurrentComponent()
        if doc and hasattr(doc, "setTitle"):
            doc.setTitle(_original_title)
    except Exception:
        _log("restore title: " + traceback.format_exc())


def _build_key_string(event: Any) -> str | None:
    mods: int = event.Modifiers
    code: int = event.KeyCode

    name: str | None = KEYCODE_MAP.get(code)
    if name:
        parts: list[str] = []
        if mods & CTRL:
            parts.append("Ctrl")
        if mods & ALT:
            parts.append("Alt")
        if mods & SHIFT:
            parts.append("Shift")
        parts.append(name)
        return "+".join(parts)

    if 512 <= code <= 537:
        letter: str = chr(ord("a") + (code - 512))
        if mods & CTRL:
            parts = ["Ctrl"]
            if mods & ALT:
                parts.append("Alt")
            parts.append(letter)
            return "+".join(parts)
        if mods & SHIFT:
            return letter.upper()
        return letter

    raw = event.KeyChar
    char: str = raw.value if hasattr(raw, "value") else str(raw)
    if char and ord(char) >= 32:
        if mods & CTRL:
            parts = ["Ctrl"]
            if mods & ALT:
                parts.append("Alt")
            parts.append(char)
            return "+".join(parts)
        return char

    return None


def _handle_mode_keys(key: str, mode_name: str) -> tuple[str, int] | None:
    global _key_buffer, _count_buffer

    if key.isdigit() and (key != "0" or _count_buffer):
        _count_buffer += key
        return None

    _key_buffer += key
    mode_binds: dict[str, str] = _keybinds.get(mode_name, {})

    if _key_buffer in mode_binds:
        action: str = mode_binds[_key_buffer]
        count: int = int(_count_buffer) if _count_buffer else 1
        _key_buffer = ""
        _count_buffer = ""
        return (action, count)

    is_prefix: bool = any(
        k.startswith(_key_buffer) and k != _key_buffer for k in mode_binds
    )
    if is_prefix:
        return None

    _key_buffer = ""
    _count_buffer = ""
    return None


class VibreofficeKeyHandler(unohelper.Base, XKeyHandler):
    def __init__(self, ctx: Any, frame: Any) -> None:
        self._ctx = ctx
        self._frame = frame
        self._consumed: bool = False
        self._need_reregister: bool = True
        self._expected_undo: int | None = None

    def _ensure_priority(self) -> None:
        if not self._need_reregister:
            return
        self._need_reregister = False
        try:
            ctrl = self._frame.Controller
            ctrl.removeKeyHandler(self)
            ctrl.addKeyHandler(self)
            _log("handler re-registered for priority")
        except Exception:
            _log("re-register failed: " + traceback.format_exc())

    def _undo_foreign_changes(self) -> None:
        if self._expected_undo is None:
            return
        current: int | None = _get_undo_count(self._ctx)
        if current is None or current <= self._expected_undo:
            return
        extra: int = current - self._expected_undo
        try:
            doc = _get_desktop(self._ctx).getCurrentComponent()
            um = doc.getUndoManager()
            for _ in range(extra):
                um.undo()
        except Exception:
            _log("undo_foreign FAILED: " + traceback.format_exc())

    def keyPressed(self, event: Any) -> bool:
        try:
            self._consumed = False
            self._expected_undo = None

            if not _enabled:
                return False

            key: str | None = _build_key_string(event)
            if not key:
                return False

            if _mode == "normal":
                pending: tuple[str, int] | None = _handle_mode_keys(key, "normal")
                if pending:
                    action: str
                    count: int
                    action, count = pending
                    _execute_action(self._ctx, action, count, self._frame)
                self._expected_undo = _get_undo_count(self._ctx)
                self._consumed = True
                return True

            if _mode == "insert":
                insert_binds: dict[str, str] = _keybinds.get("insert", {})
                if key in insert_binds:
                    action = insert_binds[key]
                    _execute_action(self._ctx, action, 1, self._frame)
                    self._consumed = True
                    return True
                return False

            if _mode in ("visual", "visual_line"):
                mode_name: str = "visual_line" if _mode == "visual_line" else "visual"
                pending = _handle_mode_keys(key, mode_name)
                if pending:
                    action, count = pending
                    _execute_action(self._ctx, action, count, self._frame)
                self._expected_undo = _get_undo_count(self._ctx)
                self._consumed = True
                return True

        except Exception:
            _log("keyPressed EXCEPTION: " + traceback.format_exc())
        return False

    def keyReleased(self, event: Any) -> bool:
        try:
            consumed: bool = self._consumed
            self._consumed = False
            if consumed:
                self._ensure_priority()
                self._undo_foreign_changes()
            return consumed
        except Exception:
            _log("keyReleased EXCEPTION: " + traceback.format_exc())
            return False

    def disposing(self, source: Any) -> None:
        global _handlers
        _handlers = [(f, h) for f, h in _handlers if h is not self]


class VibreofficeHandler(
    unohelper.Base, XDispatchProvider, XDispatch, XServiceInfo, XInitialization
):
    IMPLE_NAME: str = "org.vibreoffice.VibreofficeHandler"
    SERVICE_NAMES: tuple[str, ...] = ("com.sun.star.frame.ProtocolHandler",)

    def __init__(self, ctx: Any) -> None:
        self.ctx = ctx

    def initialize(self, args: Any) -> None:
        pass

    def getImplementationName(self) -> str:
        return self.IMPLE_NAME

    def supportsService(self, name: str) -> bool:
        return name in self.SERVICE_NAMES

    def getSupportedServiceNames(self) -> tuple[str, ...]:
        return self.SERVICE_NAMES

    def queryDispatch(
        self, url: Any, target: str, flags: int
    ) -> VibreofficeHandler | None:
        if url.Protocol == "org.vibreoffice.vibreoffice:":
            return self
        return None

    def queryDispatches(self, requests: Any) -> list[VibreofficeHandler | None]:
        return [
            self.queryDispatch(r.FeatureURL, r.FrameName, r.SearchFlags)
            for r in requests
        ]

    def dispatch(self, url: Any, args: Any) -> None:
        global _enabled, _mode, _key_buffer, _count_buffer
        try:
            cmd: str = url.Path
            if cmd == "toggle":
                if _enabled:
                    _enabled = False
                    _restore_title(self.ctx)
                else:
                    _enabled = True
                    _key_buffer = ""
                    _count_buffer = ""
                    _save_original_title(self.ctx)
                    _mode = "insert"
                    _set_mode(self.ctx, "normal")
            elif cmd == "enable":
                if not _enabled:
                    _enabled = True
                    _key_buffer = ""
                    _count_buffer = ""
                    _save_original_title(self.ctx)
                    _mode = "insert"
                    _set_mode(self.ctx, "normal")
            elif cmd == "disable":
                if _enabled:
                    _enabled = False
                    _restore_title(self.ctx)
        except Exception:
            _log("dispatch: " + traceback.format_exc())

    def addStatusListener(self, listener: Any, url: Any) -> None:
        pass

    def removeStatusListener(self, listener: Any, url: Any) -> None:
        pass


class VibreofficeStartupJob(unohelper.Base, XJob, XServiceInfo):
    IMPLE_NAME: str = "org.vibreoffice.VibreofficeStartupJob"
    SERVICE_NAMES: tuple[str, ...] = ("com.sun.star.task.Job",)

    def __init__(self, ctx: Any) -> None:
        self.ctx = ctx

    def execute(self, args: Any) -> tuple[()]:
        global _handlers, _enabled, _mode, _key_buffer, _count_buffer
        try:
            _load_keybinds()

            env: dict[str, Any] = {}
            for nv in args:
                if nv.Name == "Environment":
                    for env_nv in nv.Value:
                        env[env_nv.Name] = env_nv.Value
            frame: Any = env.get("Frame")
            if not frame:
                model = env.get("Model")
                if model:
                    frame = model.getCurrentController().getFrame()
            if frame and frame.Controller:
                for stored_frame, _ in _handlers:
                    try:
                        if stored_frame == frame:
                            return ()
                    except Exception:
                        pass
                kh: VibreofficeKeyHandler = VibreofficeKeyHandler(self.ctx, frame)
                frame.Controller.addKeyHandler(kh)
                _handlers.append((frame, kh))

                _enabled = True
                _key_buffer = ""
                _count_buffer = ""
                _save_original_title(self.ctx)
                _mode = "normal"
                _update_title(self.ctx)

                _log("vibreoffice enabled, key handler registered")
        except Exception:
            _log("startup job: " + traceback.format_exc())
        return ()

    def getImplementationName(self) -> str:
        return self.IMPLE_NAME

    def supportsService(self, name: str) -> bool:
        return name in self.SERVICE_NAMES

    def getSupportedServiceNames(self) -> tuple[str, ...]:
        return self.SERVICE_NAMES


g_ImplementationHelper = unohelper.ImplementationHelper()
g_ImplementationHelper.addImplementation(
    VibreofficeHandler,
    VibreofficeHandler.IMPLE_NAME,
    VibreofficeHandler.SERVICE_NAMES,
)
g_ImplementationHelper.addImplementation(
    VibreofficeStartupJob,
    VibreofficeStartupJob.IMPLE_NAME,
    VibreofficeStartupJob.SERVICE_NAMES,
)
