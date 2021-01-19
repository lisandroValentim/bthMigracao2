select distinct
	*
from (
	select
	regcodigo as id,
	regcodigo as codigo,	
	(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'entidade', 11968))) as entidade,
	regdescricao||' ('||regcodigo::varchar||')' as descricao,
	(case cascodigo when 21 then 'REGIME_PROPRIO' when 1  then 'CLT' else 'OUTROS' end) as tipo,
	null as descricaoRegimePrevidenciario,
    coalesce((select id_gerado
	   from public.controle_migracao_registro
	  where hash_chave_dsk = md5(concat('300','categoria-trabalhador',
	  						(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'entidade', 11968))),
	  						(select left(c.catdescricao,100)
	  						   from wfp.tbcategoriatrabalhador as c
	  						where c.catcodigo = coalesce (r.catcodigo,case regcodigo
	  						when 1 then 101
	  						when 2 then 301
	  						when 20 then 301
	  						when 23 then 306
	  						when 21 then 306
	  						when 25 then 309
	  						when 14 then 904
	  						when 22 then 904
	  						when 27 then 771
	  						else 0
	  						end)), coalesce(catcodigo,case regcodigo
	  						when 1 then 101
	  						when 2 then 301
	  						when 20 then 301
	  						when 23 then 306
	  						when 21 then 306
	  						when 25 then 309
	  						when 22 then 904
	  						when 14 then 904
	  						when 27 then 771
	  						else 0
	  						end)::varchar))),(select id_gerado
	   from public.controle_migracao_registro
	  where hash_chave_dsk = md5(concat('300','categoria-trabalhador',
	  						(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'entidade', 11968))),'MIGRAÇÃO',987)))) as categoriaTrabalhador,
	'EMPREGADO' as sefip,
	'true' as geraRais,
	'TRABALHADOR_URBANO_VINCULADO_PESSOA_JURIDICA_CONTRATO_TRABALHO_CLT_PRAZO_INDETERMINADO' as rais,
	(CASE
     when regcodigo in(1,2,5,8,10,15,19,21,23,24,25,27) then 'true'
     else 'false'
    end ) as vinculoTemporario,
	(CASE
     when regcodigo in(1,2,5,8,10,15,19,21,23,24,25,27) then '6368' -- ajustar par final
     else null
    end ) as motivoRescisao, -- REFERENCIAR TABELA DE MOTIVO DE RESCISÃO
	false as dataFinalObrigatoria,
	(case cascodigo when 1  then 'true' else 'false' end) as geraCaged,
	'true' as geraLicencaPremio
	from wfp.tbregime as r
	where odomesano = 202012
  	  --and regcodigo not in(3,4,6,7,10,11,12,16,17,18,22,26,28) -- Específico Biguacu
) as a
where (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300','vinculo-empregaticio', entidade, codigo))) is null;