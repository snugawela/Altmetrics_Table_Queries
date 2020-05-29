-- CREATE OR REPLACE SEQUENCE alt_score_field_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking for existing article id, period id and score combination for Fetch API
insert into "DEV2_EDW"."ALTMETRICS"."ALT_FACT_ARTICLE_ALTMETRIC_SCORE_FIELDS" (ARTICLE_ALTMETRIC_SCORE_FIELD_ID,
ARTICLE_ID, HISTORY_PERIOD_ID, ALTMETRIC_SCORE, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, article_id, history_period_id, score, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select history_period_id, score, article_id from (select history_period_id, score, alt_id from (select v.key::varchar as time,
v.value::double as score, alt_id from (select content:altmetric_score:score_history as history,
content:altmetric_id::bigint as alt_id from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH"), table(flatten(history)) v) inner join
"DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLE_HISTORY_SCORE_PERIODS" on history_period_value=time) inner join
"DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES" on alt_id=ALTMETRIC_ID),
table(getnextval(alt_score_field_seq)) seq
where not exists (select * from "DEV2_EDW"."ALTMETRICS"."ALT_FACT_ARTICLE_ALTMETRIC_SCORE_FIELDS" where article_id=ARTICLE_ID and
history_period_id=HISTORY_PERIOD_ID and score=ALTMETRIC_SCORE);