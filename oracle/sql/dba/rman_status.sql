--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col OPERATION format a40
col STATUS format a10
col MBYTES_PROCESSED format 999999

SELECT
  OPERATION,
  STATUS,
  MBYTES_PROCESSED,
  START_TIME,
  END_TIME
FROM
  V$RMAN_STATUS
ORDER BY END_TIME,START_TIME DESC;
