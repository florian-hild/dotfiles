--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col OWNER format a25;
col OBJECT_NAME format a35
col OBJECT_TYPE format a20

select count(*) as "#", object_type
  from all_objects
  where status != 'VALID'
  group by object_type
  order by object_type;

SET SERVEROUTPUT ON SIZE 1000000

alter session set "_fix_control" = '8528517:off';
alter session set "_fix_control" = '7534027:off';

BEGIN
  FOR cur_rec IN (
                  select object_type,OBJECT_NAME,status,OWNER
                    from all_objects
                    where status != 'VALID'
                    order by object_type,OBJECT_NAME,status,OWNER ASC
                 )
  LOOP
    BEGIN
      EXECUTE IMMEDIATE 'ALTER ' || cur_rec.object_type || ' "' || cur_rec.owner || '"."' || cur_rec.object_name || '" COMPILE';
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(cur_rec.object_type || ' : ' || cur_rec.owner || ' : ' || cur_rec.object_name);
    END;
  END LOOP;
END;
/

select count(*) as "#", object_type
  from all_objects
  where status != 'VALID'
  group by object_type
  order by object_type;
