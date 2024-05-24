--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set linesize 250
set pagesize 1000

col SPID format a10
col PNAME format a5
col PROGRAM format a50
col TRACEFILE format a75

select PNAME,SPID,TRACEFILE,PGA_ALLOC_MEM,PGA_USED_MEM,PGA_MAX_MEM
  from v$process
  order by PNAME,SOSID;
