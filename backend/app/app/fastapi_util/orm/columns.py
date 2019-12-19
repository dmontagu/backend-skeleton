from datetime import datetime
from typing import Any, Dict, Optional, Type, TypeVar, Union, overload
from uuid import UUID

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
from typing_extensions import Literal

from app.fastapi_util.orm.guid_type import GUID

IdentifierT = TypeVar("IdentifierT", bound=UUID)


@overload
def pk_column(_id_type: Type[IdentifierT]) -> "sa.Column[IdentifierT]":
    ...


@overload
def pk_column(_id_type: None = None) -> "sa.Column[UUID]":
    ...


def pk_column(_id_type: Optional[Type[IdentifierT]] = None) -> "Union[sa.Column[IdentifierT], sa.Column[UUID]]":
    """
    The server-default value should be updated in the metadata later
    """
    return sa.Column(GUID, primary_key=True, index=True, server_default=sa.text("gen_random_uuid()"))


@overload
def fk_column(
    column: Union[str, "sa.Column[IdentifierT]"],
    nullable: Literal[True],
    index: bool = False,
    primary_key: bool = False,
    unique: bool = False,
) -> "sa.Column[Optional[IdentifierT]]":
    ...


@overload
def fk_column(
    column: Union[str, "sa.Column[IdentifierT]"],
    nullable: Literal[False] = False,
    index: bool = False,
    primary_key: bool = False,
    unique: bool = False,
) -> "sa.Column[IdentifierT]":
    ...


def fk_column(
    column: Union[str, "sa.Column[IdentifierT]"],
    nullable: bool = False,
    index: bool = False,
    primary_key: bool = False,
    unique: bool = False,
) -> "Union[sa.Column[IdentifierT], sa.Column[Optional[IdentifierT]]]":
    return sa.Column(  # type: ignore
        GUID,
        sa.ForeignKey(column, ondelete="CASCADE"),
        index=index,
        nullable=nullable,
        primary_key=primary_key,
        unique=unique,
    )


def json_column(*, nullable: bool) -> "sa.Column[Dict[str, Any]]":
    column_type = JSONB()
    return sa.Column(column_type, nullable=nullable)  # type: ignore


def created_at_column() -> "sa.Column[datetime]":
    return sa.Column(sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False)


def updated_at_column() -> "sa.Column[datetime]":
    return sa.Column(sa.DateTime(timezone=True), server_default=sa.func.now(), onupdate=sa.func.now(), nullable=False)
