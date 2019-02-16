import pynvim
from os.path import isfile
from os import unlink
import sys

sys.path.append("./rplugin/python3/deoplete/sources")

from deoplete_firestore import Source


def test_hoge(vim: pynvim.Nvim) -> None:
    vim.command("normal itesting\npython\napi")
    vim.command("w! /tmp/test.txt")
    assert isfile("/tmp/test.txt")
    unlink("/tmp/test.txt")
