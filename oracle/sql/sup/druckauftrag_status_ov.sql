--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set linesize 250

col Anzahl format 99999999
col Status format 99

select
    count(*) "Anzahl",
    BEARBEITUNGSSTATUS "Status"
  from druckauftrag
  GROUP BY BEARBEITUNGSSTATUS
  ORDER BY 1,BEARBEITUNGSSTATUS;
