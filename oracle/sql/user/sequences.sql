--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col SEQUENCE_NAME format a50
col LAST_NUMBER format 9999999999
col MIN_VALUE format 9999999999
col MAX_VALUE format 999999999999999999999999999999
col INCREMENT_BY format 9999
col CYCLE_FLAG format A10

SELECT SEQUENCE_NAME,LAST_NUMBER,INCREMENT_BY,MIN_VALUE,MAX_VALUE,CYCLE_FLAG
  FROM user_sequences
  ORDER BY SEQUENCE_NAME;
