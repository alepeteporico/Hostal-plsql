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
CREATE OR REPLACE PROCEDURE ActividadInexistente (v_codactividad actividades.codigo%type)
IS
    CURSOR c_codigo IS
        SELECT *
        FROM actividades
        WHERE codigo=v_codactividad;
    v_codigo actividades.codigo%type;
BEGIN
    IF v_codigo IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002,'La actividad especificada no existe');
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
        RAISE_APPLICATION_ERROR(-20003,'La actividad especificada se ha realizado en regimen de Todo Incluido');
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
        RAISE_APPLICATION_ERROR(-20004,'El cliente nunca ha realizado esa actividad');
    END IF;
END;
/

---Funciona correctamente
EXEC ClienteRealizaActividad ('69191424H', 'B302');


---Procedimiento que compruebe si el cliente ha pagado la última actividad con ese código que ha realizado introduciendo el código de la actividad y el NIF del cliente.
CREATE OR REPLACE PROCEDURE ActividadAbonada (v_codcliente personas.nif%type, v_codactividad actividades.codigo%type)
IS
    CURSOR c_actividad_abonada IS
        SELECT *
        FROM actividadesrealizadas
        WHERE codigoestancia = (SELECT codigo FROM estancias WHERE nifcliente=v_codcliente) AND codigoactividad=v_codactividad
        ORDER BY fecha DESC
        FETCH FIRST 1 ROWS ONLY;
    v_actividad_abonada actividadesrealizadas%ROWTYPE;
BEGIN
    OPEN c_actividad_abonada;
    FETCH c_actividad_abonada INTO v_actividad_abonada;
    IF v_actividad_abonada.abonado = 'N' THEN
        DBMS_OUTPUT.PUT_LINE('FALSE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TRUE');
    END IF;
    CLOSE c_actividad_abonada;
END;
/


---Funciona correctamente
EXEC ActividadAbonada ('06852683V','A302'); ---true
EXEC ActividadAbonada ('69191424H','B302'); ---false

---Fallo
EXEC ActividadAbonada ('54890865P','A002');

---Procedimiento ComprobarPago que muestrer TRUE si el cliente ha pagado la última actividad con ese código que ha realizado y un FALSE en caso contrario.
CREATE OR REPLACE PROCEDURE ComprobarPago (v_codcliente personas.NIF%type, v_codactividad actividades.codigo%type) IS
    v_pago NUMBER;
BEGIN
    ClienteInexistente(v_codcliente);
    ActividadInexistente(v_codactividad);
    ActividadTodoIncluido(v_codactividad);
    ClienteRealizaActividad(v_codcliente, v_codactividad);
    ActividadAbonada(v_codcliente, v_codactividad);
END;
/
    

EXEC ComprobarPago  ('06852683V','A032'); ---true
    
EXEC ComprobarPago  ('69191424H','B302'); ---false

EXEC ComprobarPago ('54890869P','A999'); ---false


---PROCEDIMIENTO FINALIZADO


---MISMO PROCEDIMIENTO ES POSTGRESQL

---Procedimiento que, ingresando NIF del cliente comprueba si existe en la tabla personas.
CREATE OR REPLACE FUNCTION ClienteInexistente (v_codcliente personas.nif%type) 
RETURNS BOOLEAN AS $ClienteInexistente$
DECLARE
    v_codigo personas.nif%type;
BEGIN
    SELECT nif INTO v_codigo
    FROM personas
    WHERE nif=v_codcliente;
    IF v_codigo IS NULL THEN
        RAISE EXCEPTION 'El cliente especificado no existe';
    ELSE
        RETURN TRUE;
    END IF;
END;
$ClienteInexistente$ LANGUAGE plpgsql;

---FALLO
SELECT ClienteInexistente ('32061164S');

---Funciona correctamente
SELECT ClienteInexistente ('06852683V');

