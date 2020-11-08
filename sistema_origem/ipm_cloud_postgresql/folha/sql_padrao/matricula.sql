--create index idx_f_fc on wfp.tbfuncontrato (fcncodigo, odomesano);
--create index idx_fc_f on wfp.tbfuncionario (fcncodigo, odomesano);
--create index idx_f_fhs on wfp.tbfunhistoricosalarial (fcncodigo, odomesano);
--create index idx_fp_fc on wfp.tbfunpreviden (fcncodigo, odomesano);

select * from (select 
row_number() over() as id,
	fc.odomesano as competencia,
	fundataadmissao::varchar as database,
	regcodigo,
	(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300','vinculo-empregaticio',regcodigo::varchar))) as vinculoEmpregaticio,
	(case fc.regcodigo when 24 then 'true' when 20 then 'true' else 'false' end) as contratoTemporario,
	'NORMAL' as indicativoAdmissao,
	'URBANO' as naturezaAtividade,
	(case funtipocontrato when 10 then 'TRANSFERENCIA' else 'ADMISSAO' end) as tipoAdmissao,	
	 (case funtipoemprego when 1 then 'true' else  'false' end) as primeiroEmprego,
	 (case regcodigo when 1 then  'true' else	'false'	 end) as optanteFgts,
	fundataopcaofgts::varchar as dataOpcao,
	ifcsequenciafgts as contaFgts,
	unicodigocsi as sindicato,
	null as tipoProvimento,
	null as leiContrato,
	txjcodigo as atoContrato,
	fundatanomeacao::varchar as dataNomeacao,
	fundataposse::varchar as dataPosse,
	null as tempoAposentadoria,
	(case (select p.tpvcodigo from wfp.tbfunpreviden as p where p.funcontrato = fc.funcontrato and p.fcncodigo = fc.fnccodigo and p.odomesano = fc.odomesano ) when 1 then true when 6 then true else false end) as previdenciaFederal,
	(case (select p.tpvcodigo from wfp.tbfunpreviden as p where p.funcontrato = fc.funcontrato and p.fcncodigo = fc.fnccodigo and p.odomesano = fc.odomesano) when 3 then 'ESTADUAL' when 4 then 'FUNDO_ASSISTENCIA' when 5 then 'FUNDO_PREVIDENCIA' when 2 then 'FUNDO_FINANCEIRO' else null end) || '%|%' || (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'plano-previdencia', (select p.tpvcodigo from wfp.tbfunpreviden as p where p.funcontrato = fc.funcontrato and p.fcncodigo = fc.fnccodigo and p.odomesano = fc.odomesano)))) as previdencias,
	(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'cargo', carcodigo))) as cargo,
	null as cargoAlterado,
	txjcodigo as atoAlteracaoCargo,
	null as areaAtuacao,
	null as areaAtuacaoAlterada,
	null as motivoAlteracaoAreaAtuacao,
	(case funocupavaga when 1 then true else false end) as ocupaVaga,
	null as salarioAlterado,
	null as origemSalario,	
	(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'nivel-salarial', nivcodigo))) as nivelSalarial,
	null as classeReferencia,
	null as cargoComissionado,
	null as areaAtuacaoComissionado,
	false as ocupaVagaComissionado,
	null as salarioComissionado,
	null as nivelSalarialComissionado,
	null as classeReferenciaComissionado,
	'MENSALISTA' as unidadePagamento,
	(case funformapagamento when 2 then 'CREDITO_EM_CONTA'  when 3 then 'DINHEIRO' when 4 then 'CHEQUE' else 'DINHEIRO' end) as formaPagamento,
	ifcsequenciapaga as contaBancariaPagamento,
	(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'configuracao-ferias', 1))) as configuracaoFerias,
	cast(regexp_replace(funhorastrabmes, '\:\d{2}$', '', 'gi') as integer) as quantidadeHorasMes,
	(cast(regexp_replace(funhorastrabmes, '\:\d{2}$', '', 'gi') as integer)/5) as quantidadeHorasSemana,
	false as jornadaParcial,
	null as dataAgendamentoRescisao,
	null as funcoesGratificadas,
	null as dataTerminoContratoTemporario,
	null as motivoContratoTemporario,
	null as tipoInclusaoContratoTemporario,
	null as dataProrrogacaoContratoTemporario,
	funcartaoponto as numeroCartaoPonto,
	null as parametroPonto,
	null as indicativoProvimento,
	null as orgaoOrigem,
	null as matriculaEmpresaOrigem,
	null as dataAdmissaoOrigem,
	(case fc.funnocivos   when 0 then null   when 1 then 'NUNCA_EXPOSTO_AGENTES_NOCIVOS'  when 2 then 'EXPOSTO_APOSENTADORIA_15_ANOS'  when 5 then 'EXPOSTO_APOSENTADORIA_15_ANOS'     when 3 then 'EXPOSTO_APOSENTADORIA_20_ANOS'  when 7 then 'EXPOSTO_APOSENTADORIA_20_ANOS'   when 4 then 'EXPOSTO_APOSENTADORIA_25_ANOS'    when 8 then 'EXPOSTO_APOSENTADORIA_25_ANOS'    else     null    end) as ocorrenciaSefip,
	null as controleJornada,
	null as configuracaoLicencaPremio,
	null as configuracaoAdicional,
	null as processaAverbacao,
	null as dataFinal,
	null as dataProrrogacao,
	null as instituicaoEnsino,
	null as agenteIntegracao,
	null as formacao,
	null as formacaoPeriodo,
	null as formacaoFase,
	null as estagioObrigatorio,
	null as objetivo,
	fc.funcontrato as numeroContrato,
	null as possuiSeguroVida,
	null as numeroApoliceSeguroVida,
	null as categoriaTrabalhador,
	null as responsaveis,
	null as dataCessacaoAposentadoria,
	null as entidadeOrigem,
	null as motivoAposentadoria,
	null as funcionarioOrigem,
	null as tipoMovimentacao,
	null as motivoInicioBeneficio,
	null as duracaoBeneficio,
	null as dataCessacaoBeneficio,
	null as motivoCessacaoBeneficio,
	null as matriculaOrigem,
	null as responsavel,
	fundataadmissao::varchar as dataInicioContrato,
	(CASE fc.funsituacao WHEN  1 THEN 'TRABALHANDO'  WHEN 2 THEN 'AFASTADO' ELSE 'DEMITIDO' end) as situacao,
	'2020-11-01 00:00:00' as inicioVigencia,
	(CASE fc.funtipocontrato WHEN  1 THEN 'FUNCIONARIO'  	WHEN 2 THEN 'ESTAGIARIO' 	WHEN 3 THEN 'PENSIONISTA'	WHEN 4 THEN 'APOSENTADO'	WHEN 5 THEN 'REINTEGRACAO'	WHEN 6 THEN 'TRANSFERENCIA'	WHEN 7 THEN 'MENOR_APRENDIZ'	WHEN 8 THEN 'CEDIDO'	WHEN 9 THEN 'CEDIDO'	WHEN 10 THEN 'RECEBIDO'	WHEN 11 THEN 'RECEBIDO'	WHEN 12 THEN 'PREVIDENCIA'	ELSE 'FUNCIONARIO' end) as tipo, 
	(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'pessoa-fisica', (select regexp_replace(u.unicpfcnpj,'[/.-]','','g') from  wun.tbunico u where u.unicodigo  = fc.unicodigo limit 1))))  as pessoa,
	(fc.funcontrato || '%|%' || '0' || '%|%' || fc.fcncodigo ) as codigoMatricula,
	null as eSocial,
	null as grupoFuncional,
	null as jornadaTrabalho,
	-- coalesce(funsalariobase,(select fhssalario from wfp.tbfunhistoricosalarial as fhs where fhs.fcncodigo = fc.fnccodigo and fhs.odomesano = fc.odomesano order by fhsdatahora desc limit 1)) as rendimentoMensal,
	coalesce(funsalariobase,(select nivsalariobase from wfp.tbnivel n where n.nivcodigo = fc.nivcodigo and n.odomesano = fc.odomesano)) as rendimentoMensal,
	(select txjcodigo from wfp.tbfunhistoricosalarial as fhs where fhs.fcncodigo = fc.fnccodigo and fhs.odomesano = fc.odomesano order by fhsdatahora desc  limit 1) as atoAlteracaoSalario,
	(select mtrcodigo from wfp.tbfunhistoricosalarial as fhs where fhs.fcncodigo = fc.fnccodigo and fhs.odomesano = fc.odomesano order by fhsdatahora desc limit 1) as motivoAlteracaoSalario, 
	null as validationStatus,		
	(select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300','organograma', (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300','configuracao-organograma', 1)))::varchar,(select left((c.organo::varchar || regexp_replace(c.cncclassif, '[\.]', '', 'gi') || '000000000000000'),15) from wun.tbcencus as c where c.cnccodigo = fc.cnccodigo limit 1)::varchar))) as organograma,
	null as lotacoesFisicas,
	null as historicos
from wfp.tbfuncontrato as fc  join wfp.tbfuncionario as f on f.fcncodigo = fc.fcncodigo and f.odomesano = fc.odomesano
--where fc.odomesano = 202009
where fc.fcncodigo = 15011
) as s
where (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'matricula', codigoMatricula, numeroContrato))) is null
and pessoa is not null
and situacao = 'TRABALHANDO'
--limit 1
