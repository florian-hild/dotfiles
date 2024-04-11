set pagesize 2000
set linesize 250

col PATH format a40
col HEADER_STATUS format a12
col NAME format a30

select HEADER_STATUS, NAME, PATH, mount_status, state
  from v$asm_disk
  order by NAME,PATH,mount_status;

