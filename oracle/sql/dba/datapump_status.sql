--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Show Data Pump directory, jobs, sessions, progress and
--              worker activity.
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

PROMPT
PROMPT #### Data Pump Directory ####

col OWNER          format a10
col DIRECTORY_NAME format a25
col DIRECTORY_PATH format a70
col ORIGIN_CON_ID  format 999999

SELECT owner,
  directory_name,
  directory_path,
  origin_con_id
FROM all_directories
WHERE directory_name = 'DATA_PUMP_DIR';

PROMPT
PROMPT #### Jobs ####

col OWNER_NAME format a20
col JOB_NAME   format a30
col OPERATION  format a10
col JOB_MODE   format a10
col STATE      format a15

SELECT owner_name,
  job_name,
  TRIM(operation) AS operation,
  TRIM(job_mode) AS job_mode,
  state,
  degree,
  attached_sessions,
  datapump_sessions
FROM dba_datapump_jobs
ORDER BY owner_name, job_name;

PROMPT
PROMPT #### Sessions ####

col MODULE   format a20
col STATE    format a20
col EVENT    format a21
col SQL_TEXT format a60

SELECT s.sid,
  s.module,
  s.state,
  SUBSTR(s.event, 1, 21) AS event,
  s.seconds_in_wait AS secs,
  SUBSTR(q.sql_text, 1, 60) AS sql_text
FROM v$session s
LEFT JOIN v$sql q ON q.sql_id = s.sql_id
WHERE s.module LIKE 'Data Pump%'
ORDER BY s.module, s.sid;

PROMPT
PROMPT #### Progress ####

col USERNAME  format a16
col OPNAME    format a30
col PCT_DONE  format 999.99
col MINS_LEFT format 99999.9

SELECT sl.sid,
  sl.serial#,
  sl.username,
  sl.opname,
  sl.sofar,
  sl.totalwork,
  ROUND(sl.sofar / NULLIF(sl.totalwork, 0) * 100, 2) AS pct_done,
  ROUND(sl.time_remaining / 60, 1) AS mins_left
FROM v$session_longops sl
WHERE sl.opname IN (SELECT job_name FROM dba_datapump_jobs)
  AND sl.sofar <> sl.totalwork
ORDER BY sl.sid;

PROMPT
PROMPT #### Working status (check if block_changes values are increasing) ####

-- https://blog.toadworld.com/2018/06/07/impdp-hangs-or-appears-to-hang-but-has-it

SELECT s.status,
  s.sid,
  s.serial#,
  io.block_changes,
  s.event
FROM v$session s
JOIN v$sess_io io ON io.sid = s.sid
WHERE s.saddr IN (SELECT saddr FROM dba_datapump_sessions)
ORDER BY s.sid;
