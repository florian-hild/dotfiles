--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 150
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col DRUCKAUFTRAGSNUMMER format 9999999999
col BEARBEITUNGSSTATUS  format 99
col MANDANT             format a10
col DRUCKERQUEUE        format a20
col DRUCKERNAME         format a20
col DRUCKART            format a8
col DRUCKAUFTRAGSTYP    format a16

select
    DRUCKAUFTRAGSNUMMER,
    BEARBEITUNGSSTATUS as Status,
    MANDANT,
    DRUCKERQUEUE,
    DRUCKERNAME,
    DRUCKART,
    DRUCKAUFTRAGSTYP,
    NEWDAT,
    MODDAT,
    TASKID
  from druckauftrag
  where BEARBEITUNGSSTATUS != '99'
  ORDER BY NEWDAT,BEARBEITUNGSSTATUS,MODDAT,DRUCKAUFTRAGSNUMMER ASC;
