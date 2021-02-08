/* 
O determinante de uma matriz quadrada Anxn pode ser calculado pela regra de Laplace
segundo a fórmula a seguir.
...
onde Aij é a submatriz de A retirando-se a i-ésima linha e a j-ésima coluna. A soma é calculada
para uma linha i qualquer da matriz A. Considerando uma função já escrita para o cálculo de
Aij, escreva uma função em PL/pgSQL para calcular o determinante de uma matriz quadrada
A. A função determinante() deve ser recursiva.
 */
/**
 * Author:  João Victor Simonassi
 * Created: 8 de fev de 2021
 */

CREATE OR REPLACE FUNCTION deleteRowAndColumn(i integer, j integer, M float[][]) RETURNS float[][] as $$
DECLARE
    linesMat integer;
    columnsMat integer;
    line float[];
    matResult float[][];
BEGIN
    SELECT array_length(M, 1) INTO linesMat;
    SELECT array_length(M, 2)INTO columnsMat;
    matResult := array_fill(0, ARRAY[0,0]);
    FOR x IN 1..linesMat LOOP
        line := '{}';
        IF x <> i THEN
            FOR y IN 1..columnsMat LOOP
                IF y <> j THEN
                    line := array_append(line, M[x][y]);
                END IF;
            END LOOP;
            matResult := array_cat(matResult, ARRAY[line]);
        END IF;
    END LOOP;
    RETURN matResult;
END 
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION determinant(mat float[][]) RETURNS float as $$
DECLARE
    x integer;
    columnsMat integer;
    det float;
BEGIN
    SELECT array_length(mat, 2)INTO columnsMat;
    x := 1;
    det := 0;

    IF columnsMat > 0 THEN
        FOR y IN 1..columnsMat LOOP
            IF ((x + y)%2 = 1) THEN
                det := det + (mat[x][y] * (-1) * determinant(deleteRowAndColumn(x, y, mat)));
            ELSE
                det := det + (mat[x][y] * determinant(deleteRowAndColumn(x, y, mat)));
            END IF;
        END LOOP;
    ELSE
        det := 1;
    END IF;
    RETURN det;
END 
$$ LANGUAGE plpgsql;

select determinant('{{1, 3}, {2, 9}}');