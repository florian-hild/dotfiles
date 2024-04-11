set pagesize 2000
set linesize 250

select count(*) as Anzahl, DRUCKART, BELEGART, MANDANT, DRUCKERQUEUE
  from druckauftrag
  where BEARBEITUNGSSTATUS = '00'
  group by DRUCKART, BELEGART, MANDANT, DRUCKERQUEUE
  order by Anzahl DESC;
