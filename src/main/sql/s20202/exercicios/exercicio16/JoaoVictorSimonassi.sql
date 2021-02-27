/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  joao.farias
 * Created: 27 de fev de 2021
 */

DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table produto(
    id bigint not null,
    nome varchar not null);

create table venda(
    "data" timestamp not null,
    produto bigint not null,
    qtd integer not null);

--Lembrar de tirar dúvidas sobre essa questão