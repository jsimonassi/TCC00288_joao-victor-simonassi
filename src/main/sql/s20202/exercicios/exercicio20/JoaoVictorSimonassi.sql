/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  joao.farias
 * Created: 18 de mar de 2021
 */

DO $$ BEGIN 
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;


CREATE TABLE empregado(
    nome VARCHAR,
    salario REAL
);

CREATE OR REPLACE FUNCTION auditoria()
RETURNS TRIGGER AS $auditoria$
    DECLARE
        usuario NAME;
    BEGIN

        IF(SELECT NOT EXISTS(SELECT FROM information_schema.tables
                            WHERE table_name = 'auditoria_empregado')) THEN
            CREATE TABLE auditoria_empregado(
                usuario NAME,
                nome_ant VARCHAR,
                salario_ant REAL,
                nome_novo VARCHAR,
                salario_novo REAL,
                data_hora TIMESTAMP
            );
        END IF;

        SELECT USER INTO usuario;
        INSERT INTO auditoria_empregado VALUES(usuario,
                                                OLD.nome,
                                                OLD.salario,
                                                NEW.nome,
                                                NEW.salario,
                                                CURRENT_TIMESTAMP
                                                );

        RETURN NEW;
    END;
$auditoria$ LANGUAGE plpgsql;

CREATE TRIGGER auditoria
AFTER INSERT OR UPDATE OR DELETE ON empregado
FOR EACH ROW EXECUTE PROCEDURE auditoria();

INSERT INTO empregado VALUES('João Victor', '1500');
SELECT * FROM empregado;
UPDATE empregado SET salario = '2000' WHERE nome = 'João Victor';
SELECT * FROM empregado;
DELETE FROM empregado WHERE nome = 'João Victor';
SELECT * FROM empregado;
SELECT * FROM auditoria_empregado;