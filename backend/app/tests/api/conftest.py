import os
from contextlib import contextmanager
from typing import Any, Iterator

import pytest
from fastapi import FastAPI
from requests import Session
from starlette.testclient import TestClient

from app.fastapi_util.setup.initialize import get_configured_metadata
from app.fastapi_util.util.session import get_engine
from app.initialize_database import initialize_app_database
from app.main import get_app
from app.settings.app import get_app_settings
from tests.api.db_setup.fixture import generate_test_database
from tests.conftest import clear_caches


@pytest.fixture(scope="session", autouse=True)
def test_setup_environment(monkeypatch_session: Any) -> None:
    database_db = os.getenv("DB_DB")
    monkeypatch_session.setenv("DB_DB", f"{database_db}_test")
    clear_caches()


@pytest.fixture(scope="session", autouse=True)
def generate_test_data(test_setup_environment: None) -> Iterator[None]:
    """ Nest the creation of any required resources here (e.g., if there is an elasticsearch server, add it) """
    with generate_test_database():
        yield


@pytest.fixture(scope="module")
def test_environment(test_setup_environment: None, monkeypatch_module: Any) -> None:
    monkeypatch_module.setenv("API_DEBUG", "1")
    monkeypatch_module.setenv("APP_INCLUDE_ADMIN_ROUTES", "1")
    monkeypatch_module.setenv("DB_LOG_SQLALCHEMY_SQL_STATEMENTS", "0")
    clear_caches()


@pytest.fixture(scope="module")
def test_app(test_environment: None) -> Iterator[FastAPI]:
    with get_test_app() as app:  # type: FastAPI
        yield app


@pytest.fixture(scope="module")
def testing_client(test_app: FastAPI) -> Iterator[Session]:
    """
    Triggers lifecycle events, which could be used for auto-rollback, etc.
    """
    with TestClient(test_app) as client:
        yield client


@contextmanager
def get_test_app() -> Iterator[FastAPI]:
    assert get_app_settings().testing is True  # requires APP_TESTING env var to be true

    app = get_app()
    engine = get_engine()
    metadata = get_configured_metadata(app)
    metadata.create_all(bind=engine)
    initialize_app_database(engine)

    yield app
