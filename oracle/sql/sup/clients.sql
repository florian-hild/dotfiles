set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col HOSTNAME format a30
col ARBEITSPLATZ format a25
col TYP format a3

SELECT HOSTNAME,ARBEITSPLATZ,GERAETE_TYP as "Typ",MODDAT,USERID,TASKID
  FROM clients
  ORDER BY HOSTNAME,ARBEITSPLATZ,GERAETE_TYP;