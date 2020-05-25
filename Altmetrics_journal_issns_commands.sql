-- Create and get data for Journal ISSNs
CREATE TABLE "DEV2_LZ"."ALTMETRICS"."ALT_DIM_JOURNAL_ISSNS" (
	JOURNAL_ISSN_ID BIGINT NOT NULL,
	JOURNAL_ID BIGINT,
	JOURNAL_ISSN VARCHAR(100),
	DERIVED_IS_ORIG_ISSN BOOLEAN,
	TIMESTAMP_OF_INSERT TIMESTAMP,
	PERIOD_ID_OF_INSERT BIGINT
);
-- CREATE OR REPLACE SEQUENCE alt_jissn_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking by ISSN number
insert into "DEV2_LZ"."ALTMETRICS"."ALT_DIM_JOURNAL_ISSNS"(JOURNAL_ISSN_ID, JOURNAL_ID, JOURNAL_ISSN, DERIVED_IS_ORIG_ISSN, TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
select seq.nextval, journal.journal_id, journal.value, 0, to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD') from
(select * from ("DEV2_LZ"."ALTMETRICS"."T_S_FETCH" as a inner join "DEV2_LZ"."ALTMETRICS"."ALT_DIM_JOURNALS" as b on a.content:altmetric_id = b.ALTMETRIC_JOURNAL_ID), table(flatten(content:citation:issns)) journal_issn
where not exists (select JOURNAL_ISSN from "DEV2_LZ"."ALTMETRICS"."ALT_DIM_JOURNAL_ISSNS" where JOURNAL_ISSN = journal_issn.value)) journal,
table(getnextval(alt_jissn_seq)) seq;
