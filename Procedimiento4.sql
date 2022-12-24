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



---Procedimiento que imprime la cabecera del resumen de la factura
CREATE OR REPLACE PROCEDURE CabeceraResumenFactura
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('--------------Resumen Factura--------------');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
END;
/


---Procedimiento que muestre la firma de la empresa en el correo electrónico---
CREATE OR REPLACE PROCEDURE FirmaCorreo
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('- - - - - - - - - - - - - - - - - - - - - ');
    DBMS_OUTPUT.PUT_LINE('Complejo Rural La Fuente');
    DBMS_OUTPUT.PUT_LINE('Calle de la Fuente, 1');
    DBMS_OUTPUT.PUT_LINE('C.P. 50001');
    DBMS_OUTPUT.PUT_LINE('Zaragoza');
    DBMS_OUTPUT.PUT_LINE('Telefono: 976 123 456');
END;
/


---Procedimiento que muestre los datos de la estancia
CREATE OR REPLACE FUNCTION FacturaResumen(p_codE estancias.codigo%type)
RETURN VARCHAR2
IS
    p_resumen VARCHAR2(2000);
BEGIN
    CabeceraResumenFactura;
    Estancia (p_codE);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Importe Total Gastos: ' || ImporteGastos(p_codE));
    DBMS_OUTPUT.PUT_LINE('Importe Total Actividades: ' || ImporteActividades(p_codE));
    DBMS_OUTPUT.PUT_LINE('Importe Total Alojamiento: ' || ImporteAlojamiento(p_codE));
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
    ImporteFactura(p_codE);
END;
/

SELECT FacturaResumen('04') FROM DUAL;

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

SELECT EmailCliente('02') FROM DUAL;

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

CREATE OR REPLACE TRIGGER envio_factura
AFTER INSERT ON facturas
FOR EACH ROW
DECLARE
    p_nombre VARCHAR2(70);
    p_email personas.email%type;
    p_fecha_fin estancias.fecha_fin%type;
    p_resumen VARCHAR2(2000);
BEGIN
    p_nombre := NombreCliente(:new.codigoestancia);
    p_email := EmailCliente(:new.codigoestancia);
    p_fecha_fin := FechaFinEstancia(:new.codigoestancia);
    UTL_MAIL.SEND (
        sender => 'mariajesus.allozarodriguez@gmail.com',
        recipients => p_email,
        subject => 'Factura Complejo Rural La Fuente',
        message => 'Estimado/a '|| p_nombre || ' le enviamos la factura de su estancia en el Complejo Rural La Fuente. ' || p_resumen,
        mime_type => 'text/plain; charset=us-ascii'
    );
END;
/




---Insertamos una factura para que se envíe el correo electrónico---

INSERT INTO personas VALUES ('32061164S','Maria','Alloza Rodriguez','C/ Leon X','Madrid (Madrid)','riiku23@gmail.com');

INSERT INTO estancias VALUES ('08',to_DATE('14-02-2020 12:00','DD-MM-YYYY hh24:mi'),to_DATE('17-02-2020 12:00','DD-MM-YYYY hh24:mi'),'00','32061164S','32061164S','AD');



INSERT INTO facturas VALUES ('08','08', to_DATE('17-02-2020 12:00','DD-MM-YYYY hh24:mi'));
