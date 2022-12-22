/* 5. Añade a la tabla Actividades una columna llamada BalanceHotel. La columna contendrá la cantidad que debe pagar el hotel a la empresa (en cuyo caso tendrá signo positivo) o la empresa al hotel (en cuyo caso tendrá signo negativo) a causa de las Actividades Realizadas por los clientes. Realiza un procedimiento que rellene dicha columna y un trigger que la mantenga actualizada cada vez que la tabla ActividadesRealizadas sufra cualquier cambio. */

/* Te recuerdo que cada vez que un cliente realiza una actividad, hay dos posibilidades: Si el cliente está en TI el hotel paga a la empresa el coste de la actividad. Si no está en TI, el hotel recibe un porcentaje de comisión del importe que paga el cliente por realizar la actividad.*/

--- Para valorar si una actividad se ha realizado en régimen de `Todo Incuido` o no, se utilizará el procedimiento **ActividadTodoIncluido** que hemos construido para el procedimiento **ControlarPago**.

--- Procedimiento que te dice si una estancia esta en todo incluido

CREATE OR REPLACE PROCEDURE EstanciaTodoIncluido (v_codestancia actividadesrealizadas.codigoestancia%type, v_codregimen OUT VARCHAR2)
AS
BEGIN
    SELECT CodigoRegimen INTO v_codregimen
    FROM Estancias
    WHERE Codigo=v_codestancia;
END;
/

--- Procedimiento que saca el numero de personas específicas que ha realizado una actividad

CREATE OR REPLACE PROCEDURE CalcularNumPersonas (v_codactividad actividadesrealizadas.codigoactividad%type, v_codestancia actividadesrealizadas.codigoestancia%type, v_fecha actividadesrealizadas.fecha%type, v_numpersonas OUT actividadesrealizadas.NumPersonas%type)
IS
BEGIN
    SELECT NumPersonas INTO v_numpersonas
    FROM ActividadesRealizadas
    WHERE CodigoActividad=v_codactividad
    AND CodigoEstancia=v_codestancia
    AND Fecha=v_fecha;
END;
/

---Procedimiento que calcula el valor del balance

CREATE OR REPLACE PROCEDURE CalcularPrecioBalance (v_codactividad actividadesrealizadas.codigoactividad%type, v_codestancia actividadesrealizadas.codigoestancia%type, v_fecha actividadesrealizadas.fecha%type, v_balance OUT NUMBER)
IS
    v_precioporpersona  actividades.PrecioPorPersona%type;
    v_comisionhotel actividades.ComisionHotel%type;
    v_costepersonaparahotel actividades.CostePersonaParaHotel%type;
    v_numpersonas   actividadesrealizadas.NumPersonas%type;
    v_regimen   VARCHAR2(4);
BEGIN
    SELECT PrecioporPersona, ComisionHotel, CostePersonaParaHotel INTO v_precioporpersona, v_comisionhotel, v_costepersonaparahotel
    FROM Actividades
    WHERE Codigo=v_codactividad;

    CalcularNumPersonas(v_codactividad, v_codestancia, v_fecha, v_numpersonas);
    EstanciaTodoIncluido(v_codestancia, v_regimen);

    IF v_regimen='TI'
    THEN
        v_balance:=v_precioporpersona * v_numpersonas;
    ELSE
        v_balance:=((v_precioporpersona + v_costepersonaparahotel + v_comisionhotel) * v_numpersonas) * -1;
    END IF;
END;
/

---Procedimiento que rellena todas las filas de la columna BalanceHotel en la tabla ActividadesRealizadas

CREATE OR REPLACE PROCEDURE RellenarBalance
IS
    v_balance   actividadesrealizadas.balancehotel%type;
    CURSOR c_actividades IS
    SELECT CodigoActividad, CodigoEstancia, Fecha
    FROM ActividadesRealizadas;

    v_codigos   c_actividades%rowtype;
BEGIN
    OPEN c_actividades;

    FETCH c_actividades INTO v_codigos;
    WHILE c_actividades%FOUND LOOP
        CalcularPrecioBalance(v_codigos.CodigoActividad, v_codigos.CodigoEstancia, v_codigos.Fecha, v_balance);

        UPDATE ActividadesRealizadas SET BalanceHotel=v_balance
        WHERE CodigoActividad=v_codigos.CodigoActividad AND CodigoEstancia=v_codigos.CodigoEstancia AND Fecha=v_codigos.Fecha;

        FETCH c_actividades INTO v_codigos;
    END LOOP;
    CLOSE c_actividades;
END;
/

---Trigger que actualiza la columna BalanceHotel cada vez que se modifica la tabla ActividadesRealizadas
