select
	'300' as sistema,
	'concurso' as tipo_registro,
	numero_edital as chave_dsk1,
	tipoRecrutamento as chave_dsk2,
	*
from (
    select distinct
		 1 as id,
		 --(select txjementa from wlg.tbtextojuridico where tbconcurso.txjcodigo = tbtextojuridico.txjcodigo) as descricao,
		 CASE (select asscodigo from wlg.tbtextojuridico where tbconcurso.txjcodigo = tbtextojuridico.txjcodigo)
			 WHEN 60 THEN 'PROCESSO_SELETIVO'
			 WHEN 58 THEN 'CONCURSO_PUBLICO'
		 END as tipoRecrutamento,
		 (CASE (select asscodigo from wlg.tbtextojuridico where tbconcurso.txjcodigo = tbtextojuridico.txjcodigo)
			 WHEN 60 THEN 'Processo seletivo '
			 WHEN 58 THEN 'Concurso público '
		 END) || (CAST(ato.txjnumero as text) || '/' || CAST(ato.txjano as text)) as descricao,
		tcodataedital as dataInicialInscricao,
		 tcodataedital as dataFinalInscricao,
		 tcodataedital as dataProrrogacao,
		 tcodatahomolog as dataHomologacao,
		 tcodatavalidade as dataValidade,
		 tcodatavalidade as dataProrrogacaoValidade,
		 tcodataedital as dataInicialInscricaoPcd,
		 tcodataedital as dataFinalInscricaoPcd,
		 tcodatahomolog as dataEncerramento,
		 (CAST(ato.txjnumero as text) || '/' || CAST(ato.txjano as text)) as numero_edital,
		 (select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'ato', (CAST(ato.txjnumero as text) || '/' || CAST(ato.txjano as text))))) as ato,
		 tcopercendef as percentualPcd
	from wfp.tbconcurso
	inner join wlg.tbtextojuridico ato on (ato.txjcodigo = tbconcurso.txjcodigo)
) tab
where COALESCE((select id_gerado from public.controle_migracao_registro where hash_chave_dsk = md5(concat('300', 'concurso', numero_edital, tipoRecrutamento))),0) = 0