import json
from pathlib import Path
from typing import Any, Dict, Optional

import pytest

from app.main import get_app
from tests.conftest import clear_caches

admin_schema_path = Path(__file__).parent / "json_schemas" / "admin.json"
non_admin_schema_path = Path(__file__).parent / "json_schemas" / "non_admin.json"


def load_schema(path: Path) -> Dict[str, Any]:
    with path.open("r") as f:
        contents = f.read()
    return json.loads(contents)


def save_schema(schema: Dict[str, Any], path: Path) -> None:
    contents = json.dumps(schema, sort_keys=True, indent=2)
    existing_contents: Optional[str]
    try:
        with path.open("r") as f:
            existing_contents = f.read()
    except FileNotFoundError:
        existing_contents = None
    if existing_contents != contents:
        with path.open("w") as f:
            f.write(contents)


@pytest.mark.parametrize("include_admin_routes,schema_path", [("1", admin_schema_path), ("0", non_admin_schema_path)])
def test_openapi_schema_generation(monkeypatch: Any, include_admin_routes: bool, schema_path: Path) -> None:
    clear_caches()
    monkeypatch.setenv("APP_INCLUDE_ADMIN_ROUTES", include_admin_routes)
    schema = get_app().openapi()

    save_schema(schema, schema_path)
    assert schema == load_schema(schema_path)
