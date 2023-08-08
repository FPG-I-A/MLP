library ieee;
use ieee.fixed_pkg.all;

library work;
use work.pacote_aux.all;

entity rede is
    generic (
        entradas : integer;
        saidas   : integer
    );
    port (
        i_clk       : in bit;
        i_init      : in bit;
        i_reset     : in bit;
        i_x         : in vec_s_fixo(entradas - 1 downto 0);
        o_resultado : out vec_s_fixo(saidas - 1 downto 0);
        o_ocupado   : out bit
    );
end rede;

architecture processa of rede is

    -- Arquitetura da rede
    constant neuronios_1 : integer := 8;
    constant neuronios_2 : integer := 8;
    constant neuronios_3 : integer := 3;

    -- Camada 1
    signal resultado_1 : vec_s_fixo(neuronios_1 - 1 downto 0);
    signal ocupado_1   : bit := '0';
    signal init_1      : bit := '0';

    -- Camada 2
    signal resultado_2 : vec_s_fixo(neuronios_2 - 1 downto 0);
    signal ocupado_2   : bit := '0';
    signal init_2      : bit := '0';

    -- Camada 3
    signal resultado_3 : vec_s_fixo(neuronios_3 - 1 downto 0);
    signal ocupado_3   : bit := '0';
    signal init_3      : bit := '0';

    -- Sinais auxiliares
    signal entrada : vec_s_fixo(entradas - 1 downto 0);
    signal terminou : bit := '0';
begin
    camada_1 : entity work.camada
        generic map(
            entradas  => entradas,
            neuronios => neuronios_1
        )
        port map(
            i_clk       => i_clk,
            i_init      => init_1,
            i_reset     => i_reset,
            i_x         => entrada,
            i_pesos     => pesos_1,
            i_vieses    => vieses_1,
            o_resultado => resultado_1,
            o_ocupado   => ocupado_1
        );

    camada_2 : entity work.camada
        generic map(
            entradas  => neuronios_1,
            neuronios => neuronios_2
        )
        port map(
            i_clk       => i_clk,
            i_init      => init_2,
            i_reset     => i_reset,
            i_x         => resultado_1,
            i_pesos     => pesos_2,
            i_vieses    => vieses_2,
            o_resultado => resultado_2,
            o_ocupado   => ocupado_2
        );

    camada_3 : entity work.camada
        generic map(
            entradas  => neuronios_2,
            neuronios => neuronios_3
        )
        port map(
            i_clk       => i_clk,
            i_init      => init_3,
            i_reset     => i_reset,
            i_x         => resultado_2,
            i_pesos     => pesos_3,
            i_vieses    => vieses_3,
            o_resultado => resultado_3,
            o_ocupado   => ocupado_3
        );

    inicia_camada_1 : process (o_ocupado, i_clk) begin
        if rising_edge(o_ocupado) then
            init_1 <= '1';
        else
            init_1 <= '0';
        end if;
    end process inicia_camada_1;

    inicia_camada_2 : process (ocupado_1, i_clk) begin
        if falling_edge(ocupado_1) then
            init_2 <= '1';
        else
            init_2 <= '0';
        end if;
    end process inicia_camada_2;

    inicia_camada_3 : process (ocupado_2, i_clk) begin
        if falling_edge(ocupado_2) then
            init_3 <= '1';
        else
            init_3 <= '0';
        end if;
    end process inicia_camada_3;

    finaliza : process(ocupado_3) begin
        if falling_edge(ocupado_3) then
            terminou <= '1';
            o_resultado <= resultado_3;
        else
            terminou <= '0';
        end if;
    end process finaliza;

    inicializa : process (o_ocupado, i_init, i_reset, terminou) begin -- Controle dos estados da FSM
        if (o_ocupado = '0' and i_init = '1') or (o_ocupado = '1' and i_reset = '1' and i_init = '1') then
            entrada <= i_x;
            o_ocupado <= '1';
        elsif rising_edge(terminou) then
            o_ocupado <= '0';
        end if;
    end process inicializa;
end processa;
