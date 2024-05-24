--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 300

col OWNER format a20
col TABLE_NAME format a35
col TABLESPACE_NAME format a12
col COLUMN_NAME format a30
col SEGMENT_NAME format a30
col INDEX_NAME format a30

SELECT OWNER,TABLE_NAME,COLUMN_NAME,TABLESPACE_NAME,SEGMENT_NAME,INDEX_NAME
  FROM dba_lobs
  WHERE OWNER != 'SYS'
  and OWNER != 'XDB'
  and OWNER != 'SYSTEM'
  and OWNER != 'MDSYS'
  and OWNER != 'ORDDATA'
  and OWNER != 'WMSYS'
  and OWNER != 'GSMADMIN_INTERNAL'
  ORDER BY OWNER,TABLE_NAME,TABLESPACE_NAME ASC;
