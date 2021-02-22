/*
 * Author:  Joao Victor Simonassi
 * Created: 22 de fev de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE pais (
    codigo integer,
    nome varchar
);

CREATE TABLE estado (
    nome varchar,
    pais integer,
    area float
);

INSERT INTO pais(codigo, nome) VALUES (1, 'Australia');
INSERT INTO pais(codigo, nome) VALUES (2, 'Brasil');

INSERT INTO estado VALUES ('Rio de Janeiro', 2, 1255);
INSERT INTO estado VALUES ('Bahia', 2, 564733);
INSERT INTO estado VALUES ('Vitoria', 1, 227416);

CREATE OR REPLACE FUNCTION computarAreaMediana(paisNome varchar) RETURNS float AS $$
DECLARE
    mediana float;
    areas float[];
    areaEstado RECORD;
    qtd_areas integer;
BEGIN
    areas = '{}';
    FOR areaEstado IN SELECT area FROM estado, pais WHERE estado.pais = pais.codigo AND pais.nome = paisNome ORDER BY area ASC LOOP
        areas = array_append(areas, areaEstado.area);
    END LOOP;

    IF array_length(areas, 1) IS NULL THEN
        mediana := 0;
    ELSE
        SELECT array_length(areas, 1) INTO qtd_areas;
        IF ((qtd_areas)%2 = 1) THEN
            mediana := areas[ROUND(qtd_areas/2)+1];
        ELSE
            mediana := (areas[qtd_areas/2]+areas[(qtd_areas/2)+1])/2;
            
        END IF;
    END IF;
    RETURN mediana;
END
$$ LANGUAGE plpgsql;

SELECT * FROM computarAreaMediana('Japao');
SELECT * FROM computarAreaMediana('Australia');
SELECT * FROM computarAreaMediana('Brasil');