/* Procedimiento 3 */

/* 3. Realiza un trigger que impida que haga que cuando se inserte la realización de una actividad asociada a una estancia en regimen TI el campo Abonado no pueda valer FALSE. */

create or replace trigger ejer3 
after insert on actividadesrealizadas
for each row
declare
    v_variable varchar2(2);
begin 
    select codigo into v_variable
    from regimenes where codigo in (select codigoregimen from estancias where codigo = :new.codigoestancia);

    if :new.abonado = 'N' and v_variable = 'TI' then 
        raise_application_error(-20001, 'La actividad asociada a una estancia en regimen TI el campo abonado no puede ser FALSE');
    end if;
end;
/

--PostgreSQL--

create or replace function ejer3() returns trigger as 
$body$
declare
    v_variable varchar(2);
begin 
    select codigo into v_variable
    from regimenes where codigo in (select codigoregimen from estancias where codigo = new.codigoestancia);

    if new.abonado = 'N' and v_variable = 'TI' then 
        raise notice '%', 'La actividad asociada a una estancia en regimen TI el campo abonado no puede ser FALSE';
        return new;
    end if;
    return null;
end;
$body$
language plpgsql;

create trigger trigger_ejer3 
after insert on actividadesrealizadas
for each row execute procedure ejer3();

--Comprobacion del error--
insert into actividadesrealizadas values ('04','A032',to_date('09-08-2022 11:30','DD-MM-YYYY hh24:mi'),6,'N');
