import asyncio
import logging
from typing import Optional

import sqlalchemy as sa

from app.fastapi_util.setup.initialize import initialize_database
from app.fastapi_util.util.session import get_engine

logger = logging.getLogger(__name__)


async def initialize_app_database_async(engine: Optional[sa.engine.Engine] = None) -> None:
    engine = engine or get_engine()
    initialize_database(engine)


def initialize_app_database(engine: Optional[sa.engine.Engine] = None) -> None:
    event_loop = asyncio.get_event_loop()
    event_loop.run_until_complete(initialize_app_database_async(engine))


if __name__ == "__main__":
    initialize_app_database()
