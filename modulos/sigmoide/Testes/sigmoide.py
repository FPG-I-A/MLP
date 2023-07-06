import matplotlib.pyplot as plt
import numpy as np


def sigmoide(x):
    return 1 / (1 + np.exp(-x))


def aprox(x, x_max, x_min):
    # x_med = 0: sigmoide simétrica
    x_med = 0
    y_min = sigmoide(x_min)
    y_max = sigmoide(x_max)

    # x_inf e x_sup são os limites superiores e inferiores
    x_inf = x[0]
    x_sup = x[-1]

    # Primeiro linear
    b0 = -y_min / (x_inf - x_min)
    c0 = -b0 * x_inf

    # Primeiro não linear
    b1 = x_min / ((2 * x_min * x_med) - x_med**2 - x_min**2)
    a1 = -b1 / (2 * x_min)
    c1 = b1**2 / (4 * a1)

    # Segundo não linear
    b2 = -x_max / (2 * x_max * x_med - x_med**2 - x_max**2)
    a2 = -b2 / (2 * x_max)
    c2 = 1 + (b2**2) / (4 * a2)

    # Segundo linear
    b3 = (1 - y_max) / (x_sup - x_max)
    c3 = 1 - b3 * x_sup

    resultado = []
    for valor in x:
        if valor < x_min:
            resultado.append(c0 + b0 * valor)
        elif x_min <= valor and valor < x_med:
            resultado.append(c1 + valor * (b1 + a1 * valor))
        elif x_med <= valor and valor < x_max:
            resultado.append(c2 + valor * (b2 + a2 * valor))
        else:
            resultado.append(c3 + b3 * valor)
    return resultado


def meu(x, fim_l, fim_n):
    # Constantes
    s_fim_l = sigmoide(fim_l)
    s_fim_n = sigmoide(fim_n)

    # Primeira parte linear
    a1 = (0.5 - s_fim_l) / (0 - fim_l)
    b1 = 0.5 - 0 * a1

    # Parte não linear
    y_med = sigmoide((fim_l + fim_n) / 2)
    a2 = (2 * s_fim_l - 4 * y_med + 2 * s_fim_n) / (fim_n - fim_l) ** 2
    b2 = 2 * (y_med - s_fim_l) / (fim_n - fim_l) - a2 * (3 * fim_l + fim_n) / 2
    c2 = s_fim_l - a2 * fim_l * fim_l - b2 * fim_l

    # Segunda parte linear
    x_sup = 8
    s_x_sup = sigmoide(8)
    a3 = (s_fim_n - s_x_sup) / (fim_n - x_sup)
    b3 = s_fim_n - fim_n * a3

    resultados = []
    for valor in x:
        if valor >= -8 and valor <= -fim_n:
            resultados.append(1 + a3 * valor - b3)
        elif valor > -fim_n and valor <= -fim_l:
            resultados.append(1 - c2 + valor * (a2 * -valor + b2))
        elif valor > -fim_l and valor <= 0:
            resultados.append(1 + a1 * valor - b1)
        elif valor > 0 and valor <= fim_l:
            resultados.append(a1 * valor + b1)
        elif valor > fim_l and valor <= fim_n:
            resultados.append(c2 + valor * (valor * a2 + b2))
        elif valor > fim_n and valor <= 8:
            resultados.append(a3 * valor + b3)

    contador = 0
    for i, x in enumerate(resultados):
        if x > 1:
            resultados[i] = 1
            contador += 1
        if x < 0:
            resultados[i] = 0
            contador += 1
    return resultados


x = np.linspace(-8.0, 8.0, num=10**6, endpoint=False)

real = sigmoide(x)
angelo = aprox(x, 4, -4)
fim_l = 0.7
fim_n = 3.85
aproximado = meu(x, fim_l, fim_n)

plt.plot(x, real, label=r'$\sigma(x)$')
plt.plot(x, aproximado, label=r'$\sigma_{meu}(x)$')
plt.legend()
plt.savefig('sig_meu.png')

ax = plt.gca()
ax.cla()
plt.plot(x, real, label=r'$\sigma(x)$')
plt.plot(x, angelo, label=r'$\sigma_{professor}(x)$')
plt.legend()
plt.savefig('sig_prof.png')

print('ERRO PROF')
erro_abs = abs(real - angelo)
print(f'\tErro máximo: {max(erro_abs):.2%}')
print(f'\tErro médio: {erro_abs.mean():.2%}')

print('ERRO MEU')
erro_abs = abs(real - aproximado)
print(f'\tErro máximo: {max(erro_abs):.2%}')
print(f'\tErro médio: {erro_abs.mean():.2%}')
