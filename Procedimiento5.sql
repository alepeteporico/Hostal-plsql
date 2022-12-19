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
