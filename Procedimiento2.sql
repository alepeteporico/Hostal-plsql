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

--Clientes--

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

--Habitaciones--

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

--Final estancias--

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

--Importe Total Alojamiento--

create or replace function ImporteAlojamiento(p_codE estancias.codigo%type)
return number
is 
    v_alojamiento number := 0;
begin 
    select sum(preciopordia) into v_alojamiento from tarifas where codigoregimen = (select codigoregimen from estancias where codigo = p_codE);
    return v_alojamiento;
end;
/

--Final Alojamiento--

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

--Importe Total Gastos Extra--

create or replace function ImporteGastos (p_codE estancias.codigo%type)
return number
is 
    v_gastos number;
begin
    select sum(cuantia) into v_gastos from gastos_extras where codigoestancia = (select codigo from estancias where codigo = p_codE);
    return v_gastos;
end;
/

--Gastos Extra--

create or replace procedure GastosExtra (p_codE estancias.codigo%type)
is 
    cursor c_cursor is 
    select fecha, concepto, cuantia from gastos_extras where codigoestancia = (select codigo from estancias where codigo = p_codE);
begin
    dbms_output.put_line('Gastos Extra');
    dbms_output.put_line('----------------------------');
    for var in c_cursor loop 
        dbms_output.put_line(var.fecha||chr(9)||var.concepto||chr(9)||var.cuantia);
    end loop;
    dbms_output.put_line('Importe Total Gastos Extra: '||ImporteGastos(p_codE));
end;
/

--Comprobar Regimen TI--

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

--Final Importe Gastos Extra--

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

--Final Gastos Extra--

create or replace procedure FinalGastosExtra (p_codE estancias.codigo%type)
is
begin
    if TI(p_codE) != 'TI' then 
        GastosExtra(p_codE);
    elsif TI(p_codE) = 'TI' then
        dbms_output.put_line('');
    end if;
end;
/

-------------------------------------------------------------------------------

--Importe Actividades--

create or replace function ImporteActividades (p_codE estancias.codigo%type)
return number
is 
    v_activ number;
begin 
    select sum(precioporpersona * numpersonas) into v_activ from actividadesrealizadas, actividades where codigo = codigoactividad and codigoestancia = (select codigo from estancias where codigo = p_codE);
    return v_activ;
end;
/

--Actividades Realizadas--

create or replace procedure Actividades_Realizadas (p_codE estancias.codigo%type)
is 
    cursor c_cursor is 
    select fecha, numpersonas, nombre, (precioporpersona * numpersonas) as Suma from actividadesrealizadas, actividades where codigo = codigoactividad and codigoestancia = (select codigo from estancias where codigo = p_codE);
begin
    dbms_output.put_line('Actividades Realizadas');
    dbms_output.put_line('----------------------------');
    for var in c_cursor loop
        dbms_output.put_line(var.fecha||chr(9)||var.nombre||chr(9)||var.numpersonas||chr(9)||var.Suma);
    end loop;
    dbms_output.put_line('Importe Total Actividades Realizadas: '||ImporteActividades(p_codE));
end;
/


--Comprobar Regimen TI--

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

--Final Importe Actividades--

create or replace function FinalImporteActividades (p_codE estancias.codigo%type)
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

--Final Actividades Realizadas--

create or replace procedure FinalActividades_Realizadas (p_codE estancias.codigo%type)
is
begin
    if TI(p_codE) != 'TI' then 
        Actividades_Realizadas(p_codE);
    elsif TI(p_codE) = 'TI' then
        dbms_output.put_line('');
    end if;
end;
/

---------------------------------------------------------------------------------

--Importe Factura--

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

--Procedimiento Final--

create or replace procedure ImprimirFactura (p_codE estancias.codigo%type)
is
begin
    dbms_output.put_line('Complejo Rural La Fuente');
    dbms_output.put_line('Candelario (Salamanca)');
    dbms_output.put_line(chr(10));
    Estancia(p_codE);
    dbms_output.put_line(chr(10));
    Alojamiento(p_codE);
    dbms_output.put_line(chr(10));
    FinalGastosExtra(p_codE);
    dbms_output.put_line(chr(10));
    FinalActividades_Realizadas(p_codE);
    dbms_output.put_line(chr(10));
    ImporteFactura(p_codE);
end;
/
