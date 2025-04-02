--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 02-04-2025
-- Description: Shows roles granted to users.
--------------------------------------------------------------------------------

set linesize 250
set pagesize 2000

col GRANTEE         format a30
col GRANTED_ROLE    format a30
col ADMIN_OPTION    format a15
col DELEGATE_OPTION format a4
col DEFAULT_ROLE    format a15

SELECT
    GRANTEE,
    GRANTED_ROLE,
    ADMIN_OPTION,
    DELEGATE_OPTION,
    DEFAULT_ROLE
FROM DBA_ROLE_PRIVS
WHERE GRANTEE IN (SELECT USERNAME FROM DBA_USERS WHERE ORACLE_MAINTAINED = 'N')
ORDER BY GRANTEE, GRANTED_ROLE ASC;
