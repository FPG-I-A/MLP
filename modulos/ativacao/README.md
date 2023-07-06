# Ativação

## Descrição

Este módulo recebe a soma ponderada dos neurônios de uma dada camada e realiza a sua ativação. Assim ele é responsável por somar aos resultados parciais o valor do viés de cada neurônio e em seguida aplicar a função sigmoide.

## Algoritmo

O algoritmo para este módulo é bem simples, ele simplesmente itera sobre o vetor de somas de uma camada, soma a ele os seus respectivos viéses e coloca o resultado como entrada do módulo de [sigmoide](../sigmoide/README.md). 

## Mapeamento genérico

|        **Nome**         | **Tipo** |              **Descrição**               |
|:-----------------------:|:--------:|:----------------------------------------:|
| `entradas` |  inteiro | Número de elementos no vetor de entradas, é igual ao número de neurônios na camada |

## Mapeamento de portas

|   **Nome**  |      **Tipo**      |              **Descrição**              |
|:-----------:|:------------------:|:---------------------------------------:|
| i_clk | bit | `Clock` para execução do algoritmo |
| i_init | bit |  Sinal para iniciar o algoritmo |
| i_reset | bit |  Sinal para resetar o algoritmo |
| i_x | vetor de sfixo | Vetor contendo as somas ponderadas |
| i_vieses | vetor de sfixo | Vetor contendo os vieses de cada neurônio |
| o_resultado | vetor de sfixo | Vetor contendo a saída da camada |
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
