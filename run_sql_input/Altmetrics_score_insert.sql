-- CREATE OR REPLACE SEQUENCE alt_score_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking for existing article ids and score values
insert into "DEV2_EDW"."ALTMETRICS"."ALT_FACT_ARTICLE_ALTMETRIC_SCORES" (ARTICLE_ALTMETRIC_SCORE_ID, ARTICLE_ID, DAYS_ALTMETRIC_SCORE,
	TOTAL_ALTMETRIC_SCORE, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, article_id, today_score, total_score, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'),
to_char(current_timestamp, 'YYYYMMDD') from
(select content:altmetric_score:score::double as total_score, content:altmetric_id as alt_id,
content:altmetric_score:score_history['1d']::double as today_score  from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH")
inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES" on ALTMETRIC_ID=alt_id,
table(getnextval(alt_score_seq)) seq
where not exists (select ARTICLE_ID from "DEV2_EDW"."ALTMETRICS"."ALT_FACT_ARTICLE_ALTMETRIC_SCORES"
where article_id=ARTICLE_ID and today_score=DAYS_ALTMETRIC_SCORE and total_score=TOTAL_ALTMETRIC_SCORE) and
(article_id is not null and today_score is not null and total_score is not null);