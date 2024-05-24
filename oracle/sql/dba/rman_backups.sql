--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set linesize 250
set pagesize 1000
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col START_TIME         format a20
col END_TIME           format a20
col INPUT_BYTES        format 99,999,999
col OUTPUT_BYTES       format 99,999,999
col STATUS             format a10
col TIME_TAKEN_DISPLAY format a10

SELECT
  START_TIME,END_TIME,
  STATUS,
  INPUT_TYPE,
  INPUT_BYTES / 1024 / 1024 "Input in MB",
  OUTPUT_BYTES / 1024 / 1024 "Output in MB",
  TIME_TAKEN_DISPLAY,
  OUTPUT_DEVICE_TYPE
FROM
  v$RMAN_BACKUP_JOB_DETAILS
ORDER BY END_TIME ASC;
