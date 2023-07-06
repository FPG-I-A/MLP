library ieee;
use ieee.fixed_pkg.all;

library work;
use work.pacote_aux.all;

entity sigmoide is
    generic (
        gen_x_min : s_fixo;
        gen_y_min : s_fixo;
        gen_x_med : s_fixo;
        gen_y_med : s_fixo;
        gen_x_max : s_fixo;
        gen_y_max : s_fixo
    );
    port (
        i_x         : in s_fixo;
        o_resultado : out s_fixo
    );
end sigmoide;

architecture quatro_partes of sigmoide is

    -- Limites superior e inferior
    constant x_inf : s_fixo := s_fixo_min;
    constant x_sup : s_fixo := s_fixo_max;

    -- Primeira parte linear
    constant b0 : s_fixo := resize(-gen_y_min / (x_inf - gen_x_min), i_x);
    constant c0 : s_fixo := resize(-b0 * x_inf, i_x);

    -- Primeira parte não linear
    constant b1 : s_fixo := resize(gen_x_min / ((2 * gen_x_min * gen_x_med) - (gen_x_med * gen_x_med) - (gen_x_min * gen_x_min)), i_x);
    constant a1 : s_fixo := resize(-b1 / (2 * gen_x_min), i_x);
    constant c1 : s_fixo := resize((b1 * b1) / (4 * a1), i_x);

    -- Segunda parte não linear
    constant b2 : s_fixo := resize(-gen_x_max / (2 * gen_x_max * gen_x_med - (gen_x_med * gen_x_med) - (gen_x_max * gen_x_max)), i_x);
    constant a2 : s_fixo := resize(-b2 / (2 * gen_x_max), i_x);
    constant c2 : s_fixo := resize(1 + (b2 * b2) / (4 * a2), i_x);

    -- Segunda parte linear
    constant b3 : s_fixo := resize((1 - gen_y_max) / (x_sup - gen_x_max), i_x);
    constant c3 : s_fixo := resize(1 - b3 * x_sup, i_x);
begin

    calcula : process (i_x) begin
        if i_x < gen_x_min then
            o_resultado     <= resize(c0 + b0 * i_x, o_resultado);
        elsif gen_x_min <= i_x and i_x < gen_x_med then
            o_resultado     <= resize(c1 + i_x * (b1 + a1 * i_x), o_resultado);
        elsif gen_x_med <= i_x and i_x < gen_x_max then
            o_resultado     <= resize(c2 + i_x * (b2 + a2 * i_x), o_resultado);
        elsif gen_x_max < i_x then
            o_resultado <= resize(c3 + b3 * i_x, o_resultado);
        end if;
    end process calcula;

end quatro_partes;

architecture tres_partes of sigmoide is
    -- Variáveis auxiliares
    constant x_sup : s_fixo := s_fixo_max;
    constant x_inf : s_fixo := s_fixo_min;

    -- Ajuste de pontos de interesse
    constant fim_l   : s_fixo := gen_x_min;
    constant fim_n   : s_fixo := gen_x_max;
    constant s_fim_l : s_fixo := gen_y_min;
    constant s_fim_n : s_fixo := gen_y_max;
    constant y_med   : s_fixo := gen_y_med;

    -- Primeira parte linear
    constant a1 : s_fixo := resize((0.5 - s_fim_l) / (0 - fim_l), parte_inteira, parte_fracionaria);
    constant b1 : s_fixo := resize(0.5 - 0 * a1, parte_inteira, parte_fracionaria);

    -- Parte não linear
    constant a2 : s_fixo := resize((2 * s_fim_l - 4 * y_med + 2 * s_fim_n) / ((fim_n - fim_l) * (fim_n - fim_l)), parte_inteira, parte_fracionaria);
    constant b2 : s_fixo := resize(2 * (y_med - s_fim_l) / (fim_n - fim_l) - a2 * (3 * fim_l + fim_n) / 2, parte_inteira, parte_fracionaria);
    constant c2 : s_fixo := resize(s_fim_l - a2 * fim_l * fim_l - b2 * fim_l, parte_inteira, parte_fracionaria);

    -- Segunda parte linear
    constant a3 : s_fixo := resize((s_fim_n - 1) / (fim_n - x_sup), parte_inteira, parte_fracionaria);
    constant b3 : s_fixo := resize(s_fim_n - fim_n * a3, parte_inteira, parte_fracionaria);

begin

    calcula : process (i_x) begin
        if i_x >= x_inf and i_x    <= - fim_n then
            o_resultado                <= resize(1 + a3 * i_x - b3, o_resultado);
        elsif i_x >- fim_n and i_x <= - fim_l then
            o_resultado                <= resize(1 - c2 + i_x * (-a2 * i_x + b2), o_resultado);
        elsif i_x >- fim_l and i_x <= 0 then
            o_resultado                <= resize(1 + a1 * i_x - b1, o_resultado);
        elsif i_x > 0 and i_x      <= fim_l then
            o_resultado                <= resize(a1 * i_x + b1, o_resultado);
        elsif i_x > fim_l and i_x  <= fim_n then
            o_resultado                <= resize(c2 + i_x * (a2 * i_x + b2), o_resultado);
        else
            o_resultado <= resize(a3 * i_x + b3, o_resultado);
        end if;
    end process calcula;
end tres_partes;
