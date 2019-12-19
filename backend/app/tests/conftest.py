from typing import Any, Iterator

import pytest

from app.fastapi_util.util.session import get_engine, get_sessionmaker
from app.settings.api import get_api_settings
from app.settings.app import get_app_settings
from app.settings.database import get_database_settings


def clear_caches() -> None:
    get_api_settings.cache_clear()
    get_app_settings.cache_clear()
    get_database_settings.cache_clear()
    get_engine.cache_clear()
    get_sessionmaker.cache_clear()


@pytest.fixture(scope="module")
def monkeypatch_module() -> Iterator[Any]:
    from _pytest.monkeypatch import MonkeyPatch

    m = MonkeyPatch()
    yield m
    m.undo()


@pytest.fixture(scope="session")
def monkeypatch_session() -> Iterator[Any]:
    from _pytest.monkeypatch import MonkeyPatch

    m = MonkeyPatch()
    yield m
    m.undo()
