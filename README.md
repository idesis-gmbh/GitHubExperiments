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
git clone https://github.com/idesis-gmbh/githubexperiments.git
cd githubexperiments
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
| 1 hour | ~50 MB | ~150 MB |
| 1 day | ~1.2 GB | ~3.6 GB |
| 1 month | ~30 GB | ~90 GB |

## Running the Pipeline

On first run, process the first file and generate dbt models using the canonical sample:
```bash
uv run main.py --canonical-schema
```

Then process all remaining files incrementally:
```bash
uv run main.py
```

Each file is processed through the full dbt pipeline — staging, snapshots, dimensions,
facts, and marts — and acknowledged in the control schema on success. Re-running
skips already processed files.

The generated SQL models and canonical sample are checked in — `--canonical-schema` 
only needs to be rerun after a database reset or if the GitHub Archive schema changes.

**Advanced usage:** If the canonical sample does not yet exist, it can be generated 
from a real file using `--infer-schema` (infers schema directly) followed by  
`--canonical-sample` (generates a canonical sample). 

## Exploring the Data

See `analytics/README.md` for the data model, schema discovery details, and example 
analyses.

## Project Structure
```
githubexperiments/
├── main.py          # regenerate dbt models from schema discovery
├── etl.py           # incremental pipeline: process new archive files into the warehouse
├── sd.py            # schema discovery and SQL code generation
├── pyproject.toml   # project metadata and dependencies
├── uv.lock          # locked dependencies
├── .gitignore
├── README.md
├── analytics/       # dbt project
│   ├── dbt_project.yml
│   ├── profiles.yml # dbt connection configuration
│   ├── models/
│   │   ├── staging/     # raw JSON ingestion via read_json_auto
│   │   ├── dimensions/  # current state of each entity
│   │   ├── facts/       # event fact table
│   │   └── marts/       # aggregated models
│   ├── snapshots/   # slowly changing dimension definitions
│   ├── analyses/    # example queries
│   └── dev.duckdb   # DuckDB database (generated, gitignored)
└── data/
    └── gharchive/   # canonical sample and downloaded .json.gz files
        └── canonical_sample.json  # canonical sample for schema discovery
```

## Further Reading

- [dbt snapshots documentation](https://docs.getdbt.com/docs/build/snapshots)
- [dbt guide to dimensional modeling](https://www.getdbt.com/blog/guide-to-dimensional-modeling)
- [GitHub Archive](https://www.gharchive.org/)

## License

This project is licensed under the [MIT License](LICENSE)