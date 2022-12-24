/* Procedimiento 8 */
/* Realiza los módulos de programación necesarios para que un cliente no pueda realizar dos estancias que se solapen en fechas entre ellas, esto es, un cliente no puede comenzar una estancia hasta que no haya terminado la anterior. */

CREATE OR REPLACE PACKAGE fechasolapada
as
TYPE tregistrofechas IS RECORD
(
	nifcliente estancias.nifcliente%TYPE,
	fecha_inicio estancias.fecha_inicio%TYPE,
	fecha_fin estancias.fecha_fin%TYPE
);
TYPE ttablafechas IS TABLE OF tregistrofechas
INDEX BY BINARY_INTEGER;
v_fechas ttablafechas;
end fechasolapada;
/

CREATE OR REPLACE TRIGGER rellenarfecha
  before insert or update on estancias
DECLARE
  cursor c_fechas is select nifcliente, fecha_inicio, fecha_fin from estancias;
  INDICE NUMBER:=0;
BEGIN
  FOR I IN c_fechas loop 
    fechasolapada.v_fechas(INDICE).nifcliente:=i.nifcliente;
    fechasolapada.v_fechas(INDICE).fecha_inicio:=i.fecha_inicio;
    fechasolapada.v_fechas(INDICE).fecha_fin:=i.fecha_fin;
    INDICE:=INDICE+1;
  end loop;
end rellenarfecha;
/

CREATE OR REPLACE TRIGGER comprobarfecha
before insert or update on estancias
for each row 
declare     
begin 
  for i in fechasolapada.v_fechas.FIRST..fechasolapada.v_fechas.LAST loop
    if fechasolapada.v_fechas(i).nifcliente = :new.nifcliente then
      if :new.fecha_inicio between fechasolapada.v_fechas(i).fecha_inicio and fechasolapada.v_fechas(i).fecha_fin then
        raise_application_error(-20000, 'No se pueden realizar dos estancias en una misma fecha');
      end if;
      if :new.fecha_fin between fechasolapada.v_fechas(i).fecha_inicio and fechasolapada.v_fechas(i).fecha_fin then
        raise_application_error(-20000, 'No se pueden realizar dos estancias en una misma fecha');
      end if;
    end if;
  end loop;
end;
/

-- COmprobaciones

insert into estancias
values ('08',to_date('24-02-2016 20:20','DD-MM-YYYY hh24:mi'),to_date('29-02-2016 20:20','DD-MM-YYYY hh24:mi'),'04','49130359J','49130359J','PC');


create table estancias2
(
	codigo varchar2(9),
	fecha_inicio date,
	fecha_fin date,
	numerohabitacion varchar2(9),
	nifresponsable varchar2(9),
	nifcliente varchar2(9),
	codigoregimen varchar2(9)
);


insert into estancias2
values ('08',to_date('12-02-2016 20:20','DD-MM-YYYY hh24:mi'),to_date('25-02-2016 20:20','DD-MM-YYYY hh24:mi'),'04','49130359J','49130359J','PC');


insert into estancias (select * from estancias2);















