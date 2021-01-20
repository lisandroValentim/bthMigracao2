from datetime import datetime
import re
import json
import logging
import sistema_origem.ipm_cloud_postgresql.model as model
import bth.interacao_cloud as interacao_cloud

sistema = 300
limite_lote = 500
tipo_registro = 'agencia-bancaria'
url = 'https://pessoal.cloud.betha.com.br/service-layer/v1/api/agencia-bancaria'


def iniciar_processo_envio(params_exec, *args, **kwargs):
    if True:
        if params_exec.get('buscar') is True:
            busca_dados_cloud(params_exec)
    if True:
        if params_exec.get('enviar') is True:
            dados_assunto = coletar_dados(params_exec)
            dados_enviar = pre_validar(params_exec, dados_assunto)
            if not params_exec.get('somente_pre_validar'):
                iniciar_envio(params_exec, dados_enviar, 'POST')
    model.valida_lotes_enviados(params_exec, tipo_registro=tipo_registro)


def busca_dados_cloud(params_exec):
    print('- Iniciando busca de dados no cloud.')
    registros = interacao_cloud.busca_dados_cloud(params_exec, url=url)
    print(f'- Foram encontrados {len(registros)} registros cadastrados no cloud.')
    registros_formatados = []
    try:
        for item in registros:
            hash_chaves = model.gerar_hash_chaves(sistema,
                                                  tipo_registro,
                                                  item['numero'],
                                                  item['banco']['id'])
            registros_formatados.append({
                'sistema': sistema,
                'tipo_registro': tipo_registro,
                'hash_chave_dsk': hash_chaves,
                'descricao_tipo_registro': 'Cadastro de Agencia Bancaria',
                'id_gerado': item['id'],
                'i_chave_dsk1': item['numero'],
                'i_chave_dsk2': item['banco']['id'],
            })
        model.insere_tabela_controle_migracao_registro(params_exec, lista_req=registros_formatados)
        print(f'- Busca de {tipo_registro} finalizada. Tabelas de controles atualizas com sucesso.')
    except Exception as error:
        print(f'Erro ao executar função "busca_dados_cloud". {error}')


def coletar_dados(params_exec):
    print('- Iniciando a consulta dos dados a enviar.')
    df = None
    try:
        tempo_inicio = datetime.now()
        query = model.get_consulta(params_exec, f'{tipo_registro}.sql')
        pgcnn = model.PostgreSQLConnection()
        df = pgcnn.exec_sql(query, index_col='id')
        tempo_total = (datetime.now() - tempo_inicio)
        print(f'- Consulta finalizada. {len(df.index)} registro(s) encontrado(s). '
              f'(Tempo consulta: {tempo_total.total_seconds()} segundos.)')
    except Exception as error:
        print(f'Erro ao executar função "enviar_assunto". {error}')
    finally:
        return df


def pre_validar(params_exec, dados):
    print('- Iniciando pré-validação dos registros.')
    dados_validados = []
    registro_erros = []
    try:
        lista_dados = dados.to_dict('records')
        for linha in lista_dados:
            registro_valido = True
            if registro_valido:
                dados_validados.append(linha)
        print(f'- Pré-validação finalizada. Registros validados com sucesso: '
              f'{len(dados_validados)} | Registros com advertência: {len(registro_erros)}')
    except Exception as error:
        logging.error(f'Erro ao executar função "pre_validar". {error}')
    finally:
        return dados_validados


def iniciar_envio(params_exec, dados, metodo, *args, **kwargs):
    print('- Iniciando envio dos dados.')
    lista_dados_enviar = []
    lista_controle_migracao = []
    hoje = datetime.now().strftime("%Y-%m-%d")
    token = params_exec['token']
    contador = 0
    for item in dados:
        hash_chaves = model.gerar_hash_chaves(sistema, tipo_registro,
                                              item['numero'],
                                              item['banco'])
        dict_dados = {
            'idIntegracao': hash_chaves,
            'conteudo': {
                "banco": {
                    "id": int(item['banco'])
                },
                "nome": item['nome'],
                "numero": item['numero'],
                "digito": item['digito']
            }
        }
        if 'bairro' in item and item['bairro'] is not None:
            dict_dados['conteudo'].update({
                'bairro': {
                    'id': item['bairro']
                }
            })
        if 'logradouro' in item and item['logradouro'] is not None:
            dict_dados['conteudo'].update({
                'logradouro': {
                    'id': item['logradouro']
                }
            })
        if 'cep' in item and item['cep'] is not None:
            dict_dados['conteudo'].update({
                'cep': item['cep']
            })
        if 'numeroendereco' in item and item['numeroendereco'] is not None:
            dict_dados['conteudo'].update({
                'numeroEndereco': item['numeroendereco']
            })
        if params_exec.get('atualizar') is True:
            if item['id'] is not None:
                dict_dados['conteudo'].update({
                    'id': int(item['id'])
                })
        contador += 1
        # print(f'Dados gerados ({contador}): ', dict_dados)
        lista_dados_enviar.append(dict_dados)
        lista_controle_migracao.append({
            'sistema': sistema,
            'tipo_registro': tipo_registro,
            'hash_chave_dsk': hash_chaves,
            'descricao_tipo_registro': 'Cadastro de Agencia Bancaria',
            'id_gerado': None,
            'json': json.dumps(dict_dados),
            'i_chave_dsk1': item['numero'],
            'i_chave_dsk2': item['banco'], # identificador
        })
    if True:
        model.insere_tabela_controle_migracao_registro(params_exec, lista_req=lista_controle_migracao)
        req_res = interacao_cloud.preparar_requisicao(lista_dados=lista_dados_enviar,
                                                      token=token,
                                                      url=url,
                                                      tipo_registro=tipo_registro,
                                                      tamanho_lote=limite_lote)
        model.insere_tabela_controle_lote(req_res)
        print('- Envio de dados finalizado.')
