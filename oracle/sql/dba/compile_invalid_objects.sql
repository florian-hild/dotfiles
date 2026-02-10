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

DECLARE
  v_object_type VARCHAR2(30);
  v_success_count INTEGER := 0;
  v_error_count INTEGER := 0;
BEGIN
  DBMS_OUTPUT.put_line('Starting compilation of invalid objects...');
  DBMS_OUTPUT.put_line(RPAD('-', 90, '-'));

  FOR cur_rec IN (
                  select object_type,OBJECT_NAME,status,OWNER
                    from all_objects
                    where status != 'VALID'
                    order by object_type,OBJECT_NAME,status,OWNER ASC
                 )
  LOOP
    BEGIN
      IF cur_rec.object_type = 'PACKAGE BODY' THEN
        v_object_type := 'PACKAGE';
      ELSE
        v_object_type := cur_rec.object_type;
      END IF;

      EXECUTE IMMEDIATE 'ALTER ' || v_object_type || ' "' || cur_rec.owner || '"."' || cur_rec.object_name || '" COMPILE';
      v_success_count := v_success_count + 1;
      DBMS_OUTPUT.put_line('[OK] ' || RPAD(cur_rec.object_type, 15) || ' | ' || cur_rec.owner || '.' || cur_rec.object_name);
    EXCEPTION
      WHEN OTHERS THEN
        v_error_count := v_error_count + 1;
        DBMS_OUTPUT.put_line('[ERROR] ' || RPAD(cur_rec.object_type, 12) || ' | ' || cur_rec.owner || '.' || cur_rec.object_name || ' | ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 50));
    END;
  END LOOP;

  DBMS_OUTPUT.put_line(RPAD('-', 90, '-'));
  DBMS_OUTPUT.put_line('Compilation Summary: ' || v_success_count || ' succeeded, ' || v_error_count || ' failed');
END;
/

select count(*) as "#", object_type
  from all_objects
  where status != 'VALID'
  group by object_type
  order by object_type;
