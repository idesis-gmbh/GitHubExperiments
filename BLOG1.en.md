# From Raw JSON to Data Warehouse: Analyzing GitHub Data Locally

Anyone who wants to understand what open-source development looks like at scale needs data. Lots of data. The [GitHub Archive](https://www.gharchive.org/) makes every public GitHub event — commits, pull requests, issues, releases — freely available as compressed JSON streams. A single day easily adds up to over a gigabyte of compressed raw data.

The real question is: how do you turn that into something you can actually analyze?

With **GitHubExperiments**, we built a complete, locally runnable data warehouse that closes exactly this gap — from raw JSON archives all the way to a clean star schema with Slowly Changing Dimensions. No cloud dependencies, no external services, everything on your own machine.

---

## The Challenge: 700 Attributes, Nested and Variable

GitHub Archive events are not simple, flat JSON. The structure varies considerably depending on the event type, fields appear or disappear, and nested objects run deep through the data model. All told, this adds up to around **700 attributes** — simply unmanageable as a single wide table.

Our solution: automatic **schema discovery**. A Python script traverses the full type tree that DuckDB infers from the raw JSON and generates the SQL models for the downstream pipeline directly from it. Structs with an `id` field are recognized as entity references and promoted to dimensions; structs without an `id` are flattened into the parent table. The result is a consistent star schema that mirrors the natural structure of the data — with no manual modeling work.

A practical problem arises here: columns that contain only NULL values in the first file read are inferred by DuckDB as a generic `JSON` type. When real values appear in later files, staging fails. The solution is the **canonical sample** — a synthetically generated JSON file that contains at least one non-null value for every column. This keeps type inference stable from the start, regardless of which archives are loaded afterward.

---

## The Stack: dbt-duckdb, Local and Fast

The centerpiece is [dbt-duckdb](https://github.com/duckdb/dbt-duckdb): dbt as the transformation framework, DuckDB as the in-process analytics database. What would require elaborate infrastructure in the cloud runs here on a single laptop — and surprisingly quickly.

The pipeline is divided into clear layers:

- **Staging** reads each `.json.gz` file together with the canonical sample via `read_json_auto` — the sample ensures correct type inference but is filtered out of the results with a `where` clause. `union_by_name` harmonizes the variable schemas of the different event types.
- **Dimensions** represent the current state of each entity — users, repositories, organizations, issues, and more. SCD1 by default (simple and idempotent), optionally SCD2 with a full history of changes.
- **Facts** holds one row per GitHub event with scalar attributes and foreign key references into the dimension tables.
- **Marts** aggregate the fact data for typical analyses: activity by day or time of day, broken down by organization, repository, event type, and author.

Incremental processing ensures that already-processed files are not read again — new archive files are simply added.

---

## Slowly Changing Dimensions — Done Pragmatically

Dimension data changes: repositories get renamed, user profiles updated, organizations restructured. SCD strategies determine how such changes are handled.

In GitHubExperiments, **SCD1 is the default**: the dimension always reflects the most recently observed state — simple, idempotent, no surprises on re-import. Anyone who needs the full history of changes can switch individual dimensions to **SCD2**: dbt snapshots then create a new row for each state change, with `dbt_valid_from` and `dbt_valid_to` marking the validity window.

One important detail: dimensions represent the *observed* state — that is, what can be derived from the events. Silent changes between two events are not captured. This is not a bug, but a deliberate decision: the system models what the data shows.

---

## Up and Running in Minutes

The project is designed for fast reproducibility. After cloning the repository, `uv sync` is all it takes to install all dependencies. Then download a handful of archive files and kick off the first run with `--canonical-schema` — this generates the dbt models based on a canonical sample and fixes the schema for all subsequent runs.

```bash
git clone https://github.com/idesis-gmbh/githubexperiments.git
cd githubexperiments
uv sync
wget -P data/gharchive/ https://data.gharchive.org/2026-03-01-{0..23}.json.gz
uv run main.py --canonical-schema
uv run main.py
```

The canonical sample and the generated SQL models are checked into the repository — `--canonical-schema` only needs to be re-run after a database reset or when the GitHub Archive schema changes. If you want to generate the sample from real data, you can take the two-step route via `--infer-schema` followed by `--canonical-sample`.

One hour of GitHub data: ~50 MB compressed, ~100 MB in DuckDB. A full day: ~1 GB compressed, ~2 GB in DuckDB. Processing is surprisingly fast — a full pipeline run for one hour of archive data takes under a minute. A single hour is plenty to get started with analysis.

---

## What Can You Discover?

Six included example analyses show where things can go: event type distribution, most active repositories, most active bots and users, most active organizations, hourly activity patterns, and the split between organization and personal repos. All queries can be run directly against the DuckDB database — using the DuckDB CLI, a SQL client, or a notebook.

---

## Seven Days of GitHub — A Look at the Data

To show what the system delivers in practice, we processed data from March 1–7, 2026 — nearly **25.8 million events** from the public GitHub Archive.

**Push events dominate clearly.** Over 69% of all events are `PushEvent`, followed by `CreateEvent` (8.6%) and `PullRequestEvent` (7.5%). The ratio reflects what GitHub development actually looks like: a lot of direct code writing, considerably less formal review process.

**Personal repos account for 80% of activity.** Only 20% of events come from organization repositories — a sign that GitHub remains a platform strongly shaped by individuals, even if organizations dominate in public perception.

**Bots are hard to miss.** With over 3.4 million events, `github-actions[bot]` leads the bot rankings by a wide margin, followed by `dependabot[bot]` and `renovate[bot]`. Notable in the top 20: `Copilot`, `chatgpt-codex-connector[bot]`, and `gemini-code-assist[bot]` — AI-assisted development tools have established themselves as a permanent fixture in the GitHub ecosystem in a remarkably short time.

**The top repositories are surprising.** The most active repos of the week are often not well-known open-source projects, but repositories with high-frequency automated commits — data pipelines, backup scripts, generated manifests. This is no coincidence: generating many small commits in a short time quickly pushes a repo to the top. That's exactly why it's worth checking regularly: the shifts from week to week — which projects rise, which disappear — are their own signal for what the developer community is focused on right now.

---

## Conclusion

GitHubExperiments demonstrates how far you can get with modern open-source tooling for local data processing. dbt and DuckDB together take on the complexity of a classic data warehouse stack — without cloud, without infrastructure, without overhead.

The full source code is available on GitHub: [idesis-gmbh/githubexperiments](https://github.com/idesis-gmbh/githubexperiments)

---

*Further resources:*
- [GitHub Archive](https://www.gharchive.org/)
- [dbt guide to dimensional modeling](https://www.getdbt.com/blog/guide-to-dimensional-modeling)
- [dbt snapshots documentation](https://docs.getdbt.com/docs/build/snapshots)