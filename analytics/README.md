# Analytics

## Design Rationale

GitHub Archive events contain around 700 attributes in a deeply nested, variable JSON 
schema that differs by event type. Managing this as a single wide table is impractical — 
queries become unwieldy and the structure is opaque.

Classical normalization provides a natural decomposition strategy: related attributes 
group into entities (user, repo, actor, issue, etc.), which produces a star schema with 
a manageable number of attributes per table. This is not a deliberate application of 
Kimball's dimensional modeling methodology — it's the shape the data naturally suggests.

SCD1 is the default strategy for dimension generation: the current state of each entity 
is derived directly from the event stream using `distinct on (id)`. This is idempotent — 
re-importing the same data produces the same result. SCD2 is available for cases where 
full change history is required, but is not idempotent if the same data is imported twice.

Note that the resulting dimensions reflect entity state *as observed in events* — not a 
complete change history. A repo renamed between two events will show both names, but 
silent changes (never appearing in an event) are not captured.

## Staging

The staging layer reads a single GitHub Archive file alongside a canonical sample,
passed via a dbt variable by the incremental pipeline:
```sql
select *
from read_json_auto(
    ['data/gharchive/canonical_sample.json',
     'data/gharchive/{{ var("filename") }}'],
    union_by_name=True,
    timestampformat='auto',
    dateformat='auto'
)
where id <> 'id of the canonical sample'
```

Including the canonical sample in every read ensures correct type inference for columns
that may be null in the real file. The canonical sample row is excluded from results
via the `where` clause.

The canonical sample is included in every read to ensure correct type inference — see
[Schema Discovery](#schema-discovery) for details.

## Schema Discovery

DuckDB's `read_json_auto` exposes the full nested schema of the GitHub Archive events 
via its type system. `sd.py` traverses this recursively to build a Python representation 
of all ~700 attributes, then generates the dbt SQL files for dimensions and the fact table.

A practical problem arises during schema discovery: columns with all NULL values in the 
first processed file are inferred as JSON by DuckDB. When non-null values appear in 
later files, staging fails. The canonical sample approach solves this: `sd.py` generates 
a synthetic JSON file (`data/gharchive/canonical_sample.json`) that contains a 
non-null value for every column, ensuring correct type inference.

A few design decisions are baked into the generated SQL:

- Structs with an `id` field are treated as entity references and reduced to their `id`
- Structs without an `id` field are flattened into the parent model
- List-typed columns are excluded
- `performed_via_github_app` is excluded
- Entities where `id` is null are excluded (events where the entity was not present)

The generated files and canonical sample are checked in — schema discovery only needs 
to be rerun after a database reset or if the GitHub Archive schema changes:
```bash
uv run main.py --canonical-schema
```

## Snapshots

The generator supports two strategies for dimension generation:

**SCD1** (default) — the current state of each entity is derived directly from the 
event stream using `distinct on (id)`. Idempotent and simple, but change history 
is not preserved.

**SCD2** (opt-in) — a new row is added whenever any attribute changes, with 
`dbt_valid_from` and `dbt_valid_to` tracking the validity period. Preserves the 
full observed history but is not idempotent if the same data is imported twice.

Currently all dimensions use SCD1. The `dbt snapshot` step runs as part of the 
incremental pipeline but is a no-op until a dimension is explicitly configured 
for SCD2 in `sd.py`.

See the [dbt snapshots documentation](https://docs.getdbt.com/docs/build/snapshots) 
for details on the SCD2 implementation.

## Dimensions

Most dimensions are generated using SCD1 — the current state of each entity is derived 
directly from the event stream:
```sql
select distinct on (id) *
from (
    select distinct
        ...
    from {{ ref('raw_event') }}
    where ... is not null
)
order by all
```

For dimensions generated with SCD2, a thin view over the corresponding snapshot is 
generated instead:
```sql
select distinct *
from {{ ref('snapshot_name') }}
where dbt_valid_to is null
```

Two dimensions are written manually rather than generated:

- **`date.sql`** — derived from `created_at` in the fact table, providing year, quarter, 
  month, week, and day attributes for date-based analysis
- **`time.sql`** — derived from `created_at` at hour resolution, providing hour, AM/PM, 
  and time of day attributes for intra-day analysis

Both dimensions reflect the time range present in the loaded data rather than a fixed 
spine — loading more data extends the range automatically.

## Facts

The fact table `event.sql` is generated by `sd.py` and contains one row per GitHub 
Archive event, with scalar attributes and foreign key references to the dimension tables:

- Scalar attributes from `raw_event` (e.g. `type`, `created_at`, `public`)
- Entity references reduced to their `id` (e.g. `actor_id`, `repo_id`, `org_id`)
- Flattened payload attributes where the struct has no `id` field

## Marts

Two marts aggregate the fact table for analytical consumption:

- **`activity_by_date.sql`** — event counts grouped by date, org, repo, event type, 
  and actor; joined to the date dimension for calendar-based analysis
- **`activity_by_time.sql`** — event counts grouped by hour, org, repo, event type, 
  and actor; joined to the time dimension for intra-day analysis

## Analyses

The `analyses/` directory contains example queries that can be run directly 
against `dev.duckdb` using the DuckDB CLI or any SQL client:

- **`event_types.sql`** — event type distribution with percentages
- **`active_repos.sql`** — most active repositories by event count
- **`active_actors.sql`** — most active bots and users by event count
- **`active_orgs.sql`** — most active organisations by event count
- **`activity_by_hour.sql`** — event volume by hour of day
- **`org_vs_personal.sql`** — organisation vs personal repository activity split

## Known Quirks

- **`reactions_+1` and `reactions_-1`** — these column names contain characters that 
  are invalid in unquoted SQL identifiers. They are quoted in the generated SQL but 
  may cause issues in downstream tools.
- **List-typed columns are excluded** — attributes containing lists of structs 
  (e.g. assignees, labels on a PR) are not represented in the generated models.

## Further Reading

- [dbt snapshots documentation](https://docs.getdbt.com/docs/build/snapshots) — SCD2 
  implementation details
- [dbt guide to dimensional modeling](https://www.getdbt.com/blog/guide-to-dimensional-modeling) — 
  star schema rationale in a modern context