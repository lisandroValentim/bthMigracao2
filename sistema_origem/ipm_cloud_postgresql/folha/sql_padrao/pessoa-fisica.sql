select * from
(
	select
	u.unicodigo as id,
	u.unicodigo as codigo,
	u.uninomerazao as nome,
	replace(replace(replace(u.unicpfcnpj,'/',''),'-',''),'.','') as cpf,
	uf.unfdatanascimento as dataNascimento,
	(case uf.unfestadocivil when 1 then 'SOLTEIRO' when 2 then 'CASADO' when 3 then 'SEPARADO_CONSENSUALMENTE' when 4 then 'DIVORCIADO' when 5 then 'VIUVO' when 6 then 'UNIAO_ESTAVEL' else null end) as estadoCivil,
	(case uf.unfsexo when 1 then 'MASCULINO' when 2 then 'FEMININO' else null end) as sexo,
	(case uf.unfcorpele when 1 then 'BRANCA' when 2 then 'PRETA' when 3 then 'AMARELA' when 4 then 'PARDA' when 5 then 'INDIGENA' else null end) as raca,
	(case uf.unfcorolhos when 1 then 'PRETO' when 2 then 'AZUL' when 3 then 'CASTANHO' when 4 then 'VERDE' else null end) as corOlhos,
	replace(cast(uf.unfaltura as varchar),',','.') as estatura,
	replace(cast(uf.unfpeso as varchar),',','.') as peso,
	(case uf.unftiporh when 1 then 'A' when 2 then 'B' when 3 then 'AB' when 4 then 'O' else null end) || (case uf.unffatorrh when 1 then 'P' when 2 then 'N' else null end) as tipoSanguineo,
	null as doador,
	cast(uf.unfnacionalidade as varchar) as nacionalidade,
	uf.paisiglaorigem as paisNascimento,
	cast(uf.cidcodigonatural as varchar) as naturalidade,
	uf.unfdatachegada as dataChegada,
	(case uf.unfnaturalizado when 0 then 'NAO' when 1 then 'SIM' else null end) as naturalizado,
	null as casadoComBrasileiro,
	null as temFilhosBrasileiros,
	null as situacaoEstrangeiro,
	null as inscricaoMunicipal,
	u.unirgie as identidade,
	uf.unfrgorgaoemissor as orgaoEmissorIdentidade,
	uf.estcodigoemissaorg as ufEmissaoIdentidade,
	uf.unfrgdataemissao as dataEmissaoIdentidade,
	null as dataValidadeIdentidade,
	uf.unfnrotitulo as tituloEleitor,
	uf.unfzonatitulo as zonaEleitoral,
	uf.unfsecaotitulo as secaoEleitoral,
	cast(uf.unfnroctps as varchar) as ctps,
	uf.unfseriectps as serieCtps,
	uf.estcodigoemissaoctps as ufEmissaoCtps,
	uf.unfdataemissaoctps as dataEmissaoCtps,
	null as dataValidadeCtps,
	cast(uf.unfpispasep as varchar) as pis,
	null as dataEmissaoPis,
	(case when uf.gincodigo in (2) then 'NAO_ALFABETIZADO' when uf.gincodigo in (3,4) then 'ENSINO_FUNDAMENTAL_ANOS_FINAIS' when uf.gincodigo in (5,6) then 'ENSINO_MEDIO' when uf.gincodigo in (7,8) then 'ENSINO_SUPERIOR_SEQUENCIAL' when uf.gincodigo in (9) then 'POS_GRADUACAO_ESPECIALIZACAO' when uf.gincodigo in (10) then 'POS_GRADUACAO_MESTRADO' when uf.gincodigo in (11) then 'POS_GRADUACAO_DOUTORADO' when uf.gincodigo in (12) then 'ENSINO_FUNDAMENTAL_ANOS_INICIAIS' when uf.gincodigo in (13) then 'ENSINO_FUNDAMENTAL_ANOS_INICIAIS' when uf.gincodigo in (14) then 'ENSINO_FUNDAMENTAL_ANOS_FINAIS' when uf.gincodigo in (15) then 'ENSINO_PROFISSIONALIZANTE' when uf.gincodigo in (16) then 'ENSINO_PROFISSIONALIZANTE' when uf.gincodigo in (17) then 'POS_DOUTORADO_HABILITACAO'else null end) as grauInstrucao,
	(case when uf.gincodigo in (1,2,3,5,7,12,14,15) then 'INCOMPLETO' when uf.gincodigo in (4,6,8,9,10,11,13,16,17) then 'COMPLETO' else null end) as situacaoGrauInstrucao,
	uf.unfnrocreservista as certificadoReservista,
	uf.unfcatcreservista as ric,
	null as ufEmissaoRic,
	uf.unforgaocreservista as orgaoEmissorRic,
	uf.unfemissaocreser as dataEmissaoRic,
	uf.unfcartaosus as cns,
	null as dataEmissaoCns,
	cast(uf.unfcnhnumero as varchar) as cnh,
	uf.unfcnhcategoria as categoriaCnh,
	null as dataEmissaoCnh,
	uf.unfcnhdatavalidade as dataVencimentoCnh,
	null as dataPrimeiraCnh,
	uf.estcodigoemissaocnh as ufEmissaoCnh,
	uf.unfcnhobs as observacoesCnh,
	null as papel,
	(select string_agg('Email' || (case suc.linha when 1 then '' else ' ' || cast(suc.linha as varchar) end) || '%|%' || suc.uncdescricao || '%|%' || (CASE suc.linha when 1 then 'true' else 'false' end),'%||%') from (select row_number() OVER (partition by uc.unicodigo order by uc.unicodigo desc) as linha,uc.uncdescricao,uc.unctipocontato,uc.unicodigo from wun.tbunicocontato as uc where unctipocontato = 5) as suc where length(trim(suc.uncdescricao)) > 0 and suc.unicodigo = u.unicodigo group by suc.unicodigo order by suc.unicodigo desc) as emails,
	(select string_agg('Telefone' || (case suc.linha when 1 then '' else ' ' || cast(suc.linha as varchar) end) || '%|%' || (CASE suc.unctipocontato when 1 then 'FIXO' when 2 then 'CELULAR' when 3 then 'FIXO' when 4 then 'FAX' end) || '%||%' || suc.uncdescricao || '%|%' || suc.unccomplemento || '%|%' || (CASE suc.linha when 1 then 'true' else 'false' end),'%||%') from (select row_number() OVER (partition by uc.unicodigo order by uc.unicodigo desc) as linha,replace(replace(replace(replace(replace(uc.uncdescricao,'-',''),'.',''),')',''),'(',''),' ','') as uncdescricao,uc.unctipocontato,uc.unicodigo,uc.unccomplemento from wun.tbunicocontato as uc where uc.unctipocontato in (1,2,3,4)) as suc where length(trim(suc.uncdescricao)) > 0 and suc.unicodigo = u.unicodigo group by suc.unicodigo order by suc.unicodigo desc) as telefones
from
	wun.tbunico as u join wun.tbunicofisica as uf on uf.unicodigo = u.unicodigo
where
	u.unitipopessoa = 1
and
	u.unisituacao = 1
and
	length(replace(replace(replace(replace(u.unicpfcnpj,'/',''),'-',''),'.',''),'0','')) > 0
and
	uf.unfsexo in (1,2)
and
	uf.unfdatanascimento is not null
) as a
limit 10 offset 0