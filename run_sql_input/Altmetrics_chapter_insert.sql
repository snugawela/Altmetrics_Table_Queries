-- CREATE OR REPLACE SEQUENCE alt_chap_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking by Chapter Altmetric ID
insert into "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES_CHAPTERS"(ARTICLE_CHAPTER_ID,
ARTICLE_ID, CHAPTER_ALTMETRIC_ID, ORDINAL_NUMBER, TITLE, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, chapter.ARTICLE_ID, chapter.content:altmetric_id::bigint,
chapter.content:citation:ordinal_number::bigint, content:citation:title,
to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select * from ("DEV2_LZ"."ALTMETRICS"."T_S_FETCH" as a inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES" as b
on a.content:altmetric_id = b.ALTMETRIC_ID) where content:citation:type = 'chapter') chapter,
table(getnextval(alt_chap_seq)) seq
where not exists (select CHAPTER_ALTMETRIC_ID from "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES_CHAPTERS" where
chapter.content:altmetric_id = CHAPTER_ALTMETRIC_ID);