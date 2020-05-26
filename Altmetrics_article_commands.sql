-- Get article data
-- Have to run this first of all
CREATE OR REPLACE TABLE "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLES" (
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
insert into "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLES"(ARTICLE_ID, ARTICLE_DOI, ARTICLE_TITLE, ALTMETRIC_ID, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT, FIRST_SEEN_ON_ALTMETRICS_TIMESTAMP)
select seq.nextval, content:citation:doi, content:citation:title, content:altmetric_id, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD'),
to_char(to_date(content:citation:first_seen_on), 'YYYY-MM-DD HH:MM:SS') from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH", table(getnextval(alt_seq)) seq
where not exists (select ALTMETRIC_ID from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLES" where content:altmetric_id=ALTMETRIC_ID);

-- Inserting existing records blocked by checking for existing altmetrics id and doi combination for Twitter API
insert into "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLES"(ARTICLE_ID, ARTICLE_DOI, ARTICLE_TITLE, ALTMETRIC_ID, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT, FIRST_SEEN_ON_ALTMETRICS_TIMESTAMP)
select seq.nextval, doi, title, alt_id, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD'), null from
(select title, alt_id, doi_flat.value as doi from (select w.value:attributes:title as title, w.value:id as alt_id, w.value:attributes:identifiers:dois as doi_arr from (select v.value as articles from "DEV2_LZ"."ALTMETRICS"."T_S_TWITTER",
table(flatten(content)) v where v.key = 'included'), table(flatten(articles)) w where w.value:attributes:title is not null and w.value:attributes['altmetric-score'] is not null), table(flatten(doi_arr)) doi_flat),
table(getnextval(alt_seq)) seq
where not exists (select ALTMETRIC_ID, ARTICLE_DOI from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLES" where
alt_id=ALTMETRIC_ID and (doi=ARTICLE_DOI or doi is null));