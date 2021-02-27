/**
 * Author:  João Victor Simonassi
 * Created: 22 de fev de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE bairro (
	bairro_id integer NOT NULL,
	nome character varying NOT NULL,
	CONSTRAINT bairro_pk
        PRIMARY KEY(bairro_id));
	
CREATE TABLE municipio (
	municipio_id integer NOT NULL,
	nome character varying NOT NULL,
	CONSTRAINT municipio_pk
	PRIMARY KEY(municipio_id));
	
CREATE TABLE antena (
	antena_id integer NOT NULL,
	bairro_id integer NOT NULL,
	municipio_id integer NOT NULL,
	CONSTRAINT antena_pk
	PRIMARY KEY(antena_id),
	CONSTRAINT bairro_fk
	FOREIGN KEY(bairro_id)
	REFERENCES bairro (bairro_id),
	CONSTRAINT municipio_fk
	FOREIGN KEY (municipio_id)
	REFERENCES municipio (municipio_id));
	
CREATE TABLE ligacao (
	ligacao_id bigint NOT NULL,
	numero_orig bigint NOT NULL,
	numero_dest bigint NOT NULL,
	antena_orig integer NOT NULL,
	antena_dest integer NOT NULL,
	inicio timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	fim timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT ligacao_pk
	PRIMARY KEY(ligacao_id),
	CONSTRAINT antena_orig_fk
	FOREIGN KEY(antena_orig)
	REFERENCES antena (antena_id),
	CONSTRAINT antena_dest_fk
	FOREIGN KEY(antena_dest)
	REFERENCES antena (antena_id));

INSERT INTO bairro VALUES(1, 'Méier'),
			(2, 'Barra da Tijuca'),
			(3, 'Nova Cidade'),
			(4, 'Venda das Pedras');

INSERT INTO municipio VALUES(1, 'Rio de Janeiro'),
                            (2, 'Itaboraí');

INSERT INTO antena VALUES(1, 1, 1),
                        (2, 2, 1),
                        (3, 3, 2),
                        (4, 3, 2),
                        (5, 4, 2);

INSERT INTO ligacao VALUES(1, 21966755666, 219644558840, 1, 1, '2021-02-23 04:00:00', '2021-02-23 04:10:00'),
                        (2, 21996605402, 2126453158, 1, 2, '2021-02-23 04:00:00', '2021-02-23 04:15:00'),
                        (3, 21966755666, 219644558840, 1, 3, '2021-02-23 04:00:00', '2021-02-23 04:20:00'),
                        (4, 21940028922, 219644558840, 1, 4, '2021-02-23 04:00:00', '2021-02-23 04:25:00'),
                        (5, 21966755666, 219644558840, 2, 1, '2021-02-23 04:00:00', '2021-02-23 04:30:00'),
                        (6, 21966755666, 219644558840, 2, 2, '2021-02-23 04:00:00', '2021-02-23 04:35:00'),
                        (7, 21966755666, 219644558840, 2, 3, '2021-02-23 04:00:00', '2021-02-23 04:40:00'),
                        (8, 21966755666, 219644558840, 2, 4, '2021-02-23 04:00:00', '2021-02-23 04:45:00'),
                        (9, 21966755666, 219644558840, 3, 1, '2021-02-23 04:00:00', '2021-02-23 04:50:00'),
                        (10, 21966755666, 219644558840, 3, 2, '2021-02-23 04:00:00', '2021-02-23 04:55:00'),
                        (11, 21966755666, 219644558840, 3, 3, '2021-02-23 04:00:00', '2021-02-23 05:00:00'),
                        (12, 21966755666, 219644558840, 3, 4, '2021-02-23 04:00:00', '2021-02-23 05:05:00'),
                        (13, 21966755666, 219644558840, 4, 1, '2021-02-23 04:00:00', '2021-02-23 05:10:00'),
                        (14, 21966755666, 219644558840, 4, 2, '2021-02-23 04:00:00', '2021-02-23 05:15:00'),
                        (15, 21966755666, 219644558840, 4, 3, '2021-02-23 04:00:00', '2021-02-23 05:20:00'),
                        (16, 21966755666, 219644558840, 4, 4, '2021-02-23 04:00:00', '2021-02-23 05:25:00');

CREATE OR REPLACE FUNCTION duracao_media(data_hora_ini TIMESTAMP, data_hora_fim TIMESTAMP)
RETURNS TABLE(municipio1 TEXT, bairro1 TEXT, municipio2 TEXT, bairro2 TEXT, tempo_medio TIME) AS $$
	DECLARE 

        crossRegioes CURSOR FOR SELECT regiao1.municipio_id M1, regiao1.bairro_id B1, regiao2.municipio_id M2, regiao2.bairro_id B2
            FROM (SELECT DISTINCT bairro_id, municipio_id FROM antena) AS regiao1,(SELECT DISTINCT bairro_id, municipio_id FROM antena) AS regiao2;

	media CURSOR(b1 INTEGER, m1 INTEGER, b2 INTEGER, m2 INTEGER) FOR SELECT AVG(fim - inicio) FROM ligacao
            WHERE antena_orig IN (SELECT antena_id FROM antena WHERE bairro_id = b1 AND municipio_id = m1) AND
		antena_dest IN (SELECT antena_id FROM antena WHERE bairro_id = b2 AND municipio_id = m2) AND
		(data_hora_ini, data_hora_fim) OVERLAPS (ligacao.inicio, ligacao.fim);
					
    BEGIN
	CREATE TEMPORARY TABLE ans(municipio1 TEXT, bairro1 TEXT, municipio2 TEXT,
                                    bairro2 TEXT, tempo_medio TIME);

        FOR dupla IN crossRegioes LOOP
            OPEN media(dupla.B1, dupla.M1, dupla.B2, dupla.M2);
            FETCH media INTO tempo_medio;
            CLOSE media;
            IF tempo_medio IS NULL THEN
                    tempo_medio = '00:00:00';
            END IF;
            SELECT nome FROM municipio WHERE municipio_id = dupla.M1 INTO municipio1;
            SELECT nome FROM municipio WHERE municipio_id = dupla.M2 INTO municipio2;
            SELECT nome FROM bairro WHERE bairro_id = dupla.B1 INTO bairro1;
            SELECT nome FROM bairro WHERE bairro_id = dupla.B2 INTO bairro2;
            INSERT INTO ans VALUES(municipio1, bairro1, municipio2, bairro2, tempo_medio);

	END LOOP;
	RETURN QUERY SELECT * FROM ans ORDER BY tempo_medio DESC;
    END;
$$ LANGUAGE plpgsql;

SELECT * FROM duracao_media('2021-02-23 03:00:00'::TIMESTAMP, '2021-02-23 06:00:00'::TIMESTAMP);
