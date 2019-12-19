from contextlib import contextmanager
from typing import Iterator

from sqlalchemy_utils import create_database, database_exists, drop_database

from app.fastapi_util.setup.initialize import get_configured_metadata, initialize_database
from app.fastapi_util.util.session import get_engine
from app.main import get_app
from app.settings.database import get_database_settings


@contextmanager
def generate_test_database() -> Iterator[None]:
    database_uri = get_database_settings().sqlalchemy_uri
    assert database_uri.endswith("_test")  # safeguard against dropping anything in prod

    if database_exists(database_uri):
        drop_test_database(database_uri)

    try:
        create_test_database(database_uri)
        yield
    finally:
        drop_test_database(database_uri)


def create_test_database(database_uri: str) -> None:
    create_database(database_uri)

    app = get_app()
    engine = get_engine()
    metadata = get_configured_metadata(app)
    metadata.create_all(bind=engine)
    initialize_database(engine)

    create_test_data()


def drop_test_database(database_uri: str) -> None:
    assert database_uri.endswith("_test")
    drop_database(database_uri)


def create_test_data() -> None:
    pass
