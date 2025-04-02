--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 03-07-2024
-- Description: Show all grants for dbms_alert
--------------------------------------------------------------------------------

set pagesize 2000 linesize 250

col GRANTEE      format a20
col OBJECT_OWNER format a20
col TABLE_NAME   format a10
col PRIVILEGE    format a20
col GRANTOR      format a20

SELECT
    GRANTEE,
    OWNER AS OBJECT_OWNER,
    TABLE_NAME,
    PRIVILEGE,
    GRANTOR
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME = 'DBMS_ALERT'
ORDER BY GRANTEE, OBJECT_OWNER, TABLE_NAME ASC;

