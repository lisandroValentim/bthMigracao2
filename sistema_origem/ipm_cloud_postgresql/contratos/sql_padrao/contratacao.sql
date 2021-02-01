select
	row_number() over() as id,
	'305' as sistema,
	'contratacao' as tipo_registro,
	concat(nro_contrato, '/', ano_contrato) as contrato,
	concat(nro_processo, '/', ano_processo) as processo,
	concat(nro_ata, '/', ano_ata) as ata,
	*
from (
	select
		c.clicodigo,
		c.ctrano as ano_contrato,
		c.ctridentificador as nro_contrato,
		c.ctrano as ano_termo,
		c.ctridentificador as nro_termo,
		c.ctrnro,
		c.minano as ano_processo,
		c.minnro as nro_processo,
		rp.arpano as ano_ata,
		rp.arpnro as nro_ata,
		left(c.ctrobjetotc, 500) as objeto,
		u.unicpfcnpj,
		t.mintipoobjeto,
		'QUANTIDADE' AS tipo_controle_saldo,
		c.ctrdataassinatura::varchar as dt_assinatura,
		c.ctrdatainivig::varchar as dt_inicio_vigencia,
		c.ctrdatavencto::varchar as dt_fim_vigencia,
		(case
			when c.ctrvalor <> 0 then c.ctrvalor
			else (select sum(v.qcpvlrtotal) from wco.vw_qcp_vencedor v where v.clicodigo = c.clicodigo and v.minano = c.minano and v.minnro = c.minnro and v.unicodigo = c.unicodigo)
		end) as valor_original,
		coalesce((select true from wco.tbcontratocoronavirus cv where cv.clicodigo = c.clicodigo and cv.ctrano = c.ctrano and cv.ctridentificador = c.ctridentificador limit 1), false) as coronavirus,
		'PROCESSO_ADMINISTRATIVO' as origem,
		concat('Contratação ', c.ctridentificador, '/', c.ctrano, ' (', c.ctrnro, ')') as observacao,
		(case when c.ctrdataassinatura is null then 'AGUARDANDO_ASSINATURA' else 'EXECUCAO' end) as situacao,
		(case t.mintipoconcorrencia when 2 then 'REGISTRO_PRECO' else 'PROCESSO' end) as instrumento,
		(case t.mintipoconcorrencia when 2 then 20 else 22 end) as id_tipo_instrumento, -- 22=TermoContrato, 20=RegistroPreço
		(case t.mintipoconcorrencia when 2 then 160 else 0 end) as id_fundamentacao_legal,
		(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, 'processo', c.clicodigo, c.minano, c.minnro))) as id_processo,
		coalesce((select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305,'tipo-objeto', (case t.mintipoobjeto when 1 then 'Compras e Outros Serviços' when 2 then 'Obras e Serviços de Engenharia' when 3 then 'Concessoes e Permissões de Serviços Públicos' when 4 then 'Alienação de bens' when 5 then 'Concessão e Permissão de Uso de Bem Público' when 6 then 'Aquisição de bens' when 7 then 'Contratação de Serviços'  else 'Compras Outros Serviços' end)))), 10) as id_tipo_objeto,
		(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('305', 'fornecedor', (regexp_replace(u.unicpfcnpj,'[/.-]|[ ]','','g'))))) as id_fornecedor,
		(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, 'entidade', c.clicodigo))) as id_entidade,
		coalesce((select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, 'ata-rp', rp.clicodigo, rp.arpano, rp.arpnro, rp.unicodigo))), 0) as id_ata,
		(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat(305, 'contratacao', c.clicodigo, c.ctrano, c.ctridentificador))) as id_gerado
	from wco.tbcontrato c
	inner join wun.tbunico u on (u.unicodigo = c.unicodigo)
	left join wco.tbminuta t on (t.clicodigo = c.clicodigo and t.minano = c.minano and t.minnro = c.minnro)
	left join wco.tbataregpreco rp on (rp.clicodigo = c.clicodigo and rp.minano = c.minano and rp.minnro = c.minnro and rp.unicodigo = c.unicodigo)
	where c.clicodigo = {{clicodigo}}
	and c.ctrano = {{ano}}
	and c.ctrtipoaditivo is null
	and c.minano is not null
	and c.minnro is not null
	--and c.ctridentificador in (231, 208)
	order by 1, 2 desc, 3 desc
) tab
where id_gerado is null
and id_entidade is not null
and id_processo is not null
and id_fornecedor is not null
and instrumento = 'PROCESSO'
--limit 5