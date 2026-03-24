with raw_event as (
    select *
    from read_json_auto(
        'data/gharchive/{{ var("filename") }}',
        union_by_name=True
    )
)
select *
from raw_event