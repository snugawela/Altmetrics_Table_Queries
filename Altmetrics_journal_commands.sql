-- Can run after running the article creation
CREATE OR REPLACE TABLE "DEV2_LZ"."ALTMETRICS"."ALT_DIM_JOURNALS" (
	JOURNAL_ID BIGINT NOT NULL,
	JOURNAL_NAME VARCHAR(10000),
	ALTMETRIC_JOURNAL_ID VARCHAR(255),
	TIMESTAMP_OF_INSERT TIMESTAMP,
	PERIOD_ID_OF_INSERT BIGINT
);

-- CREATE OR REPLACE SEQUENCE alt_journal_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking for altmetrics id
insert into "DEV2_LZ"."ALTMETRICS"."ALT_DIM_JOURNALS"(JOURNAL_ID, JOURNAL_NAME, ALTMETRIC_JOURNAL_ID, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
(select seq.nextval, content:citation:journal, content:altmetric_id,
to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD')
from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH", table(getnextval(alt_journal_seq)) seq
where (content:citation:type = 'journal' or content:citation:journal is not null) and
not exists (select * from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_JOURNALS" where content:altmetric_id=ALTMETRIC_JOURNAL_ID));
