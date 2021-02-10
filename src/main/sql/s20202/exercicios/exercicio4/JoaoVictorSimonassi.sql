/* 
Escreva uma função PL/pgSQL para excluir uma linha i e uma coluna j de uma matriz m,
onde i, j e m são informados como parâmetros da função.

Dicas:
1. linha = array_append(linha,e) inclui o elemento e no vetor linha
2. m = array_cat(m,array[linha]) inclui o vetor linha na matriz m
 */
/**
 * Author:  João Victor Simonassi
 * Created: 8 de fev de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE FUNCTION deleteRowAndColumn(INTEGER[][],INTEGER, INTEGER) RETURNS INTEGER[][] AS $$
    DECLARE
        response INTEGER[][];
        i INTEGER:= 1;
        j INTEGER:= 1;
    BEGIN
        RAISE NOTICE 'Matriz recebida: %', ($1);
        RAISE NOTICE 'Removendo linha: % e coluna: %', ($2), ($3);
        response := array_fill(null::integer, ARRAY[array_length(($1), 1)-1,array_length(($1), 2)-1]);

        FOR currentRow IN 1..array_length(($1), 1) LOOP
            FOR currentColumn IN 1..array_length(($1), 2) LOOP
                IF((currentRow != ($2)) AND (currentColumn != ($3))) THEN
                    response[i][j] = ($1)[currentRow][currentColumn];
                    j = j+1;
                END IF;
            END LOOP;
            IF(response[i][1] IS NOT NULL) THEN
                i = i + 1;
            END IF;
            j = 1;
        END LOOP;
    RETURN response;
END;
$$ LANGUAGE plpgsql;

--                                      (Matriz, linha, coluna)
SELECT deleteRowAndColumn((ARRAY[[1,2,3],[4,5,6],[7,8,9],[10,11,12],[13,14,15]]), 1, 1);