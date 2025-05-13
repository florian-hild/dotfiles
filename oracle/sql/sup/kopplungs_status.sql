--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 07-05-2025
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

set echo off
set term on
set verify off
set feedback off
set heading on
set trimspool on
set wrap off
set serveroutput on size 1000000

col satzart format a7
col status format a6
col bearbeitungsstatus format a18
col kennung format a7

column spoolname new_value spoolname
SELECT '$HOME/kopplungs_status_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.lst' spoolname FROM dual;
spool &spoolname

prompt
prompt === KOPPLUNG ===
select
  count(*) AS "count",
  satzart,
  status,
  min(moddat) as "from",
  max(moddat) as "to"
from kopplung
group by satzart, status
order by status, satzart;

prompt
prompt === VSD_KOPPLUNG ===
select
  satzart,
  STATUS,
  min(moddat) as "from",
  max(moddat) as "to"
from vsd_kopplung
group by STATUS, satzart
order by STATUS, satzart;

prompt
prompt === VSD_TRANSFER ===
select
  kennung,
  bearbeitungsstatus,
  min(moddat) as "from",
  max(moddat) as "to"
from vsd_transfer
group by bearbeitungsstatus, kennung
order by bearbeitungsstatus, kennung;

prompt
prompt === HST_SEND ===
select
  count(*) AS "count",
  satzart,
  bearbeitungsstatus,
  min(moddat) as "from",
  max(moddat) as "to"
from hst_send
group by satzart, bearbeitungsstatus
order by bearbeitungsstatus, satzart;

prompt
prompt === HST_RECEIVE ===
select
  count(*) AS "count",
  satzart,
  bearbeitungsstatus,
  min(moddat) as "from",
  max(moddat) as "to"
from hst_receive
group by satzart, bearbeitungsstatus
order by bearbeitungsstatus, satzart;

prompt
prompt === DRUCKAUFTRAG ===
select
  count(*) AS "count",
  bearbeitungsstatus,
  min(moddat) as "from",
  max(moddat) as "to"
from druckauftrag
group by bearbeitungsstatus
order by bearbeitungsstatus;

spool off;
prompt Output written to: &spoolname
