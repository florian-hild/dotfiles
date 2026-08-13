--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Shows account status of all DB users. LAST_LOGIN and
--              PASSWORD_CHANGE_DATE are only included when the columns exist
--              in dba_users (depends on the Oracle version).
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
set verify off
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col ACCOUNT_STATUS format a20
col USERNAME format a30
col LOCK_DATE format a20
col EXPIRY_DATE format a20
col DEFAULT_TABLESPACE format a25
col LAST_LOGIN format a45
col PASSWORD_CHANGE_DATE format a20
col PROFILE format a20

-- Build the column list depending on which optional columns exist.
set termout off
set feedback off
column user_status_cols new_value user_status_cols noprint
SELECT 'username,account_status,LOCK_DATE,EXPIRY_DATE,DEFAULT_TABLESPACE,'
       || MAX(CASE WHEN column_name = 'LAST_LOGIN' THEN 'LAST_LOGIN,' END)
       || MAX(CASE WHEN column_name = 'PASSWORD_CHANGE_DATE' THEN 'PASSWORD_CHANGE_DATE,' END)
       || 'PROFILE' AS user_status_cols
  FROM dba_tab_columns
  WHERE table_name = 'DBA_USERS'
    AND column_name IN ('LAST_LOGIN', 'PASSWORD_CHANGE_DATE');
set feedback on
set termout on

SELECT &user_status_cols
  FROM dba_users
  ORDER BY account_status,username,CREATED,DEFAULT_TABLESPACE ASC;
