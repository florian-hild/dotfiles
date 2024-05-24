--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col DTA_NUMMER format 9999
col DRUCKERNAME format a25
col ARBEITSPLATZ format a25
col KOMMISSIONIERBEREICH format a15
col BELEGART format a15

SELECT DTA_NUMMER,DRUCKERNAME,ARBEITSPLATZ,KOMMISSIONIERBEREICH,BELEGART,MODDAT,USERID,TASKID
  FROM druckertabelle
  ORDER BY DTA_NUMMER,DRUCKERNAME,ARBEITSPLATZ;
