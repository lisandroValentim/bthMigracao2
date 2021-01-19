/* 
insert into public.controle_migracao_registro (sistema, tipo_registro, hash_chave_dsk, descricao_tipo_registro, id_gerado, i_chave_dsk1)
values ('300', 'configuracao-lotacao-fisica', md5(concat('300', 'configuracao-lotacao-fisica', '1')), 'Configuração de Lotação Física', 265, '1');
*/

select * from (
select *,ROW_NUMBER() OVER()::varchar as id,ROW_NUMBER() OVER()::varchar as codigo from (select
'Configuração Geral' as descricao,
'true' as emUso,
(select string_agg(nivel::varchar || '%|%' || descricao || '%|%' || quantidadeDigitos::varchar || '%|%' || separador,'%||%') from
        (select
        1 as nivel,
        'Código' as descricao,
        3 as quantidadeDigitos,
        'PONTO' as separador
    ) as suc) as niveis
        ) as a
        ) as b
        where (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'configuracao-lotacao-fisica',codigo))) is null
	                    