--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col RESOURCE_NAME format a30
col RESOURCE_TYPE format a15
col LIMIT format a30
col PROFILE format a20

SELECT PROFILE,RESOURCE_NAME,LIMIT,RESOURCE_TYPE
  FROM DBA_PROFILES
  ORDER BY PROFILE,LIMIT,RESOURCE_TYPE,RESOURCE_NAME ASC;

-- ALTER USER <USERNAME> IDENTIFIED BY <PWASSWORD> ACCOUNT UNLOCK;
-- ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_TIME UNLIMITED;
-- ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
-- ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED;
