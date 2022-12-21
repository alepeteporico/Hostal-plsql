/* Procedimiento 1 */

/* Realiza una función ComprobarPago que reciba como parámetros un código de cliente y un código de actividad y devuelva un TRUE si el cliente ha pagado la última actividad con ese código que ha realizado y un FALSE en caso contrario. Debes controlar las siguientes excepciones: 
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
    v_actividad NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_actividad
    FROM actividades
    WHERE codigo=v_codactividad;
    IF v_actividad=0 THEN
        RAISE_APPLICATION_ERROR(-20002,'La actividad especificada no existe');
    END IF;
END;
/
    

---FALLO
EXEC ActividadInexistente ('A003');

---Funciona correctamente
EXEC ActividadInexistente ('A001');


---Procedimiento que compruebe si una actividad se ha realizado en régimen de Todo Incluido.
CREATE OR REPLACE PROCEDURE ActividadTodoIncluido (v_codactividad actividades.codigo%type) 
IS
    CURSOR c_todoIncluido IS
        SELECT COUNT(*)
        FROM actividadesrealizadas
        WHERE codigoestancia = (SELECT codigo FROM estancias WHERE codigoregimen='TI') AND codigoactividad=v_codactividad;
    v_todoIncluido NUMBER;
BEGIN
    OPEN c_todoIncluido;
    FETCH c_todoIncluido INTO v_todoIncluido;
    IF v_todoIncluido>0 THEN
        RAISE_APPLICATION_ERROR(-20003,'La actividad se ha realizado en regimen de Todo Incluido');
    END IF;
    CLOSE c_todoIncluido;
END;
/
    
---FALLO
EXEC ActividadTodoIncluido ('A001');

---Funciona correctamente
EXEC ActividadTodoIncluido ('A032');


---Procedimiento que compruebe si el cliente ha realizado una actividad ingresando el código de la actividad.
CREATE OR REPLACE PROCEDURE ClienteRealizaActividad (v_codcliente personas.NIF%type, v_codactividad actividades.codigo%type) IS
    v_realizada NUMBER;
BEGIN
    SELECT codigo INTO v_realizada
    FROM estancias WHERE nifcliente=v_codcliente AND codigo IN (SELECT codigoestancia FROM actividadesrealizadas WHERE codigoactividad=v_codactividad);
    IF v_realizada IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004,'El cliente nunca ha realizado esa actividad');
    END IF;
END;
/

---Funciona correctamente
EXEC ClienteRealizaActividad ('69191424H', 'B302');


---Procedimiento de Excepciones
CREATE OR REPLACE PROCEDURE ComprobarExcepciones (v_codcliente personas.NIF%type, v_codactividad actividades.codigo%type)
IS
BEGIN
    ClienteInexistente(v_codcliente);
    ActividadInexistente(v_codactividad);
    ActividadTodoIncluido(v_codactividad);
    ClienteRealizaActividad(v_codcliente, v_codactividad);
END;
/


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
CREATE OR REPLACE FUNCTION ComprobarPago (v_codcliente personas.NIF%type, v_codactividad actividades.codigo%type)
RETURN BOOLEAN
IS
    v_abonado BOOLEAN;
BEGIN
    ComprobarExcepciones(v_codcliente, v_codactividad);
    ActividadAbonada(v_codcliente, v_codactividad);
    RETURN v_abonado;
END;
/

---Régimen Todo Incluido
DECLARE
    v_abonado BOOLEAN;
BEGIN
    v_abonado := ComprobarPago('06852683V','A032');
    RETURN;
END;
/

---FALSE
DECLARE
    v_abonado BOOLEAN;
BEGIN
    v_abonado := ComprobarPago('69191424H','B302');
    RETURN;
END;
/

---Cliente no existe    
DECLARE
    v_abonado BOOLEAN;
BEGIN
    v_abonado := ComprobarPago('54890869P','A999');
    RETURN;
END;
/

---Actividad no existe
DECLARE
    v_abonado BOOLEAN;
BEGIN
    v_abonado := ComprobarPago('69191424H','A002');
    RETURN;
END;
/


---TRUE
DECLARE
    v_abonado BOOLEAN;
BEGIN
    v_abonado := ComprobarPago('40687067K','A001');
    RETURN;
END;
/


---------------------------------------------------------------------------
-----------------------PROCEDIMIENTO FINALIZADO----------------------------
---------------------------------------------------------------------------

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


--Procedimiento que, ingresando el código de la actividad comprueba si existe en la tabla actividades.
CREATE OR REPLACE FUNCTION ActividadInexistente (v_codactividad actividades.codigo%type)
RETURNS BOOLEAN AS $ActividadInexistente$
DECLARE
    c_codigo CURSOR FOR
        SELECT *
        FROM actividades
        WHERE codigo=v_codactividad;
    v_codigo actividades.codigo%type;
BEGIN
    FOR v_codigo IN c_codigo LOOP
        RETURN TRUE;
    END LOOP;
    RAISE EXCEPTION 'La actividad especificada no existe';
END;
$ActividadInexistente$ LANGUAGE plpgsql;


---FALLO
SELECT ActividadInexistente ('A003');

---Funciona correctamente
SELECT ActividadInexistente ('A032');


---Procedimiento que compruebe si una actividad se ha realizado en régimen de Todo Incluido.

CREATE OR REPLACE FUNCTION ActividadTodoIncluido (v_codactividad actividades.codigo%type)
RETURNS VOID AS $ActividadTodoIncluido$
DECLARE
    v_todoIncluido INT;
BEGIN
    SELECT COUNT(*) INTO v_todoIncluido
    FROM actividadesrealizadas
    WHERE codigoestancia = (SELECT codigo FROM estancias WHERE codigoregimen='TI') AND codigoactividad=v_codactividad;
    IF v_todoIncluido > 0 THEN
        RAISE EXCEPTION 'La actividad especificada se ha realizado en régimen de Todo Incluido';
    END IF;
END;
$ActividadTodoIncluido$ LANGUAGE plpgsql;

   
---FALLO
SELECT ActividadTodoIncluido ('A001');

---Funciona correctamente
SELECT ActividadTodoIncluido ('A032');


---Procedimiento que compruebe si el cliente ha realizado una actividad ingresando el código de la actividad.
CREATE OR REPLACE FUNCTION ClienteRealizaActividad (v_codcliente personas.nif%type, v_codactividad actividades.codigo%type)
RETURNS BOOLEAN AS $ClienteRealizaActividad$
DECLARE
    v_cliente INTEGER;
BEGIN
    SELECT codigo INTO v_cliente
    FROM estancias 
    WHERE nifcliente=v_codcliente AND codigo IN (SELECT codigoestancia FROM actividadesrealizadas WHERE codigoactividad=v_codactividad);
    IF v_cliente IS NULL THEN
        RAISE EXCEPTION 'El cliente nunca ha realizado esa actividad';
    ELSE
        RETURN TRUE;
    END IF;
END;
$ClienteRealizaActividad$ LANGUAGE plpgsql;


---Funciona correctamente
SELECT ClienteRealizaActividad ('69191424H', 'B302');


---Procedimiento de comprobación de excepciones.
CREATE OR REPLACE FUNCTION ComprobarExcepciones (v_codcliente personas.nif%type, v_codactividad actividades.codigo%type)
RETURNS VOID AS $ComprobarExcepciones$
BEGIN
    PERFORM ClienteInexistente (v_codcliente);
    PERFORM ActividadInexistente (v_codactividad);
    PERFORM ActividadTodoIncluido (v_codactividad);
    PERFORM ClienteRealizaActividad (v_codcliente, v_codactividad);
END;
$ComprobarExcepciones$ LANGUAGE plpgsql;


---Procedimiento que compruebe si el cliente ha pagado la última actividad con ese código que ha realizado introduciendo el código de la actividad y el NIF del cliente que retorne true si ha pagado y false si no ha pagado.
CREATE OR REPLACE FUNCTION ActividadAbonada (v_codcliente personas.nif%type, v_codactividad actividades.codigo%type)
RETURNS BOOLEAN AS $ActividadAbonada$
DECLARE
    c_abonado CURSOR FOR
        SELECT *
        FROM actividadesrealizadas
        WHERE codigoestancia = (SELECT codigo FROM estancias WHERE nifcliente=v_codcliente) AND codigoactividad=v_codactividad
        ORDER BY fecha DESC
        FETCH FIRST 1 ROW ONLY;
    v_abonado actividadesrealizadas%ROWTYPE;
BEGIN
    OPEN c_abonado;
    FETCH c_abonado INTO v_abonado;
    IF v_abonado.abonado = 'N' THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
END;
$ActividadAbonada$ LANGUAGE plpgsql;


---Funciona correctamente
SELECT ActividadAbonada ('06852683V','A302'); ---true
SELECT ActividadAbonada ('69191424H','B302'); ---false

---Fallo
EXEC ActividadAbonada ('54890865P','A002');


---Procedimiento ComprobarPago que muestrer TRUE si el cliente ha pagado la última actividad con ese código que ha realizado y un FALSE en caso contrario.

CREATE OR REPLACE FUNCTION ComprobarPago (v_codcliente personas.nif%type, v_codactividad actividades.codigo%type)
RETURNS BOOLEAN AS $ComprobarPago$
DECLARE
    v_abonado BOOLEAN;
BEGIN
    PERFORM ComprobarExcepciones (v_codcliente, v_codactividad);
    v_abonado := ActividadAbonada(v_codcliente, v_codactividad);
    RETURN v_abonado;
END;
$ComprobarPago$ LANGUAGE plpgsql;


SELECT ComprobarPago  ('06852683V','A032'); ---Régimen Todo Incluido
    
SELECT ComprobarPago  ('69191424H','B302'); ---false

SELECT ComprobarPago ('54890869P','A999'); ---Cliente no existe

SELECT ComprobarPago ('69191424H','A002'); ---Actividad no existe

SELECT ComprobarPago ('40687067K','A001'); ---true


