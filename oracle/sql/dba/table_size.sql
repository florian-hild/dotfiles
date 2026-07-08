--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Show large table segments (> 1 GB or more than one extent).
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col OWNER format a20
col SEGMENT_NAME format a30
col TABLESPACE_NAME format a20
col SEGMENT_TYPE format a15
col "Size in MB" format 999,999,999.99

SELECT seg.OWNER,
       seg.SEGMENT_NAME,
       seg.SEGMENT_TYPE,
       seg.TABLESPACE_NAME,
       seg.BYTES / 1024 / 1024 "Size in MB",
       tab.NUM_ROWS,
       seg.EXTENTS
  FROM dba_segments seg
  JOIN all_tables tab
    ON seg.OWNER = tab.OWNER
   AND seg.SEGMENT_NAME = tab.TABLE_NAME
  WHERE seg.OWNER not in ('SYS')
  AND (seg.BYTES > (1024 * 1024 * 1024) OR seg.EXTENTS > 1)
  ORDER BY seg.bytes ASC;
