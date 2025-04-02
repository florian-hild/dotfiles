--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Retrieves system privileges granted to users (excluding roles and system accounts)
--------------------------------------------------------------------------------

set linesize 250
set pagesize 2000

col GRANTEE         format a30
col PRIVILEGE       format a30
col ADMIN_OPTION    format a4
col COMMON          format a4
col INHERITED       format a4

SELECT GRANTEE, PRIVILEGE, ADMIN_OPTION, COMMON, INHERITED
  FROM dba_sys_privs
  WHERE GRANTEE IN ( SELECT USERNAME FROM DBA_USERS WHERE ORACLE_MAINTAINED = 'N')
  ORDER BY GRANTEE, PRIVILEGE ASC;
