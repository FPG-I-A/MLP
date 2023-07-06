# Normalização

## Descrição

Módulo para calculo da sigmoide de um dado valor x. Por se tratar de uma única conta, feita em um circuito combinatório, não há necessiade de um sinal de `clock` nem de uma FSM.

## Algoritmo

A função sigmoide pode ser calculada por:

$$
\sigma(x) = \dfrac{1}{1 + e^{-x}} = 1 - \sigma(-x)
$$

Como essa função é definida em termos de quocientes e expoentes de x sua implementação em hardware é muito custosa. Assim utiliza-se aproximações em trechos lineares e não lineares. Construímos aqui duas arquiteturas para o módulo de sigmoide, cada uma utilizando uma aproximação diferente.

A primeira aproximação utilizada foi baseada [neste artigo](https://www.researchgate.net/publication/281640393_Modeling_of_Pain_on_a_FPGA-based_Neural_Network), porém, como buscamos uma sigmoide com os parâmetros padrões, ou seja uma sigmoide simétrica tal que $\sigma(0) = 0,5$ consideramos sempre $x_{med} = 0$ e $x_{min} = -x_{max}$. Nos nossos testes encontramos que o menor erro ocorre quando $x_{min} = -x_{max} = -4$.

A segunda aproximação foi feita levando em conta a simetria da função sigmoide. Assim, considerando que $\sigma(x) = 1 - \sigma(-x)$ podemos aproximar apenas para valores positivos. Desta forma separamos esta metade da curva em três segmentos sendo dois lineares e um não linear, mais explicações sobre isso podem ser vistas no [estudo sobre a sigmoide](teoria/teoria.pdf).

## Mapeamento genérico

O mapeamento genérico tem um significado diferente para cada uma das arquiteturas, assim ele será dividido em duas partes.

### Arquitetura de quatro partes

|        **Nome**         | **Tipo** |              **Descrição**               |
|:-----------------------:|:--------:|:----------------------------------------:|
|        `gen_x_min`      |  s_fixo  | Limiar entre o intervalo linear e não linear |
|        `gen_y_min`      |  s_fixo  | $\sigma($ gen_x_min $)$ |
|        `gen_x_med`      |  s_fixo  | Limiar entre o intervalo linear e não linear |
|        `gen_y_med`      |  s_fixo  | $\sigma($ gen_x_med $)$ |
|        `gen_x_max`      |  s_fixo  | Limiar entre o intervalo linear e não linear |
|        `gen_y_max`      |  s_fixo  | $\sigma($ gen_x_max $)$ |

### Arquitetura de três partes

|        **Nome**         | **Tipo** |              **Descrição**               |
|:-----------------------:|:--------:|:----------------------------------------:|
|        `gen_x_min`      |  s_fixo  | Limiar entre o intervalo linear e não linear, valor de $fim_l$|
|        `gen_y_min`      |  s_fixo  | $\sigma($ gen_x_max $)$ |
|        `gen_x_med`      |  s_fixo  | Média entre $fim_l$ e $fim_n$ |
|        `gen_y_med`      |  s_fixo  | $\sigma($ gen_x_max $)$ |
|        `gen_x_max`      |  s_fixo  | Limiar entre o intervalo linear e não linear, valor de $fim_n$ |
|        `gen_y_max`      |  s_fixo  | $\sigma($ gen_x_max $)$ |

## Mapeamento de portas

|   **Nome**  |      **Tipo**      |              **Descrição**              |
|:-----------:|:------------------:|:---------------------------------------:|
| i_x | s_fixo | Entrada, número utilizado para calcular a sigmoide |
| o_resultado | s_fixo | $\sigma($ i_x $)$ |
