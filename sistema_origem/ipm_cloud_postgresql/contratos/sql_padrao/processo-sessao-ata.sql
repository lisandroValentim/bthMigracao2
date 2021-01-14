select
	row_number() over() as id,
	'305' as sistema,
	'processo-participante-proposta' as tipo_registro,
	'@' as separador,
	*
from (
  select
  	a.clicodigo,
  	a.minano as ano_processo,
  	a.minnro as nro_processo,
  	a.aprsequencia as sequencial,
  	concat(a.minnro, a.aprsequencia)::integer as nro_ata,
  	left(a.aprdata::varchar, 4)::integer as ano_ata,
  	coalesce (a.aprobservacao, 'MIGRACAO CLOUD - ATA SEM TEXTO') as texto_ata,
  	(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, 'processo', a.clicodigo, a.minano, a.minnro))) as id_processo,
  	(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, 'processo-sessao', a.clicodigo, a.minano, a.minnro))) as id_sessao,
  	386 as tipo_ata,
  	(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, 'processo-sessao-ata', a.clicodigo, a.minano, a.minnro, '@', a.aprsequencia))) as id_gerado
  from wco.tbatalicitacao a
  order by 1, 2 desc, 3 desc
) tab
where id_gerado is null
and id_processo is not null
and id_sessao is not null