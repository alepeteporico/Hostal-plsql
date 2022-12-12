CREATE OR REPLACE PROCEDURE ClienteInexistente (v_codcliente personas.NIF%type)
IS
    ind_existe  number:=0;
BEGIN
    SELECT count(*) into ind_existe
    FROM personas
    WHERE NIF=v_codcliente;

    IF ind_existe=0 then
        raise_application_error(-20001,'El cliente especificado no existe');
    END IF;
END ClienteInexistente;

CREATE OR REPLACE PROCEDURE ActividadInexistente (v_codactividad Actividades.Codigo%type)
IS
    ind_existe  number:=0;
BEGIN
    SELECT count(*) into ind_existe
    FROM personas
    WHERE NIF=v_codactividad;

    IF ind_existe=0 then
        raise_application_error(-20002,'El cliente especificado no existe');
    END IF;
END ActividadInexistente;
