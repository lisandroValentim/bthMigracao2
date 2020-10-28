select *,ROW_NUMBER() OVER()::varchar as id,ROW_NUMBER() OVER()::varchar as codigo from (select
'Configura��o Organograma 2020' as descricao,
            'true' as emUso,
                (select string_agg(nivel::varchar || '%|%' || descricao || '%|%' || quantidadeDigitos::varchar || '%|%' || separador || '%|%' || responsavelControleVagas || '%|%' || nivelSecretaria,'%||%') from
	                    (select 3 as nivel,
	                    'Centro de Custo' as descricao,
	                    3 as quantidadeDigitos,
	                    'PONTO' as separador,
	                    false as responsavelControleVagas,
	                    false as nivelSecretaria
	                union                                       
	                     select 4 as nivel,
	                    'Centro de Custo Pai' as descricao,
	                    3 as quantidadeDigitos,
	                    'PONTO' as separador,
	                    false as responsavelControleVagas,
	                    false as nivelSecretaria
	             union                                     
						select 5 as nivel,
	                    'Secretaria' as descricao,
	                    3 as quantidadeDigitos,
	                    'PONTO' as separador,
	                    true as responsavelControleVagas,
	                    false as nivelSecretaria
	                union      
						select 2 as nivel,
	                    'Unidade' as descricao,
	                    3 as quantidadeDigitos,
	                    'PONTO' as separador,
	                    false as responsavelControleVagas,
	                    true as nivelSecretaria
	             union                 
						select 1 as nivel,
	                    '�rg�o' as descricao,
	                    2 as quantidadeDigitos,
	                    'PONTO' as separador,
	                    false as responsavelControleVagas,
	                    false as nivelSecretaria) as suc) as niveis
	                    ) as a