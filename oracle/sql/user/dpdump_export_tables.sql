--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 0
set linesize 250
col table_name format a50

SELECT table_name,NUM_ROWS
  FROM user_tables
  WHERE table_name not like '%\_H' ESCAPE '\'
  AND not table_name like 'TMP\_%' escape '\'
  AND not table_name like 'TEMP\_%' escape '\'
  AND not table_name like '%\_TMP' escape '\'
  AND not table_name like '%\_TEMP' escape '\'
  AND not table_name like '%STATISTIK' escape '\'
  AND not table_name = 'NF_STATISTIK'
  AND not table_name = 'NF_EREIGNIS'
  AND not table_name = 'LAGERSACHNUMMERNSTAMM'
  AND not table_name = 'SACHNUMMERNSTAMM'
  AND not table_name = 'BESTANDSBEWEGUNG'
  AND not table_name = 'BESTANDSSTATISTIK'
  AND not table_name = 'PACKSTUECKSTATISTIK'
  AND not table_name = 'SERIENNUMMER'
  AND not table_name = 'LAGERBEREICHSBESTAND'
  AND not table_name = 'ANSICHTSFILTER'
  AND not table_name = 'KAPAZITAETSBEDARF'
  AND not table_name = 'LAGERPLATZ'
  AND not table_name = 'VORGANGSPROTOKOLL'
  AND not table_name = 'HST_SEND'
  AND not table_name = 'HST_RECEIVE'
  AND not table_name = 'BESTELLUNG'
  ORDER BY num_rows,table_name;
