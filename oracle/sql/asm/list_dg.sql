set pagesize 2000
set linesize 250

select group_number, name, state, type
  from v$asm_diskgroup
  order by GROUP_NUMBER;

