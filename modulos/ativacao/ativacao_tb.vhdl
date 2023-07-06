library ieee;
use ieee.fixed_pkg.all;
use std.env.finish;
use ieee.math_real.all;

library work;
use work.pacote_aux.all;
entity ativacao_tb is
end ativacao_tb;

architecture sim of ativacao_tb is
    -- Constantes
    constant tamanho_in : integer := 4;

    -- portas do componente
    signal i_clk     : bit := '0';
    signal i_init    : bit := '0';
    signal i_reset   : bit := '0';
    signal o_ocupado : bit := '0';
    signal i_vec     : vec_s_fixo(tamanho_in - 1 downto 0) := (others => to_sfixed(0, parte_inteira, parte_fracionaria));
    signal resultado : vec_s_fixo(tamanho_in - 1 downto 0) := (others => to_sfixed(0, parte_inteira, parte_fracionaria));
    signal vieses : vec_s_fixo(tamanho_in - 1 downto 0) := (
        0 => to_sfixed(0, parte_inteira, parte_fracionaria),
        1 => to_sfixed(1, parte_inteira, parte_fracionaria),
        2 => to_sfixed(2, parte_inteira, parte_fracionaria),
        3 => to_sfixed(3, parte_inteira, parte_fracionaria),
        others => to_sfixed(0, parte_inteira, parte_fracionaria)
        );

    -- sinais auxiliares
    signal contador  : integer := 0;
    signal finalizou : bit     := '0';


begin

    UUT : entity work.ativacao
        generic map (
            entradas => tamanho_in
            )
        port map (
            i_clk       => i_clk,
            i_init      => i_init,
            i_reset     => i_reset,
            i_x         => i_vec,
            i_vieses    => vieses,
            o_resultado => resultado,
            o_ocupado   => o_ocupado
            );

    clock : process
    begin
        i_clk <= not i_clk;
        wait for 400 ns;                -- 50Mhz
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

    conta : process (o_ocupado, i_clk)
    begin
        if falling_edge(o_ocupado) or rising_edge(o_ocupado) then
            contador <= 0;
        elsif rising_edge(i_clk) then
            contador <= contador + 1;
        end if;
    end process conta;
    
    
    termina : process(o_ocupado, i_clk) is
    begin
        if falling_edge(o_ocupado) then
            finalizou <= '1';
        elsif falling_edge(i_clk) and finalizou = '1' then
            finish;
        end if;
    end process termina;

end architecture sim;
