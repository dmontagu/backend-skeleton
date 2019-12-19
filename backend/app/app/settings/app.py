from functools import lru_cache

from app.fastapi_util.settings.base_api_settings import BaseAPISettings


class AppSettings(BaseAPISettings):
    include_admin_routes: bool = False
    testing: bool = False

    class Config:
        env_prefix = "app_"


@lru_cache()
def get_app_settings() -> AppSettings:
    return AppSettings()
