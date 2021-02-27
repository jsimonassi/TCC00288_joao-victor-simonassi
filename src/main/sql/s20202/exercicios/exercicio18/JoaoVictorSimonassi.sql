/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  joao.farias
 * Created: 27 de fev de 2021
 */

DROP TABLE IF EXISTS cliente CASCADE;
DROP TABLE IF EXISTS procedimento CASCADE;
DROP TABLE IF EXISTS atendimento CASCADE;
DROP TABLE IF EXISTS fato CASCADE;

create table cliente(
    id bigint primary key,
    titular bigint references cliente(id),
    nome varchar not null
);
create table procedimento(
    id bigint primary key,
    nome varchar not null
);

create table atendimento(
    id bigint primary key,
    "data" timestamp not null,
    proc bigint references procedimento(id)
    not null,
    cliente bigint not null
);

create table fato(
    id bigint not null,
    "data" timestamp not null,
    procedimento bigint not null,
    qtd_vidas_contrato int not null,
    qtd_atend_urgencia int not null
);

INSERT INTO cliente VALUES  (1, 1, 'João'),
                            (2, 1, 'Joana'),
                            (3, 3, 'Pedro'),
                            (4, 3, 'Ana');

INSERT INTO procedimento VALUES (1, 'Procedimento 1'),
                                (2, 'Procedimento 2');

INSERT INTO atendimento VALUES  (1, '2021-02-27 04:00:00', 1, 1),
                                (2, '2021-02-27 07:00:00', 2, 2),
                                (3, '2021-02-27 08:00:00', 2, 2),
                                (4, '2021-02-27 22:30:00', 1, 4),            
                                (5, '2021-02-27 23:00:00', 1, 3);
         

DROP FUNCTION IF EXISTS popular_fato;
CREATE OR REPLACE FUNCTION popular_fato()
RETURNS VOID AS $$
    DECLARE
        nUrgencias INTEGER;
        nVidas INTEGER;
        clientes CURSOR FOR SELECT id FROM cliente;
        atendimentos CURSOR(cliente_id BIGINT) FOR SELECT * FROM atendimento
                                      WHERE atendimento.cliente = cliente_id;
        countVidas CURSOR(id_cliente BIGINT) FOR SELECT COUNT(*) FROM cliente
                                             WHERE cliente.titular = (SELECT DISTINCT titular
                                             FROM cliente
                                             WHERE cliente.id = id_cliente);
        countUrgencias CURSOR(id_cliente BIGINT, datah TIMESTAMP) FOR SELECT COUNT(*)
                                             FROM atendimento
                                             WHERE cliente = id_cliente AND 
                                            "data" < datah AND
                                            EXTRACT(HOUR FROM "data") >= 22;--Isso está correto?
    BEGIN
        FOR c IN clientes LOOP
            OPEN countVidas(c.id);
            FETCH countVidas INTO nVidas;
            CLOSE countvidas;
            FOR a IN atendimentos(c.id) LOOP
                OPEN countUrgencias(c.id, a."data");
                FETCH countUrgencias INTO nUrgencias;
                RAISE NOTICE 'nUrgencias: %  a.data: %', nUrgencias, a.data; -- Dúvida: nUrgencias sempre é zero. Pq?
                CLOSE countUrgencias;
                INSERT INTO fato VALUES(a.id, a."data", a.proc, nVidas, nUrgencias);
            END LOOP;
        END LOOP;
    END;
$$ LANGUAGE plpgsql;
SELECT popular_fato();
SELECT * FROM fato;