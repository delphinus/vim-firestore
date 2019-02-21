import pynvim
import pytest
from sources.firestore import Source
from typing import List, Set


@pytest.fixture
def source(vim: pynvim.Nvim) -> Source:
    source = Source(vim)
    source.on_init({})
    return source


@pytest.mark.parametrize(
    "input_str,expected",
    [
        # access controls
        ("allow", {"exists(", "get(", "getAfter(", "math", "path(", "request"}),
        ("allow ", {"read", "write", "get", "list", "create", "update", "delete"}),
        ("allow r", {"read", "write", "get", "list", "create", "update", "delete"}),
        ("allow read", {"write", "create", "update", "delete"}),
        ("allow read,", {"write", "create", "update", "delete"}),
        ("allow read,c", {"write", "create", "update", "delete"}),
        ("allow read,create", {"write", "update", "delete"}),
        ("allow read,create,", {"write", "update", "delete"}),
        ("allow read,create,update", {"write", "delete"}),
        ("allow read,create,update,", {"write", "delete"}),
        ("allow read,create,update,delete", set([])),
        # globals
        ("if ", set([])),
        ("if a", {"exists(", "get(", "getAfter(", "math", "path(", "request"}),
        ("if get(", set([])),
    ],
)
def test_candidates(source: Source, input_str: str, expected: Set[str]) -> None:
    candidates = source.gather_candidates({"input": input_str})
    assert set([x["word"] for x in candidates]) == expected
