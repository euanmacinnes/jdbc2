"""
jdbc2 package initializer.

- Re-exports primary DB-API symbols from jdbc2.core for convenience.
- Imports the SQLAlchemy dialect module to ensure the dialect is registered
  with SQLAlchemy's plugin registry when the package is imported.
"""
from __future__ import annotations

# Re-export common DB-API items
from .core import (
    connect,
    Connection,
    Cursor,
    Error,
    apilevel,
    threadsafety,
    paramstyle,
)

# Import the dialect module for its side-effect: it registers the "jdbc2" dialect
# with SQLAlchemy's dialect registry. Without this, users may see
# sqlalchemy.exc.NoSuchModuleError: Can't load plugin: sqlalchemy.dialects:jdbc2
# if the dialect module hasn't been imported via entry points.
from . import sqlalchemy_dialect as _jdbc2_sa_dialect  # noqa: F401