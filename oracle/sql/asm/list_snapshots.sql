--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

column snap_name    format a30  heading "Snapshot Name"
column fs_name      format a30  heading "File System"
column vol_device   format a25  heading "Volume Device"
column create_time  format a20  heading "Create Time"

select snap_name, fs_name, vol_device, to_char(create_time, 'YYYY-MM-DD HH24:MI:SS') as create_time
  from v$asm_acfssnapshots
  order by fs_name,create_time;
