set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col NAME format a10
col CURRENT_SCN format 9999999999999999999999
col LOG_MODE format a10

SELECT NAME,CURRENT_SCN,LOG_MODE,CREATED
  FROM v$database;
