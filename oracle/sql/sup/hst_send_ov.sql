set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col Anzahl format 999999
col Satzart format 999

SELECT count(*) "Anzahl",satzart "Satzart",min(moddat) "Von",max(moddat) "Bis"
  FROM hst_send
  GROUP BY satzart
  ORDER BY satzart;