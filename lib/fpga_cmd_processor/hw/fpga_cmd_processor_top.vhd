-- Copyright (C) 2017 Philipp Holzinger
-- Copyright (C) 2017 Martin Stumpf
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity fpga_cmd_processor_top is
    generic(
	G_START_ADDRESS			: std_logic_vector(63 downto 0)	:= x"0003000000000000";
	G_EXCEPTION_HANDLER_ADDRESS	: std_logic_vector(63 downto 0) := x"0003000000000070";
        -- interrupts
        G_TIMER_INTERRUPT               : boolean := false;
	G_NUM_ACCELERATOR_CORES		: integer := 1;
        -- exceptions
        G_EXC_ADDRESS_ERROR_LOAD        : boolean := true;
        G_EXC_ADDRESS_ERROR_FETCH       : boolean := true;
        G_EXC_ADDRESS_ERROR_STORE       : boolean := true;
        G_EXC_INSTRUCTION_BUS_ERROR     : boolean := true;
        G_EXC_DATA_BUS_ERROR            : boolean := true;
        G_EXC_SYSCALL                   : boolean := false;
        G_EXC_BREAKPOINT                : boolean := false;
        G_EXC_RESERVED_INSTRUCTION      : boolean := false;
        G_EXC_COP_UNIMPLEMENTED         : boolean := false;
        G_EXC_ARITHMETIC_OVERFLOW       : boolean := false;
        G_EXC_TRAP                      : boolean := false;
        G_EXC_FLOATING_POINT            : boolean := false;
        -- memory configuration
        G_MEM_NUM_4K_DATA_MEMS          : integer := 4;
        G_MEM_NUM_4K_INSTR_MEMS         : integer := 4;
	-- configuration addresses	
	C_CMD_LOW_ADDR			: std_logic_vector	:= x"0002000000000000";
	C_CMD_HIGH_ADDR			: std_logic_vector	:= x"0004000200000000";
	C_CMD_AXI_ADDR_WIDTH		: integer		:= 64;
	C_CMD_AXI_DATA_WIDTH		: integer		:= 64;	
	C_DATA_LOW_ADDR			: std_logic_vector	:= x"0001000000000000";
	C_DATA_HIGH_ADDR		: std_logic_vector	:= x"0001000100000000";
	C_DATA_AXI_ADDR_WIDTH		: integer		:= 64;
	C_DATA_AXI_DATA_WIDTH		: integer		:= 64;
	C_CPU_HALT_NUM_ADDR		: std_logic_vector	:= x"0002000000000000";
	C_IRQ_SND_NUM_ADDR		: std_logic_vector	:= x"0002000000000008";
    	C_IMEM_LOW_ADDR       		: std_logic_vector	:= x"0003000000000000";
        C_IMEM_INIT_FILE    		: string 		:= "";
    	C_DMEM_LOW_ADDR       		: std_logic_vector 	:= x"0003000002000000";
        C_DMEM_INIT_FILE    		: string 		:= ""
    );
    port(
        tp_clk                  : in  std_logic;
        tp_rstn                 : in  std_logic;
    	-- ingoing interrupts
	rcv_dma_irq		: in std_logic;
	rcv_cpl_irq		: in std_logic;
	rcv_add_irq		: in std_logic;
	rcv_rem_irq		: in std_logic;
	rcv_dma_irq_ack		: out std_logic;
	rcv_cpl_irq_ack		: out std_logic;
	rcv_add_irq_ack		: out std_logic;
	rcv_rem_irq_ack		: out std_logic;
        -- outgoing interrupts
        snd_aql_irq		: out std_logic;
        snd_dma_irq		: out std_logic;
        snd_cpl_irq		: out std_logic;
        snd_add_irq		: out std_logic;
        snd_rem_irq		: out std_logic;
        snd_aql_irq_ack		: in std_logic;
        snd_dma_irq_ack		: in std_logic;
        snd_cpl_irq_ack		: in std_logic;
        snd_add_irq_ack		: in std_logic;
        snd_rem_irq_ack		: in std_logic;

	-- cpu halt signals
        pp_halt			: out std_logic;
        ac_halt_lanes		: out std_logic_vector(G_NUM_ACCELERATOR_CORES-1 downto 0);
	
	-- axi interfaces
	cmd_axi_aclk      : in    std_logic; 
	cmd_axi_aresetn   : in    std_logic;
	data_axi_aclk     : in    std_logic;                                              
	data_axi_aresetn  : in    std_logic;
	
	cmd_axi_awaddr	: out std_logic_vector(C_CMD_AXI_ADDR_WIDTH-1 downto 0);   
	cmd_axi_awprot	: out std_logic_vector(2 downto 0);
	cmd_axi_awvalid	: out std_logic;
	cmd_axi_awready	: in std_logic;
	cmd_axi_wdata	: out std_logic_vector(C_CMD_AXI_DATA_WIDTH-1 downto 0);
	cmd_axi_wstrb	: out std_logic_vector(C_CMD_AXI_DATA_WIDTH/8-1 downto 0);
	cmd_axi_wvalid	: out std_logic;
	cmd_axi_wready	: in std_logic;
	cmd_axi_bresp	: in std_logic_vector(1 downto 0);
	cmd_axi_bvalid	: in std_logic;
	cmd_axi_bready	: out std_logic;
	cmd_axi_araddr	: out std_logic_vector(C_CMD_AXI_ADDR_WIDTH-1 downto 0);
	cmd_axi_arprot	: out std_logic_vector(2 downto 0);
	cmd_axi_arvalid	: out std_logic;
	cmd_axi_arready	: in std_logic;
	cmd_axi_rdata	: in std_logic_vector(C_CMD_AXI_DATA_WIDTH-1 downto 0);
	cmd_axi_rresp	: in std_logic_vector(1 downto 0);
	cmd_axi_rvalid	: in std_logic;
	cmd_axi_rready	: out std_logic;
	
	data_axi_awaddr	 : out std_logic_vector(C_DATA_AXI_ADDR_WIDTH-1 downto 0);     
	data_axi_awprot	 : out std_logic_vector(2 downto 0);
	data_axi_awvalid : out std_logic;
	data_axi_awready : in std_logic;
	data_axi_wdata	 : out std_logic_vector(C_DATA_AXI_DATA_WIDTH-1 downto 0);
	data_axi_wstrb   : out std_logic_vector(C_DATA_AXI_DATA_WIDTH/8-1 downto 0);
	data_axi_wvalid	 : out std_logic;
	data_axi_wready	 : in std_logic;
	data_axi_bresp	 : in std_logic_vector(1 downto 0);
	data_axi_bvalid	 : in std_logic;
	data_axi_bready	 : out std_logic;
	data_axi_araddr  : out std_logic_vector(C_DATA_AXI_ADDR_WIDTH-1 downto 0);
	data_axi_arprot	 : out std_logic_vector(2 downto 0);
	data_axi_arvalid : out std_logic;
	data_axi_arready : in std_logic;
	data_axi_rdata	 : in std_logic_vector(C_DATA_AXI_DATA_WIDTH-1 downto 0);
	data_axi_rresp	 : in std_logic_vector(1 downto 0);
	data_axi_rvalid	 : in std_logic;
	data_axi_rready	 : out std_logic
    );
end entity;
-- /*end-folding-block*/

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture behav of fpga_cmd_processor_top is


--------------------------------------------------------------------------------
-- COMPONENTS
--------------------------------------------------------------------------------
-- /*start-folding-block*/

component cpu_top_64 is
    generic(
        G_START_ADDRESS             : std_logic_vector(63 downto 0) := x"0000000000000000";
        G_EXCEPTION_HANDLER_ADDRESS : std_logic_vector(63 downto 0) := x"0000000000000010";
        -- interrupts
        G_TIMER_INTERRUPT           : boolean := false;
        G_NUM_HW_INTERRUPTS         : integer range 0 to 6 := 1;
        -- exceptions
        G_EXC_ADDRESS_ERROR_LOAD    : boolean := false;
        G_EXC_ADDRESS_ERROR_FETCH   : boolean := false;
        G_EXC_ADDRESS_ERROR_STORE   : boolean := false;
        G_EXC_INSTRUCTION_BUS_ERROR : boolean := false;
        G_EXC_DATA_BUS_ERROR        : boolean := false;
        G_EXC_SYSCALL               : boolean := false;
        G_EXC_BREAKPOINT            : boolean := false;
        G_EXC_RESERVED_INSTRUCTION  : boolean := false;
        G_EXC_COP_UNIMPLEMENTED     : boolean := false;
        G_EXC_ARITHMETIC_OVERFLOW   : boolean := false;
        G_EXC_TRAP                  : boolean := false;
        G_EXC_FLOATING_POINT        : boolean := false;
        -- ASIP
        G_SENSOR_DATA_WIDTH         : integer range 1 to 1024;
        G_SENSOR_CONF_WIDTH         : integer range 1 to 1024;
        G_BUSY_LIST_WIDTH           : integer range 1 to 1024
    );
    port(
        clk                         : in  std_logic;
        resetn                      : in  std_logic;
        enable                      : in  std_logic;

        interrupt                   : in  std_logic_vector(5 downto 0);
        interrupt_ack               : out std_logic;
        --interrupt_ack               : out std_logic_vector(1 downto 0);

        -- memory interface
        -- instruction memory interface
        inst_addr                   : out std_logic_vector(63 downto 0);
        inst_din                    : in  std_logic_vector(31 downto 0);
        inst_read_busy              : in  std_logic;

        -- data memory interface
        data_addr                   : out std_logic_vector(63 downto 0);
        data_din                    : in  std_logic_vector(63 downto 0);
        data_dout                   : out std_logic_vector(63 downto 0);
        data_read_busy              : in  std_logic;
        data_write_busy             : in  std_logic;

        -- control memory interface
        hazard_stall                : out std_logic;
        data_read_access            : out std_logic;
        data_write_access           : out std_logic;

        -- memory exceptions
        address_error_exc_load      : in  std_logic;
        address_error_exc_fetch     : in  std_logic;
        address_error_exc_store     : in  std_logic;
        instruction_bus_exc         : in  std_logic;
        data_bus_exc                : in  std_logic;

        -- sensor interface
        sensor_data_in              : in  std_logic_vector(G_SENSOR_DATA_WIDTH-1 downto 0);
        sensor_config_out           : out std_logic_vector(G_SENSOR_CONF_WIDTH-1 downto 0)
    );
end component;

component memory_controller_fcp is
    generic(
		C_CPU_INSTR_WIDTH			: integer		:= 32;
		C_CPU_DATA_WIDTH			: integer		:= 64;
		C_CPU_ADDR_WIDTH			: integer		:= 64;
		C_CMD_LOW_ADDR				: std_logic_vector	:= x"0002000000000000";
		C_CMD_HIGH_ADDR				: std_logic_vector	:= x"0002000000010000";
		C_CMD_AXI_ADDR_WIDTH			: integer		:= 64;
		C_CMD_AXI_DATA_WIDTH			: integer		:= 64;	
		C_DATA_LOW_ADDR				: std_logic_vector	:= x"0001000000000000";
		C_DATA_HIGH_ADDR			: std_logic_vector	:= x"0001000100000000";
		C_DATA_AXI_ADDR_WIDTH			: integer		:= 64;
		C_DATA_AXI_DATA_WIDTH			: integer		:= 64;
		C_CPU_HALT_NUM_ADDR			: std_logic_vector	:= x"0002000000000000";
		C_IRQ_SND_NUM_ADDR			: std_logic_vector	:= x"0002000000000008";
    		C_IMEM_LOW_ADDR       			: std_logic_vector	:= x"0003000000000000";
    		C_IMEM_BRAM_SIZE       			: integer 		:= 16348;
		C_IMEM_INIT_FILE    			: string 		:= "";
    		C_DMEM_LOW_ADDR       			: std_logic_vector 	:= x"0003000002000000";
    		C_DMEM_BRAM_SIZE       			: integer 		:= 16348;
		C_DMEM_INIT_FILE    			: string 		:= ""
    );
    port(
        clk                     : in    std_logic;
        rstn                    : in    std_logic;
        halt                    : in    std_logic;

	-- connections to MIPS
	mips_inst_addr  	: in    std_logic_vector(C_CPU_ADDR_WIDTH-1 downto 0);
	mips_inst_re    	: in    std_logic;
	mips_inst_dout  	: out   std_logic_vector(C_CPU_INSTR_WIDTH-1 downto 0);
	mips_data_addr  	: in    std_logic_vector(C_CPU_ADDR_WIDTH-1 downto 0);
	mips_data_re    	: in    std_logic;
	mips_data_we    	: in    std_logic;
	mips_data_din   	: in    std_logic_vector(C_CPU_DATA_WIDTH-1 downto 0);
	mips_data_dout  	: out   std_logic_vector(C_CPU_DATA_WIDTH-1 downto 0);
	mips_inst_read_busy     : out   std_logic;
	mips_data_read_busy     : out   std_logic;
	mips_data_write_busy    : out   std_logic;

	-- exceptions to MIPS
	mips_address_error_exc_load     : out std_logic;
	mips_address_error_exc_fetch    : out std_logic;
	mips_address_error_exc_store    : out std_logic;
	mips_instruction_bus_exc        : out std_logic;
	mips_data_bus_exc               : out std_logic; 
    	
	-- to interrupt controller
	SND_INT_NUM			: out std_logic_vector(C_CPU_DATA_WIDTH-1 downto 0);
	SND_INT_SIG			: out std_logic;
	
	-- to halt logic
	SND_CPU_HALT_NUM		: out std_logic_vector(C_CPU_DATA_WIDTH-1 downto 0);
	SND_CPU_HALT_SIG		: out std_logic;

	-- AXI clock and reset
	cmd_axi_aclk   	: in    std_logic;                                              
	cmd_axi_aresetn : in    std_logic;
	data_axi_aclk 	: in    std_logic;                                              
	data_axi_aresetn: in    std_logic;
		
	-- Ports of Axi Master Bus Interface CMD_AXI
	cmd_axi_awaddr	: out std_logic_vector(C_CMD_AXI_ADDR_WIDTH-1 downto 0);   
	cmd_axi_awprot	: out std_logic_vector(2 downto 0);
	cmd_axi_awvalid	: out std_logic;
	cmd_axi_awready	: in std_logic;
	cmd_axi_wdata	: out std_logic_vector(C_CMD_AXI_DATA_WIDTH-1 downto 0);
	cmd_axi_wstrb	: out std_logic_vector(C_CMD_AXI_DATA_WIDTH/8-1 downto 0);
	cmd_axi_wvalid	: out std_logic;
	cmd_axi_wready	: in std_logic;
	cmd_axi_bresp	: in std_logic_vector(1 downto 0);
	cmd_axi_bvalid	: in std_logic;
	cmd_axi_bready	: out std_logic;
	cmd_axi_araddr	: out std_logic_vector(C_CMD_AXI_ADDR_WIDTH-1 downto 0);
	cmd_axi_arprot	: out std_logic_vector(2 downto 0);
	cmd_axi_arvalid	: out std_logic;
	cmd_axi_arready	: in std_logic;
	cmd_axi_rdata	: in std_logic_vector(C_CMD_AXI_DATA_WIDTH-1 downto 0);
	cmd_axi_rresp	: in std_logic_vector(1 downto 0);
	cmd_axi_rvalid	: in std_logic;
	cmd_axi_rready	: out std_logic;
		
	-- Ports of Axi Master Bus Interface DATA_AXI
	data_axi_awaddr	: out std_logic_vector(C_DATA_AXI_ADDR_WIDTH-1 downto 0);     
	data_axi_awprot	: out std_logic_vector(2 downto 0);
	data_axi_awvalid: out std_logic;
	data_axi_awready: in std_logic;
	data_axi_wdata	: out std_logic_vector(C_DATA_AXI_DATA_WIDTH-1 downto 0);
	data_axi_wstrb	: out std_logic_vector(C_DATA_AXI_DATA_WIDTH/8-1 downto 0);
	data_axi_wvalid	: out std_logic;
	data_axi_wready	: in std_logic;
	data_axi_bresp	: in std_logic_vector(1 downto 0);
	data_axi_bvalid	: in std_logic;
	data_axi_bready	: out std_logic;
	data_axi_araddr	: out std_logic_vector(C_DATA_AXI_ADDR_WIDTH-1 downto 0);
	data_axi_arprot	: out std_logic_vector(2 downto 0);
	data_axi_arvalid: out std_logic;
	data_axi_arready: in std_logic;
	data_axi_rdata	: in std_logic_vector(C_DATA_AXI_DATA_WIDTH-1 downto 0);
	data_axi_rresp	: in std_logic_vector(1 downto 0);
	data_axi_rvalid	: in std_logic;
	data_axi_rready	: out std_logic
    );
end component;

component INTERRUPT_DEMUX is
generic(
	N: integer := 4
);
port(
    	INT_LANES: out std_logic_vector(N-1 downto 0);
    	INT_LANES_RESPONSE: in std_logic_vector(N-1 downto 0);
	INT_NUM: in std_logic_vector(integer(ceil(log2(real(N))))-1 downto 0);
	INT_SIG: in std_logic;
    	EN: in std_logic;
	RE: in std_logic;
	CLK: in std_logic
);
end component;

-- /*end-folding-block*/


--------------------------------------------------------------------------------
-- CONSTANTS AND SIGNALS
--------------------------------------------------------------------------------
-- /*start-folding-block*/

-- signals to cpu
    signal cpu_enable	: std_logic;

-- memory interface
    signal s_inst_addr                  : std_logic_vector(63 downto 0);
    signal s_data_addr                  : std_logic_vector(63 downto 0);

    signal s_data_dout                  : std_logic_vector(63 downto 0);
    signal s_data_we                    : std_logic;
    signal s_data_re                    : std_logic;

    signal s_inst_din                   : std_logic_vector(31 downto 0);
    signal s_data_din                   : std_logic_vector(63 downto 0);

    signal s_address_error_exc_load     : std_logic;
    signal s_address_error_exc_fetch    : std_logic;
    signal s_address_error_exc_store    : std_logic;
    signal s_instruction_bus_exc        : std_logic;
    signal s_data_bus_exc               : std_logic;
    
    signal r_exception                  : std_logic;

    signal s_memctrl_halt               : std_logic;
    signal s_cpu_hazard    	  	: std_logic;

    signal s_data_read_busy             : std_logic;
    signal s_inst_read_busy             : std_logic;
    signal s_data_write_busy            : std_logic;

-- signals for the interrupt controller
    signal s_cpu_irq_ack: std_logic;
    signal r_prev_cpu_irq_ack: std_logic;
    signal s_irq_type: std_logic_vector(5 downto 0);
    signal s_snd_irq_lanes: std_logic_vector(4 downto 0);
    signal s_snd_irq_lanes_resp: std_logic_vector(4 downto 0);
    signal s_snd_irq_num: std_logic_vector(2 downto 0);
    signal s_snd_irq_num64: std_logic_vector(63 downto 0);
    signal s_snd_irq_en: std_logic;
    signal s_rcv_int_lanes: std_logic_vector(3 downto 0);

-- halt signals
    signal s_cpu_halt_write_en :std_logic;
    signal s_cpu_halt_num64    :std_logic_vector(63 downto 0);
    signal r_cpu_halt          :std_logic_vector(G_NUM_ACCELERATOR_CORES downto 0);

-- /*end-folding-block*/

begin

cpu_enable <= '1';
s_memctrl_halt <= not (cpu_enable); -- or s_cpu_hazard;

s_snd_irq_num <= s_snd_irq_num64(2 downto 0);
 
s_rcv_int_lanes <= rcv_dma_irq & rcv_cpl_irq & rcv_add_irq & rcv_rem_irq;
s_irq_type(5 downto 2) <= s_rcv_int_lanes;
s_irq_type(1 downto 0) <= (others => '0');

s_snd_irq_lanes_resp <= snd_aql_irq_ack & snd_dma_irq_ack & snd_cpl_irq_ack & snd_add_irq_ack & snd_rem_irq_ack;

snd_aql_irq		<= s_snd_irq_lanes(4);
snd_dma_irq		<= s_snd_irq_lanes(3);
snd_cpl_irq		<= s_snd_irq_lanes(2);
snd_add_irq		<= s_snd_irq_lanes(1);
snd_rem_irq		<= s_snd_irq_lanes(0);

-- only send the irq ack when it is caused by an interrupt and not by an exception
rcv_dma_irq_ack		<= rcv_dma_irq and not(r_prev_cpu_irq_ack) and s_cpu_irq_ack and not(r_exception);
rcv_cpl_irq_ack		<= rcv_cpl_irq and not(r_prev_cpu_irq_ack) and s_cpu_irq_ack and not(r_exception);
rcv_add_irq_ack		<= rcv_add_irq and not(r_prev_cpu_irq_ack) and s_cpu_irq_ack and not(r_exception);
rcv_rem_irq_ack		<= rcv_rem_irq and not(r_prev_cpu_irq_ack) and s_cpu_irq_ack and not(r_exception);

pp_halt	     		<= r_cpu_halt(0);
ac_halt_lanes		<= r_cpu_halt(G_NUM_ACCELERATOR_CORES downto 1);

--------------------------------------------------------------------------------
-- PORT MAPS
--------------------------------------------------------------------------------
-- /*start-folding-block*/
cpu_top_inst : cpu_top_64
    generic map(
        G_START_ADDRESS                 => G_START_ADDRESS,
        G_EXCEPTION_HANDLER_ADDRESS     => G_EXCEPTION_HANDLER_ADDRESS,
        -- interrupts
        G_TIMER_INTERRUPT               => G_TIMER_INTERRUPT,
        G_NUM_HW_INTERRUPTS             => 4,
        -- exceptions
        G_EXC_ADDRESS_ERROR_LOAD        => G_EXC_ADDRESS_ERROR_LOAD,
        G_EXC_ADDRESS_ERROR_FETCH       => G_EXC_ADDRESS_ERROR_FETCH,
        G_EXC_ADDRESS_ERROR_STORE       => G_EXC_ADDRESS_ERROR_STORE,
        G_EXC_INSTRUCTION_BUS_ERROR     => G_EXC_INSTRUCTION_BUS_ERROR,
        G_EXC_DATA_BUS_ERROR            => G_EXC_DATA_BUS_ERROR,
        G_EXC_SYSCALL                   => G_EXC_SYSCALL,
        G_EXC_BREAKPOINT                => G_EXC_BREAKPOINT,
        G_EXC_RESERVED_INSTRUCTION      => G_EXC_RESERVED_INSTRUCTION,
        G_EXC_COP_UNIMPLEMENTED         => G_EXC_COP_UNIMPLEMENTED,
        G_EXC_ARITHMETIC_OVERFLOW       => G_EXC_ARITHMETIC_OVERFLOW,
        G_EXC_TRAP                      => G_EXC_TRAP,
        G_EXC_FLOATING_POINT            => G_EXC_FLOATING_POINT,
        -- ASIP
        G_SENSOR_DATA_WIDTH             => 2, -- not used
        G_SENSOR_CONF_WIDTH             => 2, -- not used
        G_BUSY_LIST_WIDTH               => 2  -- not used
    )
    port map(
        clk                             => tp_clk,
        resetn                          => tp_rstn,
        enable                          => cpu_enable,

        interrupt                       => s_irq_type,
        interrupt_ack                   => s_cpu_irq_ack,

        -- memory interface
        -- instruction memory interface
        inst_addr                       => s_inst_addr,
        inst_din                        => s_inst_din,
        inst_read_busy                  => s_inst_read_busy,

        -- data memory interface
        data_addr                       => s_data_addr,
        data_din                        => s_data_din,
        data_dout                       => s_data_dout,
        data_read_busy                  => s_data_read_busy,
        data_write_busy                 => s_data_write_busy,


        -- control memory interface
        hazard_stall                    => s_cpu_hazard,
        data_read_access                => s_data_re,
        data_write_access               => s_data_we,

        -- memory exceptions
        address_error_exc_load          => s_address_error_exc_load,
        address_error_exc_fetch         => s_address_error_exc_fetch,
        address_error_exc_store         => s_address_error_exc_store,
        instruction_bus_exc             => s_instruction_bus_exc,
        data_bus_exc                    => s_data_bus_exc,

        -- sensor interface
        sensor_data_in                  => (others => '0'),
        sensor_config_out               => open
);

inst_memory_controller: memory_controller_fcp
    generic map(
	C_CPU_INSTR_WIDTH	=> 32,
	C_CPU_DATA_WIDTH	=> 64,
	C_CPU_ADDR_WIDTH	=> 64,
	C_CMD_LOW_ADDR		=> C_CMD_LOW_ADDR,
	C_CMD_HIGH_ADDR		=> C_CMD_HIGH_ADDR,
	C_CMD_AXI_ADDR_WIDTH	=> C_CMD_AXI_ADDR_WIDTH,
	C_CMD_AXI_DATA_WIDTH	=> C_CMD_AXI_DATA_WIDTH,
	C_DATA_LOW_ADDR		=> C_DATA_LOW_ADDR,		
	C_DATA_HIGH_ADDR	=> C_DATA_HIGH_ADDR,
	C_DATA_AXI_ADDR_WIDTH	=> C_DATA_AXI_ADDR_WIDTH,
	C_DATA_AXI_DATA_WIDTH	=> C_DATA_AXI_DATA_WIDTH,
	C_CPU_HALT_NUM_ADDR	=> C_CPU_HALT_NUM_ADDR,
	C_IRQ_SND_NUM_ADDR	=> C_IRQ_SND_NUM_ADDR,
    	C_IMEM_LOW_ADDR         => C_IMEM_LOW_ADDR, 
    	C_IMEM_BRAM_SIZE      	=> G_MEM_NUM_4K_INSTR_MEMS*4096,
        C_IMEM_INIT_FILE        => C_IMEM_INIT_FILE,
    	C_DMEM_LOW_ADDR       	=> C_DMEM_LOW_ADDR, 
    	C_DMEM_BRAM_SIZE      	=> G_MEM_NUM_4K_DATA_MEMS*4096,
        C_DMEM_INIT_FILE        => C_DMEM_INIT_FILE
    )                                    
    port map(
        clk                   	=> tp_clk,
        rstn                    => tp_rstn,
        halt                    => s_memctrl_halt,
	mips_inst_addr  	=> s_inst_addr,      
	mips_inst_re    	=> '1',        
	mips_inst_dout  	=> s_inst_din,      
	mips_data_addr  	=> s_data_addr,      
	mips_data_re    	=> s_data_re,        
	mips_data_we    	=> s_data_we,        
	mips_data_din   	=> s_data_dout,       
	mips_data_dout  	=> s_data_din,      
	mips_inst_read_busy     => s_inst_read_busy, 
	mips_data_read_busy     => s_data_read_busy, 
	mips_data_write_busy    => s_data_write_busy,
	mips_address_error_exc_load  	=> s_address_error_exc_load,    
	mips_address_error_exc_fetch    => s_address_error_exc_fetch,
	mips_address_error_exc_store    => s_address_error_exc_store,
	mips_instruction_bus_exc        => s_instruction_bus_exc,    
	mips_data_bus_exc               => s_data_bus_exc,           
	SND_INT_NUM			=> s_snd_irq_num64,
	SND_INT_SIG			=> s_snd_irq_en,
	SND_CPU_HALT_NUM		=> s_cpu_halt_num64,
	SND_CPU_HALT_SIG		=> s_cpu_halt_write_en,
	cmd_axi_aclk   	=> cmd_axi_aclk,
        cmd_axi_aresetn => cmd_axi_aresetn, 
        data_axi_aclk 	=> data_axi_aclk,
        data_axi_aresetn=> data_axi_aresetn,
	cmd_axi_awaddr	=> cmd_axi_awaddr,
	cmd_axi_awprot	=> cmd_axi_awprot,
	cmd_axi_awvalid	=> cmd_axi_awvalid,
	cmd_axi_awready	=> cmd_axi_awready,
	cmd_axi_wdata	=> cmd_axi_wdata,
	cmd_axi_wstrb	=> cmd_axi_wstrb,
	cmd_axi_wvalid	=> cmd_axi_wvalid,
	cmd_axi_wready	=> cmd_axi_wready,
	cmd_axi_bresp	=> cmd_axi_bresp,
	cmd_axi_bvalid	=> cmd_axi_bvalid,
	cmd_axi_bready	=> cmd_axi_bready,
	cmd_axi_araddr	=> cmd_axi_araddr,
	cmd_axi_arprot	=> cmd_axi_arprot,
	cmd_axi_arvalid	=> cmd_axi_arvalid,
	cmd_axi_arready	=> cmd_axi_arready,
	cmd_axi_rdata	=> cmd_axi_rdata,
	cmd_axi_rresp	=> cmd_axi_rresp,
	cmd_axi_rvalid	=> cmd_axi_rvalid,
	cmd_axi_rready	=> cmd_axi_rready,
	
	data_axi_awaddr	 => data_axi_awaddr,
	data_axi_awprot	 => data_axi_awprot,
	data_axi_awvalid => data_axi_awvalid,
	data_axi_awready => data_axi_awready,
	data_axi_wdata	 => data_axi_wdata,
	data_axi_wstrb   => data_axi_wstrb,
	data_axi_wvalid	 => data_axi_wvalid,
	data_axi_wready	 => data_axi_wready,
	data_axi_bresp	 => data_axi_bresp,
	data_axi_bvalid	 => data_axi_bvalid,
	data_axi_bready	 => data_axi_bready,
	data_axi_araddr  => data_axi_araddr,
	data_axi_arprot	 => data_axi_arprot,
	data_axi_arvalid => data_axi_arvalid,
	data_axi_arready => data_axi_arready,
	data_axi_rdata	 => data_axi_rdata,
	data_axi_rresp	 => data_axi_rresp,
	data_axi_rvalid	 => data_axi_rvalid,
	data_axi_rready	 => data_axi_rready
   );

inst_interrupt_demux: INTERRUPT_DEMUX
generic map(
	N => 5
)
port map(
    	INT_LANES => s_snd_irq_lanes,
	INT_LANES_RESPONSE => s_snd_irq_lanes_resp,
	INT_NUM => s_snd_irq_num,
	INT_SIG => s_snd_irq_en,
	EN => cpu_enable,
	RE => tp_rstn,
	CLK => tp_clk
);

handle_cpu_halts: process(tp_clk)
begin
	if(rising_edge(tp_clk)) then
		if(tp_rstn='0') then
			r_cpu_halt <= (others => '1');
		elsif(s_cpu_halt_write_en = '1') then
			r_cpu_halt(to_integer(unsigned(s_cpu_halt_num64))) <= not r_cpu_halt(to_integer(unsigned(s_cpu_halt_num64)));
		else 
			r_cpu_halt <= r_cpu_halt;
		end if;
	end if;
end process;

shift_registers: process(tp_clk)
begin
	if(rising_edge(tp_clk)) then
		if(tp_rstn='0') then
			r_prev_cpu_irq_ack <= '0';
			r_exception <= '0';
		else
			r_prev_cpu_irq_ack <= s_cpu_irq_ack; 
			if(r_prev_cpu_irq_ack = '1') then
				r_exception <= '0';
			elsif(s_irq_type /= "000000" and r_exception = '0') then
				r_exception <= '0';
			else
				r_exception <= r_exception or s_address_error_exc_load or s_address_error_exc_fetch or s_address_error_exc_store or s_instruction_bus_exc or s_data_bus_exc;
			end if;
		end if;
	end if;
end process;

end architecture;
