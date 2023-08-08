library ieee;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use std.textio.all;
use std.env.finish;

library work;
use work.pacote_aux.all;
entity rede_tb is
end rede_tb;

architecture sim of rede_tb is
    -- Portas do componente
    signal clk                : bit := '0';
    signal i_init             : bit := '1';
    signal i_reset            : bit := '0';
    signal entrada_ponto_fixo : vec_s_fixo(n_caracteristicas - 1 downto 0) := (
        0 => x_teste(0, 0),
        1 => x_teste(0, 1),
        2 => x_teste(0, 2),
        3 => x_teste(0, 3)
        );
    signal o_resultado        : vec_s_fixo(n_classes - 1 downto 0);
    signal o_ocupado          : bit := '0';

    -- Sinais auxiliares
    signal contador  : integer := 0;
    signal incrementou : bit := '0';
    signal terminou : bit := '0';
    file fptr        : text;

begin

    UUT : entity work.rede
        generic map(
            entradas => n_caracteristicas,
            saidas   => n_classes
        )
        port map(
            i_clk       => clk,
            i_init      => i_init,
            i_reset     => i_reset,
            i_x         => entrada_ponto_fixo,
            o_resultado => o_resultado,
            o_ocupado   => o_ocupado
        );

    clock : process
    begin
        clk <= not clk;
        wait for 400 ns; -- 50 MHz
    end process clock;

    itera : process (o_ocupado)
        variable fstatus   : file_open_status;
        variable file_line : line;

    begin
        if falling_edge(o_ocupado) and incrementou = '0' then
            if contador = 0 then
                file_open(fstatus, fptr, "rede.csv", write_mode);
                write(file_line, string'("y;out_1;out_2;out_3"), left, 39);
                writeline(fptr, file_line);
            end if;

            write(file_line, y_teste(contador));
            write(file_line, string'(";"));
            write(file_line, o_resultado(0));
            write(file_line, string'(";"));
            write(file_line, o_resultado(1));
            write(file_line, string'(";"));
            write(file_line, o_resultado(2));
            writeline(fptr, file_line);

            contador <= contador + 1;
            if contador = amostras_teste - 1 then
               finish;
            end if;
            
            incrementou <= '1';
        else
            incrementou <= '0';
        end if;

    end process itera;

    termina: process(o_ocupado)
    begin
        if falling_edge(o_ocupado) then
            terminou <=  '1';
        elsif i_init = '1' then
            terminou <= '0';
        end if;

    end process termina;

    inicia: process(clk)
    begin
        if falling_edge(clk) and terminou = '1' then
            i_init <= '1';
        else
            i_init <= '0';
        end if;
    end process inicia;

    modifica_entrada: process(contador)
    begin
        entrada_ponto_fixo <= (
                0 => x_teste(contador, 0),
                1 => x_teste(contador, 1),
                2 => x_teste(contador, 2),
                3 => x_teste(contador, 3)
                );
    end process modifica_entrada;

end architecture sim;
