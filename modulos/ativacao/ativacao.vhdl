library ieee;
use ieee.fixed_pkg.all;
use std.textio.all;

library work;
use work.pacote_aux.all;

entity ativacao is
    generic (
        entradas : integer
    );
    port (
        i_clk       : in bit;
        i_init      : in bit;
        i_reset     : in bit;
        i_x         : in vec_s_fixo(entradas - 1 downto 0);
        i_vieses    : in vec_s_fixo(entradas - 1 downto 0);
        o_resultado : out vec_s_fixo(entradas - 1 downto 0);
        o_ocupado   : out bit
    );
end ativacao;

architecture soma_sig of ativacao is
    -- Sinais de controle
    signal iniciar : bit := '0';
    signal resetar : bit := '0';

    -- Sinais auxiliares
    signal contador : integer := 0;

    -- Sinais do módulo de sigmoide
    signal entrada_sigmoide : s_fixo := to_sfixed(0, parte_inteira, parte_fracionaria);
    signal resultado_sigmoide : s_fixo := to_sfixed(0, parte_inteira, parte_fracionaria);

    -- Sinais de entrada e saia
    signal entrada : vec_s_fixo(entradas - 1 downto 0) := (others => to_sfixed(0, parte_inteira, parte_fracionaria));
    signal vieses : vec_s_fixo(entradas - 1 downto 0) := (others => to_sfixed(0, parte_inteira, parte_fracionaria));
    signal resultado : vec_s_fixo(entradas - 1 downto 0) := (others => to_sfixed(0, parte_inteira, parte_fracionaria));

begin

    sigmoide : entity work.sigmoide(tres_partes)
    generic map(
        gen_x_min => fim_l,
        gen_y_min => s_fim_l,
        gen_x_med => fim_med,
        gen_y_med => s_fim_med,
        gen_x_max => fim_n,
        gen_y_max => s_fim_n
    )
    port map(
        i_x         => entrada_sigmoide,
        o_resultado => resultado_sigmoide
    );

    calcula : process(i_clk) begin
        if resetar = '1' then
            o_ocupado <= '0';
            contador <= 0;
        end if;

        if iniciar = '1' then
            o_ocupado <= '1';
            contador <= 0;
            
            -- Recebe entradas
            entrada <= i_x;
            vieses <= i_vieses;

            -- Reinicia saída
            resultado <= (others=>to_sfixed(0, resultado(0)));

        end if;

        if o_ocupado = '1' then
            if contador < entradas then
                entrada_sigmoide <= resize(entrada(contador) + vieses(contador), entrada_sigmoide);
                contador <= contador + 1;
            end if;
           
            if contador > 0 and contador <= entradas then
                resultado(contador - 1) <= resultado_sigmoide;
                contador <= contador + 1;
            elsif contador > entradas then
                o_resultado <= resultado;
                o_ocupado <= '0';
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
end soma_sig;
