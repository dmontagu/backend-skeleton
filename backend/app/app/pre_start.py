import logging

from tenacity import after_log, before_log, retry, stop_after_attempt, wait_fixed

from app.fastapi_util.util.session import get_engine

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

max_tries = 60 * 5  # 5 minutes
wait_seconds = 3
retry_decorator = retry(
    stop=stop_after_attempt(max_tries),
    wait=wait_fixed(wait_seconds),
    before=before_log(logger, logging.INFO),
    after=after_log(logger, logging.WARN),
)


@retry_decorator
def check_db() -> None:
    get_engine().execute("SELECT 1")
    logger.info("Database is ready")


def pre_start() -> None:
    logger.info("Confirming database is up...")
    check_db()


if __name__ == "__main__":
    pre_start()
