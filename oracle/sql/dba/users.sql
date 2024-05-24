--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col ACCOUNT_STATUS format a20
col USERNAME format a30
col LOCK_DATE format a20
col EXPIRY_DATE format a20
col DEFAULT_TABLESPACE format a25
col LAST_LOGIN format a45
col PASSWORD_CHANGE_DATE format a20
col PROFILE format a20

SELECT username,account_status,DEFAULT_TABLESPACE,PROFILE
  FROM dba_users
  WHERE account_status = 'OPEN'
  ORDER BY account_status,username,CREATED,DEFAULT_TABLESPACE ASC;
