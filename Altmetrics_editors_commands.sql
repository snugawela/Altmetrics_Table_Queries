-- Create and extract data from APIs for Editors
CREATE OR REPLACE TABLE "DEV2_LZ"."ALTMETRICS"."ALT_DIM_EDITORS" (
	EDITOR_ID BIGINT,
	EDITOR_NAME VARCHAR(1000),
	TIMESTAMP_OF_INSERT TIMESTAMP,
	PERIOD_ID_OF_INSERT BIGINT
);

-- CREATE OR REPLACE SEQUENCE alt_editor_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking by editor name
insert into "DEV2_LZ"."ALTMETRICS"."ALT_DIM_EDITORS"(EDITOR_ID, EDITOR_NAME, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, editors.name, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select distinct v.value as name from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH", table(flatten(content:citation:book:editors)) v
where not exists (select EDITOR_NAME from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_EDITORS" where EDITOR_NAME = v.value)) editors,
table(getnextval(alt_editor_seq)) seq;