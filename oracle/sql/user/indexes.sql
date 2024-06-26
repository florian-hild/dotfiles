--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col INDEX_NAME format a40
col INDEX_TYPE format a14
col TABLESPACE_NAME format a15
col TABLE_OWNER format a20
col TABLE_NAME format a30
col STATUS format a10

SELECT INDEX_NAME,INDEX_TYPE,TABLESPACE_NAME,TABLE_OWNER,TABLE_NAME,NUM_ROWS,STATUS,LAST_ANALYZED
  FROM user_indexes
  ORDER BY INDEX_NAME,TABLESPACE_NAME,NUM_ROWS ASC;
