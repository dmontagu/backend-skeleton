import logging

from fastapi import FastAPI

from app.api.api_v1.api import get_app_router
from app.fastapi_util.setup.setup_api import setup_openapi
from app.fastapi_util.util.timing import add_timing_middleware
from app.settings.api import get_api_settings

logger = logging.getLogger(__name__)


def get_app() -> FastAPI:
    api_settings = get_api_settings()
    server = FastAPI(**api_settings.fastapi_kwargs)
    add_routes(server, api_settings.main_router_prefix)
    setup_openapi(server)
    add_timing_middleware(server, record=logger.info)
    return server


def add_routes(server: FastAPI, router_prefix: str) -> None:
    app_router = get_app_router()
    server.include_router(app_router, prefix=router_prefix)


app = get_app()
app.openapi()  # Eagerly generate the OpenAPI spec to flush out errors
