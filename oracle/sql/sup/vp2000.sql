--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col OBJECT_NAME format a30
col OBJECT_TYPE format a20
col STATUS format a20
col OWNER format a25

SELECT OBJECT_NAME,OBJECT_TYPE,OWNER,STATUS
  FROM DBA_OBJECTS
  WHERE OBJECT_NAME like '%_VP2000%'
  OR OBJECT_NAME = 'VSD_TRANSFER'
  ORDER BY OWNER,OBJECT_NAME,OBJECT_TYPE ASC;

