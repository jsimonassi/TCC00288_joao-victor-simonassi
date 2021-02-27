-- Considerando o esquema lógico do banco de dados apresentado a seguir para campeonatos
-- de futebol, especifique uma função para computar a tabela de classificação dos campeonatos.
-- A função deverá ter como parâmetros de entrada 1) o código do campeonato para o qual se
-- deseja gerar a tabela de classificação, 2) a posição inicial do ranque e 3) a posição final do
-- ranque.
-- 
-- Obs. 1: Uma vitória vale 3 pontos e um empate 1 ponto.
-- Obs. 2: A classificação é feita por ordem decrescente de pontuação.
-- Obs. 3: O critério de desempate é o número de vitórias
-- 
-- Dica: SELECT... LIMIT l OFFSET 0; -- recupera l tupla a partir da
-- posição 0 do result set.

/**
 * Author:  João Victor Simonassi
 * Created: 22 de fev de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

DROP TABLE IF EXISTS campeonato CASCADE;
DROP TABLE IF EXISTS time_ CASCADE;
DROP TABLE IF EXISTS jogo CASCADE;

CREATE TABLE campeonato (
    codigo TEXT NOT NULL,
	nome TEXT NOT NULL,
	ano INTEGER NOT NULL,
    CONSTRAINT campeonato_pk
        PRIMARY KEY (codigo));

CREATE TABLE time_ (
    sigla TEXT NOT NULL,
	nome TEXT NOT NULL,
	CONSTRAINT time_pk
		PRIMARY KEY (sigla));

CREATE TABLE jogo(
	campeonato TEXT NOT NULL, 
	numero INTEGER NOT NULL,
	time1 TEXT NOT NULL,
	time2 TEXT NOT NULL,
	gols1 INTEGER NOT NULL,
	gols2 INTEGER NOT NULL,
	data_ DATE NOT NULL DEFAULT CURRENT_DATE,
	CONSTRAINT jogo_pk
	PRIMARY KEY (campeonato,numero),
	CONSTRAINT jogo_campeonato_fk
	FOREIGN KEY	(campeonato)
	REFERENCES campeonato (codigo),
	CONSTRAINT jogo_time_fk1
	FOREIGN KEY	(time1)
	REFERENCES time_ (sigla),
	CONSTRAINT jogo_time_fk2
	FOREIGN KEY	(time2)
	REFERENCES time_ (sigla));

INSERT INTO campeonato VALUES('1', 'Brasileiro', 2021);
INSERT INTO time_ VALUES('FLA', 'Flamengo'),
                        ('BOT', 'Botafogo'),
                        ('VSC', 'VASCO'),
                        ('FLU', 'Fluminense');
INSERT INTO jogo VALUES('1', 1, 'FLA', 'BOT', 7, 7),
                        ('1', 2, 'FLA', 'VSC', 1, 0),
                        ('1', 3, 'FLA', 'FLU', 5, 0),
                        ('1', 4, 'BOT', 'VSC', 1, 2),
                        ('1', 5, 'BOT', 'FLU', 3, 2),
                        ('1', 6, 'VSC', 'FLU', 0, 1),
                        ('1', 7, 'VSC', 'FLA', 0, 4),
                        ('1', 8, 'FLU', 'FLA', 0, 1),
                        ('1', 9, 'BOT', 'FLA', 0, 0),
                        ('1', 10, 'FLU', 'BOT', 0, 0),
                        ('1', 11, 'FLU', 'VSC', 1, 0),
                        ('1', 12, 'VSC', 'BOT', 1, 0);

CREATE OR REPLACE FUNCTION classificacao(codigo TEXT, pos1 INTEGER, pos2 INTEGER)
RETURNS TABLE(Time_ TEXT, Pontos INTEGER, V INTEGER, E INTEGER, D INTEGER) AS $$
    DECLARE
        times CURSOR(cod TEXT) FOR SELECT sigla FROM time_ WHERE sigla IN 
            (SELECT time1 FROM jogo WHERE campeonato = cod) OR
            sigla IN (SELECT time2 FROM jogo WHERE campeonato = cod);		
    BEGIN
        CREATE TEMPORARY TABLE ans(Time_ TEXT, Pontos INTEGER, V INTEGER,
                                    E INTEGER, D INTEGER);

        FOR timeX IN times(codigo) LOOP
            SELECT COUNT(*) FROM jogo WHERE (time1 = timeX.sigla AND gols1 > gols2) OR
                                            (time2 = timeX.sigla and gols2 > gols1)
            INTO V;
            SELECT COUNT(*) FROM jogo WHERE (time1 = timeX.sigla OR time2 = timeX.sigla) AND gols1 = gols2
            INTO E;
            SELECT COUNT(*) FROM jogo WHERE (time1 = timeX.sigla AND gols1 < gols2) OR
                                            (time2 = timeX.sigla and gols2 < gols1)
            INTO D;

            Pontos := V * 3 + E;
            Time_ := timeX.sigla;

            INSERT INTO ans VALUES(Time_, Pontos, V, E, D);
        END LOOP;
	RETURN QUERY SELECT * FROM ans ORDER BY(ans.Pontos, ans.V) DESC LIMIT pos2 OFFSET pos1;
    END;
$$ LANGUAGE plpgsql;

SELECT * FROM classificacao('1', 0, 4);
SELECT * FROM classificacao('1', 0, 2);