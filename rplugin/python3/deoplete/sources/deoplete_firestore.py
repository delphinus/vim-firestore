import re
import subprocess

from deoplete.util import debug
from .base import Base
from functools import reduce
from pathlib import Path
from json import load


class Source(Base):
    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = "firestore"
        self.mark = "[fs]"
        self.filetypes = ["firestore"]
        self.input_pattern = r"(?: [peg]\w*|[]\w\)\}'\"]+\.\w*|allow\s[a-z\s,]*)$"
        self.rank = 500

    def on_init(self, context):
        setting = Path(__file__).parent / "firestore.json"
        with setting.open() as f:
            loaded = load(f)
            self.__access_controls = loaded["access_controls"]
            self.__globals = loaded["globals"]
            self.__methods = loaded["methods"]
            self.__types = loaded["types"]
            self.__all_types_methods = reduce(
                lambda a, b: a + self.__types[b], self.__types.keys(), []
            )

    def get_complete_position(self, context):
        m = re.search(r"\w*$", context["input"])
        return m.start() if m else -1

    def gather_candidates(self, context):
        (candidates, input_str) = self._search_candidates(context)
        return (
            candidates
            if input_str == ""
            else [x for x in candidates if x["word"].startswith(input_str)]
        )

    def _search_candidates(self, context):
        method_match = re.search(r"[\[\]\w\(\)\{\}'\".]+\.\w*$", context["input"])
        if method_match:
            return self._method_candidates(context, method_match.group(0))
        global_match = re.search(r"[^.]\b([a-zA-Z]*)$", context["input"])
        if global_match:
            return self._top_candidates(context, global_match.group(1))
        allow_match = re.search(r"allow\s[a-z\s,]*$", context["input"])
        if allow_match:
            return self._access_control_candidates(context, allow_match.group(0))
        return ([], "")

    def _top_candidates(self, context, matched):
        return (self.__globals, matched)

    def _method_candidates(self, context, matched):
        (var, input_str) = matched.rsplit(".", 1)
        properties = self.__methods.get(var, None)
        if properties:
            return (properties, input_str)
        if var.endswith("]"):
            methods = self.__types.get("list", [])
            return (methods, input_str)
        if var.endswith(")"):
            return (self._func_return_value_methods(context, var), input_str)
        if "." in var:
            return (self._parent_methods(context, var), input_str)
        return ([], "")

    def _func_return_value_methods(self, context, var):
        if len(var) < 2:
            return []
        func_name = ""
        parens = 1
        for i in range(len(var) - 2, 0, -1):
            char = var[i : i + 1]
            if char == ")":
                parens += 1
            elif char == "(":
                if parens > 0:
                    parens -= 1
            elif parens == 0:
                if re.match(r"\w", char):
                    func_name = char + func_name
                else:
                    break
        if len(func_name) == 0:
            return []
        funcs = [x for x in self.__all_types_methods if x["abbr"] == func_name]
        if len(funcs) == 0:
            return []
        return_type = funcs[0].get("_type", None)
        if return_type and return_type in self.__types:
            return self.__types[return_type]
        return []

    def _parent_methods(self, context, var):
        (parent, name) = var.rsplit(".", 1)
        parent_properties = self.__methods.get(parent, None)
        if not parent_properties:
            return []
        props = [x for x in parent_properties if x["word"] == name]
        if props:
            prop_type = props[0].get("_type", None)
            if prop_type and prop_type in self.__types:
                return self.__types[prop_type]
        return []

    def _access_control_candidates(self, context, matched):
        if matched == "":
            return self.__access_controls
        words = re.sub(r"\s+", "", matched).split(",")
        last_word = words[-1]
        word_set = set(words)

        def gather(a, b):
            word = b["word"]
            include_set = set(b.get("_include", []))
            if word in word_set:
                a.add(word)
                a |= include_set
            elif len(include_set) > 0 and include_set <= word_set:
                a.add(word)
            return a

        selected = reduce(gather, self.__access_controls, set())
        if last_word == "":
            return [x for x in self.__access_controls if x["word"] not in selected]
        return [
            x
            for x in self.__access_controls
            if x["word"] == last_word
            or (x["word"].startswith(last_word) and x["word"] not in selected)
        ]
