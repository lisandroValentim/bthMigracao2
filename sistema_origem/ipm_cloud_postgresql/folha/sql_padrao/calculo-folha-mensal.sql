select * from ( select 
row_number() over() as id,
(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'entidade', 2016))) as entidade,
row_number() over(partition by matricula order by matricula asc, dataPagamento asc) as codigo,
* from (
	select distinct
	'MENSAL' AS tipoProcessamento,	 
	(case tipcodigo  when 8 then 'COMPLEMENTAR' when 10 then 'ADIANTAMENTO' else 'INTEGRAL' end) AS subTipoProcessamento,
	 null as dataAgendamento,
	 pagdata as dataPagamento,
	 'TEMPORAL' tipoVinculacaoMatricula,	 
	 (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'matricula', (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'entidade', 2016))), fcncodigo, funcontrato))) as matricula,	 
	 true as consideraAvosPerdidos,
	 null as saldoFgts,
	 false as fgtsMesAnterior,	 
	 substring(odomesano::varchar,1,4) || '-' || substring(odomesano::varchar,5,2) as competencia
	FROM wfp.tbpagamento
	where tipcodigo in (1,8,10)
--	and fcncodigo = 4714  	
) as a
) as b
where matricula is not null
and (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'rescisao',(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'entidade', 2016))),matricula,tipoProcessamento,subTipoProcessamento,dataPagamento))) is null
