CREATE OR REPLACE TABLE "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POSTS" (
	POST_ID BIGINT,
	ARTICLE_ID BIGINT,
	SOCIAL_CHANNEL_ID BIGINT,
	POST_AUTHOR_ID BIGINT,
	URL VARCHAR(1000),
	POSTED_ON_TIMESTAMP TIMESTAMP,
	DERIVED_IS_RETWEET BOOLEAN,
	TIMESTAMP_OF_INSERT TIMESTAMP,
	PERIOD_ID_OF_INSERT BIGINT
);

-- CREATE OR REPLACE SEQUENCE alt_post_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking based on the 3 foreign keys
insert into "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POSTS" (POST_ID, ARTICLE_ID, SOCIAL_CHANNEL_ID,
POST_AUTHOR_ID, URL, POSTED_ON_TIMESTAMP, DERIVED_IS_RETWEET, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, article_id, social_channel_id, post_author_id, post_url, posted_date, false, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select * from (select distinct post_name, post_altmetric_id, social_channel_id, author_name, posted_date, post_url, post_author_id from
(select social_channel, altmetric_id as post_altmetric_id, w.value:author:name as author_name, w.value:posted_on as posted_date, w.value:url as post_url, w.value:title as post_name from
(select v.key as social_channel, v.value as author_arr, content:altmetric_id as altmetric_id from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH",
table(flatten(content:posts)) v where v.value is not null), table(flatten(author_arr)) w) inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POST_AUTHORS" on
post_author_name = author_name) post_data inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES" on post_data.post_altmetric_id = altmetric_id) post_combined,
table(getnextval(alt_post_seq)) seq
where not exists (select article_id from "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POSTS" where article_id = post_combined.article_id and
social_channel_id = post_combined.social_channel_id and post_author_id = post_combined.post_author_id);
