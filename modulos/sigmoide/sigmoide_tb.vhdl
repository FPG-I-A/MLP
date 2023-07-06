library ieee;
use ieee.fixed_pkg.all;
use std.textio.all;
use std.env.finish;

library work;
use work.pacote_aux.all;
entity sigmoide_tb is
end sigmoide_tb;

architecture sim of sigmoide_tb is

    signal entrada_ponto_fixo : s_fixo  := s_fixo_zero;
    signal clk                : bit     := '1';
    signal contador           : integer := 0;

    -- portas do componente
    signal resultado_quatro_partes : s_fixo;
    signal resultado_tres_partes   : s_fixo;

    -- Escrita no arquivo de saída
    file fptr_quatro_partes : text;
    file fptr_tres_partes   : text;

begin

    UUT_quatro : entity work.sigmoide(quatro_partes)
        generic map(
            gen_x_min => sig_x_min,
            gen_y_min => sig_y_min,
            gen_x_med => sig_x_med,
            gen_y_med => sig_y_med,
            gen_x_max => sig_x_max,
            gen_y_max => sig_y_max
        )
        port map(
            i_x         => entrada_ponto_fixo,
            o_resultado => resultado_quatro_partes
        );

    UUT_tres : entity work.sigmoide(tres_partes)
        generic map(
            gen_x_min => fim_l,
            gen_y_min => s_fim_l,
            gen_x_med => fim_med,
            gen_y_med => s_fim_med,
            gen_x_max => fim_n,
            gen_y_max => s_fim_n
        )
        port map(
            i_x         => entrada_ponto_fixo,
            o_resultado => resultado_tres_partes
        );

    clock : process
    begin
        clk <= not clk;
        wait for 400 ns; -- 50Mhz
    end process clock;

    itera : process (clk)
        variable fstatus_quatro_partes   : file_open_status;
        variable fstatus_tres_partes     : file_open_status;
        variable file_line_quatro_partes : line;
        variable file_line_tres_partes   : line;
    begin
        if rising_edge(clk) then
            if entrada_ponto_fixo = s_fixo_zero then
                file_open(fstatus_quatro_partes, fptr_quatro_partes, "sigmoide_quatro.csv", write_mode);
                write(file_line_quatro_partes, string'("x;sigmoide(x)"), left, 13);
                writeline(fptr_quatro_partes, file_line_quatro_partes);

                file_open(fstatus_tres_partes, fptr_tres_partes, "sigmoide_tres.csv", write_mode);
                write(file_line_tres_partes, string'("x;sigmoide(x)"), left, 13);
                writeline(fptr_tres_partes, file_line_tres_partes);
            end if;

            write(file_line_quatro_partes, entrada_ponto_fixo, left, parte_inteira - parte_fracionaria + 1);
            write(file_line_quatro_partes, string'(";"), left, 1);
            write(file_line_quatro_partes, resultado_quatro_partes, left, parte_inteira - parte_fracionaria + 1);
            writeline(fptr_quatro_partes, file_line_quatro_partes);

            write(file_line_tres_partes, entrada_ponto_fixo, left, parte_inteira - parte_fracionaria + 1);
            write(file_line_tres_partes, string'(";"), left, 1);
            write(file_line_tres_partes, resultado_tres_partes, left, parte_inteira - parte_fracionaria + 1);
            writeline(fptr_tres_partes, file_line_tres_partes);

            entrada_ponto_fixo <= resize(entrada_ponto_fixo + s_fixo_lsb, entrada_ponto_fixo);
            contador           <= contador + 1;
            if entrada_ponto_fixo = s_fixo_max then
                finish;
            end if;
        end if;
    end process itera;

end architecture sim;
