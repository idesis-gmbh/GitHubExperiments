import pprint
from string import Template
import duckdb

EXCLUDED_COLUMNS = {
    "performed_via_github_app"
}  # always a nested struct; excluded by policy


def deeply_nested_schema(data_type):
    if str(data_type).endswith("[]"):
        return [deeply_nested_schema(data_type.child)]
    elif str(data_type).startswith("STRUCT"):
        return {
            element_column_name: deeply_nested_schema(element_data_type)
            for element_column_name, element_data_type in data_type.children
        }
    else:
        return str(data_type)


def find_entity_candidates(root, schema):
    result = []
    if isinstance(schema, dict):
        for key, value in schema.items():
            name = root + "." + key
            if isinstance(value, dict):
                result.append((name, "id" in value))
            result.extend(find_entity_candidates(name, value))
    elif isinstance(schema, list):
        name = root + "[]"
        result.append((name, False))
        result.extend(find_entity_candidates(name, schema[0]))
    return sorted(result)


def get_base_columns(struct):
    assert isinstance(struct, dict)
    return [
        key
        for key in struct
        if key not in EXCLUDED_COLUMNS
        and not isinstance(struct[key], dict)
        and not isinstance(struct[key], list)
    ]


def get_nested_columns(struct):
    assert isinstance(struct, dict)
    return [
        f"{key}.id"
        for key in struct
        if key not in EXCLUDED_COLUMNS
        and isinstance(struct[key], dict)
        and "id" in struct[key]
    ]


def get_deeply_nested_columns(struct):
    assert isinstance(struct, dict)
    return (
        get_base_columns(struct)
        + get_nested_columns(struct)
        + [
            f"{key}.{struct_key}"
            for key in struct
            if key not in EXCLUDED_COLUMNS
            and isinstance(struct[key], dict)
            and "id" not in struct[key]
            for struct_key in get_deeply_nested_columns(struct[key])
        ]
    )


def introspect_schema(connection, dump_schema=False, dump_entity_candidates=False):
    cursor = connection.cursor()
    cursor.execute("""
        SELECT * 
        FROM raw_event
    """)
    schema = {}
    for key in cursor.description:
        column_name, data_type = key[0], key[1]
        schema[column_name] = deeply_nested_schema(data_type)
    if dump_schema:
        pprint.pprint(schema)
    if dump_entity_candidates:
        pprint.pprint(find_entity_candidates("raw_event", schema))
    return schema


def get_selected_columns(struct):
    return sorted(
        (".".join(f'"{token}"' for token in key.split(".")), key.replace(".", "_"))
        for key in get_deeply_nested_columns(struct)
    )


def generate_sqls(schema, roots):
    sqls = []
    for root in roots:
        parts = root.split(".")
        struct = schema
        for part in parts[1:]:
            struct = struct[part]
        sqls.append(
            Template("""
select distinct
$columns
from {{ ref('$root') }}
where $id is not null
""").substitute(
                columns=",\n".join(
                    f'    {".".join(parts[1:])}.{name} AS "{alias}"'
                    for name, alias in get_selected_columns(struct)
                ),
                root=parts[0],
                id=f'{".".join(parts[1:])}."id"',
            )
        )
    return sqls


def generate_scd1(name, sqls):
    dimension = Template("""
select distinct on (id) *
from ($sqls)
order by all
""").substitute(sqls="union all".join(sqls))
    with open(f"analytics/models/dimensions/{name}.sql", "w", encoding="utf-8") as file:
        print(dimension, file=file)


def generate_scd2(name, sqls):
    snapshot = Template("""
{% snapshot $snapshot_name %}

{{ config(
    unique_key='id',
    strategy='check',
    check_cols='all',
) }}
$sqls
{% endsnapshot %}
""").substitute(
        snapshot_name=f"{name}_snapshot",
        sqls="union".join(sqls),
    )
    with open(f"analytics/snapshots/{name}.sql", "w", encoding="utf-8") as file:
        print(snapshot, file=file)
    dimension = Template("""
select distinct *
from {{ ref('$snapshot_name') }}
where dbt_valid_to is null
""").substitute(
        snapshot_name=f"{name}_snapshot",
    )
    with open(f"analytics/models/dimensions/{name}.sql", "w", encoding="utf-8") as file:
        print(dimension, file=file)


def generate_dimension(schema, roots, name, scd_type=1):
    sqls = generate_sqls(schema, roots)
    if scd_type == 1:
        generate_scd1(name, sqls)
    elif scd_type == 2:
        generate_scd2(name, sqls)
    else:
        assert False


def generate_fact(struct):
    entity_columns = get_selected_columns(struct)
    columns = (f'{name} AS "{alias}"' for name, alias in entity_columns)
    fact = Template("""
select distinct
$columns
from {{ ref('raw_event') }}
""").substitute(columns=",\n".join(f"    {column}" for column in columns))
    with open("analytics/models/facts/event.sql", "w", encoding="utf-8") as file:
        print(fact, file=file)


def generate_model(schema):
    generate_dimension(schema, ["raw_event.actor"], "actor")
    generate_dimension(schema, ["raw_event.org"], "org")
    generate_dimension(
        schema,
        [
            "raw_event.payload.assignee",
            "raw_event.payload.comment.user",
            "raw_event.payload.discussion.user",
            "raw_event.payload.forkee.owner",
            "raw_event.payload.issue.assignee",
            "raw_event.payload.issue.milestone.creator",
            "raw_event.payload.issue.user",
            "raw_event.payload.member",
            "raw_event.payload.release.author",
            "raw_event.payload.review.user",
        ],
        "user",
    )
    generate_dimension(
        schema,
        [
            "raw_event.repo",
            "raw_event.payload.pull_request.head.repo",
            "raw_event.payload.pull_request.base.repo",
        ],
        "repo",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.discussion.category"],
        "category",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.issue.type"],
        "type",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.label"],
        "label",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.comment"],
        "comment",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.discussion"],
        "discussion",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.forkee"],
        "forkee",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.issue.milestone"],
        "milestone",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.issue"],
        "issue",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.pull_request"],
        "pull_request",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.release"],
        "release",
    )
    generate_dimension(
        schema,
        ["raw_event.payload.review"],
        "review",
    )
    generate_fact(schema)


if __name__ == "__main__":
    with duckdb.connect("dev.duckdb") as connection:
        schema = introspect_schema(connection)
        generate_model(schema)
