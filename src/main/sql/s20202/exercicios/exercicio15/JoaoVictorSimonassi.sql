/**
 * Author:  Joao Victor Simonassi
 * Created: 27 de fev de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE cliente (
    cpf integer NOT NULL,
    nome character varying NOT NULL,
    CONSTRAINT cliente_pk PRIMARY KEY (cpf)
);

CREATE TABLE conta (
    agencia integer NOT NULL,
    numero integer NOT NULL,
    cliente integer NOT NULL,
    saldo real NOT NULL default 0,
    CONSTRAINT conta_pk PRIMARY KEY
    (agencia,numero),
    CONSTRAINT cliente_fk FOREIGN KEY
    (cliente) REFERENCES cliente (cpf)
);

CREATE TABLE movimentacao (
    agencia integer NOT NULL,
    conta integer NOT NULL,
    data_hora timestamp NOT NULL default
    current_timestamp,
    valor real NOT NULL,
    descricao character varying NOT NULL,
    CONSTRAINT mov_pk PRIMARY KEY
    (conta,agencia,data_hora),
    CONSTRAINT conta_fk FOREIGN KEY
    (agencia,conta) REFERENCES conta
    (agencia,numero)
);


INSERT INTO cliente VALUES(1, 'Joao'),
                          (2, 'Pedro');
INSERT INTO conta VALUES(1, 1, 1),
                        (1, 2, 1),
                        (2, 1, 1),
                        (2, 2, 2);
INSERT INTO movimentacao VALUES (1, 1, '2021-02-27 04:00:00', 1000, 'Entrada'),
                                (1, 1, '2021-02-27 05:00:00', 500, 'Saida'),
                                (1, 2, '2021-02-27 06:00:00', 200, 'Entrada'),
                                (2, 1, '2021-02-27 07:00:00', 1500, 'Entrada'),
                                (2, 1, '2021-02-27 08:00:00', 200, 'Entrada'),
                                (2, 2, '2021-02-27 09:00:00', 75, 'Entrada'),
                                (2, 2, '2021-02-27 10:00:00', 750, 'Saida');

CREATE OR REPLACE FUNCTION atualizar_saldo()
RETURNS VOID AS $$
    DECLARE
        contas CURSOR FOR SELECT agencia, numero, saldo FROM conta;
        transacoes CURSOR(a INTEGER, c INTEGER) FOR SELECT valor, descricao
                    FROM movimentacao WHERE agencia = a AND conta = c;
        contador INTEGER;
        novo_saldo FLOAT;		
    BEGIN
        contador := 0;
        FOR id IN contas LOOP
            novo_saldo := id.saldo;
            FOR transacao IN transacoes(id.agencia, id.numero) LOOP
                IF transacao.descricao = 'Entrada' THEN
                    novo_saldo := novo_saldo + transacao.valor;
                ELSE
                    novo_saldo := novo_saldo - transacao.valor;
                END IF;
            END LOOP;
            UPDATE conta
            SET saldo = novo_saldo
            WHERE agencia = id.agencia AND numero = id.numero;
            contador = contador + 1;
	END LOOP;
    END;
$$ LANGUAGE plpgsql;
SELECT * FROM conta;
SELECT atualizar_saldo();
SELECT * FROM conta;