import sistema_origem.ipm_cloud_postgresql.model as model
import bth.interacao_cloud as interacao_cloud
import re
import json
import logging
from datetime import datetime

sistema = 300
tipo_registro = 'bancos'
url = 'https://pessoal.cloud.betha.com.br/service-layer/v1/api/banco'


def iniciar_processo_envio(params_exec, *args, **kwargs):
    # Verifica se existe algum lote pendente de execução
    # model.valida_lotes_enviados(params_exec)

    # Realiza rotina de busca dos dados no cloud
    busca_dados_cloud(params_exec)



def busca_dados_cloud(params_exec):
    print('- Iniciando busca de dados no cloud.')
    registros = interacao_cloud.busca_dados_cloud(params_exec, url=url)
    print(f'- Foram encontrados {len(registros)} registros cadastrados no cloud.')
    registros_formatados = []

    try:
        for item in registros:
            cod_febraban = str.replace(item['numeroBanco'], '-', '')
            if not re.search("[a-zA-Z]", cod_febraban):
                cod_febraban = str(int(cod_febraban))
                hash_chaves = model.gerar_hash_chaves('300', tipo_registro, cod_febraban)
                registros_formatados.append({
                    'sistema': sistema,
                    'tipo_registro': tipo_registro,
                    'hash_chave_dsk': hash_chaves,
                    'descricao_tipo_registro': 'Cadastro de Bancos',
                    'id_gerado': item['id'],
                    'i_chave_dsk1': cod_febraban
                })
        model.insere_tabela_controle_migracao_registro2(params_exec, lista_req=registros_formatados)
        print(f'- Busca de {tipo_registro} finalizada. Tabelas de controles atualizas com sucesso.')

    except Exception as error:
        print(f'Erro ao executar função "busca_dados_cloud". {error}')