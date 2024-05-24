--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 38
set linesize 250
set pause 'Press Enter'
set pause on

col OWNER format a20
col OBJECT_NAME format a30
col PROCEDURE_NAME format a32
col OBJECT_TYPE format a10

SELECT DISTINCT OWNER,OBJECT_NAME,PROCEDURE_NAME,OBJECT_TYPE
  FROM ALL_PROCEDURES
  WHERE OBJECT_TYPE='PACKAGE'
  ORDER BY OWNER,OBJECT_NAME,PROCEDURE_NAME,OBJECT_TYPE ASC;

set pause off
