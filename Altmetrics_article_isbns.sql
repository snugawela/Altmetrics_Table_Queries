CREATE TABLE "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLE_ISBNS" (
	ARTICLE_ISBN_ID BIGINT NOT NULL,
	ARTICLE_ID BIGINT,
	ARTICLE_ISBN VARCHAR(18),
	TIMESTAMP_OF_INSERT TIMESTAMP,
	PERIOD_ID_OF_INSERT BIGINT
);

-- CREATE OR REPLACE SEQUENCE alt_aisbn_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking by the ISBN number
insert into "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLE_ISBNS"(ARTICLE_ISBN_ID, ARTICLE_ID, ARTICLE_ISBN, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, book.article_id, book.value, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select * from ("DEV2_LZ"."ALTMETRICS"."T_S_FETCH" as a inner join "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLES" as b on a.content:altmetric_id = b.ALTMETRIC_ID), table(flatten(content:citation:isbns)) book_isbn
where not exists (select ARTICLE_ISBN from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLE_ISBNS" where ARTICLE_ISBN = book_isbn.value)) book,
table(getnextval(alt_aisbn_seq)) seq;