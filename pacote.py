import os
from math import exp
from pathlib import Path
from zipfile import ZipFile

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split


def recebe_dados(seed, tamanho_teste):
    # Baixa conjunto de dados e salva dados crus
    # TODO: download dos dados se eles não existem
    dados_crus = Path('..', 'Dados', 'iris.csv')

    # Carrega conjuntos de dados
    x = np.loadtxt(dados_crus, delimiter=',', usecols=[0, 1, 2, 3])
    y = pd.read_csv(
        dados_crus,
        sep=',',
        usecols=[4],
        header=None,
        names=['Nome'],
    )

    # One-hot
    y.loc[:, 'setosa'] = 0
    y.loc[:, 'virginica'] = 0
    y.loc[:, 'versicolor'] = 0
    y.loc[y['Nome'] == 'Iris-setosa', 'setosa'] = 1
    y.loc[y['Nome'] == 'Iris-virginica', 'virginica'] = 1
    y.loc[y['Nome'] == 'Iris-versicolor', 'versicolor'] = 1
    del y['Nome']
    y = np.array(y)

    # Separa conjunto de treino e teste e calcula resultados
    dados = train_test_split(x, y, test_size=tamanho_teste, random_state=seed)
    return dados


def verifica_modelo(seed, n_caracteristicas, n_classes):
    dir_modelo = Path('..', 'Dados', 'Pesos')
    camadas = len(
        list(filter(lambda caminho: caminho.is_dir(), dir_modelo.iterdir()))
    )
    if camadas == 0:
        np.random.seed(seed)
        pesos = [np.random.randn(n_caracteristicas, n_classes)]
        vieses = [np.random.randn(n_classes)]
        return pesos, vieses

    pesos = []
    vieses = []
    for n_camada in range(1, camadas + 1):
        camada = dir_modelo / f'l{n_camada}'
        pesos.append(np.loadtxt(camada / 'weight.txt', delimiter=',').T)
        vieses.append(np.loadtxt(camada / 'bias.txt', delimiter=','))

    return pesos, vieses


def cria_cabecalho(arquivo):
    linhas = [
        'library ieee;\n',
        'use ieee.fixed_pkg.all;\n',
        'use ieee.std_logic_1164.all;\n\n',
        'package pacote_aux is\n\n',
    ]
    arquivo.writelines(linhas)


def cria_costantes(arquivo, inteira, fracionaria):
    linhas = [
        f'\t-- -------------------------- Definições de constantes --------------------------\n',
        f'\tconstant parte_inteira     : integer := {inteira};\n',
        f'\tconstant parte_fracionaria : integer := -{fracionaria};\n',
        f'\tconstant tamanho           : integer := parte_inteira - parte_fracionaria + 1;\n\n',
        "\tconstant vec_zero      : std_logic_vector(tamanho - 1 downto 0) := (others => '0');\n",
        "\tconstant vec_um        : std_logic_vector(tamanho - 1 downto 0) := (others => '1');\n",
        "\tconstant vec_lsb       : std_logic_vector(tamanho - 1 downto 0) := (0 => '1', others => '0');\n",
        "\tconstant vec_msb       : std_logic_vector(tamanho - 1 downto 0) := (tamanho - 1 => '1', others => '0');\n",
        "\tconstant vec_msb_m_lsb : std_logic_vector(tamanho - 1 downto 0) := (tamanho - 1 => '0', others => '1');\n\n",
        '\tconstant s_fixo_max  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_msb_m_lsb, parte_inteira, parte_fracionaria);\n',
        '\tconstant s_fixo_min  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_msb, parte_inteira, parte_fracionaria);\n',
        '\tconstant s_fixo_lsb  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_lsb, parte_inteira, parte_fracionaria);\n',
        '\tconstant s_fixo_msb  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_msb, parte_inteira, parte_fracionaria);\n',
        '\tconstant s_fixo_zero : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_zero, parte_inteira, parte_fracionaria);\n\n',
        '\tconstant u_fixo_min : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_zero, parte_inteira, parte_fracionaria);\n',
        '\tconstant u_fixo_max : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_um, parte_inteira, parte_fracionaria);\n',
        '\tconstant u_fixo_lsb : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_lsb, parte_inteira, parte_fracionaria);\n',
        '\tconstant u_fixo_msb : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_msb, parte_inteira, parte_fracionaria);\n\n',
    ]
    arquivo.writelines(linhas)


def cria_tipos(arquivo):
    linhas = [
        '\t-- ----------------------------- Definições de tipos ----------------------------\n',
        '\tsubtype s_fixo is sfixed(parte_inteira downto parte_fracionaria);\n'
        '\tsubtype u_fixo is ufixed(parte_inteira downto parte_fracionaria);\n\n'
        '\ttype vec_s_fixo is array (integer range <>) of s_fixo;\n'
        '\ttype vec_u_fixo is array (integer range <>) of u_fixo;\n'
        '\ttype vec_inteiro is array (integer range <>) of integer;\n\n'
        '\ttype mat_s_fixo is array(integer range <>, integer range<>) of s_fixo;\n'
        '\ttype mat_u_fixo is array(integer range <>, integer range<>) of u_fixo;\n\n',
    ]
    arquivo.writelines(linhas)


def escreve_vetor(
    arquivo, vetor, espacos, quantidade_elementos, quantidade_por_linha
):
    tamanho = len(str(quantidade_elementos))
    inicio = ' ' * espacos
    for indice, valor in enumerate(vetor):

        if indice != quantidade_elementos:
            string = f'{str(indice).ljust(tamanho)}=>{valor.argmax()},'
        else:
            string = f'{str(indice).ljust(tamanho)}=>{valor.argmax()}'

        if indice % quantidade_por_linha == 0:
            if indice != quantidade_elementos:
                string = inicio + string
            else:
                string = inicio + string

        if indice % quantidade_por_linha == quantidade_por_linha - 1:
            string = string + '\n'
        else:
            string = string + '\t'

        arquivo.writelines([string])
    arquivo.writelines(['\n'])


def escreve_matriz(
    arquivo, matriz, espacos, quantidade_linhas, elementos_por_linha
):
    linhas = []
    tamanho = len(str(quantidade_linhas))
    for id_linha, linha in enumerate(matriz):
        string = ' ' * espacos + f'{str(id_linha).ljust(tamanho)} => ('
        for id_elemento, elemento in enumerate(linha):

            if id_elemento < elementos_por_linha:
                string = (
                    string
                    + f'{id_elemento} => to_sfixed({elemento}, parte_inteira, parte_fracionaria), '
                )
            else:
                string = (
                    string
                    + f'{id_elemento} => to_sfixed({elemento}, parte_inteira, parte_fracionaria))'
                )

        if id_linha < quantidade_linhas:
            string = string + ',\n'
        else:
            string = string + '\n'

        linhas.append(string)
    linhas.append('\t);\n\n')
    arquivo.writelines(linhas)


def cria_dataset(arquivo, nome, dados, amostras_treino, amostras_teste):
    arquivo.writelines(
        [
            f'\t-- ---------------------------------- {nome} ----------------------------------\n'
        ]
    )

    # Checa se é vetor ou matriz
    if 'x' in nome:
        quantidade_caracteristicas = dados.shape[1] - 1
        if 'treino' in nome:
            declaracao = f'\tconstant {nome} : mat_s_fixo(amostras_treino - 1 downto 0, n_caracteristicas - 1 downto 0) := (\n'
        else:
            declaracao = f'\tconstant {nome} : mat_s_fixo(amostras_teste - 1 downto 0, n_caracteristicas -1 downto 0) := (\n'
        espacos = len(declaracao) + 4

        arquivo.writelines([declaracao])
        escreve_matriz(
            arquivo,
            dados,
            espacos,
            dados.shape[0] - 1,
            quantidade_caracteristicas,
        )
    else:
        quantidade = dados.shape[0] - 1
        if 'treino' in nome:
            declaracao = f'\tconstant {nome} : vec_inteiro(amostras_treino - 1 downto 0) := (\n'
        else:
            declaracao = f'\tconstant {nome} : vec_inteiro(amostras_teste - 1 downto 0) := (\n'
        espacos = len(declaracao) + 4

        arquivo.writelines([declaracao])
        escreve_vetor(arquivo, dados, espacos, quantidade, 4)
        arquivo.writelines(['\t);\n\n'])


def cria_camada(arquivo, camada, pesos, vieses):
    cabecalho = f'\t-- ---------------------------------- Camada {camada} ----------------------------------\n'

    # Escrevendo pesos
    declaracao = f'\tconstant pesos_{camada} : mat_s_fixo({pesos.shape[0]} - 1 downto 0, {pesos.shape[1]} - 1 downto 0) := (\n'
    arquivo.writelines([cabecalho, declaracao])
    escreve_matriz(
        arquivo,
        pesos,
        len(declaracao) + 4,
        pesos.shape[0] - 1,
        pesos.shape[1] - 1,
    )

    # Escrevendo vieses
    declaracao = f'\tconstant vieses_{camada} : vec_s_fixo({vieses.shape[0]} - 1 downto 0) := (\n'
    arquivo.writelines(declaracao)
    vetor = ' ' * (len(declaracao) + 4)
    for i, valor in enumerate(vieses):
        vetor = (
            vetor
            + f'{i} => to_sfixed({valor}, parte_inteira, parte_fracionaria)'
        )
        if i != vieses.shape[0] - 1:
            vetor = vetor + ', '
        if i % 2 == 1:
            vetor = vetor + '\n' + ' ' * (len(declaracao) + 4)
    vetor = vetor + '\n\t);\n\n'
    arquivo.writelines(vetor)


def gera(
    parte_inteira=2,
    parte_fracionaria=14,
    seed=42,
    tamanho_teste=0.33,
    x_min=-4,
    x_med=0,
    x_max=4,
    fim_l=0.7,
    fim_n=3.85,
):
    dados = recebe_dados(seed, tamanho_teste)
    amostras_treino = dados[0].shape[0]
    amostras_teste = dados[1].shape[0]
    n_classes = dados[3].shape[1]
    n_caracteristicas = dados[0].shape[1]
    nomes = ['x_treino', 'x_teste', 'y_treino', 'y_teste']
    pesos, vieses = verifica_modelo(seed, n_caracteristicas, n_classes)

    with open('pacote_aux.vhdl', mode='w') as arquivo:
        cria_cabecalho(arquivo)
        cria_costantes(arquivo, parte_inteira, parte_fracionaria)
        cria_tipos(arquivo)

        linhas = [
            f'\t-- ---------------------------------- Sigmoide ----------------------------------\n',
            f'\tconstant sig_x_min         : s_fixo  := to_sfixed({x_min}, parte_inteira, parte_fracionaria);\n',
            f'\tconstant sig_x_med         : s_fixo  := to_sfixed({x_med}, parte_inteira, parte_fracionaria);\n',
            f'\tconstant sig_x_max         : s_fixo  := to_sfixed({x_max}, parte_inteira, parte_fracionaria);\n',
            f'\tconstant fim_l             : s_fixo  := to_sfixed({fim_l}, parte_inteira, parte_fracionaria);\n'
            f'\tconstant fim_n             : s_fixo  := to_sfixed({fim_n}, parte_inteira, parte_fracionaria);\n'
            f'\tconstant fim_med           : s_fixo  := to_sfixed({(fim_n + fim_l) / 2}, parte_inteira, parte_fracionaria);\n'
            f'\tconstant sig_y_min         : s_fixo  := to_sfixed({1 / (1 + exp(-x_min)):.10f}, parte_inteira, parte_fracionaria);\n',
            f'\tconstant sig_y_med         : s_fixo  := to_sfixed({1 / (1 + exp(-x_med)):.10f}, parte_inteira, parte_fracionaria);\n',
            f'\tconstant sig_y_max         : s_fixo  := to_sfixed({1 / (1 + exp(-x_max)):.10f}, parte_inteira, parte_fracionaria);\n',
            f'\tconstant s_fim_l           : s_fixo  := to_sfixed({1 / (1 + exp(-fim_l))}, parte_inteira, parte_fracionaria);\n'
            f'\tconstant s_fim_n           : s_fixo  := to_sfixed({1 / (1 + exp(-fim_n))}, parte_inteira, parte_fracionaria);\n'
            f'\tconstant s_fim_med         : s_fixo  := to_sfixed({1 / (1 + exp(-(fim_n + fim_l) / 2))}, parte_inteira, parte_fracionaria);\n\n',
            f'\t-- ---------------------------------- Dataset ----------------------------------\n',
            f'\tconstant amostras_treino   : integer := {amostras_treino};\n'
            f'\tconstant amostras_teste    : integer := {amostras_teste};\n'
            f'\tconstant n_classes         : integer := {n_classes};\n'
            f'\tconstant n_caracteristicas : integer := {n_caracteristicas};\n\n',
        ]

        linha = f'\tconstant maior_por_caracteristica : vec_s_fixo({n_caracteristicas} - 1 downto 0) := ('
        for i in range(dados[0].shape[1]):
            linha = (
                linha
                + f'{i}=>to_sfixed({np.max(dados[0][:,i])}, s_fixo_min), '
            )
        linha = linha[:-2] + ');\n'
        linhas.append(linha)

        linha = f'\tconstant menor_por_caracteristica : vec_s_fixo({n_caracteristicas} - 1 downto 0) := ('
        for i in range(dados[0].shape[1]):
            linha = (
                linha
                + f'{i}=>to_sfixed({np.min(dados[0][:,i])}, s_fixo_min), '
            )
        linha = linha[:-2] + ');\n\n'
        linhas.append(linha)

        arquivo.writelines(linhas)

        x_treino = dados[0]
        for i in range(x_treino.shape[1]):
            x_treino[:, i] = (x_treino[:, i] - np.min(x_treino[:, i])) / (
                np.max(x_treino[:, i]) - np.min(x_treino[:, i])
            )
        
        cria_dataset(arquivo, nomes[1], dados[1], amostras_treino, amostras_teste)
        cria_dataset(arquivo, nomes[3], dados[3], amostras_treino, amostras_teste)

        for camada, (p, v) in enumerate(zip(pesos, vieses)):
            cria_camada(arquivo, camada + 1, p, v)

        arquivo.writelines(['end package pacote_aux;\n'])


if __name__ == '__main__':
    gera()
