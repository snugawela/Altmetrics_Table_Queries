-- CREATE OR REPLACE SEQUENCE alt_author_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking by author name
insert into "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POST_AUTHORS"(POST_AUTHOR_ID,
POST_AUTHOR_NAME, SOCIAL_CHANNEL_ID, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT,
ID_ON_SOURCE, FACEBOOK_WALL_NAME, TWEETER_ID, OPS_INSTITUTION_ID)
select seq.nextval, author_name, social_channel_id, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'),
to_char(current_timestamp, 'YYYYMMDD'), id_on_src, (case when wall_name = 'true' then author_name
else null end), null, null from
(select distinct w.value:author:name as author_name, social_channel,
 w.value:id_on_source as id_on_src, w.value:facebook_wall_name as wall_name from
 (select v.key as social_channel, v.value as author_arr from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH",
  table(flatten(content:posts)) v where v.value is not null), table(flatten(author_arr)) w) inner join
  "DEV2_EDW"."ALTMETRICS"."ALT_DIM_SOCIAL_CHANNELS" on social_channel_name = social_channel,
  table(getnextval(alt_author_seq)) seq
where author_name is not null and not exists (select POST_AUTHOR_NAME from "DEV2_EDW"."ALTMETRICS"."ALT_DIM_POST_AUTHORS" where
POST_AUTHOR_NAME = author_name);