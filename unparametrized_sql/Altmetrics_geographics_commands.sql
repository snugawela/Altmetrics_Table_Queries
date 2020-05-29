CREATE OR REPLACE TABLE "DEV2_EDW"."ALTMETRICS"."ALT_DIM_GEOGRAPHICS" (
	GEOGRAPHIC_ID BIGINT NOT NULL,
	GEOGRAPHIC_VALUE VARCHAR(255),
	TIMESTAMP_OF_INSERT TIMESTAMP,
	PERIOD_ID_OF_INSERT BIGINT
);

-- CREATE OR REPLACE SEQUENCE alt_geo_seq START = 1 INCREMENT = 1;

-- Inserting the duplicates blocked by taking distinct geographic code keys and checking for already inserted geo codes
insert into "DEV2_EDW"."ALTMETRICS"."ALT_DIM_GEOGRAPHICS"(GEOGRAPHIC_ID, GEOGRAPHIC_VALUE, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, geo_code, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select distinct w.key as geo_code from (select v.value as geo_set from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH",
table(flatten(content:demographics:geo)) v where content:demographics is not null), table(flatten(geo_set)) w),
table(getnextval(alt_geo_seq)) seq
where not exists (select GEOGRAPHIC_VALUE from "DEV2_EDW"."ALTMETRICS"."ALT_DIM_GEOGRAPHICS" where GEOGRAPHIC_VALUE = geo_code);
