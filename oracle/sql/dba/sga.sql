set pagesize 2000
set linesize 250

col NAME format a30
col TYPE format a15
col VALUE format a10
show parameter sga

SELECT
  round(tot.bytes /1024/1024 ,2) total_mb,
  round(used.bytes /1024/1024 ,2) used_mb,
  round(free.bytes /1024/1024 ,2) free_mb
FROM (SELECT sum(bytes) bytes
FROM v$sgastat
WHERE
  name != 'free memory') used,
  (select sum(bytes) bytes
FROM v$sgastat
WHERE
  name = 'free memory') free,
  (SELECT sum(bytes) bytes
FROM v$sgastat) tot;
