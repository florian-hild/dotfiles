--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Show RMAN backup job history with size and duration
--------------------------------------------------------------------------------

set linesize 250
set pagesize 1000
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col START_TIME         format a20
col END_TIME           format a20
col "Input in MB"      format 99,999,999
col "Output in MB"     format 99,999,999
col STATUS             format a10
col TIME_TAKEN_DISPLAY format a10

SELECT
  START_TIME,END_TIME,
  STATUS,
  INPUT_TYPE,
  round(INPUT_BYTES / 1048576) "Input in MB",
  round(OUTPUT_BYTES / 1048576) "Output in MB",
  TIME_TAKEN_DISPLAY,
  OUTPUT_DEVICE_TYPE
FROM
  v$RMAN_BACKUP_JOB_DETAILS
ORDER BY END_TIME ASC;
