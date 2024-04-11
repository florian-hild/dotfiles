alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
set linesize 500
set pagesize 300
col JOB_NAME format a30
col OWNER format a10
col JOB_TYPE format a10
col JOB_ACTION format a60
col START_DATE format a20
col REPEAT_INTERVAL format a70
col ENABLED format a4
col STATE format a9
col "RUN CTN" format 9999
col LAST_START_DATE format a20
col NEXT_RUN_DATE format a20
col COMMENTS format a10

SET WRAP OFF

SELECT
  JOB_NAME,
  -- STATE,
  OWNER,
  JOB_TYPE,
  JOB_ACTION,
  REPEAT_INTERVAL,
  -- to_char(START_DATE,'DD-Mon-YYYY HH24:MI') START_DATE,
  to_char(LAST_START_DATE,'DD-Mon-YYYY HH24:MI') LAST_START_DATE,
  to_char(NEXT_RUN_DATE,'DD-Mon-YYYY HH24:MI') NEXT_RUN_DATE,
  RUN_COUNT as "RUN CTN",
  ENABLED,
  COMMENTS
FROM dba_scheduler_jobs
WHERE OWNER != 'SYS'
ORDER BY START_DATE,JOB_NAME;
