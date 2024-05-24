--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

SET PAGESIZE 1000
SET LINESIZE 1000

COL TABLESPACE_SIZE FOR 999,999,999,999
COL ALLOCATED_SPACE FOR 999,999,999,999
COL FREE_SPACE FOR 999,999,999,999

select inst_id, tablespace_name, segment_file, total_blocks, used_blocks, free_blocks, max_used_blocks, max_sort_blocks
from gv$sort_segment;

col TABLESPACE format a6
col TEMP_SIZE format 999,999,999,999
col INSTANCE format 99
col USERNAME format a10
col PROGRAM format a20
col STATUS format a8
col SQL_ID format 99

SELECT b.tablespace,
    ROUND(((b.blocks*p.value)/1024/1024),2)||'M' AS temp_size,
    a.inst_id as Instance,
    a.sid||','||a.serial# AS sid_serial,
    NVL(a.username, '(oracle)') AS username,
    a.program, a.status, a.sql_id
FROM gv$session a, gv$sort_usage b, gv$parameter p
WHERE p.name = 'db_block_size'
    AND a.saddr = b.session_addr
    AND a.inst_id=b.inst_id
    AND a.inst_id=p.inst_id
ORDER BY temp_size desc;
