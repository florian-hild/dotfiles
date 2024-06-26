--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
set pagesize 100
set linesize 250

col LE_NUMMER               format 99999999999
col LE_TYP                  format a4
col TRANSPORTSTATUS         format 99
col TRANSPORTAUFTRAGSNUMMER format 99999999999
col AUFTRAGSNUMMER          format 99999999999
col TRANSPORTKENNZEICHEN    format a2
col AKTUELLER_LAGERBEREICH  format a6
col ZIEL_LAGERBEREICH       format a6
col FEHLERNUMMER            format a4
col TASKID                  format a10

SELECT LE_NUMMER,LE_TYP,TRANSPORTSTATUS,TRANSPORTAUFTRAGSNUMMER,AUFTRAGSNUMMER,TRANSPORTKENNZEICHEN,AKTUELLER_LAGERBEREICH,ZIEL_LAGERBEREICH,FEHLERNUMMER,NEWDAT,TASKID
  FROM transportauftrag
  ORDER BY NEWDAT;
