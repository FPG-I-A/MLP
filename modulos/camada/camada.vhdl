library ieee;
use ieee.fixed_pkg.all;

library work;
use work.pacote_aux.all;

entity camada is
    generic (
        entradas  : integer;
        neuronios : integer
    );
    port (
        i_clk       : in bit;
        i_init      : in bit;
        i_reset     : in bit;
        i_x         : in vec_s_fixo(entradas - 1 downto 0);
        i_pesos     : in mat_s_fixo(entradas - 1 downto 0, neuronios - 1 downto 0);
        i_vieses    : in vec_s_fixo(neuronios - 1 downto 0);
        o_resultado : out vec_s_fixo(neuronios - 1 downto 0);
        o_ocupado   : out bit
    );
end camada;

architecture processa of camada is
    signal iniciar    : bit     := '0';

    -- Variáveis internas
    signal entrada : vec_s_fixo(entradas - 1 downto 0);
    signal pesos   : mat_s_fixo(entradas - 1 downto 0, neuronios - 1 downto 0);
    signal vieses  : vec_s_fixo(neuronios - 1 downto 0);

    -- Sinais para multiplicação
    signal mult_init          : bit := '0';
    signal mult_reset         : bit := '0';
    signal mult_ocupado       : bit;
    signal vetor_multiplicado : vec_s_fixo(neuronios - 1 downto 0);
    signal mult_comecou : bit := '0';
    signal mult_terminou : bit := '0';
    signal finaliza_mult : bit := '0';

    -- Sinais para sigmoide
    signal ativ_init : bit := '0';
    signal ativ_reset : bit := '0';
    signal ativ_ocupado : bit := '0';
    signal ativ_entrada : vec_s_fixo(neuronios - 1 downto 0);
    signal vetor_ativado : vec_s_fixo(neuronios - 1 downto 0);
    signal ativ_comecou : bit := '0';
    signal ativ_terminou : bit := '0';
    signal finaliza_ativ : bit := '0';

begin

    multiplicador : entity work.vec_mat_mul
        generic map(
            entradas  => entradas,
            neuronios => neuronios
        )
        port map(
            i_clk       => i_clk,
            i_init      => mult_init,
            i_reset     => mult_reset,
            i_vec       => entrada,
            i_mat       => pesos,
            o_resultado => vetor_multiplicado,
            o_ocupado   => mult_ocupado
        );
    ativa : entity work.ativacao
        generic map(
            entradas => neuronios
        )
        port map(
            i_clk       => i_clk,
            i_init      => ativ_init,
            i_reset     => ativ_reset,
            i_x         => ativ_entrada,
            i_vieses    => vieses,
            o_resultado => vetor_ativado,
            o_ocupado   => ativ_ocupado
        );
        
    
    termina_mult : process(mult_ocupado, i_clk) begin
        if falling_edge(mult_ocupado) then
            finaliza_mult <= '1';
        else
            finaliza_mult <= '0';
        end if;
    end process termina_mult;

    termina_ativ : process(ativ_ocupado, i_clk) begin
        if falling_edge(ativ_ocupado) then
            finaliza_ativ <= '1';
        else
            finaliza_ativ <= '0';
        end if;
    end process termina_ativ;

    calcula : process (i_clk) begin
        if iniciar = '1' then
            o_ocupado <= '1';
            
        end if;

        if o_ocupado = '1' then
            
            -- Multiplicação
            if mult_terminou = '0' and mult_ocupado = '0' and mult_comecou = '0' then
                mult_init <= '1';
                mult_comecou <= '1';
            elsif mult_terminou = '0' and mult_ocupado = '1' then
                mult_init <= '0';
            end if;
            if finaliza_mult = '1' then
                mult_terminou <= '1';
                ativ_entrada <= vetor_multiplicado;
            end if;

            -- Ativacoes
            if finaliza_mult = '1' and ativ_comecou = '0' then
                ativ_init <= '1';
                ativ_comecou <= '1';
            elsif ativ_terminou = '0' and ativ_ocupado = '1' then
                ativ_init <= '0';
            end if;

            -- Finaliza camada
            if finaliza_ativ = '1' then
                o_ocupado <= '0';

                -- Reseta variáveis de estado
                mult_comecou <= '0';
                mult_terminou <= '0';

                ativ_comecou <= '0';
                ativ_terminou <= '0';

                -- Ajusta resultado
                o_resultado <= vetor_ativado;
            end if;
        end if;


    end process calcula;
    
    inicializa : process (o_ocupado, i_init, i_reset, iniciar) begin -- Controle dos estados da FSM
        checa_estado : if (o_ocupado = '0' and i_init = '1') or (o_ocupado = '1' and i_reset = '1' and i_init = '1') then
            entrada <= i_x;
            pesos <= i_pesos;
            vieses <= i_vieses;
            iniciar <= '1';
        else
            iniciar <= '0';
        end if checa_estado;
    end process inicializa;

    
end processa;
