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


---Función para obtener el importa total de los gastos extra
--Para ello llamamos ala función ImporteGastos ya realizada con anterioridad
create or replace function ImporteGastos (p_codE estancias.codigo%type)
return number
is 
    v_gastos number;
begin
    select sum(cuantia) into v_gastos from gastos_extra where codigoestancia = (select codigo from estancias where codigo = p_codE);
    return v_gastos;
end;
/

---Función para obtener el precio total de la estancia
--Para ello llamamos a la función ImporteAlojamiento ya realizada con anterioridad
create or replace function ImporteAlojamiento(p_codE estancias.codigo%type)
return number
is 
    v_alojamiento number := 0;
begin 
    select sum(preciopordia) into v_alojamiento from tarifas where codigoregimen = (select codigoregimen from estancias where codigo = p_codE);
    return v_alojamiento;
end;
/

---Función para imprimir el importe de las actividades realizadas
--Para ello llamamos a la función ImporteActividades ya realizada con anterioridad
create or replace function ImporteActividades(p_codE estancias.codigo%type)
return number
is 
    v_activ number;
begin 
    select sum(precioporpersona * numpersonas) into v_activ from actividadesrealizadas, actividades where codigo = codigoactividad and codigoestancia = (select codigo from estancias where codigo = p_codE);
    return v_activ;
end;
/

SELECT ImporteActividades('08') FROM DUAL;

---Procedimiento que muestra el email del cliente ingresando su código de estancia
CREATE OR REPLACE FUNCTION EmailCliente (p_codE estancias.codigo%type)
return personas.email%type
IS
    p_email personas.email%type;
BEGIN
    SELECT email INTO p_email
    FROM personas 
    WHERE nif = (SELECT nifcliente FROM estancias WHERE codigo = p_codE);
    RETURN p_email;
END;
/

SELECT EmailCliente('08') FROM DUAL;

---Función que obtenga la última fecha insertada en la tabla facturas---
CREATE OR REPLACE FUNCTION FechaFinEstancia (p_codE estancias.codigo%type)
RETURN DATE
IS
    p_fecha_fin estancias.fecha_fin%type;
BEGIN
    SELECT fecha_fin INTO p_fecha_fin
    FROM estancias
    WHERE codigo = p_codE;
    RETURN p_fecha_fin;
END;
/

SELECT FechaFinEstancia('08') FROM DUAL;

---Función que devuelva el nombre y los apellidos de los cliente en una sola variable---
CREATE OR REPLACE FUNCTION NombreCliente (p_codE estancias.codigo%type)
RETURN VARCHAR2
IS
    p_nombre VARCHAR2(70);
BEGIN
    SELECT nombre || ' ' || apellidos INTO p_nombre
    FROM personas
    WHERE nif = (SELECT nifcliente FROM estancias WHERE codigo = p_codE);
    RETURN p_nombre;
END;
/

SELECT NombreCliente('08') FROM DUAL;

---Crea un trigger para enviar un correo electrónico cuando se rellena la fecha de la factura. El correo electrónico contendrá el resumen de la factura---

CREATE OR REPLACE TRIGGER CorreoFactura
AFTER INSERT OR UPDATE ON facturas
FOR EACH ROW
DECLARE
    ---Declaración de variables---
    p_nombre VARCHAR2(70);
    p_email personas.email%type;
    p_codE estancias.codigo%type;
    p_fecha_fin estancias.fecha_fin%type;
    v_gastos number;
    v_alojamiento number;
    v_activ number;
    v_total number;
BEGIN
    ---Asignación de variables---
    p_fecha_fin := FechaFinEstancia(:new.codigoestancia);
    p_email := EmailCliente(:new.codigoestancia);
    v_gastos := ImporteGastos(:new.codigoestancia);
    v_alojamiento := ImporteAlojamiento(:new.codigoestancia);
    v_activ := ImporteActividades(:new.codigoestancia);
    p_nombre := NombreCliente(:new.codigoestancia);
    v_total := v_gastos + v_alojamiento + v_activ;
    ---Envío del correo electrónico---
    UTL_MAIL.SEND (
        sender => 'mariajesus.allozarodriguez@gmail.com',
        recipients => p_email,
        subject => 'Factura Complejo Rural La Fuente',
        message => 'Estimado/a '|| p_nombre || ' le enviamos la factura de su estancia en el Complejo Rural La Fuente. ' || CHR(10) || '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -' || CHR(10) || '--------------Resumen Factura--------------' || CHR(10) ||  '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -' || CHR(10) || 'El importe de los gastos extra es de ' || v_gastos || ' euros. ' || CHR(10) || 'El importe total de las actividades es de ' || v_activ || ' euros.' || CHR(10) || 'El importe del alojamiento es de ' || v_activ || ' euros.' || CHR(10) ||'El importe total de su estancia es de ' || v_total || ' euros. '|| CHR(10) || '- - - - - - - - - - - - - - - - - - - - - ' || CHR(10) || 'Gracias por compartir su tiempo con nosotros.' || CHR(10) ||  '- - - - - - - - - - - - - - - - - - - - - ' || CHR(10) || 'Complejo Rural La Fuente' || CHR(10) || 'Calle de la Fuente, 1' || CHR(10) || 'C.P. 50001' || CHR(10) || 'Zaragoza' || CHR(10) || 'Telefono: 976 123 456',
        mime_type => 'text/plain'
    );
END;
/


---Insertamos una factura para que se envíe el correo electrónico---

INSERT INTO personas VALUES ('32061164S','Maria','Alloza Rodriguez','C/ Leon X','Madrid (Madrid)','riiku23@gmail.com');

INSERT INTO estancias VALUES ('08',to_DATE('14-02-2020 12:00','DD-MM-YYYY hh24:mi'),to_DATE('17-02-2020 12:00','DD-MM-YYYY hh24:mi'),'05','32061164S','32061164S','AD');

INSERT INTO gastos_extra VALUES ('12','08',to_DATE('15-02-2020 10:00','DD-MM-YYYY hh24:mi'),'Alquiler de pistas',2);


---Insertamos una factura para que se envíe el correo electrónico---
INSERT INTO facturas VALUES ('06','08', to_DATE('17-02-2020 12:00','DD-MM-YYYY hh24:mi'));

---Eliminamos la factura para que no se envíe el correo electrónico---
delete from facturas where codigoestancia='08';