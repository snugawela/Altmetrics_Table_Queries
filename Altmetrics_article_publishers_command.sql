CREATE OR REPLACE TABLE "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLE_PUBLISHERS" (
	ARTICLE_PUBLISHER_ID BIGINT,
	ARTICLE_ID BIGINT,
	PUBLISHER_ID BIGINT,
	TIMESTAMP_OF_INSERT TIMESTAMP,
	PERIOD_ID_OF_INSERT BIGINT
);

-- CREATE OR REPLACE SEQUENCE alt_art_pub_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking by article_id and publisher_id.
-- Inserting duplicates blocked by taking distinct altmetric ids
insert into "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLE_PUBLISHERS"(ARTICLE_PUBLISHER_ID, ARTICLE_ID, PUBLISHER_ID, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, art_pub.article_id, art_pub.publisher_id, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select article_id, publisher_id from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_PUBLISHERS", (select article_id, content:citation:publisher as pub_name from
"DEV2_LZ"."ALTMETRICS"."T_S_FETCH", (select distinct altmetric_id, article_id from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLES") where content:altmetric_id = altmetric_id and content:citation:publisher is not null)
where publisher_name = pub_name) art_pub,
table(getnextval(alt_art_pub_seq)) seq
where not exists (select article_id, publisher_id from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLE_PUBLISHERS" where art_pub.article_id = article_id and art_pub.publisher_id = publisher_id);
