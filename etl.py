import glob
import os
import subprocess
import sys
import duckdb


def create_control(connection):
    connection.execute("""
CREATE SCHEMA IF NOT EXISTS control
""")
    connection.execute("""
CREATE TABLE IF NOT EXISTS control.processed_files (
    filename VARCHAR PRIMARY KEY,
    processed_at TIMESTAMP DEFAULT current_timestamp
)
""")


def filter_incoming(connection, incoming):
    processed = {
        row[0]
        for row in connection.execute(
            "SELECT filename FROM control.processed_files"
        ).fetchall()
    }
    return [filename for filename in incoming if filename not in processed]


def acknowledge_file(connection, filename):
    connection.execute(
        "INSERT INTO control.processed_files (filename) VALUES (?)",
        [filename],
    )


def dbt_run_select_staging(filename):
    result = subprocess.run(
        [
            "dbt",
            "run",
            "--project-dir",
            "analytics",
            "--select",
            "staging",
            "--vars",
            f'{{"filename": "{filename}"}}',
        ]
    )
    if result.returncode != 0:
        print("dbt run --select staging failed")
    return result.returncode


def dbt_snapshot():
    result = subprocess.run(
        [
            "dbt",
            "snapshot",
            "--project-dir",
            "analytics",
        ]
    )
    if result.returncode != 0:
        print("dbt snapshot failed")
    return result.returncode


def dbt_run_exclude_staging():
    result = subprocess.run(
        [
            "dbt",
            "run",
            "--project-dir",
            "analytics",
            "--exclude",
            "staging",
        ]
    )
    if result.returncode != 0:
        print("dbt run --exclude staging failed")
    return result.returncode


def dbt_test():
    result = subprocess.run(
        [
            "dbt",
            "test",
            "--project-dir",
            "analytics",
        ]
    )
    if result.returncode != 0:
        print("dbt test failed")
    return result.returncode


def run_file(filename, prepare_schema_discovery=False):
    if dbt_run_select_staging(filename) != 0:
        return True
    if prepare_schema_discovery:
        return False
    if dbt_snapshot() != 0:
        return True
    if dbt_run_exclude_staging() != 0:
        return True
    if dbt_test() != 0:
        return True
    return False


def run_files(prepare_schema_discovery=False):
    incoming = sorted(
        os.path.basename(filename) for filename in glob.glob("data/gharchive/*.json.gz")
    )
    with duckdb.connect("dev.duckdb") as connection:
        create_control(connection)
        filenames = filter_incoming(connection, incoming)
    for filename in filenames:
        if run_file(filename, prepare_schema_discovery=prepare_schema_discovery):
            return True
        if prepare_schema_discovery:
            break
        with duckdb.connect("dev.duckdb") as connection:
            acknowledge_file(connection, filename)
    return False


if __name__ == "__main__":
    run_files()
