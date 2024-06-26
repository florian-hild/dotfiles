--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col TABLE_NAME format a40
col TABLESPACE_NAME format a20
col STATUS format a10

SELECT TABLE_NAME,TABLESPACE_NAME,NUM_ROWS,STATUS
  FROM user_tables
  ORDER BY TABLE_NAME,TABLESPACE_NAME,NUM_ROWS ASC;
