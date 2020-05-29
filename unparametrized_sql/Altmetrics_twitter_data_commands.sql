-- Inserting into Post Authors, de-duplicating by tweeter id
insert into "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POST_AUTHORS"(POST_AUTHOR_ID,
POST_AUTHOR_NAME, SOCIAL_CHANNEL_ID, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT,
ID_ON_SOURCE, FACEBOOK_WALL_NAME, TWEETER_ID, OPS_INSTITUTION_ID)
select seq.nextval, twitter_data.author_id, twitter_data.social_channel_id, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'),
to_char(current_timestamp, 'YYYYMMDD'), twitter_data.author_id, null, twitter_data.author_id, null from
(select author_id, social_channel_id from (select substring(twtr_author_id, 7, length(twtr_author_id)) as author_id, 'twitter' as channel from
(select w.value:relationships:author:data:id::varchar as twtr_author_id, 'twitter' as twtr_social_name from
(select v.value as entries from "DEV2_LZ"."ALTMETRICS"."T_S_TWITTER", table(flatten(content)) v where v.key='data'),
 table(flatten(entries)) w)) join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_SOCIAL_CHANNELS" on social_channel_name=channel) twitter_data,
table(getnextval(alt_author_seq)) seq
where not exists (select TWEETER_ID from "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POST_AUTHORS" where TWEETER_ID=twitter_data.author_id);

-- Inserting into Posts, de-duplicating by article id, social channel id and post author id
insert into "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POSTS"(POST_ID, ARTICLE_ID, SOCIAL_CHANNEL_ID,
POST_AUTHOR_ID, URL, POSTED_ON_TIMESTAMP, DERIVED_IS_RETWEET, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, article_id, social_channel_id, post_author_id, null, timestamp_of_insert,
null, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select article_id, social_channel_id, post_author_id, timestamp_of_insert from
(select author_id, article_id, channel from
 (select data_id, substring(twtr_author_id, 7, length(twtr_author_id)) as author_id,
x.value:data:id::varchar as alt_id, 'twitter' as channel from
(select w.value:id as data_id, w.value:relationships:author:data:id::varchar as twtr_author_id,
w.value:relationships['research-outputs'] as research_outputs from
(select v.value as entries from "DEV2_LZ"."ALTMETRICS"."T_S_TWITTER", table(flatten(content)) v where v.key='data'),
 table(flatten(entries)) w), table(flatten(research_outputs)) x) inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_ARTICLES"
 on alt_id=ALTMETRIC_ID) inner join "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POST_AUTHORS" on TWEETER_ID=author_id),
 table(getnextval(alt_post_seq)) seq
where not exists (select * from "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POSTS" where
article_id=ARTICLE_ID and social_channel_id=SOCIAL_CHANNEL_ID and post_author_id=POST_AUTHOR_ID);
