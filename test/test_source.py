import pynvim
from os.path import dirname, isfile, join
from os import unlink
import sys

from sources.firestore import Source


def test_hoge(vim: pynvim.Nvim) -> None:
    vim.command("normal itesting\npython\napi")
    vim.command("w! /tmp/test.txt")
    assert isfile("/tmp/test.txt")
    unlink("/tmp/test.txt")
