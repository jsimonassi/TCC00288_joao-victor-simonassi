/* 
 Escreva uma função PL/pgSQL que retorne uma relação com esquema {i,numero}
contendo os n primeiros números da sequência de Fibonacci, onde n é informado como
parâmetro.
 */
/**
 * Author:  Joao Victor Simonassi
 * Created: 10 de fev de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE OR REPLACE FUNCTION fibonacci(n integer) RETURNS TABLE(i integer, num integer) AS $$
DECLARE
    num integer;
    before1 integer;
    before2 integer;
BEGIN
    before1 := 1;
    before2 := 0;
    FOR i IN 1..n LOOP
        IF i = 1 THEN
            RETURN query SELECT i, before1;
        ELSE
            num := before1 + before2;
            before2 := before1;
            before1 := num;
            RETURN query SELECT i, num;
        END IF;
    END LOOP;
    RETURN;
END
$$ LANGUAGE plpgsql;

SELECT * FROM fibonacci(30);