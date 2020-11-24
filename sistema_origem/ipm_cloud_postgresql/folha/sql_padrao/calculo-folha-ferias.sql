select * from ( select 
row_number() over() as id,
(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'entidade', 2016))) as entidade,
(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'periodo-aquisitivo-ferias',(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'entidade', 2016))),matricula,datainicial))) as periodos,
row_number() over(partition by matricula order by matricula asc, dataPagamento asc) as codigo,
* from (
	select distinct
	'FERIAS' AS tipoProcessamento,	 
	'INTEGRAL' AS subTipoProcessamento,
	 null as dataAgendamento,
	 pagdata as dataPagamento,
	 'INDIVIDUAL' tipoVinculacaoMatricula,	 
	 (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'matricula', (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'entidade', 2016))), fcncodigo, funcontrato))) as matricula,	 
	 true as consideraAvosPerdidos,
	 null as saldoFgts,
	 false as fgtsMesAnterior,	 
	 (select fg.ferdatainicio from wfp.tbferiasgozada as fg where fg.odomesano = 202010 and fg.fcncodigo = p.fcncodigo and fg.funcontrato = p.funcontrato and fg.fgodatainicio between pagdata and pagdata) as datainicial,	 
	 --substring(odomesano::varchar,1,4) || '-' || substring(odomesano::varchar,5,2) as competencia
	 substring(pagdata::varchar,1,7) as competencia
	FROM wfp.tbpagamento as p
	where tipcodigo in (2)
and fcncodigo = 4714  	
) as a
) as b
where matricula is not null
and (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'rescisao',(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'entidade', 2016))),matricula,tipoProcessamento,subTipoProcessamento,dataPagamento))) is null
