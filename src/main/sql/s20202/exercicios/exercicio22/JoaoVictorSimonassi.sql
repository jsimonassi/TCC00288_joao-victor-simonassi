/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  joao.farias
 * Created: 19 de mar de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table conta_corrente(
    id int primary key,
    abertura timestamp not null,
    encerramento timestamp
);

create table limite_credito(
    conta_corrente int references conta_corrente(id),
    valor float not null,
    inicio timestamp not null,
    fim timestamp
);

create table movimento(
    conta_corrente int references conta_corrente(id),
    "data" timestamp,
    valor float not null,
    primary key (conta_corrente,"data")
);

insert into conta_corrente values(0, CURRENT_TIMESTAMP),
                                    (1, CURRENT_TIMESTAMP);
insert into limite_credito values(0, 500, CURRENT_TIMESTAMP, NULL),
                                 (1, 100, CURRENT_TIMESTAMP, '2021-04-19'::timestamp);

CREATE OR REPLACE FUNCTION criar_tab_temp()
RETURNS TRIGGER AS $criar_tabela_temporária$
    BEGIN
        create TEMPORARY table conta_alterada(id int, "data" timestamp) on COMMIT DROP;
        return NULL;
    END;
$criar_tabela_temporária$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pop_temp()
RETURNS TRIGGER AS $popular_temporaria$
    BEGIN
        INSERT into conta_alterada values (new.conta_corrente, new."data");
        return new;
    END;
$popular_temporaria$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validar()
RETURNS TRIGGER AS $validar_entradas$
    DECLARE
        dt timestamp;
        saldo float;
        limite float;
        i record;

    BEGIN
        for i in select distinct id from conta_alterada loop
            select max("data") from conta_alterada where id = i.id into dt;
            select valor from limite_credito where conta_corrente = i.id and dt >= inicio and (fim is NULL or dt <= fim) into limite;
            select sum(valor) from movimento where conta_corrente = i.id and dt >= "data" into saldo;
            if limite is null THEN
                limite := 0;
            end if;
            if saldo < -limite then
                RAISE EXCEPTION 'Atingiu o limite';
            end if;
        end loop;
        return NULL;
    END;
$validar_entradas$ LANGUAGE plpgsql;


CREATE TRIGGER criar_tabela_temporária
BEFORE INSERT ON movimento
FOR EACH STATEMENT EXECUTE PROCEDURE criar_tab_temp();

CREATE TRIGGER popular_temporaria
BEFORE INSERT ON movimento
FOR EACH ROW EXECUTE PROCEDURE pop_temp();

CREATE TRIGGER validar_entradas
AFTER INSERT ON movimento
FOR EACH STATEMENT EXECUTE PROCEDURE validar();

insert into movimento values(1, '2021-03-19 00:00:00', -500),
                            (1, '2021-03-19 00:00:01', 1000),
                            (0, '2021-03-19 00:00:00', -500),
                            (0, '2021-03-19 00:00:01', -100);


select * from movimento;