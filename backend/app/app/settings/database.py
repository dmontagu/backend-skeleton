from functools import lru_cache

from app.fastapi_util.settings.base_api_settings import BaseAPISettings


class DatabaseSettings(BaseAPISettings):
    scheme: str = "postgresql"
    user: str
    password: str
    host: str
    db: str

    log_sqlalchemy_sql_statements: bool = False

    @property
    def sqlalchemy_uri(self) -> str:
        return f"{self.scheme}://{self.user}:{self.password}@{self.host}/{self.db}"

    class Config:
        env_prefix = "db_"


@lru_cache()
def get_database_settings() -> DatabaseSettings:
    return DatabaseSettings()
