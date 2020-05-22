CREATE OR REPLACE TABLE "DEV2_LZ"."ALTMETRICS"."ALT_DIM_PUBLISHERS" (
	PUBLISHER_ID BIGINT,
	PUBLISHER_NAME VARCHAR(512),
	TIMESTAMP_OF_INSERT TIMESTAMP,
	PERIOD_ID_OF_INSERT BIGINT
);

-- CREATE OR REPLACE SEQUENCE alt_pub_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking by publisher Name
insert into "DEV2_LZ"."ALTMETRICS"."ALT_DIM_PUBLISHERS"(PUBLISHER_ID, PUBLISHER_NAME, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, pub.pub_name, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select distinct content:citation:publisher as pub_name from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH") pub,
table(getnextval(alt_pub_seq)) seq
where not exists (select PUBLISHER_NAME from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_PUBLISHERS" where pub.pub_name = PUBLISHER_NAME);