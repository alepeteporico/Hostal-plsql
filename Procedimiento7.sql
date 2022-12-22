/* Procedimiento 7 */

/* Realiza los módulos de programación necesarios para que los precios de un mismo tipo de habitación en una misma temporada crezca en función de los servicios ofrecidos de esta forma: Precio TI > Precio PC > Precio MP> Precio AD */

---Procedimiento que saca el coste de un regimen en concreto

CREATE OR REPLACE PROCEDURE PrecioDeRegimen (v_codregimen Tarfias.CodigoRegimen%type, v_añadido OUT NUMBER)
IS
    v_PrecioBaseAD    NUMBER(6,2);
    v_PrecioBaseMP    NUMBER(6,2);
    v_PrecioBasePC    NUMBER(6,2);
    v_PrecioBaseTI    NUMBER(6,2);

BEGIN
    v_PrecioBaseAD:=30;
    v_PrecioBaseMP:=45;
    v_PrecioBasePC:=65;
    v_PrecioBaseTI:=80;

    IF v_codregimen='AD'
    THEN
        v_añadido:=v_PrecioBaseAD;
    ELSE IF v_codregimen='MP'
    THEN
        v_añadido:=v_PrecioBaseMP;
    ELSE IF v_codregimen='PC'
    THEN
        v_añadido:=v_PrecioBasePC;
    ELSE IF v_codregimen='TI'
    THEN
        v_añadido:=v_PrecioBaseTI;
    END IF;
END;
/

---Procedimiento que calcula el precio de una habitación en Alojamiento y Desayuno 

