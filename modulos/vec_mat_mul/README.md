# Normalização

## Descrição

Módulo para multiplicação de uma matriz com um vetor. Este módulo é utilizado para, dada um vetor de entradas de uma certa camada da rede neural e uma matriz de pesos desta camada realizar o primeiro calculo da saída dessa camada, a soma ponderada, para ter o resultado correto de uma camada, deve-se calcular a função de ativação do resultado obtido por este módulo.

## Algoritmo

O cálculo da multiplicação é feito pelo método mais intuitivo o possível: um loop duplo. O loop interno itera pelas linhas da matriz, já o externo por suas colunas. Quando o loop interno termina a última linha da matriz significa que o resultado de um dos neurônios foi finalizado, passamos assim para o próximo neurônio, a próxima coluna da matriz.

## Mapeamento genérico

|        **Nome**         | **Tipo** |              **Descrição**               |
|:-----------------------:|:--------:|:----------------------------------------:|
|        `entradas`       | inteiro  | Número de elementos no vetor de entradas |
|        `neurônios`      | inteiro  | Número de neurônios na camada e, por consequência, número de elementos no vetor de saídas da camada |

## Mapeamento de portas

|   **Nome**  |      **Tipo**      |              **Descrição**              |
|:-----------:|:------------------:|:---------------------------------------:|
| i_clk | bit | `Clock` para execução do algoritmo |
| i_init | bit |  Sinal para iniciar o algoritmo |
| i_reset | bit |  Sinal para resetar o algoritmo |
| i_vec | vec_s_fixo | Vetor com os dados de entrada da camada |
| i_mat | mat_s_fixo | Matriz contendo os pess de cada conexão dos neurônios |
| o_resultado | vec_s_fixo | Vetor cntendo as somas ponderadas da camada |
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
