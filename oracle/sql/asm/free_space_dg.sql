--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

select name, total_mb, free_mb, round((free_mb/total_mb)*100,2) pct_free
  from v$asm_diskgroup
  where total_mb != 0
  order by free_mb DESC;

