import logging
from contextlib import contextmanager
from functools import lru_cache
from typing import Iterator, Optional

import sqlalchemy as sa
from sqlalchemy.orm import Session

from app.settings.database import get_database_settings


@lru_cache()
def get_engine() -> sa.engine.Engine:
    db_settings = get_database_settings()
    uri = db_settings.sqlalchemy_uri
    log_sqlalchemy_sql_statements = db_settings.log_sqlalchemy_sql_statements
    return get_new_engine(uri, log_sqlalchemy_sql_statements)


@lru_cache()
def get_sessionmaker() -> sa.orm.sessionmaker:
    return get_sessionmaker_for_engine(get_engine())


def get_new_engine(uri: str, log_sqlalchemy_sql_statements: bool = False,) -> sa.engine.Engine:
    if log_sqlalchemy_sql_statements:
        logging.getLogger("sqlalchemy.engine").setLevel(logging.INFO)
    else:
        logging.getLogger("sqlalchemy.engine").setLevel(logging.ERROR)
    return sa.create_engine(uri, pool_pre_ping=True)


def get_sessionmaker_for_engine(engine: sa.engine.Engine) -> sa.orm.sessionmaker:
    return sa.orm.sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_session() -> sa.orm.Session:
    return get_sessionmaker()()


@contextmanager
def context_session(engine: Optional[sa.engine.Engine] = None) -> Iterator[Session]:
    yield from _get_db(engine)


def get_db() -> Iterator[Session]:
    """
    Intended for use as a FastAPI dependency
    """
    yield from _get_db()


def _get_db(engine: Optional[sa.engine.Engine] = None) -> Iterator[Session]:
    if engine is None:
        session = get_session()
    else:
        session = get_sessionmaker_for_engine(engine)()
    try:
        yield session
        session.commit()
    except Exception as exc:
        session.rollback()
        raise exc
    finally:
        session.close()
