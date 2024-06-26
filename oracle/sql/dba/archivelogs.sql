--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 26-06-2024
-- Description: Show archive logs status
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col NAME format a100

select RECID,NAME,ARCHIVED,BACKUP_COUNT,FIRST_TIME,COMPLETION_TIME,IS_RECOVERY_DEST_FILE,STATUS
  from V$ARCHIVED_LOG
  where DELETED = 'NO'
  order by NAME ASC;

