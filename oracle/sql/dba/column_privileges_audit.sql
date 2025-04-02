--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 02-04-2025
-- Description: Shows fine-grained (column-level) privileges.
--------------------------------------------------------------------------------

set linesize 250
set pagesize 2000

col GRANTEE       format a30
col OWNER         format a30
col TABLE_NAME    format a15
col COLUMN_NAME   format a15
col PRIVILEGE     format a15
col GRANTABLE     format a15

SELECT
    GRANTEE,
    OWNER,
    TABLE_NAME,
    COLUMN_NAME,
    PRIVILEGE,
    GRANTABLE
FROM DBA_COL_PRIVS
WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS WHERE ORACLE_MAINTAINED = 'N')
ORDER BY OWNER, TABLE_NAME, GRANTEE, COLUMN_NAME, PRIVILEGE;
