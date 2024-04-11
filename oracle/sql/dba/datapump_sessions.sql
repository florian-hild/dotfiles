set pagesize 2000
set linesize 250

COLUMN owner_name FORMAT A20
COLUMN job_name FORMAT A30
COLUMN session_type FORMAT A15

select owner_name, job_name, session_type
  from dba_datapump_sessions
  order by owner_name,session_type,job_name;
