from typing import List

from fastapi import APIRouter
from fastapi.params import Depends


def get_app_router() -> APIRouter:
    api_dependencies: List[Depends] = []  # Can add an auth-checking dependency here if you want to lock down your API
    api_router = get_api_router()
    app_router = APIRouter()
    app_router.include_router(api_router, dependencies=api_dependencies)
    return app_router


def get_api_router() -> APIRouter:
    api_router = APIRouter()

    # Obtain routers here:
    # sub_router_1 = get_sub_router_1()

    # Include routers here:
    # api_router.include_router(sub_router_1, prefix="/sub-router-1", tags=["Sub1"])

    return api_router
