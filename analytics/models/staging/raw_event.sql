select *
from read_json_auto(
    ['data/gharchive/canonical_sample.json',
     'data/gharchive/{{ var("filename") }}'],
    union_by_name=True,
    timestampformat='auto',
    dateformat='auto'    
)
where id <> 'id of the canonical sample'
