import getopt
import math
import sys
from pathlib import Path
from statistics import mean
from pathlib import Path

import matplotlib.pyplot as plt


def ajuda():
    print('Script python para verificação de erros de aproximação.')
    print('Uso:')
    print('\tpython erros.py -m {modulo} [-h]')
    print('\tmodulo: string := nome do módulo a ser testado')
    print('Argumentos opcionais:')
    print('\t-h: mostra esta mensagem ')


def parse_args():
    optlist, args = getopt.gnu_getopt(sys.argv[1:], 'm:i:f:h')
    modulo = None
    for opcao, argumento in optlist:
        if opcao == '-h':
            ajuda()
            sys.exit(0)
        elif opcao == '-m':
            modulo = argumento
        else:
            ajuda()
            print(f'\nERRO: Opção {opcao} inválida.')
            sys.exit(1)

    if modulo is None:
        ajuda()
        print('\nERRO: A opção -m é obrigatória mas não foi fornecida.')
        sys.exit(1)
    else:
        return modulo


def fixo_para_float(fixo):
    inteiro, fracionario = fixo.split('.')
    sinal = inteiro[0]
    inteiro = inteiro[1:]
    exp_max = len(inteiro) - 1
    try:
        parte_inteira = sum(
            [
                int(bit) * 2 ** (exp_max - ind)
                for ind, bit in enumerate(inteiro)
            ]
        )
        parte_fracionaria = sum(
            [int(bit) * 2 ** (-ind - 1) for ind, bit in enumerate(fracionario)]
        )
        return parte_inteira + parte_fracionaria

    except ValueError:
        return 0


def erros_sigmoide():
    def processa_linha(linha):
        return list(map(fixo_para_float, linha.split(';')))

    def erro(quantidade):
        plt.gca().cla()
        with open(Path('resultados', 'sigmoide', f'sigmoide_{quantidade}.csv')) as arquivo:
            arquivo.readline()
            dados = map(lambda string: string[:-1], arquivo.readlines())
            x, calculado = zip(*map(processa_linha, dados))
            reais = list(map(lambda x: 1 / (1 + math.exp(-x)), x))
            calculado = list(calculado)

        erros = list(map(lambda a, b: a - b, reais, calculado))
        erros_abs = list(map(abs, erros))

        print(f'Aproximação de {quantidade} parâmetros:')
        print(f'\tErro máximo: {max(erros_abs):.2%}')
        print(f'\tErro absoluto médio: {mean(erros_abs):.2%}')
        plt.plot(x, calculado)
        plt.plot(x, reais)
        plt.title(f'Sigmoide de {quantidade} parâmetros')
        plt.savefig(Path('resultados', 'sigmoide', f'sigmoide_{quantidade}.png'))

    erro('quatro')
    erro('tres')


if __name__ == '__main__':
    modulo = parse_args()
    funcao = None
    match modulo:
        case 'sigmoide':
            erros_sigmoide()
