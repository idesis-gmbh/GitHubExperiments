with raw_event as (
    select *
    from read_json_auto(
        'data/gharchive/{{ var("file") }}',
        union_by_name=True
    )
)
select *
from raw_event