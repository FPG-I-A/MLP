# MLP

## O algoritmo

Multilayer perceptron, ou [perceptron multicamadas](https://pt.wikipedia.org/wiki/Perceptron_multicamadas), é uma rede neural totalmente conectada baseada em $C$ camadas com $N_C$ neurônios perceptron em cada. Cada um desses neurônios possuí um número $I$ de entradas que é determinado pelo número de neurônios na camada anterior e uma única saída, e produz como resultado uma única saída de acordo com a expressão abaixo:

$$
o = \sigma\left(\sum_{j=0}^I w_j i_j\right)
$$

Sendo $o$ a saída do neurônio, $w_j$ o peso da entrada $j$ e $i_j$ a entrada $j$ do neurônio. Sendo assim, o resultado de um neurônio trata-se de uma soma ponderada, uma [combinação linear](https://pt.wikipedia.org/wiki/Combina%C3%A7%C3%A3o_linear) das entradas do neurônio, sendo utilizada como entrada para uma função de ativação, que no caso a utilizada é a [sigmoide](https://pt.wikipedia.org/wiki/Fun%C3%A7%C3%A3o_sigmoide):

$$
\sigma(x) = \dfrac{1}{1 + e^{-x}}
$$

Ainda assim, pode ser mais simples tratar a função sigmoide como uma função que recebe um vetor de tamanho arbitrário $n$ e resulta em um vetor de mesmo tamanho utilizando a seguinte definição:

$$
\sigma(\vec{x}) = [\sigma(x_1), \sigma(x_2), \ldots, \sigma(x_n)]
$$

Isso torna o processo mais simples pois, podemos tratar as camadas como uma única entidade por si só, e não como um conjunto de neurônios, assim sendo $J_C$ o número de entradas de uma camada $C$, $N_C$ o número de neurônios (ou saídas) desta mesma camada podemos criar duas matrizes.

A primeira delas é a matriz $W_C$ contendo os pesos de cada conexão da camada anterior até a camada $C$, esta matriz possuí $J_C$ linhas e $N_C$ colunas. A segunda matriz é a matriz $I_C$ de entradas com uma única linha e $J_C$ colunas. A multiplicação dessas matrizes resulta no vetor de potenciais de uma dada camada, tal vetor pode ser utilizado como entrada da função sigmoide assim obtendo a saída da camada, ou seja:

$$
\overrightarrow{O_C} = \sigma\left( I_C \times W_C\right)
$$

Assim, reduzimos o algoritmo para a normalização dos dados de entrada antes da primeira camada e uma iteração passando por todas as camadas realizando a operação de multiplicação de matrizes e a sigmoide vetorial.

## Módulos implementados

Uma descrição de hardware em VHDL é realizada criando e unindo diversos blocos de circuitos digitais. Assim, para criar o algoritmo vários blocos com funções limitadas foram criados.

O hardware de uma FPGA não possuí diversas operações matemáticas necessárias. Na realidade ele possuí apenas soma, subtração, multiplicação e divisão. Todas as outras operações devem ser implementadas de alguma forma.

Vale notar que, além disso, não há unidades de ponto flutuante, então, ao menos por enquanto, decidimos utilizar números de ponto fixo.

Cada módulo possuí uma sessão de mapeamento genérico e uma de mapeamento de portas, além de uma descrição de seu funcionamento.

- [`norm`](modulos/norm/README.md)
- [`vec_mat_mul`](modulos/vec_mat_mul/README.md)
- [`sigmoide`](modulos/sigmoide/README.md)
- [`ativacao`](modulos/ativacao/README.md)
- [`camada`](modulos/camada/README.md)
