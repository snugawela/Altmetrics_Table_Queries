-- CREATE OR REPLACE SEQUENCE alt_journal_seq START = 1 INCREMENT = 1;

-- Inserting existing records blocked by checking for altmetrics id
-- No need to de-duplicate the altmetrics ids in the inserting set since that was done in a previous stage
insert into "DEV2_EDW"."ALTMETRICS"."ALT_DIM_JOURNALS"(JOURNAL_ID, JOURNAL_NAME, ALTMETRIC_JOURNAL_ID,
TIMESTAMP_OF_INSERT, PERIOD_ID_OF_INSERT)
(select seq.nextval, content:citation:journal::varchar, content:altmetric_id::bigint,
to_char(current_timestamp, 'YYYY-MM-DD HH:MM:SS'), to_char(current_timestamp, 'YYYYMMDD')
from "DEV2_LZ"."ALTMETRICS"."T_S_FETCH", table(getnextval(alt_journal_seq)) seq
where (content:citation:type = 'journal' or content:citation:journal is not null) and
not exists (select ALTMETRIC_JOURNAL_ID from "DEV2_EDW"."ALTMETRICS"."ALT_DIM_JOURNALS" where
content:altmetric_id=ALTMETRIC_JOURNAL_ID));
