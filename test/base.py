import pynvim


class Base:
    def __init__(self, vim: pynvim.Nvim) -> None:
        self.vim = vim
