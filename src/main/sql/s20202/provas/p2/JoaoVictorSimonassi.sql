/* 
 6) [5,0 pontos] Considere o esquema de banco de dados sobre apresentações artísticas como
definido a seguir. Implemente trigger(s) em PL/pgSQL para garantir que tanto as arenas
quanto os artistas não estejam ocupados simultaneamente com mais de um concerto. Crie
também outro(s) trigger(s) em PL/pgSQL para não se permitir excluir todos os artistas
associados a uma atividade, isto é, após a associação de um artista a uma atividade essa
atividade não poderá deixar de estar associada a pelo menos um artista.
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE Atividade(
    id INT,
    nome VARCHAR);

CREATE TABLE Artista(
    id INT,
    nome VARCHAR,
    atividade INT);

CREATE TABLE Arena(
    id INT,
    nome VARCHAR);

CREATE TABLE Concerto(
    id INT,
    artista INT,
    arena INT,
    inicio TIMESTAMP,
    fim TIMESTAMP);


INSERT INTO Atividade values (1, 'cantor');
INSERT INTO Atividade values (2, 'guitarrista');
INSERT INTO Atividade values (3, 'pianista');
INSERT INTO Artista values (1, 'Axl Rose', 1);
INSERT INTO Artista values (2, 'Slash', 2);
INSERT INTO Artista values (3, 'Chopin', 2);
INSERT INTO Arena values (1, 'Arena - UFF');
INSERT INTO Arena values (2, 'Maracanã');
INSERT INTO Arena values (3, 'Vivo Rio');

CREATE OR REPLACE FUNCTION checkUnique() RETURNS TRIGGER AS $$
declare
begin
    
    IF EXISTS (SELECT * FROM Concerto
                WHERE concerto.id != new.id AND
                (concerto.arena = new.arena OR concerto.artista = new.artista) AND
                (concerto.inicio BETWEEN new.inicio AND new.fim or concerto.fim BETWEEN new.inicio and new.fim)) THEN
        raise exception 'OS HORÁRIOS INFORMADOS NÃO SÃO COMPATÍVEIS';
    END IF;

    return NEW;
end;
$$ language plpgsql;

CREATE TRIGGER trigger1
AFTER INSERT OR UPDATE ON Concerto FOR EACH ROW
EXECUTE PROCEDURE checkUnique();

CREATE OR REPLACE FUNCTION auxFunction() RETURNS TRIGGER AS $$
declare
begin
    create temp table activityAux(id int) on commit drop;
    return null;
end;
$$ language plpgsql;

CREATE TRIGGER trigger2
BEFORE UPDATE OR DELETE ON Artista FOR EACH STATEMENT
EXECUTE PROCEDURE auxFunction();

CREATE OR REPLACE FUNCTION registerArtist() RETURNS TRIGGER AS $$
declare
begin
    INSERT INTO activityAux values(old.atividade);
    return null;
end;
$$ language plpgsql;

CREATE TRIGGER trigger3
AFTER UPDATE OR DELETE ON Artista FOR EACH ROW
EXECUTE PROCEDURE registerArtist();

CREATE OR REPLACE FUNCTION checkActivity() RETURNS TRIGGER AS $$
declare
    counter int;
    atvd record;
begin
    
    FOR atvd in SELECT DISTINCT * FROM activityAux LOOP

        Select count(*) from Artista WHERE atividade = atvd.id INTO counter;
        IF counter = 0 THEN
            raise exception 'ATIVIDADE SEM ARTISTA!';
        END IF;

    END LOOP;

    return NULL;
end;
$$ language plpgsql;

CREATE TRIGGER trigger4
AFTER UPDATE OR DELETE ON Artista FOR EACH STATEMENT
EXECUTE PROCEDURE checkActivity();

-- -- Problema da atividade vazia:
DELETE FROM Artista WHERE id = 1;

-- -- Problema da atividade vazia:
-- UPDATE Artista set atividade = 2 WHERE id = 1;

-- -- Arenas
-- INSERT INTO Concerto values (1, 1, 1, '2020-11-10 00:00:00', '2020-11-10 00:00:10');
-- INSERT INTO Concerto values (2, 1, 2, '2020-11-10 00:00:00', '2020-11-10 00:00:05');
-- INSERT INTO Concerto values (3, 1, 3, '2020-11-10 00:00:00', '2020-11-10 00:00:30');

-- Artistas
-- INSERT INTO Concerto values (1, 1, 1, '2020-11-10 00:00:00', '2020-11-10 00:00:10');
-- INSERT INTO Concerto values (2, 2, 1, '2020-11-10 00:00:00', '2020-11-10 00:00:05');
-- INSERT INTO Concerto values (3, 3, 1, '2020-11-10 00:00:00', '2020-11-10 00:00:30');

-- -- Horários
-- INSERT INTO Concerto values (1, 1, 1, '2020-11-10 00:00:00', '2020-11-10 00:00:10');
-- INSERT INTO Concerto values (2, 2, 1, '2020-10-10 00:00:00', '2020-10-10 00:00:05');
-- INSERT INTO Concerto values (3, 3, 1, '2020-11-10 00:00:00', '2020-11-10 00:00:30');

