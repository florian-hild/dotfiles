--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col TABLE_OWNER format a20
col TABLE_NAME format a30
col INDEX_NAME format a40
col COLUMN_NAME format a35
col COLUMN_POSITION format 999

SELECT TABLE_OWNER,TABLE_NAME,INDEX_NAME,COLUMN_POSITION,COLUMN_NAME
  FROM dba_ind_columns
  WHERE TABLE_OWNER not in ('SYSTEM','SYS','XDB','WMSYS','ORDDATA','OJVMSYS','MDSYS','CTXSYS','OUTLN','ORDSYS')
  ORDER BY TABLE_OWNER,TABLE_NAME,INDEX_NAME,COLUMN_POSITION ASC;
