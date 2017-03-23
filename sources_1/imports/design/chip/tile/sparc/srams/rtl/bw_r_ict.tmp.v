// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: bw_r_ict.v
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
////////////////////////////////////////////////////////////////////////
/*
 //  Module Name:  bw_r_ict.v
 //  Description:
 //    Contains the RTL for the icache and dcache tag blocks.
 //    This is a 1RW 512 entry X 33b macro, with 132b rd and 132b wr,
 //    broken into 4 33b segments with its own write enable.
 //    Address and Control inputs are available the stage before
 //    array access, which is referred to as "_x".  Write data is
 //    available in the same stage as the write to the ram, referred
 //    to as "_y".  Read data is also read out and available in "_y".
 //
 //            X       |      Y
 //     index          |  ram access
 //     index sel      |  write_tag
 //     rd/wr req      |     -> read_tag
 //     way enable     |
 */


////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////





`ifndef NO_USE_IBM_SRAMS
`define IBM_SRAM_CACHE_TAG
`endif

//PITON_PROTO enables all FPGA related modifications
`ifdef PITON_PROTO
`define FPGA_SYN_ICT
`endif

//`ifdef IBM_SRAM_CACHE_TAG_MODEL_CHECKER
`ifdef NO_USE_IBM_SRAMS

`ifdef FPGA_SYN_ICT

//`ifndef IBM_SRAM_CACHE_TAG
module bw_r_ict(rdtag_y, so, rclk, se,
//`else
//module bw_r_ict_orig(rdtag_y, so, rclk, se,
//`endif
	si, reset_l, sehold, rst_tri_en, index0_x, index1_x, index_sel_x,
	dec_wrway_x, rdreq_x, wrreq_x, wrtag_y,
	wrtag_x,
  adj,

  // sram wrapper interface
  sramid,
  srams_rtap_data,
  rtap_srams_bist_command,
  rtap_srams_bist_data
  );

	input			rclk;
	input			se;
	input			si;
	input			reset_l;
	input			sehold;
	input			rst_tri_en;
  input [`IC_SET_IDX_HI:0]   index0_x;
  input [`IC_SET_IDX_HI:0]   index1_x;
	input			index_sel_x;
	input	[`IC_WAY_ARRAY_MASK]		dec_wrway_x;
	input			rdreq_x;
	input			wrreq_x;
  input [`IC_TLB_TAG_MASK] wrtag_x;
  input [`IC_TLB_TAG_MASK] wrtag_y;
	input	[`IC_WAY_ARRAY_MASK]		adj;

  // sram wrapper interface
  output [`SRAM_WRAPPER_BUS_WIDTH-1:0] srams_rtap_data;
  // dummy output for the reference model
  assign srams_rtap_data = 4'b0;
  input  [`BIST_OP_WIDTH-1:0] rtap_srams_bist_command;
  input  [`SRAM_WRAPPER_BUS_WIDTH-1:0] rtap_srams_bist_data;
  input  [`BIST_ID_WIDTH-1:0] sramid;
  wire unused = rtap_srams_bist_command
                | rtap_srams_bist_data
                | sramid;

  output  [`IC_TLB_TAG_MASK_ALL] rdtag_y;
	output			so;

  wire _unused_sink = |wrtag_x; // wrtag_x is unused in this implementation

	wire			clk;
	reg	[`IC_SET_IDX_HI:0]		index_y;
	reg			rdreq_y;
	reg			wrreq_y;
	reg	[`IC_WAY_ARRAY_MASK]		dec_wrway_y;
	wire	[`IC_SET_IDX_HI:0]		index_x;
	wire	[`IC_WAY_ARRAY_MASK]		we;

   	reg [`IC_TLB_TAG_MASK_ALL]  rdtag_sa_y; //for error_inject XMR

	assign clk = rclk;
	assign index_x = (index_sel_x ? index1_x : index0_x);
    assign we = ({`IC_NUM_WAY {((wrreq_y & reset_l) & (~rst_tri_en))}} & dec_wrway_y);

	always @(posedge clk) begin
	  if (~sehold) begin
	    rdreq_y <= rdreq_x;
	    wrreq_y <= wrreq_x;
	    index_y <= index_x;
	    dec_wrway_y <= dec_wrway_x;
	  end
	end

  
  bw_r_ict_array ictag_ary_0(
    .we (we[0]),
    .clk  (clk),
        .way (`IC_WAY_IDX_WIDTH'd0),
    .rd_data(rdtag_y[`IC_TLB_TAG_WAY0_MASK]),
    .wr_data(wrtag_y),
    .addr (index_y),
    .dec_wrway_y (dec_wrway_y));


  bw_r_ict_array ictag_ary_1(
    .we (we[1]),
    .clk  (clk),
        .way (`IC_WAY_IDX_WIDTH'd1),
    .rd_data(rdtag_y[`IC_TLB_TAG_WAY1_MASK]),
    .wr_data(wrtag_y),
    .addr (index_y),
    .dec_wrway_y (dec_wrway_y));


  bw_r_ict_array ictag_ary_2(
    .we (we[2]),
    .clk  (clk),
        .way (`IC_WAY_IDX_WIDTH'd2),
    .rd_data(rdtag_y[`IC_TLB_TAG_WAY2_MASK]),
    .wr_data(wrtag_y),
    .addr (index_y),
    .dec_wrway_y (dec_wrway_y));


  bw_r_ict_array ictag_ary_3(
    .we (we[3]),
    .clk  (clk),
        .way (`IC_WAY_IDX_WIDTH'd3),
    .rd_data(rdtag_y[`IC_TLB_TAG_WAY3_MASK]),
    .wr_data(wrtag_y),
    .addr (index_y),
    .dec_wrway_y (dec_wrway_y));



endmodule

module bw_r_ict_array(we, clk, rd_data, wr_data, addr,dec_wrway_y,way);

input we;
input clk;
input [`IC_TLB_TAG_MASK] wr_data;
input [`IC_SET_IDX_HI:0] addr;
input [`IC_WAY_ARRAY_MASK] dec_wrway_y;
input [`IC_WAY_MASK] way;
output [`IC_TLB_TAG_MASK] rd_data;
reg [`IC_TLB_TAG_MASK] rd_data;

reg	[`IC_TLB_TAG_MASK]		array[`IC_ENTRY_HI:0] /* synthesis syn_ramstyle = block_ram  syn_ramstyle = no_rw_check */ ;
integer i;

initial begin
// `ifdef DO_MEM_INIT
//     // Add the memory init file in the database
//     $readmemb("/import/dtg-data11/sandeep/niagara/design/sys/iop/srams/rtl/mem_init_ict.txt",array);
// `endif
  // Tri: nonsynthesizable
  for (i = 0; i <= `IC_ENTRY_HI; i = i + 1)
  begin
    array[i] = {`IC_TAG_SZ{1'b0}};
  end
end

	always @(negedge clk) begin
	  if (we)
          begin
              array[addr] <= wr_data;
          end
	  else
          rd_data <= array[addr];
	end
endmodule

`else // when NO_USE_IBM_SRAMS is defined

module bw_r_ict(/*AUTOARG*/
   // Outputs
   rdtag_y, so,
   // Inputs
   rclk, se, si, reset_l, sehold, rst_tri_en, index0_x, index1_x,
   index_sel_x, dec_wrway_x, rdreq_x, wrreq_x, wrtag_y,
   wrtag_x,
   adj,

  // sram wrapper interface
  sramid,
  srams_rtap_data,
  rtap_srams_bist_command,
  rtap_srams_bist_data

   );

   input          rclk,
                  se,
                  si,
                  reset_l;      // active LOW reset

   input          sehold;
   input          rst_tri_en;

   input [`IC_SET_IDX_HI:0]    index0_x;     // read/write address0
   input [`IC_SET_IDX_HI:0]    index1_x;     // read/write address1

   input          index_sel_x;  // selects between index1 and index0

   input [`IC_WAY_ARRAY_MASK]    dec_wrway_x;  // way -- functions as a write enable
                                // per 33b

   input          rdreq_x,      // read enable
		              wrreq_x;      // write enable

   // Don't use rdreq and wrreq to gate off the clock, since these are
   // critical.  A separate power down signal can be supplied if
   // needed.

  input [`IC_TLB_TAG_MASK] wrtag_x;
  input [`IC_TLB_TAG_MASK] wrtag_y;

   input [`IC_WAY_ARRAY_MASK]    adj;

  // sram wrapper interface
  output [`SRAM_WRAPPER_BUS_WIDTH-1:0] srams_rtap_data;
  // dummy output for the reference model
  assign srams_rtap_data = 4'b0;
  input  [`BIST_OP_WIDTH-1:0] rtap_srams_bist_command;
  input  [`SRAM_WRAPPER_BUS_WIDTH-1:0] rtap_srams_bist_data;
  input  [`BIST_ID_WIDTH-1:0] sramid;
  wire unused = rtap_srams_bist_command
                | rtap_srams_bist_data
                | sramid;


  output  [`IC_TLB_TAG_MASK_ALL] rdtag_y;

   output        so;

  wire _unused_sink = |wrtag_x; // wrtag_x is unused in this implementation

   // Declarations
   // local signals
`ifdef DEFINE_0IN
`else
   reg [`IC_TLB_TAG_MASK]   ictag_ary  [`IC_ENTRY_HI:0];
   reg [`IC_TLB_TAG_MASK_ALL]  rdtag_bl_y,
                rdtag_sa_y;
`endif

   wire         clk;


   reg [`IC_SET_IDX_HI:0]    index_y;
   reg          rdreq_y,
		            wrreq_y;
   reg [`IC_WAY_ARRAY_MASK]    dec_wrway_y;

   wire [`IC_SET_IDX_HI:0]   index_x;


   //----------------
   // Code start here
   //----------------

   assign       clk = rclk;

   //-------------------------
   // 2:1 mux on address input
   //-------------------------
   // address inputs are critical and this mux needs to be merged with
   // the receiving flop.
   assign index_x = index_sel_x ? index1_x :
                                  index0_x;

   //------------------------
   // input flops from x to y
   //------------------------
   // these need to be scannable
   always @ (posedge clk)
     begin
        if (~sehold)
          begin
                   rdreq_y <= rdreq_x;
                   wrreq_y <= wrreq_x;
                   index_y <= index_x;
                   dec_wrway_y <= dec_wrway_x;
          end
     end

`ifdef DEFINE_0IN

DEBUG_UNUSED; // trin

// wire [`IC_TLB_TAG_MASK_ALL] wm = { {`IC_PHYS_TAG_SZ{(dec_wrway_y[3])}},{`IC_PHYS_TAG_SZ{(dec_wrway_y[2])}},{`IC_PHYS_TAG_SZ{(dec_wrway_y[1])}},{`IC_PHYS_TAG_SZ{(dec_wrway_y[0])}} };
// wire         we = wrreq_y & ~se;

// l1_tag l1_tag ( .nclk(~clk), .adr(index_y[6:0]), .we(we), .wm(wm),
//                                               .din ({rtag_y}),
//                                               .dout({rdtag_y[`IC_TLB_TAG_WAY3_MASK],
//                                                      rdtag_y[`IC_TLB_TAG_WAY2_MASK],
//                                                      rdtag_y[`IC_TLB_TAG_WAY1_MASK],
//                                                      rdtag_y[`IC_TLB_TAG_WAY0_MASK]}) );
`else

   //----------------------------------------------------------------------
   // Read Operation
   //----------------------------------------------------------------------

   always @(/*AUTOSENSE*/ /*memory or*/ index_y or rdreq_y or reset_l
            or wrreq_y)
     begin
	      if (rdreq_y & reset_l)
          begin
             if (wrreq_y)    // rd_wr conflict
	             begin
	                rdtag_bl_y = {(`IC_TLB_TAG_SZ * `IC_NUM_WAY){1'bx}};
	             end

	           else   // no write, read only
	             begin
                  // __WAYID
                  
  rdtag_bl_y[`IC_TLB_TAG_WAY0_MASK] = ictag_ary[{index_y,`IC_WAY_IDX_WIDTH'd0}];  // way0


  rdtag_bl_y[`IC_TLB_TAG_WAY1_MASK] = ictag_ary[{index_y,`IC_WAY_IDX_WIDTH'd1}];  // way1


  rdtag_bl_y[`IC_TLB_TAG_WAY2_MASK] = ictag_ary[{index_y,`IC_WAY_IDX_WIDTH'd2}];  // way2


  rdtag_bl_y[`IC_TLB_TAG_WAY3_MASK] = ictag_ary[{index_y,`IC_WAY_IDX_WIDTH'd3}];  // way3


	             end
          end
        else    // no read
          begin
             rdtag_bl_y =  {(`IC_TLB_TAG_SZ * `IC_NUM_WAY){1'bx}};
          end

     end // always @ (...


   // SA latch -- to make 0in happy
   always @ (/*AUTOSENSE*/clk or rdreq_y or rdtag_bl_y or reset_l)
     begin
        if (rdreq_y & ~clk & reset_l)
          begin
             rdtag_sa_y <= rdtag_bl_y;
          end
     end

   // Output is held the same if there is no read.  This is not a
   // hard requirement, please let me know if the output has to
   // be something else for ease of implementation.

   // Output behavior during reset is currently not coded.
   // Functionally there is no preference, though it should be
   // unchanging to keep the power low.

   // Final Output
   assign rdtag_y = rdtag_sa_y;

   integer i;
   initial
   begin
      for (i = 0; i <= `IC_ENTRY_HI; i = i + 1)
      begin
         ictag_ary[i] = 0;
      end
   end

   //----------------------------------------------------------------------
   // Write Operation
   //----------------------------------------------------------------------
   // Writes should be blocked off during scan shift.
   always @ (negedge clk)
     begin
	   if (wrreq_y & reset_l & ~rst_tri_en)
	   begin
        // __WAYID
        
  if (dec_wrway_y[0])
    ictag_ary[{index_y, `IC_WAY_IDX_WIDTH'd0}] = wrtag_y;


  if (dec_wrway_y[1])
    ictag_ary[{index_y, `IC_WAY_IDX_WIDTH'd1}] = wrtag_y;


  if (dec_wrway_y[2])
    ictag_ary[{index_y, `IC_WAY_IDX_WIDTH'd2}] = wrtag_y;


  if (dec_wrway_y[3])
    ictag_ary[{index_y, `IC_WAY_IDX_WIDTH'd3}] = wrtag_y;


	   end
     end

   // TBD: Need to model rd-wr contention
`endif

   //******************************************************
   // The stuff below is not part of the main functionality
   // and has no representation in the actual circuit.
   //******************************************************

   // synopsys translate_off

   //-----------------------
   // Contention Monitor
   //-----------------------
 `ifdef INNO_MUXEX
 `else
   always @ (negedge clk)
   begin
      if (rdreq_y & wrreq_y & reset_l)
        begin
           // 0in <fire -message "FATAL ERROR: rd and wr contention in ict"
           //$error("IDtag Contention", "ERROR rd and wr contention in ict");
        end
   end // always @ (negedge clk)

 `endif



   // synopsys translate_on


endmodule // bw_r_ict
`endif

`endif // checker model

`ifdef IBM_SRAM_CACHE_TAG
module bw_r_ict(rdtag_y, so, rclk, se,
  si, reset_l, sehold, rst_tri_en, index0_x, index1_x, index_sel_x,
  dec_wrway_x, rdreq_x, wrreq_x, wrtag_y,
  wrtag_x, adj,

  // sram wrapper interface
  sramid,
  srams_rtap_data,
  rtap_srams_bist_command,
  rtap_srams_bist_data
  );

  input     rclk;
  input     se;
  input     si;
  input     reset_l;
  input     sehold;
  input     rst_tri_en;
  input [`IC_SET_IDX_HI:0]   index0_x;
  input [`IC_SET_IDX_HI:0]   index1_x;
  input     index_sel_x;
  input [`IC_WAY_ARRAY_MASK]   dec_wrway_x;
  input     rdreq_x;
  input     wrreq_x;
  input [`IC_TLB_TAG_MASK] wrtag_x;
  input [`IC_TLB_TAG_MASK] wrtag_y;
  input [`IC_WAY_ARRAY_MASK]   adj;


  // sram wrapper interface
  output [`SRAM_WRAPPER_BUS_WIDTH-1:0] srams_rtap_data;
  input  [`BIST_OP_WIDTH-1:0] rtap_srams_bist_command;
  input  [`SRAM_WRAPPER_BUS_WIDTH-1:0] rtap_srams_bist_data;
  input  [`BIST_ID_WIDTH-1:0] sramid;

  output  [`IC_TLB_TAG_MASK_ALL] rdtag_y;
  output      so;

  wire      clk;
  wire  [`IC_SET_IDX_HI:0]   index_x;
  reg   [`IC_SET_IDX_HI:0]   index_y;
  wire  [`IC_WAY_ARRAY_MASK]   we;
  reg           wrreq_y;
  reg           rdreq_y;

  reg [`IC_TLB_TAG_MASK_ALL]  rdtag_sa_y; //for error_inject XMR

  assign clk = rclk;
  assign index_x = (index_sel_x ? index1_x : index0_x);
  assign we = ({`IC_NUM_WAY {((wrreq_x & reset_l) & (~rst_tri_en))}} & dec_wrway_x);

  // assign write_bus_x[`IC_PHYS_TAG_WAY0_MASK] = wrtag_x;
  // assign write_bus_x[`IC_PHYS_TAG_WAY1_MASK] = wrtag_x;
  // assign write_bus_x[`IC_PHYS_TAG_WAY2_MASK] = wrtag_x;
  // assign write_bus_x[`IC_PHYS_TAG_WAY3_MASK] = wrtag_x;

  always @ (posedge rclk)
  begin
    index_y <= index_x;
    wrreq_y <= wrreq_x;
    rdreq_y <= rdreq_x;
  end

`ifdef IBM_SRAM_CACHE_TAG_MODEL

wire [`IC_PHYS_TAG_MASK_ALL] write_bus_mask_x = {
{`IC_TLB_TAG_SZ{we[3]}},
{`IC_TLB_TAG_SZ{we[2]}},
{`IC_TLB_TAG_SZ{we[1]}},
{`IC_TLB_TAG_SZ{we[0]}}

};

  wire [`IC_TLB_TAG_MASK_ALL] write_bus_x = {wrtag_x*`IC_NUM_WAY};


  reg [`IC_TLB_TAG_MASK_ALL] cache [`IC_SET_COUNT-1:0];

  always @ (posedge rclk)
  begin
      if (wrreq_x)
        cache[index_x] <= (write_bus_x & write_bus_mask_x) | (cache[index_x] & ~write_bus_mask_x);
      else
      begin
          if (rdreq_x)
              rdtag_y <= cache[index_x];
          else
              rdtag_y <= rdtag_y;
      end
  end

`else
// real SRAM instance
wire [`IC_PHYS_TAG_MASK_ALL] write_bus_mask_x = {
{`IC_PHYS_TAG_SZ{we[3]}},
{`IC_PHYS_TAG_SZ{we[2]}},
{`IC_PHYS_TAG_SZ{we[1]}},
{`IC_PHYS_TAG_SZ{we[0]}}

};

  wire [`IC_PHYS_TAG_HI:0] wrtag_x_phys = wrtag_x;
  wire [`IC_PHYS_TAG_MASK_ALL] write_bus_x_phys = {`IC_NUM_WAY{wrtag_x_phys}};
  // wire [`IC_PHYS_TAG_MASK_ALL] write_bus_x_phys = {wrtag_x_phys, wrtag_x_phys, wrtag_x_phys, wrtag_x_phys};
  wire [`IC_PHYS_TAG_MASK_ALL] rdtag_y_phys;

  // assign rdtag_y[`IC_TLB_TAG_WAY0_MASK] = rdtag_y_phys[`IC_PHYS_TAG_WAY0_MASK];
  // assign rdtag_y[`IC_TLB_TAG_WAY1_MASK] = rdtag_y_phys[`IC_PHYS_TAG_WAY1_MASK];
  // assign rdtag_y[`IC_TLB_TAG_WAY2_MASK] = rdtag_y_phys[`IC_PHYS_TAG_WAY2_MASK];
  // assign rdtag_y[`IC_TLB_TAG_WAY3_MASK] = rdtag_y_phys[`IC_PHYS_TAG_WAY3_MASK];

  // truncate tags from 33 bits to appropriate size
  
  wire [`IC_PHYS_TAG_HI:0] rdtag_y_phys_WAY0 = rdtag_y_phys[`IC_PHYS_TAG_WAY0_MASK];
  assign rdtag_y[`IC_TLB_TAG_WAY0_MASK] = rdtag_y_phys_WAY0[`IC_TLB_TAG_HI:0];
  

  wire [`IC_PHYS_TAG_HI:0] rdtag_y_phys_WAY1 = rdtag_y_phys[`IC_PHYS_TAG_WAY1_MASK];
  assign rdtag_y[`IC_TLB_TAG_WAY1_MASK] = rdtag_y_phys_WAY1[`IC_TLB_TAG_HI:0];
  

  wire [`IC_PHYS_TAG_HI:0] rdtag_y_phys_WAY2 = rdtag_y_phys[`IC_PHYS_TAG_WAY2_MASK];
  assign rdtag_y[`IC_TLB_TAG_WAY2_MASK] = rdtag_y_phys_WAY2[`IC_TLB_TAG_HI:0];
  

  wire [`IC_PHYS_TAG_HI:0] rdtag_y_phys_WAY3 = rdtag_y_phys[`IC_PHYS_TAG_WAY3_MASK];
  assign rdtag_y[`IC_TLB_TAG_WAY3_MASK] = rdtag_y_phys_WAY3[`IC_TLB_TAG_HI:0];
  


  sram_l1i_tag cache
  (
    .MEMCLK(rclk),
      .RESET_N(reset_l),
    .CE(wrreq_x | rdreq_x),
    .A(index_x),
    .DIN(write_bus_x_phys),
    .BW(write_bus_mask_x),
    .RDWEN(~wrreq_x),
    .DOUT(rdtag_y_phys),

    .BIST_COMMAND(rtap_srams_bist_command),
    .BIST_DIN(rtap_srams_bist_data),
    .BIST_DOUT(srams_rtap_data),
    .SRAMID(sramid)
  );
  `endif


`ifdef IBM_SRAM_CACHE_TAG_MODEL_CHECKER

   wire [`IC_TLB_TAG_MASK_ALL] rdtag_y_ref;

   wire [`IC_TLB_TAG_MASK_ALL] dout = rdtag_y;
   wire [`IC_TLB_TAG_MASK_ALL] dout_ref = rdtag_y_ref;

   bw_r_ict_orig cache_orig(
      .index0_x(index0_x),
      .index1_x(index1_x),
      .index_sel_x(index_sel_x),
      .dec_wrway_x(dec_wrway_x),
      .rdreq_x(rdreq_x),
      .wrreq_x(wrreq_x),
      .wrtag_y(wrtag_y),
      .wrtag_x(wrtag_x),
      .adj(adj),
      .rdtag_y(rdtag_y_ref),

      .rst_tri_en(rst_tri_en),

      .rclk(rclk),
      .se(se),
      .si(si),
      .reset_l(reset_l),
      .sehold(sehold),

      .so(),

      .sramid(8'b0),
      .srams_rtap_data(),
      .rtap_srams_bist_command(4'b0),
      .rtap_srams_bist_data(4'b0)
   );

always @ (posedge rclk)
begin
  // #1;
   if (rdreq_y == 1'b1 && (dout != dout_ref))
   begin
      $display("%d : Simulation -> FAIL(%0s)", $time, "bw_r_ict_ref not same");
      repeat(5)@(posedge rclk);
      `MONITOR_PATH.fail("w_r_idct_ref not same");
   end
end

`endif // model checker


endmodule

`endif // IBM TAG

