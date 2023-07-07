library ieee;
use ieee.fixed_pkg.all;
use std.env.finish;
use ieee.math_real.all;

library work;
use work.pacote_aux.all;
entity camada_tb is
end camada_tb;


architecture sim of camada_tb is
    -- constantes
    constant tamanho_in : integer := 3;
    constant tamanho_out : integer := 4;

    -- portas do componentes
    signal i_clk       : bit := '0';
    signal i_init      : bit := '0';
    signal i_reset     : bit := '0';
    signal i_vec       : vec_s_fixo(tamanho_in - 1 downto 0);
    signal o_resultado : vec_s_fixo(tamanho_out - 1 downto 0);
    signal o_ocupado   : bit;
    
    -- Pesos e vieses
    constant i_mat     : mat_s_fixo(tamanho_in - 1 downto 0, tamanho_out - 1 downto 0) := (
        0 => (0 => to_sfixed(1, parte_inteira, parte_fracionaria), 3 => to_sfixed(1, parte_inteira, parte_fracionaria), others => to_sfixed(0, parte_inteira, parte_fracionaria)),
        1 => (1 => to_sfixed(1, parte_inteira, parte_fracionaria), 3 => to_sfixed(1, parte_inteira, parte_fracionaria), others => to_sfixed(0, parte_inteira, parte_fracionaria)),
        2 => (2 => to_sfixed(1, parte_inteira, parte_fracionaria), 3 => to_sfixed(1, parte_inteira, parte_fracionaria), others => to_sfixed(0, parte_inteira, parte_fracionaria))
    );
    constant i_vieses : vec_s_fixo(tamanho_out - 1 downto 0) := (
        0 => to_sfixed(0, parte_inteira, parte_fracionaria),
        1 => to_sfixed(1, parte_inteira, parte_fracionaria),
        2 => to_sfixed(2, parte_inteira, parte_fracionaria),
        3 =>to_sfixed(3, parte_inteira, parte_fracionaria)
    );

    -- Sinais auxiliares
    signal contador : integer := 0;
    signal finalizou : bit := '0';


begin

    UUT : entity work.camada
    generic map(
        entradas => tamanho_in,
        neuronios => tamanho_out
    )
    port map(
        i_clk =>i_clk,
        i_init     =>i_init,
        i_reset    =>i_reset,
        i_x        =>i_vec,
        i_pesos    =>i_mat,
        i_vieses   =>i_vieses,
        o_resultado => o_resultado,
        o_ocupado  =>o_ocupado
    );

    clock : process
    begin
        i_clk <= not i_clk;
        wait for 400 ns; -- 50Mhz
    end process clock;

    inicia : process
        -- Variáveis do gerador de números aleatórios
        variable seed1 : positive := 15646526;
        variable seed2 : positive := 54612348;
        variable rand  : real;
    begin

        -- popula vetor de entradas
        for i in tamanho_in - 1 downto 0 loop
            uniform(seed1, seed2, rand);
            i_vec(i) <= to_sfixed(rand, i_vec(i));
            wait for 10 ns;
        end loop;

        i_init <= '1';
        wait for 1 us;
        i_init <= '0';
        wait;
    end process inicia;

    conta: process (o_ocupado, i_clk) begin
        if falling_edge(o_ocupado) or rising_edge(o_ocupado) then
            contador <= 0;
        elsif rising_edge(i_clk) then
            contador <= contador + 1;
        end if;
    end process conta;

    termina: process(o_ocupado, i_clk) is
    begin
        if falling_edge(o_ocupado) then
            finalizou <= '1';
        end if;

        if falling_edge(i_clk) and finalizou = '1' then
            finish;
        end if;
    end process termina;

end architecture sim;
