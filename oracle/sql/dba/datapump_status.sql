--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

! printf "#### Data Pump Directory ####"

col OWNER format a7
col DIRECTORY_NAME format a25
col DIRECTORY_PATH format a70
col ORIGIN_CON_ID format 999999

SELECT *
FROM ALL_DIRECTORIES
WHERE DIRECTORY_NAME = 'DATA_PUMP_DIR';

! printf "#### Jobs ####"

COLUMN owner_name FORMAT A20
COLUMN job_name FORMAT A30
COLUMN operation FORMAT A10
COLUMN job_mode FORMAT A10
COLUMN state FORMAT A20

SELECT owner_name,
  job_name,
  TRIM(operation) AS operation,
  TRIM(job_mode) AS job_mode,
  state,
  degree,
  attached_sessions,
  datapump_sessions
FROM dba_datapump_jobs
WHERE state='EXECUTING'
ORDER BY 1, 2;

! printf "#### Status ####"

col MODULE format a20
col EVENT format a50
col SQL_TEXT format a60

SELECT s.sid, s.module, s.state,
  substr(s.event, 1, 21) AS event,
  s.seconds_in_wait AS secs,
  substr(sql.sql_text, 1, 60) AS sql_text
from v$session s
JOIN v$sql sql on sql.sql_id = s.sql_id
WHERE s.module like 'Data Pump%'
ORDER BY s.module, s.sid;

! printf "#### Working status (Check if block values are increasing) ####"

-- https://blog.toadworld.com/2018/06/07/impdp-hangs-or-appears-to-hang-but-has-it

select v.status, v.sid,v.serial#,io.block_changes,event
from v$sess_io io, v$session v
where io.sid = v.sid
and v.saddr in (
    select saddr
    from dba_datapump_sessions
) order by sid;
