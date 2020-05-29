-- CREATE OR REPLACE SEQUENCE alt_reader_count_seq START = 1 INCREMENT = 1;

insert into "DEV2_EDW"."ALTMETRICS"."ALT_FACT_ARTICLE_READER_COUNTS"(ARTICLE_READER_COUNT_ID, ARTICLE_ID,
SOCIAL_CHANNEL_ID, READER_COUNT, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, article_id, social_channel_id, reader_count,
to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select social_channel_id, reader_count, article_id from (select social_channel_id, alt_id,
reader_count from (select v.key::varchar as channel, v.value::int as reader_count,
alt_id from (select content:counts:readers as readers,
content:altmetric_id as alt_id from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH" where content:counts:readers is not null),
table(flatten(readers)) v) inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_SOCIAL_CHANNELS" on channel=social_channel_name)
inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES" on alt_id=ALTMETRIC_ID),
table(getnextval(alt_reader_count_seq)) seq
where not exists (select * from "DEV2_EDW"."ALTMETRICS"."ALT_FACT_ARTICLE_READER_COUNTS"
where article_id=ARTICLE_ID and social_channel_id=SOCIAL_CHANNEL_ID);