--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 03-07-2024
-- Description: Show all dbms_alert package
--------------------------------------------------------------------------------

set pagesize 2000 linesize 250

col OWNER format a20
col OBJECT_NAME format a10
col PROCEDURE_NAME format a20
col OBJECT_TYPE format a10

SELECT DISTINCT OWNER,OBJECT_NAME,PROCEDURE_NAME,OBJECT_TYPE
  FROM ALL_PROCEDURES
  WHERE OBJECT_NAME like '%DBMS_ALERT%'
  ORDER BY OWNER,OBJECT_NAME,PROCEDURE_NAME,OBJECT_TYPE ASC;
