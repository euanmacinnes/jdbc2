jdbc2 — Minimal Python DB‑API over JDBC (with SQLAlchemy support)

Overview
- jdbc2 is a lightweight, experimental DB‑API 2.0 driver that talks to databases via JDBC using JPype.
- Includes a minimal SQLAlchemy dialect so you can use SQLAlchemy by supplying a creator.
- Comes with runnable examples for SQLite and PostgreSQL.

Status
- This project is intended for demonstration/learning purposes. APIs may change.

Requirements
- Python 3.8+
- JPype1 (pip install jpype1)
- A JDBC driver JAR for your target database (e.g., Xerial SQLite JAR, PostgreSQL JAR)
- On Windows, use backslashes in paths (e.g., C:\path\to\driver.jar)

Quickstart (DB‑API)
- Connect using jdbc2.core.connect and pass the JDBC URL, driver class, and the JAR path(s).

Example (SQLite):
    from jdbc2.core import connect

    jdbc_url = r"jdbc:sqlite:C:\\tmp\\demo.db"
    driver = "org.sqlite.JDBC"
    jar = r"C:\\path\\to\\sqlite-jdbc-3.45.3.0.jar"

    with connect(jdbc_url=jdbc_url, driver=driver, jars=[jar]) as conn:
        cur = conn.cursor()
        cur.execute("select 1 as x")
        print(cur.fetchall())

Using with SQLAlchemy
- The package provides a simple SQLAlchemy dialect registered as "jdbc2".
- Create an engine using a creator that returns a jdbc2.core.Connection.

Example (SQLAlchemy + SQLite):
    from sqlalchemy import create_engine, text
    from jdbc2.core import connect

    jdbc_url = r"jdbc:sqlite:C:\\tmp\\sa_demo.db"
    driver = "org.sqlite.JDBC"
    jar = r"C:\\path\\to\\sqlite-jdbc-3.45.3.0.jar"

    engine = create_engine(
        "jdbc2://",  # placeholder; real connection is provided by creator
        creator=lambda: connect(jdbc_url=jdbc_url, driver=driver, jars=[jar]),
    )

    with engine.begin() as conn:
        res = conn.execute(text("select 1 as x"))
        print(list(res))

Examples
- All examples live in the examples\ folder and read settings from examples\config.ini.
- A template file examples\config.ini.sample is included—copy it to config.ini and edit paths/credentials.

Run DB‑API examples:
- SQLite:    python examples\sqlite_example.py
- PostgreSQL: python examples\postgres_example.py

Run SQLAlchemy examples:
- SQLite (Core):    python examples\sqlalchemy_sqlite_example.py
- SQLite (ORM):     python examples\sqlalchemy_sqlite_orm_example.py
- PostgreSQL:       python examples\sqlalchemy_postgres_example.py

Documentation
- See doc\index.md for detailed instructions, configuration, and troubleshooting.

Troubleshooting
- ImportError: Install JPype1 -> pip install jpype1
- Class not found / JVM startup issues: Ensure the JDBC driver JAR path is correct and accessible.
- PostgreSQL auth issues: Verify URL/user/password and server connectivity.

License
- Sample/demo code for educational purposes.