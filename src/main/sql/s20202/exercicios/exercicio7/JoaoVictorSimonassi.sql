/* 
Implemente uma função em PL/pgSQL para transpor uma matriz. A função deve receber
uma matriz do tipo float[][] e retornar outra matriz do tipo float[][].
 */
/**
 * Author:  João Victor Simonassi
 * Created: 10 de fev de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE matrix (
    content float[][]
);

CREATE OR REPLACE FUNCTION transpose(matrix float[][])
    RETURNS float[][]
    AS $$
DECLARE
    m_i integer;
    m_j integer;
    transposed_matrix float[][];
BEGIN
    SELECT 
        ARRAY_LENGTH(matrix, 1) INTO m_i;
    SELECT
        CARDINALITY(matrix[1][1:]) INTO m_j;
    
    IF m_i = 0 THEN
        RAISE EXCEPTION 'Erro';
    END IF;

    SELECT array_fill(0, ARRAY[m_j, m_i]) INTO transposed_matrix;
    
    FOR j IN 1..m_j
        LOOP
        FOR i in 1..m_i
            LOOP
                transposed_matrix[j][i] := matrix[i][j];
            END LOOP;
        END LOOP;
   RETURN transposed_matrix;
END;
$$
LANGUAGE PLPGSQL;

INSERT INTO matrix (content) VALUES (ARRAY[[1,2,5],[4,3,6],[0,2,8]]);

SELECT transpose(matrix.content) FROM matrix;