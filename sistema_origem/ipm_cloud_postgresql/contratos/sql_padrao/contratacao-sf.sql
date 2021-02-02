select
	row_number() over() as id,
	'305' as sistema,
	'contratacao-sf' as tipo_registro,
	concat(nro_minuta, '/', ano_minuta) as minuta,
	concat(nro_contrato, '/', ano_contrato, ' (', identificador_contrato, ')') as contrato,
	concat(nro_sf, '/', ano_sf) as sf,
	'@' as separador,
	*
from (
	select
		c.clicodigo,
		c.minano as ano_minuta,
		c.minnro as nro_minuta,
		ct.ctrano as ano_contrato,
		ct.ctrnro as nro_contrato,
		ct.ctridentificador as identificador_contrato,
		c.copano as ano_sf,
		c.copnro as nro_sf,
		c.copdataemissao::varchar as data_sf,
		c.unicodigo,
		concat(c.copfinalidade, c.cophistorico, ' (Migração: ', c.copnro, '/', c.copano, ').') as observacao,
		c.coplocalentrega,
		c.cnccodigo,
		cc.cncclassif as nro_ogranograma,
		(select u.uninomerazao from wun.tbunico u where u.unicodigo = (select usr.unicodigo from webbased.tbusuario usr where usr.usucodigo = c.usucodigo)) as solicitante,
		(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, 'contratacao', c.clicodigo, ct.ctrano, ct.ctridentificador))) as id_contratacao,
		(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, 'centro-custo',c.copano, replace(cc.cncclassif,'.','')))) as id_organograma,
		(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('305', 'fornecedor', (regexp_replace(u.unicpfcnpj,'[/.-]|[ ]','','g'))))) as id_fornecedor,
		(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('305', 'entidade', c.clicodigo))), upper(unaccent(left(coalesce(trim(c.coppreventrega),'Imediata'), 50)))))) as id_prazo_entrega,
		14011 as id_local_entrega,
		md5(concat(305, 'contratacao-sf', c.clicodigo, ct.ctrano, ct.ctridentificador, '@', c.copano, c.copnro)) as hash,
		(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, 'contratacao-sf', c.clicodigo, ct.ctrano, ct.ctridentificador, '@', c.copano, c.copnro))) as id_gerado
	from wco.tbcompra c
	inner join wco.tbcontrato ct on (ct.clicodigo = c.clicodigo and ct.minano = c.minano and ct.minnro = c.minnro and ct.unicodigo = c.unicodigo)
	left join wun.tbcencus cc on (cc.organo = c.copano and cc.cnccodigo = c.cnccodigo)
	left join wun.tbunico u on (u.unicodigo = c.unicodigo)
	where c.clicodigo = {{clicodigo}}
	and c.minano = {{ano}}
	and c.minnro = 62
	and c.minano is not null
	and c.minnro is not null
	and ct.ctrtipoaditivo is null -- Esse filtro faz com que não sejam enviadas solicitação vinculadas a aditivos
	order by 1, 2 desc, 3 desc, 4 desc, 5 desc, 6 desc, 7 desc
) tab
where id_gerado is null
and id_contratacao is not null
and id_organograma is not null
and id_fornecedor is not null
limit 1