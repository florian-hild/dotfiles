--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col OWNER format a20
col OBJECT_NAME format a30
col TABLESPACE_NAME format a20
col SEGMENT_TYPE format a10

SELECT OWNER,SEGMENT_NAME,SEGMENT_TYPE,TABLESPACE_NAME,BYTES / 1024 / 1024 "Size in MB",EXTENTS
  FROM dba_segments
  WHERE OWNER not in ('SYS')
  AND (BYTES > (1024 * 1024 * 1024) OR EXTENTS > 1)
  ORDER BY bytes ASC;
