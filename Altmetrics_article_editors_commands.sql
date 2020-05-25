CREATE OR REPLACE TABLE "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLE_EDITORS" (
	ARTICLE_EDITOR_ID BIGINT NOT NULL,
	ARTICLE_ID BIGINT,
	EDITOR_ID BIGINT,
	TIMESTAMP_OF_INSERT TIMESTAMP,
	PERIOD_ID_OF_INSERT BIGINT
);

-- CREATE OR REPLACE SEQUENCE alt_art_editor_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking by a combination of article and editor ids
insert into "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLE_EDITORS"(ARTICLE_EDITOR_ID, ARTICLE_ID, EDITOR_ID, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, v.article_id, v.editor_id, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select article_id, editor_id from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_EDITORS",
(select v.value as edit_name, article_id from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH", table(flatten(content:citation:book:editors)) v, (select article_id, altmetric_id from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLES") where content:altmetric_id = altmetric_id and content:citation:book:editors is not null)
where editor_name = edit_name) v,
table(getnextval(alt_art_editor_seq)) seq
where not exists (select editor_id from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_ARTICLE_EDITORS" where v.editor_id = editor_id and v.article_id = article_id);
