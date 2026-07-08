--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Show temp tablespace usage per sort segment and per session.
--------------------------------------------------------------------------------

SET PAGESIZE 1000
SET LINESIZE 1000

COL TABLESPACE_NAME FORMAT a20
COL TOTAL_BLOCKS    FORMAT 999,999,999,999
COL USED_BLOCKS     FORMAT 999,999,999,999
COL FREE_BLOCKS     FORMAT 999,999,999,999

SELECT inst_id,
       tablespace_name,
       segment_file,
       total_blocks,
       used_blocks,
       free_blocks,
       max_used_blocks,
       max_sort_blocks
FROM gv$sort_segment
ORDER BY inst_id, tablespace_name;

col TABLESPACE format a10
col TEMP_MB    format 999,999,999.99
col INSTANCE   format 99
col SID_SERIAL format a12
col USERNAME   format a16
col PROGRAM    format a25
col STATUS     format a8
col SQL_ID     format a13

SELECT b.tablespace,
       ROUND((b.blocks * p.value) / 1024 / 1024, 2) AS temp_mb,
       a.inst_id AS instance,
       a.sid || ',' || a.serial# AS sid_serial,
       NVL(a.username, '(oracle)') AS username,
       a.program,
       a.status,
       a.sql_id
FROM gv$session a
JOIN gv$sort_usage b ON a.saddr = b.session_addr AND a.inst_id = b.inst_id
JOIN gv$parameter p ON p.inst_id = a.inst_id AND p.name = 'db_block_size'
ORDER BY temp_mb DESC;
