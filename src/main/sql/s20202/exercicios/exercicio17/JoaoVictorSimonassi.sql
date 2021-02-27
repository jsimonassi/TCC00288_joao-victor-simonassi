/**
 * Author:  João Victor Simonassi
 * Created: 27 de fev de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE produto(
    codigo VARCHAR,
    descricao VARCHAR,
    preco FLOAT
);

INSERT INTO produto VALUES  (1,'MacBookPro 2021', 20000),
                            (2,'MacBookAir 2021', 17000),
                            (3,'Avell A62', 8000),
                            (4,'DELL G3', 6500),
                            (5,'Positivo Motion', 50);

DROP FUNCTION IF EXISTS calcular_preco;
CREATE OR REPLACE FUNCTION calcular_preco(cod_prods varchar[], qtds INTEGER[])
RETURNS FLOAT AS $$
    DECLARE
        ans FLOAT; 
    BEGIN
        SELECT SUM(produto.preco * t.qtd)FROM produto, (SELECT t.* FROM unnest(cod_prods, qtds) as t(codigo,qtd)) as t
            WHERE produto.codigo = t.codigo INTO ans;
        RETURN ans;
    END;
$$ LANGUAGE plpgsql;

SELECT calcular_preco('{"1", "2"}', '{1, 2}');-- 01 macPro e 2 macAir - esperado 54k
SELECT calcular_preco('{"1", "2", "3"}', '{1, 2, 3}');-- 01 macPro, 2 Air e 3 Avell - esperado 78k
SELECT calcular_preco('{"1", "2", "3", "4"}', '{1, 2, 3, 4}');-- 01 Pro, 02 Air, 03 Avell, 04 Dell - Esperado 104k
SELECT calcular_preco('{"1", "2", "3", "4", "5"}', '{1, 2, 3, 4, 5}');-- 01 Pro, 02 Air, 03 Avell, 04 Dell, 5 Positivo - Esperado 104.250
