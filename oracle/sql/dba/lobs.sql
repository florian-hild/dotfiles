--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Show LOB segments of non-Oracle-maintained schemas
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 300

col OWNER format a20
col TABLE_NAME format a35
col TABLESPACE_NAME format a12
col COLUMN_NAME format a30
col SEGMENT_NAME format a30
col INDEX_NAME format a30

SELECT l.OWNER,l.TABLE_NAME,l.COLUMN_NAME,l.TABLESPACE_NAME,l.SEGMENT_NAME,l.INDEX_NAME
  FROM dba_lobs l
  JOIN dba_users u ON u.username = l.owner
  WHERE u.oracle_maintained = 'N'
  ORDER BY l.OWNER,l.TABLE_NAME,l.TABLESPACE_NAME ASC;
