-- Get article data
-- Have to run this first of all
CREATE OR REPLACE TABLE "DEV2_ODS"."ALTMETRICS"."ALT_DIM_ARTICLES" (
	ARTICLE_ID BIGINT NOT NULL,
	ARTICLE_DOI VARCHAR(10000),
	ARTICLE_TITLE VARCHAR(10000),
	ALTMETRIC_ID BIGINT,
	TIMESTAMP_OF_INSERT TIMESTAMP,
	PERIOD_ID_OF_INSERT BIGINT,
	FIRST_SEEN_ON_ALTMETRICS_TIMESTAMP TIMESTAMP
);

-- CREATE OR REPLACE SEQUENCE alt_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking for existing altmetrics id and doi combination for Fetch API
-- No need to de-duplicate the altmetrics ids in the inserting set since that was done in a previous stage
insert into "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES"(ARTICLE_ID, ARTICLE_DOI, ARTICLE_TITLE, ALTMETRIC_ID,
TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT, FIRST_SEEN_ON_ALTMETRICS_TIMESTAMP)
select seq.nextval, content:citation:doi::varchar, content:citation:title::varchar, content:altmetric_id::bigint,
to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD'),
to_char(to_date(content:citation:first_seen_on), 'YYYY-MM-DD HH:MM:SS') from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH", table(getnextval(alt_seq)) seq
where not exists (select ALTMETRIC_ID from "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES" where content:altmetric_id=ALTMETRIC_ID);
