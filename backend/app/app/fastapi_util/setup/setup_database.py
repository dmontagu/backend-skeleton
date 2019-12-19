import sqlalchemy as sa

from app.fastapi_util.orm.guid_type import GUID


def setup_database(engine: sa.engine.Engine) -> None:
    setup_guids(engine)


def setup_guids(engine: sa.engine.Engine) -> None:
    """
    Set up UUID generation using the uuid-ossp extension for postgres
    """
    # noinspection SqlDialectInspection,SqlNoDataSourceInspection
    uuid_generation_setup_query = 'create EXTENSION if not EXISTS "pgcrypto"'
    engine.execute(uuid_generation_setup_query)


def setup_database_metadata(metadata: sa.MetaData, engine: sa.engine.Engine) -> None:
    setup_guid_server_defaults(metadata, engine)


def setup_guid_server_defaults(metadata: sa.MetaData, engine: sa.engine.Engine) -> None:
    for table in metadata.tables.values():
        if len(table.primary_key.columns) != 1:
            continue
        for column in table.primary_key.columns:
            if type(column.type) is GUID:
                column.server_default = sa.DefaultClause(sa.text("gen_random_uuid()"))
