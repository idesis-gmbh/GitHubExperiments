# GitHubExperiments

A worked example of building a local data warehouse on the [GitHub Archive](https://www.gharchive.org/)
using [dbt-duckdb](https://github.com/duckdb/dbt-duckdb) — from raw JSON to a star schema
with slowly changing dimensions, running entirely locally.

## Getting Started

### Prerequisites

- Python 3.13 or higher
- [uv](https://docs.astral.sh/uv/) — Python package manager
- [Git](https://git-scm.com/)
- `wget` or `curl` for downloading dumps
- ~x GB free disk space per day of GitHub Archive data

### Installation

Clone the repository and install dependencies:
```bash
git clone https://github.com/idesis-gmbh/wikiexperiments.git
cd wikiexperiments
uv sync
```

`uv sync` reads `pyproject.toml` and installs all dependencies into a local virtual environment automatically.

### Data Download

Download GitHub Archive data into the `data/gharchive/` directory.

Using `wget`:
```bash
wget -P data/gharchive/ https://data.gharchive.org/2026-03-01-{0..23}.json.gz
```

Adjust the date and hour range to your needs, e.g. a full day or month:
```bash
wget -P data/gharchive/ https://data.gharchive.org/2026-03-{01..31}-{0..23}.json.gz
```

| Data | Compressed | DuckDB |
|------|------------|--------|
| 1 hour | ~50 MB | ~250 MB |
| 1 day | ~1.2 GB | ~6 GB |
| 1 month | ~30 GB | ~150 GB |

### Running the Pipeline

Build the warehouse:
```bash
dbt build --project-dir analytics
```

This runs the full pipeline — snapshots, dimensions, facts, and marts — and writes the 
result to `analytics/dev.duckdb`.

## Project structure

## Project Structure
```
githubexperiments/
├── main.py          # regenerate dbt models from schema discovery
├── sd.py            # schema discovery and SQL code generation
├── pyproject.toml   # project metadata and dependencies
├── uv.lock          # locked dependencies
├── .gitignore
├── README.md
├── analytics/       # dbt project
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── staging/     # raw JSON ingestion via read_json_auto
│   │   ├── dimensions/  # current state views (from snapshots)
│   │   ├── facts/       # event fact table
│   │   └── marts/       # aggregated models
│   ├── snapshots/   # slowly changing dimension definitions
│   ├── analyses/    # example queries
│   └── dev.duckdb   # DuckDB database (generated, gitignored)
└── data/            # gitignored — local data only
    └── gharchive/   # downloaded .json.gz files
```

## Schema Discovery

GitHub Archive events contain deeply nested, variable JSON structures that differ 
by event type. Rather than writing the dbt models by hand, `sd.py` introspects the 
schema automatically via DuckDB's type system and generates the staging, snapshot, 
and dimension SQL files.

You only need to rerun this if the GitHub Archive schema changes:
```bash
uv run python main.py
```

See `analytics/README.md` for details on the generated model structure.

## Exploring the Data

See `analytics/README.md` for the full data model and example analyses.

## Further Reading

- [dbt snapshots documentation](https://docs.getdbt.com/docs/build/snapshots)
- [dbt guide to dimensional modeling](https://www.getdbt.com/blog/guide-to-dimensional-modeling)
- [GitHub Archive](https://www.gharchive.org/)

## License

This project is licensed under the [MIT License](LICENSE)