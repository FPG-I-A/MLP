library ieee;
use ieee.fixed_pkg.all;
use std.textio.all;
library work;
use work.pacote_aux.all;

entity vec_mat_mul is
    -- Vetor: entradas da camada
    -- Matriz: pesos da camada (cada coluna é um neurônio)
    generic (
        entradas : integer;    -- Número de entradas da camada (nº de neurônios da camada anterior)
        neuronios : integer    -- Número de neurônios na camada
    );
    port (
        i_clk       : in bit;
        i_init      : in bit;
        i_reset     : in bit;
        i_vec       : in vec_s_fixo(entradas - 1 downto 0);
        i_mat       : in mat_s_fixo(entradas - 1 downto 0, neuronios - 1 downto 0);
        o_resultado : out vec_s_fixo(neuronios - 1 downto 0);
        o_ocupado   : out bit
    );
end vec_mat_mul;

architecture multiplica of vec_mat_mul is
    signal iniciar        : bit := '0';
    signal resetar        : bit := '0';
    signal vetor          : vec_s_fixo(entradas - 1 downto 0);
    signal matriz         : mat_s_fixo(entradas - 1 downto 0, neuronios - 1 downto 0);
    signal linha_matriz   : integer := 0;
    signal coluna_matriz  : integer := 0;
    signal resultado      : vec_s_fixo(neuronios - 1 downto 0);
begin
    calcula : process (i_clk) begin
        if resetar = '1' then
            o_ocupado     <= '0';
            linha_matriz  <= 0;
            coluna_matriz <= 0;
            resultado     <= (others => to_sfixed(0, resultado(0)));
        end if;

        if iniciar = '1' then
            o_ocupado <= '1';

            -- Recebe entradas
            vetor  <= i_vec;
            matriz <= i_mat;

            -- Reinicia saída
            resultado <= (others => to_sfixed(0, resultado(0)));

            -- Reinicia indices
            linha_matriz   <= 0;
            coluna_matriz  <= 0;

        end if;

        if o_ocupado = '1' then
            -- Primeiro: itera na coluna da matriz e multiplica pelo vetor, somando ao resultado
            if linha_matriz < entradas then
                resultado(coluna_matriz) <= resize(resultado(coluna_matriz) + vetor(linha_matriz) * matriz(linha_matriz, coluna_matriz), resultado(0));
                linha_matriz <= linha_matriz + 1;
            end if;
            
            -- Quando terminar a coluna passa para o início da próxima
            if linha_matriz = entradas - 1 and coluna_matriz < neuronios - 1 then
                linha_matriz <= 0;
                coluna_matriz  <= coluna_matriz + 1;
            end if;
            
            -- Quando terminar todas as colunas a multiplicação foi finalizada
            if linha_matriz = entradas - 1 and coluna_matriz = neuronios - 1 then
                o_ocupado   <= '0';
                o_resultado <= resultado;
            end if;

            

        end if;
    end process calcula;

    inicializa : process (o_ocupado, i_init, i_reset) begin -- Controle dos estados da FSM
        if o_ocupado = '0' and i_init = '1' then
            iniciar <= '1';
            resetar <= '0';
        elsif o_ocupado = '1' and i_reset = '1' and i_init = '1' then
            iniciar <= '1';
            resetar <= '0';
        elsif o_ocupado = '1' and i_reset = '1' then
            resetar <= '1';
        else
            iniciar <= '0';
            resetar <= '0';
        end if;
    end process inicializa;
end multiplica;
