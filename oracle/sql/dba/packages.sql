--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col OWNER format a10
col OBJECT_NAME format a30
col PROCEDURE_NAME format a32
col OBJECT_TYPE format a10

SELECT DISTINCT OWNER,OBJECT_NAME,PROCEDURE_NAME,OBJECT_TYPE
  FROM ALL_PROCEDURES
  WHERE OBJECT_TYPE='PACKAGE' AND (
    OBJECT_NAME like '%DBMS_ALERT%'
    OR OBJECT_NAME like '%DBMS_MONITOR%'
    OR OBJECT_NAME like '%DBMS_CRYPTO%'
    OR OBJECT_NAME like '%PERF%'
  )
  ORDER BY OWNER,OBJECT_NAME,PROCEDURE_NAME,OBJECT_TYPE ASC;
