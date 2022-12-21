---5. Añade a la tabla Actividades una columna llamada BalanceHotel. La columna contendrá la cantidad que debe pagar el hotel a la empresa (en cuyo caso tendrá signo positivo) o la empresa al hotel (en cuyo caso tendrá signo negativo) a causa de las Actividades Realizadas por los clientes. Realiza un procedimiento que rellene dicha columna y un trigger que la mantenga actualizada cada vez que la tabla ActividadesRealizadas sufra cualquier cambio.

--- Procedimiento que devuelve true si la actividad se ha realizado en regimen de todo incluido

CREATE OR REPLACE PROCEDURE ActividadTodoIncluidoTrue (v_codactividad actividades.codigo%type) RETURN BOOLEAN
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
        RETURN 'T';
    ELSE
        RETURN 'F';
    END IF;
    CLOSE c_todoIncluido;
END;
/

---Procedimiento que calcula el valor del balance

CREATE OR REPLACE PROCEDURE CalcularPrecioBalance (v_codactividad, v_codestancia, v_fecha)
IS
    v_precioporpersona  NUMBER(6,2);
    v_comisionhotel NUMBER(6,2);
    v_costepersonaparahotel NUMBER(6,2);
    v_numpersonas   NUMBER(6,2);
    v_balance   NUMBER(6,2);
BEGIN
    SELECT PrecioporPersona, ComisionHotel, CostePersonaparaHotel INTO v_precioporpersona, v_comisionhotel, v_costepersonaparahotel
    FROM Actividades
    WHERE Codigo=v_codactividad;

    SELECT NumPersonas INTO v_numpersonas
    FROM ActividadesRealizadas
    WHERE CodigoActividad = v_codactividad
    AND CodigoEstancia = v_codestancia
    AND Fecha = v_fecha);

    IF ActividadTodoIncluido='True'
    THEN
        v_balance=SUM(v_precioporpersona, costepersonaparahotel) * v_numpersonas;
    ELSE
        v_balance=SUM(v_precioporpersona, v_costepersonaparahotel, v_comisionhotel) * v_numpersonas;
    END IF;
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
