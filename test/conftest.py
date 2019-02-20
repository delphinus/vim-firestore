import json
from os.path import dirname, join
from sys import path
import pynvim
import pytest


BASE_DIR = dirname(dirname(__file__))
path.insert(0, join(BASE_DIR, "rplugin/python3"))
path.insert(0, join(BASE_DIR, "rplugin/python3/deoplete/source"))
path.insert(0, join("deoplete.nvim", BASE_DIR, "rplugin/python3/deoplete"))


@pytest.fixture
def vim() -> pynvim.Nvim:
    child_argv = '["nvim", "-u", "NONE", "--embed"]'
    return pynvim.attach("child", argv=json.loads(child_argv))
