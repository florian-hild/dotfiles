--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 0
set linesize 250

set feedback off
SET SERVEROUTPUT ON SIZE 1000000

declare
  startdate date;
  dateafter date;
  nextdate  date;

begin
  startdate := sysdate;
  dateafter := startdate;

  for i in 1..24 loop
    dbms_scheduler.evaluate_calendar_string( 'FREQ=MINUTELY; INTERVAL=30', startdate, dateafter, nextdate );
    dbms_output.put_line(to_char(nextdate,'YYYY-MM-DD HH24:MI'));
    dateafter := nextdate;
  end loop;
end;
/

-- Every 30min              = 'FREQ=MINUTELY; INTERVAL=30'
-- Every hour               = 'FREQ=hourly; BYMINUTE=0'
-- Every Monday             = 'FREQ=WEEKLY; BYDAY=MON'
-- Every Monday at 2:30 AM  = 'FREQ=WEEKLY; BYDAY=Mon; BYHOUR=2; BYMINUTE=30; BYSECOND=0'
-- Every weekday at 3:00 PM = 'FREQ=WEEKLY; BYDAY=MON,TUE,WED,THU,FRI; BYHOUR=15; BYMINUTE=0; BYSECOND=0'
