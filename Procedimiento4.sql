/* Procedimiento 4 */

/* Añade un campo email a los clientes y rellénalo para algunos de ellos. Realiza un trigger que cuando se rellene el campo Fecha de la Factura envíe por correo electrónico un resumen de la factura al cliente, incluyendo los datos fundamentales de la estancia, el importe de cada apartado y el importe total. */


---Añadimos la columna email a la tabla personas---
ALTER TABLE personas ADD email VARCHAR2(60);

---Rellenamos algunos clientes con email---

UPDATE personas set email = 'alvaro.rodriguez@gmail.com' where nif='54890865P';
UPDATE personas set email = 'aitor.leon@gmail.com' where nif='40687067K';
UPDATE personas set email = 'virginia.leon@gmail.com' where nif='77399071T';
UPDATE personas set email = 'antonio.fernandez@gmail.com' where nif='69191424H';
UPDATE personas set email = 'antonio.melandez@gmail.com' where nif='36059752F';
UPDATE personas set email = 'carlos.mejias@gmail.com' where nif='10402498N';
UPDATE personas set email = 'ana.gutierrez@gmail.com' where nif='10950967T';
UPDATE personas set email = 'adrian.garcia@gmail.com' where nif='88095695Z';
UPDATE personas set email = 'juan.romero@gmail.com' where nif='95327640T';
UPDATE personas set email = 'francisco.franco@gmail.com' where nif='06852683V';


---Procedimiento que muestre los datos de la estancia

CREATE OR REPLACE PROCEDURE MostrarDatosEstancia(p_codE estancias.codigo%type)
IS
BEGIN
    Estancia (p_codE);
    Alojamiento (p_codE);
    Actividades_Realizadas (p_codE);
    GastosExtras (p_codE);
    ImporteFactura (p_codE);
END;
/


---Trigger que envía un correo electrónico cuando se rellena la fecha de la factura---

CREATE OR REPLACE TRIGGER CorreoFactura
AFTER INSERT OR UPDATE ON facturas.fecha
FOR EACH ROW
DECLARE
    CURSOR c_correo IS
        SELECT email
        FROM personas
        WHERE nif = (SELECT nifcliente
                        FROM estancias
                        WHERE fecha = :new.fecha);
BEGIN
    UTL_MAIL.SEND (
    sender => 'mariajesus.allozarodriguez@gmail.com',
    recipients => personas.email,
    subject => 'Factura Complejo Rural La Fuente',
    message => MostrarDatosEstancia,
    mime_type => 'text/plain', charset => 'utf-8',
    );
END;
/
     
    
        

















































create or replace procedure Enviar(p_envia varchar2, p_recibe varchar2, p_asunto varchar2, p_cuerpo varchar2, p_host varchar2)
is 
    v_mailhost varchar2(80) := ltrim(rtrim(p_host)); 
    v_mail_conn utl_smtp.connection;
    v_crlf varchar2(2):= chr(13) || chr(10); 
    v_mesg varchar2(1000); 
begin 
    v_mail_conn := utl_smtp.open_connection(mailhost, 25); 
    v_mesg:= 'Date: ' || TO_CHAR( sysdate, 'dd Mon yy hh24:mi:ss' ) || v_crlf || 'From:  <'||p_envia||'>' || v_crlf || 'Subject: '||p_asunto || v_crlf || 'To: '||p_recibe || v_crlf || '' || v_crlf || p_cuerpo; 
 
    utl_smtp.helo(v_mail_conn, v_mailhost); 
    utl_smtp.mail(v_mail_conn, p_envia);  
    utl_smtp.rcpt(v_mail_conn, p_recibe); 
    utl_smtp.data(v_mail_conn, v_mesg);   
    utl_smtp.quit(v_mail_conn);         
end; 
/

create or replace function DevolverEmail (p_codE facturas.codigoestancia%type)
return personas.email%type
is
    v_email personas.email%type;
begin
    select email into v_email
      from personas
      where nif=(select nifcliente
                   from estancias
                   where codigo = p_codE);
    return v_email;
exception
    when no_data_found then
      return '-1';
end;
/

--Rellenar Datos--

create or replace function ObtenerPrecioPorDia (p_codTemp temporadas.codigo%type, p_codReg estancias.codigoregimen%type, p_codTipoHab habitaciones.codigotipo%type)
return number
is
    v_cuantia tarifas.preciopordia%type;
begin
    select preciopordia into v_cuantia
      from tarifas
      where codigotipohabitacion = p_codTipoHab and codigoregimen = p_codReg and codigotemporada = p_codTemp;
    return v_cuantia;
end;
/

create or replace function ObtenerTemporada (p_fecha estancias.fecha_inicio%type)
return temporadas.codigo%type
is
    cursor c_cursor is
    select fecha_inicio, fecha_fin, codigo
    from temporadas;
    
    var c_cursor%rowtype;
begin
    for var in c_cursor loop
      if p_fecha between var.fecha_inicio and var.fecha_fin then
        return var.codigo;
      end if;
    end loop;
end;
/

create or replace function ObtenerNumeroDias(p_fechaInicio estancias.fecha_inicio%type, p_fechaFin estancias.fecha_fin%type)
return number
is
    v_dias number;
begin
    v_dias := trunc(p_fechaFin - p_fechaInicio);
    return v_dias;
end;
/

create or replace procedure RellenarDatosEstancia(p_codE estancias.codigo%type, p_fechaInicio estancias.fecha_inicio%type, p_fechaFin estancias.fecha_fin%type, p_codReg estancias.codigoregimen%type, p_codTipoHab habitaciones.codigotipo%type)
is
    v_dias number;
    v_codTemp temporadas.codigo%type;
    v_precioPorDia tarifas.preciopordia%type;
begin
    v_dias := ObtenerNumeroDias(p_fechaInicio, p_fechaFin);
    for i in 1..v_dias loop
      v_codTemp:=ObtenerTemporada(p_fechaFin+i);
      v_precioPorDia:=ObtenerPrecioPorDia(v_codTemp, p_codReg, p_codTipoHab);
      CrearFilaPaqueteFactura('Dia '||i, v_precioPorDia);
    end loop;
end;
/

--Rellernar Gastos Extra--

create or replace procedure RellenarGastosExtras (p_codE estancias.codigo%type)
is
    cursor c_cursor
	select concepto, cuantia
	from gastos_extras
	where codigoestancia = p_codE;

    var c_cursor%rowtype;
begin
    for var in c_cursor loop
      CrearFilaPaqueteFactura(var.concepto, var.cuantia);
    end loop;
end;
/

--Rellernar Actividades--

create or replace procedure RellenarActividades(p_codEst estancias.CODIGO%type)
is
    cursor c_cursor
	select precioporpersona, nombre, numpersonas
    from actividades, actividadesrealizadas
	where codigoestancia = p_codEst and codigoactividad = codigo and abonado = 'N';

    var c_cursor%rowtype;
    v_coste number(6,2);
begin
    for var in c_cursor loop
      v_coste:=var.precioporpersona * var.numpersonas;
      CrearFilaPaqueteFactura(var.nombre, v_coste);
    end loop;
end;
/

--Informacion--

create or replace procedure CrearFilaFactura(p_concepto varchar2, p_cuantia number)
is
begin
    PkgFactura.v_TabFactura(PkgFactura.v_TabFactura.last+1).concepto:=p_concepto;
    PkgFactura.v_TabFactura(PkgFactura.v_TabFactura.last).cuantia:=p_cuantia;
exception
    when value_error then
      PkgFactura.v_TabFactura(1).CONCEPTO:=p_concepto;
      PkgFactura.v_TabFactura(1).CUANTIA:=p_cuantia;
end;
/


--Procedimiento Final--

create or replace procedure RellenarFactura(p_codE estancias.codigo%type, p_fechaInicio estancias.fecha_inicio%type, p_fechaFin estancias.fecha_fin%type, p_codReg estancias.codigoregimen%type, p_codTipoHab habitaciones.codigotipo%type)
is
begin
    RellenarDatosEstancia(p_codE, p_fechaInicio, p_fechaFin, p_codReg, p_codTipoHab);
    RellenarGastosExtras(p_codE);
    RellenarActividades(p_codE);
end;
/

alter table Clientes add email varchar2(30);
update personas set email='oscarlucasleo124@gmail.com' where nif='10402498N';

create or replace trigger CorreoCliente
after insert or update of valor on puntuaciones
for each row
declare
begin
	if :new.valor<5 then
		EnviarCorreoInvestigador(:new.nif_cat, :new.COD_ASP, :new.COD_VERS, :new.COD_EXP);
	end if;
end CorreoInvestigadorPuntuacion;
/

--Mandar Correo--

create or replace procedure MandarCorreo(p_nif personas.nif%type, p_nombre personas.nombre%type, p_APELLIDOS personas.apellidos%type, p_FECHAINICIO estancias.fecha_inicio%type, p_FECHAFIN estancias.fecha_fin%type, p_correo personas.email%type)
is
    v_cont number(6,2):=0;
    v_cuerpomedio varchar2(500);
    v_cuerpo varchar2(1000);
begin
    for i in PkgFactura.v_TabFactura.FIRST .. PkgFactura.v_TabFactura.LAST loop
      v_cuerpo:=(v_cuerpo||PkgFactura.v_TabFactura(i).concepto||'  -	'||PkgFactura.v_TabFactura(i).cuantia||chr(10));
      v_cont:=v_cont+PkgFactura.v_TabFactura(i).cuantia;
    end loop;
    Enviar('oracle@servidororacle', p_correo, 'Hotel Rural', 'Estimado cliente '||p_nombre ||' '||p_apellidos||chr(10)||'Su factura para la estancia en Hotel Rural durante los dias '||p_fechainicio||' '||p_fechafin||' ya está disponible.'||chr(10)||v_cuerpo||'Total: '||v_cont||chr(10)||'Atentamente, la empresa'||chr(10)||sysdate, 'olucas.gonzalonazareno.org');
end;
/

--Trigger--

create or replace trigger EnviarCorreoCliente
after insert or update of fecha on facturas
for each row
declare
    v_correo personas.email%type;
    select p.nif as v_nif, p.nombre as v_nombre, p.apellidos as v_apellidos, e.fecha_inicio as v_fechaInicio, e.fecha_fin as v_fechaFin, e.codigoregimen as v_codReg, h.codigotipo as v_tipoHab
    from personas p, estancias e, habitaciones h
    where e.codigo=:new.codigoestancia and e.numerohabitacion=h.NUMERO and p.nif=e.nifcliente;
begin
    v_correo:=DevolverEmail(:new.codigoestancia);
    if v_correo!='-1' then
      RellenarPaqueteFactura(:new.codigoestancia, v_fechaInicio, v_fechaFin, v_codReg, v_tipoHab);
      MandarCorreo(v_nif, v_nombre, v_apellidos, v_fechaInicio, v_fechaFin, v_correo);
    end if;
end;
/
