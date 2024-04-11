set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col Anzahl format 999999
col Satzart format 999

SELECT count(NEWDAT) as "Anzahl",satzart "Satzart", to_char(NEWDAT, 'YYYY-MM-DD') as "Datum"
  FROM hst_send
  GROUP BY to_char(NEWDAT, 'YYYY-MM-DD'),satzart
  ORDER BY 3 ASC;
