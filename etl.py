import glob
import os
import subprocess
import sys
import duckdb


def create_control(connection):
    connection.execute("""
CREATE SCHEMA IF NOT EXISTS control;
CREATE TABLE IF NOT EXISTS control.processed_files (
    filename VARCHAR PRIMARY KEY,
    processed_at TIMESTAMP DEFAULT current_timestamp
)
""")


def filter_incoming_files(connection, incoming_files):
    processed_files = {
        row[0]
        for row in connection.execute(
            "SELECT filename FROM control.processed_files"
        ).fetchall()
    }
    new_files = [
        file for file in incoming_files if os.path.basename(file) not in processed_files
    ]
    return new_files


def acknowledge_new_file(connection, file):
    connection.execute(
        "INSERT INTO control.processed_files (filename) VALUES (?)",
        [os.path.basename(file)],
    )


def run(init=False):
    incoming_files = sorted(glob.glob("data/gharchive/*.json.gz"))
    with duckdb.connect("dev.duckdb") as connection:
        create_control(connection)
        new_files = filter_incoming_files(connection, incoming_files)
    for file in new_files:
        result = subprocess.run(
            [
                "dbt",
                "run",
                "--project-dir",
                "analytics",
                "--select",
                "staging",
                "--vars",
                f'{{"file": "{os.path.basename(file)}"}}',
            ]
        )
        if result.returncode != 0:
            print(f"dbt run --select staging failed")
            break

        if init:
            break

        result = subprocess.run(
            [
                "dbt",
                "snapshot",
                "--project-dir",
                "analytics",
            ]
        )
        if result.returncode != 0:
            print(f"dbt snapshot failed")
            break

        result = subprocess.run(
            ["dbt", "run", "--project-dir", "analytics", "--exclude", "staging"]
        )
        if result.returncode != 0:
            print(f"dbt run --exclude staging failed")
            break

        result = subprocess.run(
            [
                "dbt",
                "test",
                "--project-dir",
                "analytics",
            ]
        )
        if result.returncode != 0:
            print(f"dbt test failed")
            break

        with duckdb.connect("dev.duckdb") as connection:
            acknowledge_new_file(connection, file)


if __name__ == "__main__":
    init = len(sys.argv) > 1
    run(init)
