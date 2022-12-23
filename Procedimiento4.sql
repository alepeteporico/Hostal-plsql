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


----Procedimiento que muestre la firma de la empresa en el correo electrónico---
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
    Habitacion (p_codE);
    Estancia (p_codE);
    DBMS_OUTPUT.PUT_LINE('- - - - - - - - - - - - - - - ');
    dbms_output.put_line('Importe Total Alojamiento: '||ImporteAlojamiento(p_codE));
    GastosExtra (p_codE);
    FinalActividadesR(p_codE);
    DBMS_OUTPUT.PUT_LINE('- - - - - - - - - - - - - - - ');
    ImporteFactura (p_codE);
    FirmaCorreo;
END;
/


---Procedimiento que muestra el email del cliente ingresando su código de estancia
CREATE OR REPLACE PROCEDURE EmailCliente (p_codE estancias.codigo%type)
IS
    p_email personas.email%type;
BEGIN
    SELECT email INTO p_email
    FROM personas 
    WHERE nif = (SELECT nifcliente FROM estancias WHERE codigo = p_codE);
    RETURN;
END;
/

EXEC EmailCliente('01');


---Crea un trigger para enviar un correo electrónico cuando se rellena la fecha de la factura. Debemos tener en cuenta el codigo de estancia de la factura para poder enviar el resumen de la factura.

CREATE OR REPLACE TRIGGER CorreoFactura
AFTER INSERT OR UPDATE ON facturas
FOR EACH ROW
DECLARE
    CURSOR c_cliente IS
        SELECT nombre, apellidos, email
        FROM personas
        WHERE nif = (SELECT nifcliente FROM estancias WHERE codigo = (SELECT codigoestancia FROM facturas WHERE fecha = :NEW.fecha));
    v_cliente c_cliente%ROWTYPE;
    p_codE estancias.codigo%type;
BEGIN
    IF :NEW.fecha ON INSERT THEN
        FOR v_cliente IN c_cliente LOOP
            UTL_MAIL.SEND (
                sender => 'mariajesus.allozarodriguez@gmail.com',
                recipients => 'mariajesus.allozarodriguez@gmail.com',
                subject => 'Factura Complejo Rural La Fuente',
                message => 'Estimado/a '||v_cliente.nombre||' '||v_cliente.apellidos||', le enviamos el resumen de su factura: '||FacturaResumen(p_codE),
                mime_type => 'text/plain; charset=us-ascii'
                );
        END LOOP;
    END IF;
END;
/


--- Nos salta un error de tabla mutante. Esto es debido a que modificamos una tabla que está siendo utilizada por el cursor. Para solucionarlo, debemos crear un cursor que no modifique la tabla. Para ello, creamos un cursor que nos devuelva el email del cliente.---



---Insertamos una factura para que se envíe el correo electrónico---

INSERT INTO facturas (numero, codigoestancia,fecha) VALUES ('08','08', to_DATE('13-03-2019 12:00','DD-MM-YYYY hh24:mi'));


