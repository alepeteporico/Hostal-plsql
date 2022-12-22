/* 5. Añade a la tabla Actividades una columna llamada BalanceHotel. La columna contendrá la cantidad que debe pagar el hotel a la empresa (en cuyo caso tendrá signo positivo) o la empresa al hotel (en cuyo caso tendrá signo negativo) a causa de las Actividades Realizadas por los clientes. Realiza un procedimiento que rellene dicha columna y un trigger que la mantenga actualizada cada vez que la tabla ActividadesRealizadas sufra cualquier cambio. */

/* Te recuerdo que cada vez que un cliente realiza una actividad, hay dos posibilidades: Si el cliente está en TI el hotel paga a la empresa el coste de la actividad. Si no está en TI, el hotel recibe un porcentaje de comisión del importe que paga el cliente por realizar la actividad.*/

--- Para valorar si una actividad se ha realizado en régimen de `Todo Incuido` o no, se utilizará el procedimiento **ActividadTodoIncluido** que hemos construido para el procedimiento **ControlarPago**.

---Procedimiento que calcula el valor del balance

CREATE OR REPLACE PROCEDURE CalcularPrecioBalance (v_codactividad actividadesrealizadas.codigoactividad%type, v_codestancia actividadesrealizadas.codigoestancia%type, v_fecha actividadesrealizadas.fecha%type)
IS
    v_precioporpersona  actividades.PrecioPorPersona%type;
    v_comisionhotel actividades.ComisionHotel%type;
    v_costepersonaparahotel actividades.CostePersonaParaHotel%type;
    v_numpersonas   actividadesrealizadas.NumPersonas%type;
    v_balance   NUMBER(6,2);
BEGIN
    SELECT PrecioporPersona, ComisionHotel, CostePersonaParaHotel INTO v_precioporpersona, v_comisionhotel, v_costepersonaparahotel
    FROM Actividades
    WHERE Codigo=v_codactividad;

    SELECT NumPersonas INTO v_numpersonas
    FROM ActividadesRealizadas
    WHERE CodigoActividad=v_codactividad
    AND CodigoEstancia=v_codestancia
    AND Fecha=v_fecha;

    IF ActividadTodoIncluido='True'
    THEN
        v_balance=v_precioporpersona + costepersonaparahotel) * v_numpersonas;
    ELSE
        v_balance=((v_precioporpersona + v_costepersonaparahotel + v_comisionhotel) * v_numpersonas) * -1;
    END IF;
    dbms_output.put_line(v_balance);
END;
/

---Procedimiento que rellena todas las filas de la columna BalanceHotel en la tabla ActividadesRealizadas

CREATE OR REPLACE PROCEDURE RellenarBalance(v_codactividad actividadesrealizadas.codigoactividad%rowtype, v_codestancia actividadesrealizadas.codigoestancia%rowtype, v_fecha actividadesrealizadas.fecha%rowtype)
IS
    CURSOR c_actividades IS
    SELECT CodigoActividad, CodigoEstancia, Fecha
    FROM ActividadesRealizadas;
BEGIN
    OPEN c_actividades;
    FETCH c_actividades INTO v_codactividad, v_codestancia, v_fecha;

    WHILE c_actividades%FOUND LOOP
    UPDATE ActividadesRealizadas
    SET BalanceHotel = NVL(SELECT PrecioporPersona, ComisionHotel, CostePersonaparaHotel
                            FROM Actividades
                            WHERE Codigo=v_codactividad) * (SELECT NumPersonas
                                                FROM ActividadesRealizadas
                                                WHERE CodigoActividad = v_codactividad
                                                AND CodigoEstancia = v_codestancia
                                                AND Fecha = v_fecha);
    END LOOP;
    CLOSE c_actividades;
END;
/


---Trigger que actualiza la columna BalanceHotel cada vez que se modifica la tabla ActividadesRealizadas
