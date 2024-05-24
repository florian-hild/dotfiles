--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
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
column "Segments"       format 9999

break on report;
compute sum of "Size MB"       on report;
compute sum of "Max extend MB" on report;
compute sum of "Used MB"       on report;
compute sum of "Avail MB"      on report;
compute sum of "Datafiles"     on report;
compute sum of "Segments"      on report;

-- SELECT df.tablespace_name "Tablespace",
--  round(df.bytes / (1024 * 1024), 2) "Size MB",
--  round(df.maxbytes / (1024 * 1024), 2) "Max extend MB",
--  round((df.bytes - sum(fs.bytes)) / (1024 * 1024), 2) "Used MB",
--  round(sum(fs.bytes) / (1024 * 1024), 2) "Avail MB",
--  round((df.bytes-sum(fs.bytes)) * 100 / df.bytes, 2) "Use%",
--  round((df.bytes - sum(fs.bytes)) / (df.maxbytes) * 100, 2) "Max use%",
--  df.datafiles "Datafiles"
--  -- nvl(round(sum(fs.bytes) * 100 / df.bytes), 2) "Free%"
-- FROM dba_free_space fs,
--  (select tablespace_name,
--  sum(bytes) bytes,
--  sum(decode(maxbytes, 0, bytes, maxbytes)) maxbytes,
--  max(autoextensible) autoextensible,
--  nvl(count(file_name), 0) datafiles
--  from dba_data_files
--  group by tablespace_name) df
-- WHERE fs.tablespace_name (+) = df.tablespace_name
-- GROUP BY df.tablespace_name, df.bytes, df.maxbytes, df.datafiles
-- UNION ALL
-- SELECT df.tablespace_name tablespace_name,
--  round(df.maxbytes / (1024 * 1024), 2) max_ts_size,
--  round((df.bytes - sum(fs.bytes)) / (df.maxbytes) * 100, 2) max_ts_pct_used,
--  round(df.bytes / (1024 * 1024), 2) curr_ts_size,
--  round((df.bytes - sum(fs.bytes)) / (1024 * 1024), 2) used_ts_size,
--  round((df.bytes-sum(fs.bytes)) * 100 / df.bytes, 2) ts_pct_used,
--  round(sum(fs.bytes) / (1024 * 1024), 2) free_ts_size,
--  nvl(round(sum(fs.bytes) * 100 / df.bytes), 2) ts_pct_free
-- FROM (select tablespace_name, bytes_used bytes
--  from V$temp_space_header
--  group by tablespace_name, bytes_free, bytes_used) fs,
--  (select tablespace_name,
--  sum(bytes) bytes,
--  sum(decode(maxbytes, 0, bytes, maxbytes)) maxbytes,
--  max(autoextensible) autoextensible
--  from dba_temp_files
--  group by tablespace_name) df
-- WHERE fs.tablespace_name (+) = df.tablespace_name
-- GROUP BY df.tablespace_name, df.bytes, df.maxbytes
-- ORDER BY 1 DESC;

select
  df.tablespace_name "Tablespace",
  round(df.bytes / (1024 * 1024), 2) "Size MB",
  round(df.maxbytes / (1024 * 1024), 2) "Max extend MB",
  round((df.bytes - fs.bytes) / (1024 * 1024), 2) "Used MB",
  round(fs.bytes / (1024 * 1024), 2) "Avail MB",
  round((df.bytes-fs.bytes) * 100 / df.bytes, 2) "Use%",
  round((df.bytes - fs.bytes) / (df.maxbytes) * 100, 2) "Max use%",
  df.datafiles "Datafiles",
  fs.segments "Segments"
from
  (
    select
      tablespace_name,
      sum(bytes) bytes,
      sum(decode(autoextensible,'YES',maxbytes,bytes)) maxbytes,
      nvl(count(file_name), 0) datafiles
    from dba_data_files
    group by tablespace_name
  ) df,
  (
    select
      tablespace_name,
      sum(bytes) bytes,
      max(bytes) max_bytes,
      count(*) segments
    from dba_free_space
   group by tablespace_name
  ) fs
where df.tablespace_name = fs.tablespace_name (+)
ORDER BY "Max use%", "Use%", "Tablespace" DESC;

clear breaks;
clear computes;
clear columns;
