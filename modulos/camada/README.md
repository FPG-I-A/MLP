# Camada

## Descrição

Módulo que faz o processamento de uma camada da rede MLP, ou seja a multiplicação entre o vetor de entradas e a matriz de pesos, a soma desse resultado ao vetor de viéses e, por fim, a aplicação da função de ativação.

## Algoritmo

Este módulo apenas chama dois outros módulos: [`vec_mat_mul`](../vec_mat_mul/REAMDE.md) e [`ativacao`](../ativacao/README.md).

## Mapeamento genérico

|        **Nome**         | **Tipo** |              **Descrição**               |
|:-----------------------:|:--------:|:----------------------------------------:|
| `entradas` |  inteiro | Número de elementos no vetor de entradas |
| `neuronios`| inteiro | Número de neurônios, tamanho do vetor de saídas|

## Mapeamento de portas

|   **Nome**  |      **Tipo**      |              **Descrição**              |
|:-----------:|:------------------:|:---------------------------------------:|
| i_clk | bit | `Clock` para execução do algoritmo |
| i_init | bit |  Sinal para iniciar o algoritmo |
| i_reset | bit |  Sinal para resetar o algoritmo |
| i_x | vetor de sfixo | Vetor contendo os elementos de entrada da camada $dim(i_x) = entradas$ |
| i_pesos | matriz de sfixo | Matriz contendo os pesos da camada $dim(i_{pesos}) = (entradas, neuronios)$ |
| i_vieses | vetor de sfixo | Vetor contendo os viéses de cada neurônio $dim(i_{vieses}) = neuronios$ | 
| o_resultado | vetor de sfixo | Vetor contendo os resultados $dim(o_{resultado}) = neuronios$ |
| o_ocupado | bit | Sinal que indica que o cálculo está sendo realizado |

## Funcionamento da FSM
A máquina de estados finitos é controlada por três portas do módulo: `i_init`, `i_reset`e `o_ocupado`. A
tabela abaixo mostra a operação realizada em cada caso.

|   `i_init`   |   `i_reset`   |   `o_ocupado`   |                 **Operação**                 |
|:------------:|:-------------:|:---------------:|:--------------------------------------------:|
|       0      |       x       |        0        |                 Nada acontece                |
|       0      |       1       |        1        |       Operação iniciada é interrompida       |
|       x      |       0       |        1        | Operação, já iniciada, continua em andamento |
|       1      |       0       |        0        |              Operação é iniciada             |
|       1      |       1       |        x        |              Operação é iniciada             |

Há também uma máquina de estados interna que controla cada um dos módulos auxiliares e quando cada um deve executar o seu processamento.