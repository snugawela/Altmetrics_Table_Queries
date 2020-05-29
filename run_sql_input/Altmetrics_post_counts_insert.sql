-- CREATE OR REPLACE SEQUENCE alt_post_count_seq START = 1 INCREMENT = 1;

-- -- Inserting existing records blocked by checking for existing article_id and social_channel_id combinations
insert into "DEV2_EDW"."ALTMETRICS"."ALT_FACT_ARTICLE_POST_COUNTS" (ARTICLE_POST_COUNTS_ID, ARTICLE_ID, SOCIAL_CHANNEL_ID,
	UNIQUE_POST_AUTHOR_COUNTS, POST_COUNT, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, article_id, social_channel_id, user_count, post_count, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select social_channel_id, post_count, user_count, alt_id from (select v.key as channel,
v.value:posts_count as post_count, v.value:unique_users_count as user_count, alt_id from
(select content:counts as counts, content:altmetric_id as alt_id from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH"),
table(flatten(counts)) v) inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_SOCIAL_CHANNELS" on SOCIAL_CHANNEL_NAME=channel)
inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES" on ALTMETRIC_ID=alt_id,
table(getnextval(alt_post_count_seq)) seq
where not exists (select ARTICLE_ID, SOCIAL_CHANNEL_ID from "DEV2_EDW"."ALTMETRICS"."ALT_FACT_ARTICLE_POST_COUNTS" where
article_id=ARTICLE_ID and social_channel_id=SOCIAL_CHANNEL_ID and UNIQUE_POST_AUTHOR_COUNTS=user_count and POST_COUNT=post_count)
and (user_count is not null and post_count is not null and article_id is not null);
