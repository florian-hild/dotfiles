alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
set pagesize 100
set linesize 250

col PARAMETER             format a40
col WERT                  format a35
col PARAMETERBESCHREIBUNG format a80
col KUNDENBEZUG format a2

SELECT PARAMETER,WERT,PARAMETERBESCHREIBUNG,KUNDENBEZUG,MODDAT,USERID,TASKID
  FROM parameter
  ORDER BY MODDAT,PARAMETER;
