/* 
Escreva uma função em PL/pgSQL para operar sobre linhas de uma matriz. Essa função
deverá receber uma matriz �, dois índices de linhas � e � e duas constantes �! e �". O
resultado da função deverá ser a matriz � com a linha � substituída por uma combinação
linear das linhas � e � da seguinte forma: �#$ = �! ∗ �#$ + �" ∗ �%$, para � ∈
[1. . �������(�)].
 */
/**
 * Author:  João Victor Simonassi
 * Created: 10 de fev de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE matrix(
    val float[][]
);

CREATE OR REPLACE FUNCTION operateLines(matrixA float[][], lineM integer, lineN integer, c1 float, c2 float) RETURNS float[][] as $$
DECLARE
    linesMatrix integer;
    columnsMatrix integer;
    matrixResult float[][];
BEGIN
    SELECT array_length(matrixA, 1)INTO linesMatrix;
    SELECT array_length(matrixA, 2)INTO columnsMatrix;
    SELECT array_fill(0, ARRAY[linesMatrix, columnsMatrix]) INTO matrixResult;
    
    FOR i IN 1..linesMatrix LOOP
        FOR j IN 1..columnsMatrix LOOP
            IF i <> lineM THEN
                matrixResult[i][j] := matrixA[i][j];
            ELSE
                matrixResult[i][j] := c1 * matrixA[i][j] + c2 * matrixA[lineN][j];
            END IF;
        END LOOP;
    END LOOP;
    RETURN matrixResult;
END 
$$ LANGUAGE plpgsql;

INSERT INTO matrix VALUES ('{{3, 3, 3}, {1, 1, 1}, {5, 5, 5}}');

SELECT operateLines(matrix.val, 2, 1, 3, 2) FROM matrix;