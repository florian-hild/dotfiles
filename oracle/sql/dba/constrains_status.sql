--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 20-11-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col OWNER format a20
col CONSTRAINT_NAME format a40
col CONSTRAINT_TYPE format a5
col TABLE_NAME format a40
col STATUS format a10

accept user char prompt 'Please enter schema name: '

SELECT OWNER,CONSTRAINT_NAME,CONSTRAINT_TYPE,TABLE_NAME,STATUS
  FROM dba_constraints
  WHERE constraint_type = 'R'
  AND OWNER = UPPER('&user')
  ORDER BY OWNER,CONSTRAINT_NAME ASC;
