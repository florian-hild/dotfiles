--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Lists all object (table) privileges granted by non-system users.
--------------------------------------------------------------------------------

set pagesize 70
set linesize 250

col TABLE_NAME format a40
col OWNER format a20
col GRANTEE format a20
col PRIVILEGE format a25
col TYPE format a10
col GRANTOR format a20

SELECT OWNER, TABLE_NAME, GRANTEE, PRIVILEGE, TYPE, GRANTOR
  FROM dba_tab_privs
  WHERE GRANTOR IN ( SELECT USERNAME FROM DBA_USERS WHERE ORACLE_MAINTAINED = 'N')
  ORDER BY OWNER, TABLE_NAME, GRANTEE, TYPE, PRIVILEGE ASC;
