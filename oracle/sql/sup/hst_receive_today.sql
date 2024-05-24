--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

SELECT TRANSAKTIONSNUMMER,BEARBEITUNGSSTATUS,SATZART,NEWDAT,USERID,TASKID
  FROM hst_receive
  WHERE NEWDAT >= trunc(sysdate)
  ORDER BY NEWDAT,TRANSAKTIONSNUMMER,BEARBEITUNGSSTATUS ASC;

SELECT count(NEWDAT) as "Anzahl",BEARBEITUNGSSTATUS "Status", to_char(NEWDAT, 'YYYY-MM-DD') as "Datum"
  FROM hst_receive
  WHERE NEWDAT >= trunc(sysdate)
  AND BEARBEITUNGSSTATUS != 99
  GROUP BY to_char(NEWDAT, 'YYYY-MM-DD'),BEARBEITUNGSSTATUS
  ORDER BY 3 ASC;