/* Procedimiento 2 */

/* 2. Realiza un procedimiento llamado ImprimirFactura que reciba un código de estancia e imprima la factura vinculada a la misma. Debes tener en cuenta que la factura tendrá el siguiente formato:
Complejo Rural La Fuente Candelario (Salamanca)

Código Estancia: xxxxxxxx
Cliente: NombreCliente ApellidosCliente
Número Habitación: nnn Fecha Inicio: nn/nn/n.nnn Fecha Salida: nn/nn/nnnn
Régimen de Alojamiento: NombreRegimen

Alojamiento
Temporada1 NumDías1 Importe1
...
TemporadaN NumDíasN ImporteN
Importe Total Alojamiento: n.nnn,nn

Gastos Extra
Fecha1 Concepto1 Cuantía1
....
FechaN ConceptoN CuantíaN
Importe Total Gastos Extra: n.nnn,nn

Actividades Realizadas
Fecha1 NombreActividad1 NumPersonas1 Importe1
...
FechaN NombreActividadN NumPersonasN ImporteN
Importe Total Actividades Realizadas: n.nnn
Importe Factura: nn.nnn,nn

Notas: Si la estancia se ha hecho en régimen de Todo Incluido no se imprimirán los apartados de Gastos Extra o Actividades Realizadas. Del mismo modo, si en la estancia no se ha efectuado ninguna Actividad o Gasto Extra, no aparecerán en la factura.

Si una Actividad ha sido abonada in situ tampoco aparecerá en la factura.

Debes tener cuidado de facturar bien las estancias que abarcan varias temporadas.*/


---Procedimiento que imprime el nombre del cliente y su apellido ingresando el codigo de la estancia
create or replace procedure Cliente (p_codE estancias.codigo%type)
is 
    cursor c_cursor is 
    select nombre, apellidos from personas where nif = (select nifcliente from estancias where codigo = p_codE);
begin 
    for var in c_cursor loop 
        dbms_output.put_line('Cliente: '||var.nombre||var.apellidos);
    end loop;
end;
/

---Procedimiento que muestra el numero de habitacion, la fecha de inicio y la fecha de salida de la estancia ingresando el codigo de la estancia
create or replace procedure Habitacion (p_codE estancias.codigo%type)
is
    cursor c_cursor is 
    select numerohabitacion, fecha_inicio, fecha_fin from estancias where codigo = p_codE;
begin 
    for var in c_cursor loop 
        dbms_output.put_line('Numero Habitacion: '||var.numerohabitacion||' Fecha Inicio: '||var.fecha_inicio||' Fecha Salida: '||var.fecha_fin);
    end loop;
end;
/

---Procedimiento que muestra el código de la estancia y el tipo de régimen de alojamiento ingresando el codigo de la estancia
create or replace procedure Estancia (p_codE estancias.codigo%type)
is 
    cursor c_cursor is 
    select nombre from regimenes where codigo = (select codigoregimen from estancias where codigo = p_codE);
begin
    for var in c_cursor loop 
        dbms_output.put_line('Codigo Estancia: '||p_codE);
        Cliente(p_codE);
        Habitacion(p_codE);
        dbms_output.put_line('Regimen de Alojamiento: '||var.nombre);
    end loop;
end;
/

--------------------------------------------------------------------------------

---Función que calcula el importe total de del alojamiento ingresando el codigo de la estancia
create or replace function ImporteAlojamiento(p_codE estancias.codigo%type)
return number
is 
    v_alojamiento number := 0;
begin 
    select sum(preciopordia) into v_alojamiento from tarifas where codigoregimen = (select codigoregimen from estancias where codigo = p_codE);
    return v_alojamiento;
end;
/

---Procedimiento que muestrea el importe total del alojamiento ingresando el código de la estancia
create or replace procedure Alojamiento (p_codE estancias.codigo%type)
is 
    cursor c_cursor is 
    select nombre, fecha_fin - fecha_inicio as dias, preciopordia  from temporadas, tarifas where codigoregimen = (select codigoregimen from estancias where codigo = p_codE);
begin
    dbms_output.put_line('Alojamiento');
    dbms_output.put_line('----------------------------');
    for var in c_cursor loop
        dbms_output.put_line(var.nombre||chr(9)||var.dias||chr(9)||var.preciopordia);
    end loop;
    dbms_output.put_line('Importe Total Alojamiento: '||ImporteAlojamiento(p_codE));
end;
/

--------------------------------------------------------------------------

---Función que realiza el cálculo del importe de los gastos extras
create or replace function ImporteGastos (p_codE estancias.codigo%type)
return number
is 
    v_gastos number;
begin
    select sum(cuantia) into v_gastos from gastos_extras where codigoestancia = (select codigo from estancias where codigo = p_codE);
    return v_gastos;
end;
/


---Procedimiento que muestra la fecha, el concepto y la cuantía de los gastos extras que ha realizado el cliente ingresando el código de la estancia. Tambien muestra el importe total de los gastos extras.
create or replace procedure GastosExtra (p_codE estancias.codigo%type)
is 
    cursor c_cursor is 
    select fecha, concepto, cuantia from gastos_extras where codigoestancia = (select codigo from estancias where codigo = p_codE);
begin
    for var in c_cursor loop 
        dbms_output.put_line(var.fecha||chr(9)||var.concepto||chr(9)||var.cuantia);
    end loop;
    dbms_output.put_line('Importe Total Gastos Extra: '||ImporteGastos(p_codE));
end;
/

---Procedimiento que verifica que, introduciendo el codigo de la estancia, esta se haya hecho en régimen de todo incluido.
create or replace function TI (p_codE estancias.codigo%type)
return varchar2
is 
    v_cod regimenes.codigo%type;
begin
    select codigo into v_cod from regimenes where codigo = (select codigoregimen from estancias where codigo = p_codE);
    if v_cod = 'TI' then
        return v_cod;
    elsif v_cod != 'TI' then
        return v_cod;
    end if;
end;
/

---Procedimiento que calcula el Importe total de la estancia, teniendo en cuenta si la misma se ha realizado en régimen de todo incluido o no.
create or replace function FinalImporteGastos (p_codE estancias.codigo%type)
return number
is
    var number;
begin
    if TI(p_codE) != 'TI' then 
        var := ImporteGastos(p_codE);
        return var;
    elsif TI(p_codE) = 'TI' then
        var := ImporteGastos(p_codE);
        var := 0;
        return var;
    end if;
end;
/

--- Procedimiento que muestra el precio final de los gastos extras en caso de que la estancia no se haya realizado en régimen de todo incluido. En caso de que la estancia se haya realizado en régimen de todo incluido, no muestra nada.
create or replace procedure GastosExtra_2 (p_codE estancias.codigo%type)
is
begin
    if TI(p_codE) != 'TI' then 
        GastosExtra(p_codE);
    elsif TI(p_codE) = 'TI' then
        dbms_output.put_line('');
    end if;
end;
/

create or replace procedure FinalGastosExtra(p_codE estancias.codigo%type)
is 
begin
    dbms_output.put_line('Gastos Extra');
    dbms_output.put_line('----------------------------');
    GastosExtra_2(p_codE);
end;
/

-------------------------------------------------------------------------------

---Procedimiento que calcula el importe de las actividades teniendo en cuenta el importe por persona y el número por persona que hay realizado la actividad, introduciendo el código de la estancia.
create or replace function ImporteActividades(p_codE estancias.codigo%type)
return number
is 
    v_activ number;
begin 
    select sum(precioporpersona * numpersonas) into v_activ from actividadesrealizadas, actividades where codigo = codigoactividad and codigoestancia = (select codigo from estancias where codigo = p_codE);
    return v_activ;
end;
/


---Procedimiento que muestra las actividades realizadas por el cliente, junto con la fecha, el nombre de la actividad, el número de personas que han realizado la actividad y el importe de la actividad. Tambien muestra el importe total de las actividades realizadas.
create or replace procedure Actividades_Realizadas(p_codE estancias.codigo%type)
is 
    cursor c_cursor is 
    select fecha, numpersonas, nombre, (precioporpersona * numpersonas) as Suma from actividadesrealizadas, actividades where codigo = codigoactividad and codigoestancia = (select codigo from estancias where codigo = p_codE);
begin
    for var in c_cursor loop
        if to_date(sysdate, 'DD-MM-YYYY hh24:mi') != var.fecha then
            dbms_output.put_line(var.fecha||chr(9)||var.nombre||chr(9)||var.numpersonas||chr(9)||var.Suma);
        end if;
    end loop;
    dbms_output.put_line('Importe Total Actividades Realizadas: '||ImporteActividades(p_codE));
end;
/



------Procedimiento que verifica que, introduciendo el codigo de la estancia, esta se haya hecho en régimen de todo incluido.
create or replace function TI(p_codE estancias.codigo%type)
return varchar2
is 
    v_cod regimenes.codigo%type;
begin
    select codigo into v_cod from regimenes where codigo = (select codigoregimen from estancias where codigo = p_codE);
    if v_cod = 'TI' then
        return v_cod;
    elsif v_cod != 'TI' then
        return v_cod;
    end if;
end;
/


---Procedimiento que, verificando si la estancia se ha realizado o no en régimen de todo incluido, calcula el importe total de las actividades realizadas. Para ello se debe ingresar el codigo de la estancia.
create or replace function FinalImporteActividades(p_codE estancias.codigo%type)
return number
is
    var number;
begin
    if TI(p_codE) != 'TI' then 
        var := ImporteActividades(p_codE);
        return var;
    elsif TI(p_codE) = 'TI' then
        var := ImporteActividades(p_codE);
        var := 0;
        return var;
    end if;
end;
/


---Procedimiento que, verificando que el codigo de estancia ingresado haya o no realizado la misma en régimen de todo incluido, muestra el procedimiento de actividades realizadas. En caso de que la estancia se haya realizado en régimen de todo incluido, no muestra nada.
create or replace procedure Actividades_Realizadas_2(p_codE estancias.codigo%type)
is
begin
    if TI(p_codE) != 'TI' then 
        Actividades_Realizadas(p_codE);
    elsif TI(p_codE) = 'TI' then
        dbms_output.put_line('');
    end if;
end;
/

create or replace procedure FinalActividadesR(p_codE estancias.codigo%type)
is 
begin
    dbms_output.put_line('Actividades Realizadas');
    dbms_output.put_line('----------------------------');
    Actividades_Realizadas_2(p_codE);
end;
/

---------------------------------------------------------------------------------

---Procedimiento que calcule el importe total de la factura ingresando el codigo de la estancia.Para ello necesitaremos llamar a los procedimientos:
---ImporteAlojamiento
---FinalImporteGastos
---FinalImporteActividades

create or replace procedure ImporteFactura(p_codE estancias.codigo%type)
is
    v_alojamiento number;
    v_gastos number;
    v_activ number;
    v_total number;
begin
    v_alojamiento := ImporteAlojamiento(p_codE);
    v_gastos := FinalImporteGastos(p_codE);
    v_activ := FinalImporteActividades(p_codE);
    v_total := v_alojamiento + v_gastos + v_activ;
    dbms_output.put_line('Importe Factura: '||v_total);
end;
/

---------------------------------------------------------------------------------

---Procedimiento que imprime la factura del cliente, introduciendo el codigo de la estancia. Para ello necesitaremos llamar a los procedimientos:
---Estancia
---Alojamiento
---FinalGastosExtra
---FinalActividades_Realizadas
---ImporteFactura

---El procedimiento imprime por pantalla el nombre del complejo, la localidad y el codigo de la estancia. Luego imprime por pantalla los datos de la estancia, los datos del alojamiento, los gastos extra, las actividades realizadas y el importe total de la factura.

create or replace procedure ImprimirProcedures (p_codE estancias.codigo%type)
is
begin
    Estancia(p_codE);
    dbms_output.put_line(chr(10));
    Alojamiento(p_codE);
    dbms_output.put_line(chr(10));
    FinalGastosExtra(p_codE);
    dbms_output.put_line(chr(10));
    FinalActividadesR(p_codE);
end;
/

create or replace procedure ImprimirFactura(p_codE estancias.codigo%type)
is 
begin
    dbms_output.put_line('Complejo Rural La Fuente');
    dbms_output.put_line('Candelario (Salamanca)');
    dbms_output.put_line(chr(10));
    ImprimirProcedures(p_codE);
    dbms_output.put_line(chr(10));
    ImporteFactura(p_codE);
end;
/

---------------------------------------------------------------------------------

--Si la estancia se ha hecho en régimen de Todo Incluido no se imprimirán los apartados de Gastos Extra o Actividades Realizadas.

exec ImprimirFactura('04');

--Si una Actividad ha sido abonada in situ tampoco aparecerá en la factura.

insert into actividadesrealizadas values ('07','A032', to_date(sysdate, 'DD-MM-YYYY hh24:mi'), 6,'S');

exec ImprimirFactura('07');
