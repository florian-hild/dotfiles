--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Tablespace usage overview (incl. TEMP) with autoextend limits.
--              "Max use%" is the fill level relative to the autoextend limit.
--------------------------------------------------------------------------------

set linesize 250
set pagesize 2000

column "Tablespace"     format a16
column "Size MB"        format 99,999,999
column "Max extend MB"  format 99,999,999
column "Used MB"        format 99,999,999
column "Avail MB"       format 99,999,999
column "Use%"           format 999
column "Max use%"       format 999
column "Datafiles"      format 99
column "Free ext"       format 9999

break on report;
compute sum of "Size MB"       on report;
compute sum of "Max extend MB" on report;
compute sum of "Used MB"       on report;
compute sum of "Avail MB"      on report;
compute sum of "Datafiles"     on report;

select
  df.tablespace_name "Tablespace",
  round(df.bytes / 1048576, 2) "Size MB",
  round(df.maxbytes / 1048576, 2) "Max extend MB",
  round((df.bytes - nvl(fs.bytes, 0)) / 1048576, 2) "Used MB",
  round(nvl(fs.bytes, 0) / 1048576, 2) "Avail MB",
  round((df.bytes - nvl(fs.bytes, 0)) * 100 / df.bytes) "Use%",
  round((df.bytes - nvl(fs.bytes, 0)) * 100 / df.maxbytes) "Max use%",
  df.datafiles "Datafiles",
  nvl(fs.free_extents, 0) "Free ext"
from
  (
    select
      tablespace_name,
      sum(bytes) bytes,
      sum(decode(autoextensible, 'YES', maxbytes, bytes)) maxbytes,
      count(*) datafiles
    from dba_data_files
    group by tablespace_name
  ) df
  left join
  (
    select
      tablespace_name,
      sum(bytes) bytes,
      count(*) free_extents
    from dba_free_space
    group by tablespace_name
  ) fs
  on fs.tablespace_name = df.tablespace_name
union all
select
  tf.tablespace_name,
  round(tf.bytes / 1048576, 2),
  round(tf.maxbytes / 1048576, 2),
  round(nvl(th.bytes_used, 0) / 1048576, 2),
  round((tf.bytes - nvl(th.bytes_used, 0)) / 1048576, 2),
  round(nvl(th.bytes_used, 0) * 100 / tf.bytes),
  round(nvl(th.bytes_used, 0) * 100 / tf.maxbytes),
  tf.tempfiles,
  null
from
  (
    select
      tablespace_name,
      sum(bytes) bytes,
      sum(decode(autoextensible, 'YES', maxbytes, bytes)) maxbytes,
      count(*) tempfiles
    from dba_temp_files
    group by tablespace_name
  ) tf
  left join
  (
    select
      tablespace_name,
      sum(bytes_used) bytes_used
    from v$temp_space_header
    group by tablespace_name
  ) th
  on th.tablespace_name = tf.tablespace_name
order by "Max use%" desc, "Use%" desc, "Tablespace";

clear breaks;
clear computes;
clear columns;
