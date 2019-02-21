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
        ("allow", {}),
        ("allow ", {"read", "write", "get", "list", "create", "update"}),
        ("allow r", {"read", "write", "get", "list", "create", "update"}),
        ("allow read", set([])),
        ("allow read,", {"write", "create", "update"}),
        ("allow read,c", {"write", "create", "update"}),
        ("allow read,create", set([])),
        ("allow read,create,", {"update"}),
        ("allow read,create,update", set([])),
    ],
)
def test_candidates(source: Source, input_str: str, expected: Set[str]) -> None:
    candidates = source.gather_candidates({"input": input_str})
    assert [x["word"] for x in candidates], expected
