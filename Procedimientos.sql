/* Procedimientos */

/* 1. Realiza una función ComprobarPago que reciba como parámetros un código de cliente y un código de actividad y devuelva un TRUE si el cliente ha pagado la última actividad con ese código que ha realizado y un FALSE en caso contrario. Debes controlar las siguientes excepciones: 
- Cliente inexistente. 
- Actividad Inexistente. 
- Actividad realizada en régimen de Todo Incluido.
- El cliente nunca ha realizado esa actividad.*/

---Procedimiento que, ingresando NIF del cliente comprueba si existe en la tabla personas.
CREATE OR REPLACE PROCEDURE ClienteInexistente (v_codcliente personas.NIF%type) IS
    v_cliente NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cliente
    FROM personas
    WHERE NIF=v_codcliente;
    IF v_cliente=0 THEN
        RAISE_APPLICATION_ERROR(-20001,'El cliente especificado no existe');
    END IF;
END;
/

---FALLO
EXEC ClienteInexistente ('12345678A');

---Funciona correctamente
EXEC ClienteInexistente ('54890865P');


---Procedimiento que, ingresando el código de la actividad comprueba si existe en la tabla actividades.
CREATE OR REPLACE PROCEDURE ActividadInexistente (v_codactividad actividades.codigo%type) IS
    v_actividad NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_actividad
    FROM actividades
    WHERE codigo=v_codactividad;
    IF v_actividad=0 THEN
        RAISE_APPLICATION_ERROR(-20001,'La actividad especificada no existe');
    END IF;
END;
/

---FALLO
EXEC ActividadInexistente ('A003');

---Funciona correctamente
EXEC ActividadInexistente ('A001');


---Procedimiento que compruebe si una actividad se ha realizado en régimen de Todo Incluido.
CREATE OR REPLACE PROCEDURE ActividadTodoIncluido (v_codactividad actividades.codigo%type) IS
    v_todoIncluido NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_todoIncluido
    FROM actividadesrealizadas
    WHERE codigoactividad=v_codactividad AND codigoestancia=(SELECT COUNT(codigo) FROM estancias WHERE codigoregimen = 'TI');
    IF v_todoIncluido>0 THEN
        RAISE_APPLICATION_ERROR(-20001,'La actividad especificada se ha realizado en regimen de Todo Incluido');
    END IF;
END;
/

---FALLO
EXEC ActividadTodoIncluido ('A001');

---Funciona correctamente
EXEC ActividadTodoIncluido ('A032');


---Procedimiento que compruebe si el cliente ha realizado una actividad ingresando el código de la actividad.
CREATE OR REPLACE PROCEDURE ClienteRealizaActividad (v_codcliente personas.NIF%type, v_codactividad actividades.codigo%type) IS
    v_cliente NUMBER;
BEGIN
    SELECT codigo INTO v_cliente
    FROM estancias WHERE nifcliente=v_codcliente AND codigo IN (SELECT codigoestancia FROM actividadesrealizadas WHERE codigoactividad=v_codactividad);
    IF v_cliente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'El cliente nunca ha realizado esa actividad');
    END IF;
END;
/

EXEC ClienteRealizaActividad ('69191424H', 'B302');


---Procedimiento que compruebe si el cliente ha pagado la última actividad con ese código que ha realizado introduciendo el código de la actividad y el NIF del cliente.
CREATE OR REPLACE PROCEDURE ClientePagoActividad (v_codcliente personas.NIF%type, v_codactividad actividades.codigo%type) IS
    v_pago NUMBER;
BEGIN
    SELECT COUNT(codigoactividad) INTO v_pago
    FROM actividadesrealizadas
    WHERE abonado > '0' AND codigoactividad=v_codactividad AND codigoestancia = (SELECT codigo FROM estancias WHERE nifcliente=v_codcliente)
    ORDER BY fecha ASC
    FETCH FIRST 1 ROWS ONLY;
    IF v_pago IS NULL THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
END;
/

---FALLO
EXEC ClientePagoActividad ('69191424H', 'B302');

---Funciona correctamente
EXEC ClientePagoActividad ('69191424H', 'B301');



---Procedimiento ComprobarPago que muestrer TRUE si el cliente ha pagado la última actividad con ese código que ha realizado y un FALSE en caso contrario.
CREATE OR REPLACE PROCEDURE ComprobarPago (v_codcliente personas.NIF%type, v_codactividad actividades.codigo%type) IS
    v_pago NUMBER;
BEGIN
    ClienteInexistente(v_codcliente);
    ActividadInexistente(v_codactividad);
    ActividadTodoIncluido(v_codactividad);
    ClienteRealizaActividad(v_codcliente, v_codactividad);
    SELECT count(*) INTO v_pago
    FROM pagos WHERE nifcliente=v_codcliente AND codigoactividad=v_codactividad AND fecha=(SELECT MAX(fecha) FROM pagos WHERE nifcliente=v_codcliente AND codigoactividad=v_codactividad);
