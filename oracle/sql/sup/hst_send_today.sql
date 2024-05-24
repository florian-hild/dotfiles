--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

select TRANSAKTIONSNUMMER,BEARBEITUNGSSTATUS,SATZART,NEWDAT,USERID,TASKID
  FROM hst_send
  WHERE NEWDAT >= trunc(sysdate)
  ORDER BY NEWDAT,TRANSAKTIONSNUMMER,BEARBEITUNGSSTATUS ASC;
