import json
import os
import pynvim
import pytest


@pytest.fixture
def vim() -> pynvim.Nvim:
    child_argv = '["nvim", "-u", "NONE", "--embed"]'
    return pynvim.attach("child", argv=json.loads(child_argv))
