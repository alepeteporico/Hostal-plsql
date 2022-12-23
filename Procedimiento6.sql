/* Procedimiento 6 */

/* Realiza los módulos de programación necesarios para que una actividad no sea realizada en una fecha concreta por más de 10 personas.*/

CREATE OR REPLACE package nomasde10
as 
TYPE tregistroactividad IS RECORD
(
	codigoactividad Actividadesrealizadas.codigoactividad%TYPE,
	fecha DATE,
	numpersonas NUMBER
);
TYPE ttablaavtividad IS TABLE OF tregistroactividad
INDEX BY BINARY_INTEGER;
v_actividad ttablaavtividad;
end nomasde10;
/

create or replace trigger rellenartabla
before insert or update on actividadesrealizadas
declare 
    cursor c_actividades2
    is 
    select codigoactividad, sum(numpersonas) as numpersonas, fecha
    from actividades a, actividadesRealizadas ar
    where a.Codigo = ar.CodigoActividad
    group by Codigo, Fecha;
    i               number:=0;
    v_codigo        actividades.codigo%type;
    v_numpersonas   actividadesRealizadas.numpersonas%type;
    v_fecha         date;
begin
    open c_actividades2;
    fetch c_actividades2 into v_codigo,v_numpersonas,v_fecha;
    while c_actividades2%found loop
        nomasde10.v_actividad(i).codigoactividad:=v_codigo;
        nomasde10.v_actividad(i).numPersonas:=v_numpersonas;
        nomasde10.v_actividad(i).fecha:=v_fecha;
        i:=i + 1;
        fetch c_actividades2 into v_codigo,v_numpersonas,v_fecha;
    end loop;
    close c_actividades2;
end rellenartabla;
/

create or replace trigger comprobar10
before insert or update on ActividadesRealizadas
for each row 
declare     
begin 
    for i in nomasde10.v_actividad.FIRST..nomasde10.v_actividad.LAST loop
        if nomasde10.v_actividad(i).fecha = :new.fecha and nomasde10.v_actividad(i).NumPersonas < 10 and nomasde10.v_actividad(i).codigoactividad = :new.codigoactividad then
            raise_application_error(-20014,'No se puede realizar una actividad en una fecha concreta por más de 10 personas');
        end if;
    end loop;

    nomasde10.v_actividad(nomasde10.v_actividad.LAST+1).codigoactividad:=:new.codigoactividad;
    nomasde10.v_actividad(nomasde10.v_actividad.LAST).numpersonas:=:new.numpersonas;
    nomasde10.v_actividad(nomasde10.v_actividad.LAST).fecha:=:new.fecha;

end comprobar10;
/


-- Comprobaciones (IMPORTANTE TENER EL PAQUETE ACTUALIZADO, SI NO DARÁ ERROR)

create table actividadesrealizadas2 
(codigoestancia varchar2(2),
codigoactividad varchar2(4),
fecha date,
numpersonas number,
abonado number);

insert into actividadesrealizadas2 values ('07','A001',to_date('10-01-2016 16:15','DD-MM-YYYY hh24:mi'),4,60);

insert into actividadesrealizadas2 values ('07','A001',to_date('10-01-2016 16:15','DD-MM-YYYY hh24:mi'),15,60);


insert into actividadesrealizadas (select * from actividadesrealizadas2);




