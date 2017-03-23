// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: iop.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
//
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
//
// The above named program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
//
// ========== Copyright Header End ============================================

`ifndef USE_TEST_TOP // useless for older TOPs

`include "define.vh"
`include "piton_system.vh"
`include "jtag.vh"

module chip(
`ifndef PITON_CHIP_FPGA
   // IO cell configs
   input                                        slew,
   input                                        impsel1,
   input                                        impsel2,
`endif // endif PITON_CHIP_FPGA

`ifdef PITON_FPGA_CLKS_GEN
   input                                        clk_osc_p,
   input                                        clk_osc_n,
`else // ifndef PITON_FPGA_CLKS_GEN
   // Input clocks
   input                                        core_ref_clk,
   input                                        io_clk,
`endif // endif PITON_FPGA_CLKS_GEN

   // Resets
   // reset is assumed to be asynchronous
   input                                        rst_n,
`ifndef PITON_CHIP_FPGA
   input                                        pll_rst_n,

   // Chip-level clock enable
   input                                        clk_en,

   // PLL settings
   output                                       pll_lock,
   input                                        pll_bypass,
   input  [4:0]                                 pll_rangea, 

   // Clock mux select (bypass PLL or not)
   // Double redundancy with pll_bypass
   input  [1:0]                                 clk_mux_sel,

   // JTAG
   input                                        jtag_clk,
   input                                        jtag_rst_l,
   input                                        jtag_modesel,
   input                                        jtag_datain,
   output                                       jtag_dataout,

   // Async FIFOs enable
   input                                        async_mux,
   
   // ORAM
   input                                        oram_on,
   input                                        oram_traffic_gen,
   input                                        oram_dummy_gen,
`else // ifdef PITON_CHIP_FPGA
   // Need to output this to chipset, since there will
   // be no passthru in the case of synthesizing chip on its own
   output                                       piton_ready_n,
 
   output [7:0]                                 leds,
`endif // endif PITON_CHIP_FPGA

`ifndef PITON_NO_CHIP_BRIDGE
   // For FPGA implementations, we convert to differential and source synchronous
`ifdef PITON_CHIP_FPGA
   output                                      chip_intf_clk_p,
   output                                      chip_intf_clk_n,
   input                                       intf_chip_clk_p,
   input                                       intf_chip_clk_n,

   output [31:0]                               chip_intf_data_p,
   output [31:0]                               chip_intf_data_n,
   output [1:0]                                chip_intf_channel_p,
   output [1:0]                                chip_intf_channel_n,
   input  [2:0]                                chip_intf_credit_back_p,
   input  [2:0]                                chip_intf_credit_back_n,

   input  [31:0]                               intf_chip_data_p,
   input  [31:0]                               intf_chip_data_n,
   input  [1:0]                                intf_chip_channel_p,
   input  [1:0]                                intf_chip_channel_n,
   output [2:0]                                intf_chip_credit_back_p,
   output [2:0]                                intf_chip_credit_back_n 
`else // ifndef PITON_CHIP_FPGA
   // Virtual channel credit-based off-chip interface
   input  [31:0]                                intf_chip_data,
   input  [1:0]                                 intf_chip_channel,
   output [2:0]                                 intf_chip_credit_back,

   output [31:0]                                chip_intf_data,
   output [1:0]                                 chip_intf_channel,
   input  [2:0]                                 chip_intf_credit_back
`endif // endif PITON_CHIP_FPGA
`else // ifdef PITON_NO_CHIP_BRIDGE
   output                                       processor_offchip_noc1_valid,
   output [`NOC_DATA_WIDTH-1:0]                 processor_offchip_noc1_data,
   input                                        processor_offchip_noc1_yummy,
   output                                       processor_offchip_noc2_valid,
   output [`NOC_DATA_WIDTH-1:0]                 processor_offchip_noc2_data,
   input                                        processor_offchip_noc2_yummy,
   output                                       processor_offchip_noc3_valid,
   output [`NOC_DATA_WIDTH-1:0]                 processor_offchip_noc3_data,
   input                                        processor_offchip_noc3_yummy,

   input                                        offchip_processor_noc1_valid,
   input  [`NOC_DATA_WIDTH-1:0]                 offchip_processor_noc1_data,
   output                                       offchip_processor_noc1_yummy,
   input                                        offchip_processor_noc2_valid,
   input  [`NOC_DATA_WIDTH-1:0]                 offchip_processor_noc2_data,
   output                                       offchip_processor_noc2_yummy,
   input                                        offchip_processor_noc3_valid,
   input  [`NOC_DATA_WIDTH-1:0]                 offchip_processor_noc3_data,
   output                                       offchip_processor_noc3_yummy
`endif // endif PITON_NO_CHIP_BRIDGE
   
);



   ///////////////////////
   // Type Declarations 
   ///////////////////////

   // Need to define types for missing inputs and outputs
   // if synthesizing chip to fpga standalone
`ifdef PITON_CHIP_FPGA
   wire                                         slew;
   wire                                         impsel1;
   wire                                         impsel2;


   wire                                         pll_rst_n;
   
   wire                                         clk_en;

   wire                                         pll_lock;
   wire                                         pll_bypass;
   wire [4:0]                                   pll_rangea;

   wire [1:0]                                   clk_mux_sel;

   wire                                         jtag_clk;
   wire                                         jtag_rst_l;
   wire                                         jtag_modesel;
   wire                                         jtag_datain;
   wire                                         jtag_dataout;

   wire                                         async_mux;

   wire                                         oram_on;
   wire                                         oram_traffic_gen;
   wire                                         oram_dummy_gen;
`endif // endif PITON_CHIP_FPGA
   // Same for generating clocks
`ifdef PITON_FPGA_CLKS_GEN
   wire                                         core_ref_clk;

   wire                                         mmcm_locked;
`endif // endif PITON_FPGA_CLKS_GEN
   // Same for chip interface
`ifndef PITON_NO_CHIP_BRIDGE
`ifdef PITON_CHIP_FPGA
   wire                                         io_clk;

   wire [31:0]                                  intf_chip_data;
   wire [1:0]                                   intf_chip_channel;
   wire [2:0]                                   intf_chip_credit_back;

   wire [31:0]                                  chip_intf_data;
   wire [1:0]                                   chip_intf_channel;
   wire [2:0]                                   chip_intf_credit_back;
`endif // endif PITON_CHIP_FPGA
`endif // endif PITON_NO_CHIP_BRIDGE

   // OCI internal wires
   
   wire                                         core_ref_clk_inter;
   wire                                         io_clk_inter;
   wire                                         rst_n_inter;
   wire                                         pll_rst_n_inter;
   wire                                         clk_en_inter;
   wire                                         pll_lock_inter;
   wire                                         pll_bypass_inter;
   wire [4:0]                                   pll_rangea_inter; 
   wire [1:0]                                   clk_mux_sel_inter;
   wire                                         jtag_clk_inter;
   wire                                         jtag_rst_l_inter;
   wire                                         jtag_rst_l_inter_sync;
   wire                                         jtag_modesel_inter;
   wire                                         jtag_datain_inter;
   wire                                         jtag_dataout_inter;
   wire                                         async_mux_inter;
   wire                                         oram_on_inter;
   wire                                         oram_traffic_gen_inter;
   wire                                         oram_dummy_gen_inter;
   wire [31:0]      		                    intf_chip_data_inter;
   wire [1:0]                                   intf_chip_channel_inter;
   wire [2:0]                                   intf_chip_credit_back_inter;
   wire [31:0]                                  chip_intf_data_inter;
   wire [1:0]                                   chip_intf_channel_inter;
   wire [2:0]                                   chip_intf_credit_back_inter;
 
   // Synchronized resets 
   wire                                         rst_n_inter_sync; 
   reg                                          rst_n_inter_sync_f;
   wire                                         io_clk_rst_n_inter_sync;
   reg                                          io_clk_rst_n_inter_sync_f;
  
  //This wire has been already declared at line 211
  // wire                                         jtag_rst_l_inter_sync;

   // PLL signals
   wire                                         core_ref_clk_inter_c;
   wire                                         core_ref_clk_inter_t;
   wire                                         clk_muxed; 
   wire                                         pll_clk;

   // Buffered chip bridge inputs
   reg  [31:0]                                  intf_chip_data_inter_buf_f /* synthesis iob = true */;
   reg  [1:0]                                   intf_chip_channel_inter_buf_f /* synthesis iob = true */;
   reg  [2:0]                                   chip_intf_credit_back_inter_buf_f /* synthesis iob = true */;

   // Chip bridge val/rdy interface
   wire                                         chip_intf_noc1_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   chip_intf_noc1_data;
   wire                                         chip_intf_noc1_rdy;
   wire                                         chip_intf_noc2_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   chip_intf_noc2_data;
   wire                                         chip_intf_noc2_rdy;
   wire                                         chip_intf_noc3_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   chip_intf_noc3_data;
   wire                                         chip_intf_noc3_rdy;

   wire                                         intf_chip_noc1_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   intf_chip_noc1_data;
   wire                                         intf_chip_noc1_rdy;
   wire                                         intf_chip_noc2_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   intf_chip_noc2_data;
   wire                                         intf_chip_noc2_rdy;
   wire                                         intf_chip_noc3_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   intf_chip_noc3_data;
   wire                                         intf_chip_noc3_rdy;

`ifndef PITON_NO_CHIP_BRIDGE
   // Need to convert a chip bridge interface to these if PITON_NO_CHIP_BRIDGE
   // is not specified
   wire                                         processor_offchip_noc1_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   processor_offchip_noc1_data;
   wire                                         processor_offchip_noc1_yummy;
   wire                                         processor_offchip_noc2_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   processor_offchip_noc2_data;
   wire                                         processor_offchip_noc2_yummy;
   wire                                         processor_offchip_noc3_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   processor_offchip_noc3_data;
   wire                                         processor_offchip_noc3_yummy;
   
   wire                                         offchip_processor_noc1_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   offchip_processor_noc1_data;
   wire                                         offchip_processor_noc1_yummy;
   wire                                         offchip_processor_noc2_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   offchip_processor_noc2_data;
   wire                                         offchip_processor_noc2_yummy;
   wire                                         offchip_processor_noc3_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   offchip_processor_noc3_data;
   wire                                         offchip_processor_noc3_yummy;
`endif // endif PITON_NO_CHIP_BRIDGE

   // ORAM muxed outputs
   reg                                          proc_oram_yummy;
   reg                                          oram_proc_valid;
   reg  [`NOC_DATA_WIDTH-1:0]                   oram_proc_data;
   reg                                          offchip_oram_yummy;
   reg                                          oram_offchip_valid;
   reg  [`NOC_DATA_WIDTH-1:0]                   oram_offchip_data;

   // ORAM Signals
   wire                                         proc_oram_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   proc_oram_data;
   wire                                         proc_oram_yummy_oram;
   wire                                         oram_proc_valid_oram;
   wire [`NOC_DATA_WIDTH-1:0]                   oram_proc_data_oram;
   wire                                         oram_proc_yummy;
   
   wire                                         offchip_oram_valid;
   wire [`NOC_DATA_WIDTH-1:0]                   offchip_oram_data;
   wire                                         offchip_oram_yummy_oram;
   wire                                         oram_offchip_valid_oram;
   wire [`NOC_DATA_WIDTH-1:0]                   oram_offchip_data_oram;
   wire                                         oram_offchip_yummy;

   // ORAM JTAG Signals
   wire                                         ctap_oram_clk_en;
   wire                                         ctap_oram_req_val;
   wire [`JTAG_ORAM_MISC_WIDTH-1:0]             ctap_oram_req_misc;
   wire [`JTAG_ORAM_DATA_WIDTH-1:0]             oram_ctap_res_data;
   // wire [`BIST_OP_WIDTH-1:0]                    ctap_oram_bist_command;
   // wire [`SRAM_WRAPPER_BUS_WIDTH-1:0]           ctap_oram_bist_data;
   // wire [`SRAM_WRAPPER_BUS_WIDTH-1:0]           oram_ctap_sram_data;

   // Merged JTAG outputs from tile
   wire                                         tiles_jtag_ucb_val;
   wire [`UCB_BUS_WIDTH-1:0]                    tiles_jtag_ucb_data;

   // Tiles JTAG interface
   wire                                         jtag_tiles_ucb_val;
   wire [`UCB_BUS_WIDTH-1:0]                    jtag_tiles_ucb_data;
   wire [127:0]                                 ctap_clk_en_inter; // trin TODO: parameterize this number (63)
   wire tile0_jtag_ucb_val;
wire [`UCB_BUS_WIDTH-1:0] tile0_jtag_ucb_data;
 

   // Generate tile wiring
wire [`DATA_WIDTH-1:0] tile_0_0_out_N_noc1_data;
wire [`DATA_WIDTH-1:0] tile_0_0_out_S_noc1_data;
wire [`DATA_WIDTH-1:0] tile_0_0_out_E_noc1_data;
wire [`DATA_WIDTH-1:0] tile_0_0_out_W_noc1_data;
wire tile_0_0_out_N_noc1_valid;
wire tile_0_0_out_S_noc1_valid;
wire tile_0_0_out_E_noc1_valid;
wire tile_0_0_out_W_noc1_valid;
wire tile_0_0_out_N_noc1_yummy;
wire tile_0_0_out_S_noc1_yummy;
wire tile_0_0_out_E_noc1_yummy;
wire tile_0_0_out_W_noc1_yummy;
wire [`DATA_WIDTH-1:0] tile_0_0_out_N_noc2_data;
wire [`DATA_WIDTH-1:0] tile_0_0_out_S_noc2_data;
wire [`DATA_WIDTH-1:0] tile_0_0_out_E_noc2_data;
wire [`DATA_WIDTH-1:0] tile_0_0_out_W_noc2_data;
wire tile_0_0_out_N_noc2_valid;
wire tile_0_0_out_S_noc2_valid;
wire tile_0_0_out_E_noc2_valid;
wire tile_0_0_out_W_noc2_valid;
wire tile_0_0_out_N_noc2_yummy;
wire tile_0_0_out_S_noc2_yummy;
wire tile_0_0_out_E_noc2_yummy;
wire tile_0_0_out_W_noc2_yummy;
wire [`DATA_WIDTH-1:0] tile_0_0_out_N_noc3_data;
wire [`DATA_WIDTH-1:0] tile_0_0_out_S_noc3_data;
wire [`DATA_WIDTH-1:0] tile_0_0_out_E_noc3_data;
wire [`DATA_WIDTH-1:0] tile_0_0_out_W_noc3_data;
wire tile_0_0_out_N_noc3_valid;
wire tile_0_0_out_S_noc3_valid;
wire tile_0_0_out_E_noc3_valid;
wire tile_0_0_out_W_noc3_valid;
wire tile_0_0_out_N_noc3_yummy;
wire tile_0_0_out_S_noc3_yummy;
wire tile_0_0_out_E_noc3_yummy;
wire tile_0_0_out_W_noc3_yummy;
wire [`DATA_WIDTH-1:0] dummy_out_N_noc1_data = `DATA_WIDTH'b0;
wire [`DATA_WIDTH-1:0] dummy_out_S_noc1_data = `DATA_WIDTH'b0;
wire [`DATA_WIDTH-1:0] dummy_out_E_noc1_data = `DATA_WIDTH'b0;
wire [`DATA_WIDTH-1:0] dummy_out_W_noc1_data = `DATA_WIDTH'b0;
wire dummy_out_N_noc1_valid = 1'b0;
wire dummy_out_S_noc1_valid = 1'b0;
wire dummy_out_E_noc1_valid = 1'b0;
wire dummy_out_W_noc1_valid = 1'b0;
wire dummy_out_N_noc1_yummy = 1'b0;
wire dummy_out_S_noc1_yummy = 1'b0;
wire dummy_out_E_noc1_yummy = 1'b0;
wire dummy_out_W_noc1_yummy = 1'b0;
wire [`DATA_WIDTH-1:0] dummy_out_N_noc2_data = `DATA_WIDTH'b0;
wire [`DATA_WIDTH-1:0] dummy_out_S_noc2_data = `DATA_WIDTH'b0;
wire [`DATA_WIDTH-1:0] dummy_out_E_noc2_data = `DATA_WIDTH'b0;
wire [`DATA_WIDTH-1:0] dummy_out_W_noc2_data = `DATA_WIDTH'b0;
wire dummy_out_N_noc2_valid = 1'b0;
wire dummy_out_S_noc2_valid = 1'b0;
wire dummy_out_E_noc2_valid = 1'b0;
wire dummy_out_W_noc2_valid = 1'b0;
wire dummy_out_N_noc2_yummy = 1'b0;
wire dummy_out_S_noc2_yummy = 1'b0;
wire dummy_out_E_noc2_yummy = 1'b0;
wire dummy_out_W_noc2_yummy = 1'b0;
wire [`DATA_WIDTH-1:0] dummy_out_N_noc3_data = `DATA_WIDTH'b0;
wire [`DATA_WIDTH-1:0] dummy_out_S_noc3_data = `DATA_WIDTH'b0;
wire [`DATA_WIDTH-1:0] dummy_out_E_noc3_data = `DATA_WIDTH'b0;
wire [`DATA_WIDTH-1:0] dummy_out_W_noc3_data = `DATA_WIDTH'b0;
wire dummy_out_N_noc3_valid = 1'b0;
wire dummy_out_S_noc3_valid = 1'b0;
wire dummy_out_E_noc3_valid = 1'b0;
wire dummy_out_W_noc3_valid = 1'b0;
wire dummy_out_N_noc3_yummy = 1'b0;
wire dummy_out_S_noc3_yummy = 1'b0;
wire dummy_out_E_noc3_yummy = 1'b0;
wire dummy_out_W_noc3_yummy = 1'b0;
wire [`DATA_WIDTH-1:0] offchip_out_E_noc1_data;
wire offchip_out_E_noc1_valid;
wire offchip_out_E_noc1_yummy;
wire [`DATA_WIDTH-1:0] offchip_out_E_noc2_data;
wire offchip_out_E_noc2_valid;
wire offchip_out_E_noc2_yummy;
wire [`DATA_WIDTH-1:0] offchip_out_E_noc3_data;
wire offchip_out_E_noc3_valid;
wire offchip_out_E_noc3_yummy;

 
   //////////////////////
   // Sequential logic
   //////////////////////

   // trin 2/3/15:
   // rst in the tile is flopped for an additional cycle
   // we'll do the same for all other modules at the chip.v level
   always @ (posedge clk_muxed)
      rst_n_inter_sync_f <= rst_n_inter_sync;

   always @ (posedge io_clk_inter)
      io_clk_rst_n_inter_sync_f <= io_clk_rst_n_inter_sync;

`ifndef PITON_NO_CHIP_BRIDGE
   // Buffer chip bridge inputs
   always @(posedge io_clk_inter) 
   begin
`ifdef PITON_PROTO
       if(~io_clk_rst_n_inter_sync_f)
`else // ifndef PITON_PROTO
       if(~rst_n_inter_sync_f)
`endif
       begin
           intf_chip_data_inter_buf_f <= 0;
           intf_chip_channel_inter_buf_f <= 0;
           chip_intf_credit_back_inter_buf_f <= 0; 
       end
       else
       begin
           intf_chip_data_inter_buf_f <= intf_chip_data_inter;
           intf_chip_channel_inter_buf_f <= intf_chip_channel_inter;
           chip_intf_credit_back_inter_buf_f <= chip_intf_credit_back_inter; 
       end
   end
`endif // endif PITON_NO_CHIP_BRIDGE

   ////////////////////////
   // Combinational Logic
   ////////////////////////

   // Need to assign missing inputs and outputs if synthesizing
   // chip for FPGA standalone
`ifdef PITON_CHIP_FPGA
   assign slew = 1'b1;
   assign impsel1 = 1'b1;
   assign impsel2 = 1'b1;

   assign pll_rst_n = 1'b1;

   assign clk_en = 1'b1;

   assign pll_lock = 1'b1;
   assign pll_bypass = 1'b1;
   assign pll_rangea = 5'b0;

   assign clk_mux_sel = 2'b0;

   assign jtag_clk = 1'b0;
   assign jtag_rst_l = 1'b1;
   assign jtag_modesel = 1'b1;
   assign jtag_datain = 1'b0;

   assign async_mux = 1'b1;

   assign oram_on = 1'b0;
   assign oram_traffic_gen = 1'b0;
   assign oram_dummy_gen = 1'b0;

   assign piton_ready_n = ~rst_n_inter_sync;

`ifdef PITON_FPGA_CLKS_GEN
   assign leds[0] = mmcm_locked;
`else // ifndef PITON_FPGA_CLKS_GEN
   assign leds[0] = 1'b1;
`endif // endif PITON_FPGA_CLKS_GEN
   assign leds[1] = rst_n_inter_sync;
   assign leds[2] = io_clk_rst_n_inter_sync;
   assign leds[3] = processor_offchip_noc1_valid;
   assign leds[4] = processor_offchip_noc2_valid;
   assign leds[5] = offchip_processor_noc2_valid;
   assign leds[6] = offchip_processor_noc3_valid;
   assign leds[7] = 1'b0;

`endif // endif PITON_CHIP_FPGA

   // PLL and clkmux alternatives
`ifdef PITON_FPGA_SYNTH
   assign clk_muxed = core_ref_clk_inter;
   assign pll_lock_inter = pll_rst_n_inter;
`elsif NO_SIM_PLL
   assign clk_muxed = core_ref_clk_inter;
   initial
   begin
     force pll_lock_inter = 1'b0;
     wait(pll_rst_n_inter == 1'b0);
     wait(pll_rst_n_inter == 1'b1);
     repeat(100)@(posedge core_ref_clk_inter);
     force pll_lock_inter = 1'b1;
   end
`endif


   // Connecting chip_bridge data to tiles/ORAM

assign proc_oram_valid = tile_0_0_out_W_noc2_valid;
assign proc_oram_data = tile_0_0_out_W_noc2_data;
assign oram_proc_yummy = tile_0_0_out_W_noc3_yummy;

   assign offchip_oram_valid = offchip_processor_noc3_valid;
   assign offchip_oram_data = offchip_processor_noc3_data;
   assign oram_offchip_yummy = processor_offchip_noc2_yummy;

assign processor_offchip_noc1_valid = tile_0_0_out_W_noc1_valid;
assign processor_offchip_noc1_data = tile_0_0_out_W_noc1_data;
assign offchip_processor_noc1_yummy = tile_0_0_out_W_noc1_yummy;

   assign processor_offchip_noc2_valid = oram_offchip_valid;
   assign processor_offchip_noc2_data = oram_offchip_data;

assign offchip_processor_noc2_yummy = tile_0_0_out_W_noc2_yummy;
assign processor_offchip_noc3_valid = tile_0_0_out_W_noc3_valid;
assign processor_offchip_noc3_data = tile_0_0_out_W_noc3_data;

   assign offchip_processor_noc3_yummy = offchip_oram_yummy;

assign offchip_out_E_noc1_data = offchip_processor_noc1_data;
assign offchip_out_E_noc1_valid = offchip_processor_noc1_valid;
assign offchip_out_E_noc1_yummy = processor_offchip_noc1_yummy;
assign offchip_out_E_noc2_data = offchip_processor_noc2_data;
assign offchip_out_E_noc2_valid = offchip_processor_noc2_valid;
assign offchip_out_E_noc2_yummy = proc_oram_yummy; //going to processor
assign offchip_out_E_noc3_data = oram_proc_data;
assign offchip_out_E_noc3_valid = oram_proc_valid;
assign offchip_out_E_noc3_yummy = processor_offchip_noc3_yummy;


   // trin: off-chip channel mux when disabling oram
   always @ *
   begin
     // default is bypassing
     oram_offchip_valid = proc_oram_valid;
     oram_offchip_data = proc_oram_data;
     proc_oram_yummy = oram_offchip_yummy;
     oram_proc_valid = offchip_oram_valid;
     oram_proc_data = offchip_oram_data;
     offchip_oram_yummy = oram_proc_yummy;
   
     if (oram_on_inter)
     begin
       oram_offchip_valid = oram_offchip_valid_oram;
       oram_offchip_data = oram_offchip_data_oram;
       proc_oram_yummy = proc_oram_yummy_oram;
       oram_proc_valid = oram_proc_valid_oram;
       oram_proc_data = oram_proc_data_oram;
       offchip_oram_yummy = offchip_oram_yummy_oram;
     end
   end

   // Merge all JTAG outputs from tiles together
assign tiles_jtag_ucb_val = tile0_jtag_ucb_val;
assign tiles_jtag_ucb_data = tile0_jtag_ucb_data;


   /////////////////////////
   // Sub-module Instances
   /////////////////////////

   // Need to generate clocks from MMCM for standalone chip FPGA synthesis
`ifdef PITON_FPGA_CLKS_GEN
   // Generate core_ref_clk
   clk_mmcm_chip clk_mmcm (
      .clk_in1_p(clk_osc_p),
      .clk_in1_n(clk_osc_n),
      
      .reset(1'b0),
      .locked(mmcm_locked),

      .core_ref_clk(core_ref_clk)
   );
`endif // endif PITON_FPGA_CLKS_GEN

`ifndef PITON_NO_CHIP_BRIDGE
`ifdef PITON_CHIP_FPGA
   // Generate io_clk from input
   IBUFGDS #(.DIFF_TERM("TRUE")) intf_chip_clk_ibufgds(
      .I(intf_chip_clk_p),
      .IB(intf_chip_clk_n),
      .O(io_clk)
   );
   // Output io_clk to intf
   OBUFDS chip_intf_clk_obufds(
      .I(io_clk),
      .O(chip_intf_clk_p),
      .OB(chip_intf_clk_n)
   );

   // Differential to single ended conversion for interface
   OBUFDS chip_intf_data_obufds[31:0] (
      .I(chip_intf_data),
      .O(chip_intf_data_p),
      .OB(chip_intf_data_n)
   );
   OBUFDS chip_intf_channel_obufds[1:0] (
      .I(chip_intf_channel),
      .O(chip_intf_channel_p),
      .OB(chip_intf_channel_n)
   );
   IBUFDS  #(.DIFF_TERM("TRUE")) chip_intf_credit_back_ibufds[2:0] (
      .I(chip_intf_credit_back_p),
      .IB(chip_intf_credit_back_n),
      .O(chip_intf_credit_back)
   );
   IBUFDS #(.DIFF_TERM("TRUE")) intf_chip_data_ibufds[31:0] (
      .I(intf_chip_data_p),
      .IB(intf_chip_data_n),
      .O(intf_chip_data)
   );
   IBUFDS #(.DIFF_TERM("TRUE")) intf_chip_channel_ibufds[1:0] (
      .I(intf_chip_channel_p),
      .IB(intf_chip_channel_n),
      .O(intf_chip_channel)
   );
   OBUFDS intf_chip_credit_back_obufds[2:0] (
      .I(intf_chip_credit_back),
      .O(intf_chip_credit_back_p),
      .OB(intf_chip_credit_back_n)
   );
`endif // endif PITON_CHIP_FPGA
`endif // endif PITON_NO_CHIP_BRIDGE

   // Off-Chip Interface Block
   
   OCI oci_inst (
   // Outside
   .slew						(slew),
   .impsel1						(impsel1),
   .impsel2						(impsel2),
   .core_ref_clk				(core_ref_clk),
   .io_clk						(io_clk),
   .rst_n						(rst_n),
   .pll_rst_n					(pll_rst_n),
   .pll_rangea					(pll_rangea),
   .clk_mux_sel					(clk_mux_sel),
   .clk_en						(clk_en),
   .pll_bypass					(pll_bypass),
   .async_mux					(async_mux),
   .oram_on						(oram_on),
   .oram_traffic_gen			(oram_traffic_gen),
   .oram_dummy_gen				(oram_dummy_gen),
   .pll_lock					(pll_lock),
   .jtag_clk					(jtag_clk),
   .jtag_rst_l					(jtag_rst_l),
   .jtag_modesel				(jtag_modesel),
   .jtag_datain					(jtag_datain),
   .jtag_dataout				(jtag_dataout),
`ifndef PITON_NO_CHIP_BRIDGE
   .intf_chip_data				(intf_chip_data),
   .intf_chip_channel			(intf_chip_channel),
   .intf_chip_credit_back		(intf_chip_credit_back),
   .chip_intf_data				(chip_intf_data),
   .chip_intf_channel			(chip_intf_channel),
   .chip_intf_credit_back		(chip_intf_credit_back),
`else // ifdef PITON_NO_CHIP_BRIDGE
   .intf_chip_data              (),
   .intf_chip_channel           (),
   .intf_chip_credit_back       (),
   .chip_intf_data              (),
   .chip_intf_channel           (),
   .chip_intf_credit_back       (), 
`endif // endif PITON_NO_CHIP_BRIDGE
   // Inside
   .core_ref_clk_inter			(core_ref_clk_inter),
   .io_clk_inter				(io_clk_inter),
   .rst_n_inter					(rst_n_inter),
   .pll_rst_n_inter				(pll_rst_n_inter),
   .pll_rangea_inter			(pll_rangea_inter),
   .clk_mux_sel_inter			(clk_mux_sel_inter),
   .clk_en_inter				(clk_en_inter),
   .pll_bypass_inter			(pll_bypass_inter),
   .async_mux_inter				(async_mux_inter),
   .oram_on_inter				(oram_on_inter),
   .oram_traffic_gen_inter		(oram_traffic_gen_inter),
   .oram_dummy_gen_inter		(oram_dummy_gen_inter),
   .pll_lock_inter				(pll_lock_inter),
   .jtag_clk_inter				(jtag_clk_inter),
   .jtag_rst_l_inter			(jtag_rst_l_inter),
   .jtag_modesel_inter			(jtag_modesel_inter),
   .jtag_datain_inter			(jtag_datain_inter),
   .jtag_dataout_inter			(jtag_dataout_inter),
   .intf_chip_data_inter		(intf_chip_data_inter),
   .intf_chip_channel_inter		(intf_chip_channel_inter),
   .intf_chip_credit_back_inter	(intf_chip_credit_back_inter),
   .chip_intf_data_inter		(chip_intf_data_inter),
   .chip_intf_channel_inter		(chip_intf_channel_inter),
   .chip_intf_credit_back_inter	(chip_intf_credit_back_inter) );
 
   // PLL and clock mux.  See above for alternatives 
`ifndef PITON_FPGA_SYNTH 
`ifndef NO_SIM_PLL
   // this clock mux is used to convert
   //  single-ended ref_clk to differential, small-swing signals
   CLKDIFFSEMUX_X48_ATITM ref_clk_converter (
       .TIEC(),
       .TIET(),
       .YC(core_ref_clk_inter_c),
       .YSE(),
       .YT(core_ref_clk_inter_t),
       .CLK0C(core_ref_clk_inter),
       .CLK0T(~core_ref_clk_inter),
       .CLK1C(1'b0),
       .CLK1T(~1'b0),
       .CLK2(1'b0),
       .DLT(1'b0),
       .EN(1'b1),
       .SC0(1'b0),
       .SC1(1'b0));
   
   CLKDIFFSEMUX_X48_ATITM clock_mux (
       .TIEC(),
       .TIET(),
       .YC(),
       .YSE(clk_muxed),
       .YT(),
       .CLK0C(core_ref_clk_inter_c),
       .CLK0T(core_ref_clk_inter_t),
       .CLK1C(1'b0),
       .CLK1T(~1'b0),
       .CLK2(pll_clk),
       .DLT(1'b0),
       .EN(1'b1),
       .SC0(clk_mux_sel_inter[0]),
       .SC1(clk_mux_sel_inter[1]));
   
   PLLLIB_TOP pll_top ( 
      .dcoempty(),
      .dcofull(),
      .freqchange(),
      .observe0(),
      .plllock(pll_lock_inter),
      .pllouta(pll_clk), // use this as clock output
      .plloutb(), // or use this as clock output
      .pllsynca(),
      .pllsyncb(),
      .so_testonly_r_0(),
      .testoutfreq(),
    
      .rangeA(pll_rangea_inter),
      .pll_bypass(pll_bypass_inter),
      .clk(core_ref_clk_inter), // clk in
      .rst(~pll_rst_n_inter)
      );
`endif // endif NO_SIM_PLL
`endif // endif PITON_FPGA_SYNTH
 
   // reset synchronizer, might need to be placed near the
   //   pll or clock source so that reset signal has the same propagation
   //   as clock for better timing
   // materials on reset tree and placement
   // http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_Resets.pdf
   synchronizer rst_sync (
      .clk(clk_muxed),
      .presyncdata(rst_n_inter),
      .syncdata(rst_n_inter_sync)
   );
   synchronizer io_clk_rst_sync (
      .clk(io_clk_inter),
      .presyncdata(rst_n_inter),
      .syncdata(io_clk_rst_n_inter_sync)
   );
   synchronizer jtag_rst_sync (
      .clk(clk_muxed),
      .presyncdata(jtag_rst_l_inter),
      .syncdata(jtag_rst_l_inter_sync)
   );

`ifndef PITON_NO_CHIP_BRIDGE
   // Chip to FPGA bridge
   chip_bridge chip_intf(
       // Xilinx afifos want asynchronous reset, so need to passs that in
       // and do internal synchronizeation
`ifdef PITON_PROTO
       .rst_n                  (rst_n_inter),
`else // ifndef PITON_FPGA_SYNTH
       .rst_n                  (rst_n_inter_sync_f),
`endif       
       .chip_clk               (clk_muxed),
       .intcnct_clk            (io_clk_inter),
       .async_mux              (async_mux_inter),
       .network_out_1          (chip_intf_noc1_data),
       .network_out_2          (chip_intf_noc2_data),
       .network_out_3          (chip_intf_noc3_data),
       .data_out_val_1         (chip_intf_noc1_valid),
       .data_out_val_2         (chip_intf_noc2_valid),
       .data_out_val_3         (chip_intf_noc3_valid),
       .data_out_rdy_1         (chip_intf_noc1_rdy),
       .data_out_rdy_2         (chip_intf_noc2_rdy),
       .data_out_rdy_3         (chip_intf_noc3_rdy),
       .intcnct_data_in        (intf_chip_data_inter_buf_f),
       .intcnct_channel_in     (intf_chip_channel_inter_buf_f),
       .intcnct_credit_back_in (intf_chip_credit_back_inter),
       .network_in_1           (intf_chip_noc1_data),
       .network_in_2           (intf_chip_noc2_data),
       .network_in_3           (intf_chip_noc3_data),
       .data_in_val_1          (intf_chip_noc1_valid),
       .data_in_val_2          (intf_chip_noc2_valid),
       .data_in_val_3          (intf_chip_noc3_valid),
       .data_in_rdy_1          (intf_chip_noc1_rdy),
       .data_in_rdy_2          (intf_chip_noc2_rdy),
       .data_in_rdy_3          (intf_chip_noc3_rdy),
       .intcnct_data_out       (chip_intf_data_inter),
       .intcnct_channel_out    (chip_intf_channel_inter),
       .intcnct_credit_back_out(chip_intf_credit_back_inter_buf_f)
   );
  
   // Chip Bridge val/rdy to credit

   valrdy_to_credit #(4, 3) chip_from_intf_noc1_v2c(
      .clk(clk_muxed),
      .reset(~rst_n_inter_sync_f),
      .data_in(intf_chip_noc1_data),
      .valid_in(intf_chip_noc1_valid),
      .ready_in(intf_chip_noc1_rdy),

      .data_out(offchip_processor_noc1_data),           // Data
      .valid_out(offchip_processor_noc1_valid),       // Val signal
      .yummy_out(offchip_processor_noc1_yummy)    // Yummy signal
   );

   credit_to_valrdy chip_to_intf_noc1_c2v(
      .clk(clk_muxed),
      .reset(~rst_n_inter_sync_f),
      .data_in(processor_offchip_noc1_data),
      .valid_in(processor_offchip_noc1_valid),
      .yummy_in(processor_offchip_noc1_yummy),

      .data_out(chip_intf_noc1_data),           // Data
      .valid_out(chip_intf_noc1_valid),       // Val signal from dynamic network to processor
      .ready_out(chip_intf_noc1_rdy)    // Rdy signal from processor to dynamic network
   );

   valrdy_to_credit #(4, 3) chip_from_intf_noc2_v2c(
      .clk(clk_muxed),
      .reset(~rst_n_inter_sync_f),
      .data_in(intf_chip_noc2_data),
      .valid_in(intf_chip_noc2_valid),
      .ready_in(intf_chip_noc2_rdy),

      .data_out(offchip_processor_noc2_data),           // Data
      .valid_out(offchip_processor_noc2_valid),       // Val signal
      .yummy_out(offchip_processor_noc2_yummy)    // Yummy signal
   );

   credit_to_valrdy chip_to_intf_noc2_c2v(
      .clk(clk_muxed),
      .reset(~rst_n_inter_sync_f),
      .data_in(processor_offchip_noc2_data),
      .valid_in(processor_offchip_noc2_valid),
      .yummy_in(processor_offchip_noc2_yummy),

      .data_out(chip_intf_noc2_data),           // Data
      .valid_out(chip_intf_noc2_valid),       // Val signal from dynamic network to processor
      .ready_out(chip_intf_noc2_rdy)    // Rdy signal from processor to dynamic network
   );

   valrdy_to_credit #(4, 3) chip_from_intf_noc3_v2c(
      .clk(clk_muxed),
      .reset(~rst_n_inter_sync_f),
      .data_in(intf_chip_noc3_data),
      .valid_in(intf_chip_noc3_valid),
      .ready_in(intf_chip_noc3_rdy),

      .data_out(offchip_processor_noc3_data),           // Data
      .valid_out(offchip_processor_noc3_valid),       // Val signal
      .yummy_out(offchip_processor_noc3_yummy)    // Yummy signal
   );

   credit_to_valrdy chip_to_intf_noc3_c2v(
      .clk(clk_muxed),
      .reset(~rst_n_inter_sync_f),
      .data_in(processor_offchip_noc3_data),
      .valid_in(processor_offchip_noc3_valid),
      .yummy_in(processor_offchip_noc3_yummy),

      .data_out(chip_intf_noc3_data),           // Data
      .valid_out(chip_intf_noc3_valid),       // Val signal from dynamic network to processor
      .ready_out(chip_intf_noc3_rdy)    // Rdy signal from processor to dynamic network
   );  
`endif // endif PITON_NO_CHIP_BRIDGE

`ifdef ORAM_ON
   oram_top oram_top(
      .clk(clk_muxed),
      .rst_n(rst_n_inter_sync),
      .clk_en(ctap_oram_clk_en && clk_en_inter),
      .oram_on(oram_on_inter),
      .oram_traffic_gen(oram_traffic_gen_inter),
      .oram_dummy_gen(oram_dummy_gen_inter),

      //from noc2
      .proc_oram_valid(proc_oram_valid),
      .proc_oram_data(proc_oram_data),
      .proc_oram_yummy(proc_oram_yummy_oram),

      //to noc3
      .oram_proc_valid(oram_proc_valid_oram),
      .oram_proc_data(oram_proc_data_oram),
      .oram_proc_yummy(oram_proc_yummy),

      //from noc3
      .offchip_oram_valid(offchip_oram_valid),
      .offchip_oram_data(offchip_oram_data),
      .offchip_oram_yummy(offchip_oram_yummy_oram),

      //to noc2
      .oram_offchip_valid(oram_offchip_valid_oram),
      .oram_offchip_data(oram_offchip_data_oram),
      .oram_offchip_yummy(oram_offchip_yummy),

      // oram-jtag
      .ctap_oram_req_val(ctap_oram_req_val),
      // .ctap_oram_req_misc(ctap_oram_req_misc),
      .oram_ctap_res_data(oram_ctap_res_data)
      // .ctap_oram_bist_command(ctap_oram_bist_command),
      // .ctap_oram_bist_data(ctap_oram_bist_data),
      // .oram_ctap_sram_data(oram_ctap_sram_data)
   );
`endif // endif ORAM_ON

   // on-chip jtag interface & test access port
   jtag jtag_port(
      .clk(clk_muxed),
      .rst_n(rst_n_inter_sync_f),
      .jtag_clk(jtag_clk_inter),
      .jtag_rst_l(jtag_rst_l_inter_sync),
      .jtag_modesel(jtag_modesel_inter),
      .jtag_datain(jtag_datain_inter),
      .jtag_dataout(jtag_dataout_inter),
      .jtag_dataout_en(),
      .jtag_tiles_ucb_val(jtag_tiles_ucb_val),
      .jtag_tiles_ucb_data(jtag_tiles_ucb_data),
      .tiles_jtag_ucb_val(tiles_jtag_ucb_val),
      .tiles_jtag_ucb_data(tiles_jtag_ucb_data),

      .ctap_oram_req_val(ctap_oram_req_val),
      .ctap_oram_req_misc(ctap_oram_req_misc),
      .oram_ctap_res_data(oram_ctap_res_data),
      // .ctap_oram_bist_command(ctap_oram_bist_command),
      // .ctap_oram_bist_data(ctap_oram_bist_data),
      // .oram_ctap_sram_data(oram_ctap_sram_data),

      .ctap_clk_en(ctap_clk_en_inter),
      .ctap_oram_clk_en(ctap_oram_clk_en)
   );

   // generate the cross bars


    // Generate tile instances

tile tile0(
    .clk                (clk_muxed),
    .rst_n              (rst_n_inter_sync),
    .clk_en             (ctap_clk_en_inter[0] && clk_en_inter),
    .default_chipid             (14'b0),    // the first chip
    .default_coreid_x           (8'd0),
    .default_coreid_y           (8'd0),
    .flat_tileid                (`JTAG_FLATID_WIDTH'd0),

    // ucb from tiles to jtag
    .tile_jtag_ucb_val (tile0_jtag_ucb_val),
    .tile_jtag_ucb_data    (tile0_jtag_ucb_data),
    // ucb from jtag to tiles
    .jtag_tiles_ucb_val (jtag_tiles_ucb_val),
    .jtag_tiles_ucb_data    (jtag_tiles_ucb_data),

    .dyn0_dataIn_N      (dummy_out_S_noc1_data),
    .dyn0_dataIn_E      (dummy_out_W_noc1_data),
    .dyn0_dataIn_W      (offchip_out_E_noc1_data),
    .dyn0_dataIn_S      (dummy_out_N_noc1_data),
    .dyn0_validIn_N     (dummy_out_S_noc1_valid),
    .dyn0_validIn_E     (dummy_out_W_noc1_valid),
    .dyn0_validIn_W     (offchip_out_E_noc1_valid),
    .dyn0_validIn_S     (dummy_out_N_noc1_valid),
    .dyn0_dNo_yummy     (dummy_out_S_noc1_yummy),
    .dyn0_dEo_yummy     (dummy_out_W_noc1_yummy),
    .dyn0_dWo_yummy     (offchip_out_E_noc1_yummy),
    .dyn0_dSo_yummy     (dummy_out_N_noc1_yummy),

    .dyn0_dNo           (tile_0_0_out_N_noc1_data),
    .dyn0_dEo           (tile_0_0_out_E_noc1_data),
    .dyn0_dWo           (tile_0_0_out_W_noc1_data),
    .dyn0_dSo           (tile_0_0_out_S_noc1_data),
    .dyn0_dNo_valid     (tile_0_0_out_N_noc1_valid),
    .dyn0_dEo_valid     (tile_0_0_out_E_noc1_valid),
    .dyn0_dWo_valid     (tile_0_0_out_W_noc1_valid),
    .dyn0_dSo_valid     (tile_0_0_out_S_noc1_valid),
    .dyn0_yummyOut_N    (tile_0_0_out_N_noc1_yummy),
    .dyn0_yummyOut_E    (tile_0_0_out_E_noc1_yummy),
    .dyn0_yummyOut_W    (tile_0_0_out_W_noc1_yummy),
    .dyn0_yummyOut_S    (tile_0_0_out_S_noc1_yummy),
    .dyn1_dataIn_N      (dummy_out_S_noc2_data),
    .dyn1_dataIn_E      (dummy_out_W_noc2_data),
    .dyn1_dataIn_W      (offchip_out_E_noc2_data),
    .dyn1_dataIn_S      (dummy_out_N_noc2_data),
    .dyn1_validIn_N     (dummy_out_S_noc2_valid),
    .dyn1_validIn_E     (dummy_out_W_noc2_valid),
    .dyn1_validIn_W     (offchip_out_E_noc2_valid),
    .dyn1_validIn_S     (dummy_out_N_noc2_valid),
    .dyn1_dNo_yummy     (dummy_out_S_noc2_yummy),
    .dyn1_dEo_yummy     (dummy_out_W_noc2_yummy),
    .dyn1_dWo_yummy     (offchip_out_E_noc2_yummy),
    .dyn1_dSo_yummy     (dummy_out_N_noc2_yummy),

    .dyn1_dNo           (tile_0_0_out_N_noc2_data),
    .dyn1_dEo           (tile_0_0_out_E_noc2_data),
    .dyn1_dWo           (tile_0_0_out_W_noc2_data),
    .dyn1_dSo           (tile_0_0_out_S_noc2_data),
    .dyn1_dNo_valid     (tile_0_0_out_N_noc2_valid),
    .dyn1_dEo_valid     (tile_0_0_out_E_noc2_valid),
    .dyn1_dWo_valid     (tile_0_0_out_W_noc2_valid),
    .dyn1_dSo_valid     (tile_0_0_out_S_noc2_valid),
    .dyn1_yummyOut_N    (tile_0_0_out_N_noc2_yummy),
    .dyn1_yummyOut_E    (tile_0_0_out_E_noc2_yummy),
    .dyn1_yummyOut_W    (tile_0_0_out_W_noc2_yummy),
    .dyn1_yummyOut_S    (tile_0_0_out_S_noc2_yummy),
    .dyn2_dataIn_N      (dummy_out_S_noc3_data),
    .dyn2_dataIn_E      (dummy_out_W_noc3_data),
    .dyn2_dataIn_W      (offchip_out_E_noc3_data),
    .dyn2_dataIn_S      (dummy_out_N_noc3_data),
    .dyn2_validIn_N     (dummy_out_S_noc3_valid),
    .dyn2_validIn_E     (dummy_out_W_noc3_valid),
    .dyn2_validIn_W     (offchip_out_E_noc3_valid),
    .dyn2_validIn_S     (dummy_out_N_noc3_valid),
    .dyn2_dNo_yummy     (dummy_out_S_noc3_yummy),
    .dyn2_dEo_yummy     (dummy_out_W_noc3_yummy),
    .dyn2_dWo_yummy     (offchip_out_E_noc3_yummy),
    .dyn2_dSo_yummy     (dummy_out_N_noc3_yummy),

    .dyn2_dNo           (tile_0_0_out_N_noc3_data),
    .dyn2_dEo           (tile_0_0_out_E_noc3_data),
    .dyn2_dWo           (tile_0_0_out_W_noc3_data),
    .dyn2_dSo           (tile_0_0_out_S_noc3_data),
    .dyn2_dNo_valid     (tile_0_0_out_N_noc3_valid),
    .dyn2_dEo_valid     (tile_0_0_out_E_noc3_valid),
    .dyn2_dWo_valid     (tile_0_0_out_W_noc3_valid),
    .dyn2_dSo_valid     (tile_0_0_out_S_noc3_valid),
    .dyn2_yummyOut_N    (tile_0_0_out_N_noc3_yummy),
    .dyn2_yummyOut_E    (tile_0_0_out_E_noc3_yummy),
    .dyn2_yummyOut_W    (tile_0_0_out_W_noc3_yummy),
    .dyn2_yummyOut_S    (tile_0_0_out_S_noc3_yummy)
);


endmodule

`endif
