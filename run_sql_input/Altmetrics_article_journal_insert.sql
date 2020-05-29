-- CREATE OR REPLACE SEQUENCE alt_art_journ_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking by article and journal id combination
insert into "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLE_JOURNALS"(ARTICLE_JOURNAL_ID, ARTICLE_ID, JOURNAL_ID, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, ARTICLE_ID, JOURNAL_ID, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select a.ARTICLE_ID as ARTICLE_ID, b.JOURNAL_ID as JOURNAL_ID from ("DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES" as a inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_JOURNALS" as b on a.ALTMETRIC_ID = b.ALTMETRIC_JOURNAL_ID)
where not exists (select * from "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLE_JOURNALS" where (a.ARTICLE_ID = ARTICLE_ID and b.JOURNAL_ID = JOURNAL_ID))),
table(getnextval(alt_art_journ_seq)) seq;