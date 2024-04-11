set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

select KOPPL_NUMMER,STATUS,SATZART,LE_NUMMER,LHM_NUMMER,LBE_NUMMER,SACHNUMMER,MODDAT,TASKID
  FROM kopplung
  WHERE NEWDAT >= trunc(sysdate)
  ORDER BY NEWDAT ASC;
