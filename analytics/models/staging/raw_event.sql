with raw_event as (
    select *
    from read_json_auto('data/gharchive/*.json.gz', union_by_name=True)
)
select *
from raw_event