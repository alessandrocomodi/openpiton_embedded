// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: lsu_mon2.v
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
////////////////////////////////////////////////////////;
//
// lsu_mon2.vpal
//
// Description: LSU Monitor for monitoring some coverage conditions
// 		as well as some checkers. Run pal to get .v using:
// 		pal -r -o lsu_mon2.v lsu_mon2.vpal
////////////////////////////////////////////////////////

`include "cross_module.tmp.h"
`include "sys.h"
`include "iop.h"

`define NUM_TILES 1


module lsu_mon2 (clk, rst_l);
input clk;		// the cpu clock
input rst_l;		// reset (active low).


reg 	lsu_mon_msg;
  initial
  begin
    if( $test$plusargs("lsu_mon_msg") )
      lsu_mon_msg = 1'b1;
    else
      lsu_mon_msg= 1'b0;
  end // initial begin


reg forcex_ldst_va;
initial
begin
  if( $test$plusargs("forcex_ldst_va") )
    forcex_ldst_va = 1'b1;
  else
    forcex_ldst_va = 1'b0;
end


// Reset code requested by Rudi
// This is to turn off monitor during reset
reg     lsu_mon_rst_l;
initial lsu_mon_rst_l = 0 ;

always @(posedge clk) begin
  while (rst_l !== 0) @(posedge clk) ;
  lsu_mon_rst_l = 0 ;
  while (rst_l !== 1) @(posedge clk) ;
  lsu_mon_rst_l = 1 ;
end
// End Reset code requested by Rudi

// Enumerate monitors for all 8 cores



`ifdef RTL_SPARC0
// Assertion for ifu_lsu_pcx_req ==============================================================
`ifndef RTL_SPU
wire        spc0_ifu_lsu_pcxreq_d   = `SPARC_CORE0.sparc0.lsu.lsu.ifu_lsu_pcxreq_d;
wire [51:0] spc0_ifu_lsu_pcxpkt_e   = `SPARC_CORE0.sparc0.lsu.lsu.ifu_lsu_pcxpkt_e;
wire        spc0_lsu_ifu_pcxpkt_ack_d   = `SPARC_CORE0.sparc0.lsu.lsu.lsu_ifu_pcxpkt_ack_d;
`else
wire		spc0_ifu_lsu_pcxreq_d	= `SPARC_CORE0.sparc0.lsu.ifu_lsu_pcxreq_d;
wire [51:0]	spc0_ifu_lsu_pcxpkt_e	= `SPARC_CORE0.sparc0.lsu.ifu_lsu_pcxpkt_e;
wire		spc0_lsu_ifu_pcxpkt_ack_d	= `SPARC_CORE0.sparc0.lsu.lsu_ifu_pcxpkt_ack_d;
`endif

reg		spc0_ifu_lsu_pcxreq_e;
wire		spc0_ifu_lsu_pcxreq_rise_d;
reg		spc0_ifu_lsu_pcxreq_rise_e;
reg [51:0] 	spc0_ifu_lsu_pcxpkt;
reg		spc0_ifu_lsu_pcxreq_check;
wire		spc0_ifu_lsu_pcxreq_check_error;


always @ (posedge clk)
	spc0_ifu_lsu_pcxreq_e <= spc0_ifu_lsu_pcxreq_d;

assign	spc0_ifu_lsu_pcxreq_rise_d = spc0_ifu_lsu_pcxreq_d & ~spc0_ifu_lsu_pcxreq_e;

always @ (posedge clk)
	spc0_ifu_lsu_pcxreq_rise_e <= spc0_ifu_lsu_pcxreq_rise_d;

always @ (posedge clk)
	if (spc0_ifu_lsu_pcxreq_rise_e)
		spc0_ifu_lsu_pcxpkt <= spc0_ifu_lsu_pcxpkt_e;

always @ (posedge clk)
	if (~rst_l)
		spc0_ifu_lsu_pcxreq_check <= 1'b0;
	else if (spc0_ifu_lsu_pcxreq_rise_d)
		spc0_ifu_lsu_pcxreq_check <= 1'b1;
	else if (spc0_lsu_ifu_pcxpkt_ack_d)
		spc0_ifu_lsu_pcxreq_check <= 1'b0;

assign	spc0_ifu_lsu_pcxreq_check_error = spc0_ifu_lsu_pcxreq_check & ~spc0_ifu_lsu_pcxreq_rise_e & (spc0_ifu_lsu_pcxpkt_e != spc0_ifu_lsu_pcxpkt);

always @ (posedge clk)
	if (spc0_ifu_lsu_pcxreq_check_error) begin
		$display("Error @%d : sparc 0 ifu_lsu_pcxreq_check_error", $time);
		if (lsu_mon_rst_l)
		`MONITOR_PATH.fail("lsu_mon2: ifu_lsu_pcxreq_check_error");
	end


// Assertion for tlu_lsu_pcxpkt ==============================================================
`ifndef RTL_SPU
wire [25:0] spc0_tlu_lsu_pcxpkt     = `SPARC_CORE0.sparc0.lsu.lsu.tlu_lsu_pcxpkt;
wire        spc0_lsu_tlu_pcxpkt_ack = `SPARC_CORE0.sparc0.lsu.lsu.lsu_tlu_pcxpkt_ack;
`else
wire [25:0]	spc0_tlu_lsu_pcxpkt		= `SPARC_CORE0.sparc0.lsu.tlu_lsu_pcxpkt;
wire		spc0_lsu_tlu_pcxpkt_ack	= `SPARC_CORE0.sparc0.lsu.lsu_tlu_pcxpkt_ack;
`endif

reg		spc0_tlu_lsu_pcxpkt_b25_d1;
wire		spc0_tlu_lsu_pcxpkt_rise;
reg [25:0]	spc0_tlu_lsu_pcxpkt_saved;
reg		spc0_tlu_lsu_pcxpkt_check;
wire		spc0_tlu_lsu_pcxpkt_check_error;

always @ (posedge clk)
	spc0_tlu_lsu_pcxpkt_b25_d1 <= spc0_tlu_lsu_pcxpkt[25];

assign	spc0_tlu_lsu_pcxpkt_rise = spc0_tlu_lsu_pcxpkt[25] & ~spc0_tlu_lsu_pcxpkt_b25_d1;

always @(posedge clk)
	if (spc0_tlu_lsu_pcxpkt_rise)
		spc0_tlu_lsu_pcxpkt_saved <= spc0_tlu_lsu_pcxpkt;

always @ (posedge clk)
	if (~rst_l)
		spc0_tlu_lsu_pcxpkt_check <= 1'b0;
	else if (spc0_tlu_lsu_pcxpkt_rise)
		spc0_tlu_lsu_pcxpkt_check <= 1'b1;
	else if (spc0_lsu_tlu_pcxpkt_ack)
		spc0_tlu_lsu_pcxpkt_check <= 1'b0;

assign	spc0_tlu_lsu_pcxpkt_check_error = spc0_tlu_lsu_pcxpkt_check & (spc0_tlu_lsu_pcxpkt != spc0_tlu_lsu_pcxpkt_saved);

always @ (posedge clk)
	if (spc0_tlu_lsu_pcxpkt_check_error) begin
		$display("Error @%d : sparc 0 tlu_lsu_pcxpkt_check_error", $time);
		if (lsu_mon_rst_l)
		`MONITOR_PATH.fail("lsu_mon2: tlu_lsu_pcxpkt_check_error");
	end


// Assertion for spu_lsu_ldst_pckt ===========================================================
`ifndef RTL_SPU
wire [`PCX_WIDTH-1:0]   spc0_spu_lsu_ldst_pckt  = `SPARC_CORE0.sparc0.lsu.lsu.spu_lsu_ldst_pckt;
wire            spc0_lsu_spu_ldst_ack   = `SPARC_CORE0.sparc0.lsu.lsu.lsu_spu_ldst_ack;
`else
wire [`PCX_WIDTH-1:0]	spc0_spu_lsu_ldst_pckt	= `SPARC_CORE0.sparc0.lsu.spu_lsu_ldst_pckt;
wire			spc0_lsu_spu_ldst_ack	= `SPARC_CORE0.sparc0.lsu.lsu_spu_ldst_ack;
`endif

reg			spc0_spu_lsu_ldst_pckt_b123_d1;
wire			spc0_spu_lsu_ldst_pckt_rise;
reg			spc0_spu_lsu_ldst_pckt_rise_d1;
reg [1:0]		spc0_spu_lsu_ldst_pckt_b71b70_saved;
reg [`PCX_WIDTH-1:0]	spc0_spu_lsu_ldst_pckt_saved;
reg			spc0_spu_lsu_ldst_pckt_check;
wire			spc0_spu_lsu_ldst_pckt_check_error;

always @ (posedge clk)
	spc0_spu_lsu_ldst_pckt_b123_d1 <= spc0_spu_lsu_ldst_pckt[`PCX_WIDTH-1];

assign	spc0_spu_lsu_ldst_pckt_rise = spc0_spu_lsu_ldst_pckt[`PCX_WIDTH-1] & ~spc0_spu_lsu_ldst_pckt_b123_d1;

always @ (posedge clk)
	spc0_spu_lsu_ldst_pckt_rise_d1 <= spc0_spu_lsu_ldst_pckt_rise;

// bank address bits are sent in first cycle
always @(posedge clk)
	if (spc0_spu_lsu_ldst_pckt_rise)
		spc0_spu_lsu_ldst_pckt_b71b70_saved <= spc0_spu_lsu_ldst_pckt[71:70];

// rest of the bits are sent in second cycle
always @(posedge clk)
	if (spc0_spu_lsu_ldst_pckt_rise_d1)
		spc0_spu_lsu_ldst_pckt_saved <= spc0_spu_lsu_ldst_pckt;

always @ (posedge clk)
	if (~rst_l)
		spc0_spu_lsu_ldst_pckt_check <= 1'b0;
	else if (spc0_spu_lsu_ldst_pckt_rise)
		spc0_spu_lsu_ldst_pckt_check <= 1'b1;
	else if (spc0_lsu_spu_ldst_ack)
		spc0_spu_lsu_ldst_pckt_check <= 1'b0;

assign	spc0_spu_lsu_ldst_pckt_check_error = spc0_spu_lsu_ldst_pckt_check &
		((!spc0_spu_lsu_ldst_pckt_rise_d1 & (spc0_spu_lsu_ldst_pckt != spc0_spu_lsu_ldst_pckt_saved)) |
		 (spc0_spu_lsu_ldst_pckt[71:70] != spc0_spu_lsu_ldst_pckt_b71b70_saved));

always @ (posedge clk)
	if (spc0_spu_lsu_ldst_pckt_check_error) begin
		$display("Error @%d : sparc 0 spu_lsu_ldst_pckt_check_error", $time);
		if (lsu_mon_rst_l)
		`MONITOR_PATH.fail("lsu_mon2: spu_lsu_ldst_pckt_check_error");
	end


// Assertion for ffu_lsu_fpop_rq_vld  ===========================================================
`ifndef RTL_SPU
wire        spc0_ffu_lsu_fpop_rq_vld    = `SPARC_CORE0.sparc0.lsu.lsu.ffu_lsu_fpop_rq_vld;
wire [80:0] spc0_ffu_lsu_data       = `SPARC_CORE0.sparc0.lsu.lsu.ffu_lsu_data;
wire        spc0_lsu_ffu_ack        = `SPARC_CORE0.sparc0.lsu.lsu.lsu_ffu_ack;
`else
wire		spc0_ffu_lsu_fpop_rq_vld	= `SPARC_CORE0.sparc0.lsu.ffu_lsu_fpop_rq_vld;
wire [80:0]	spc0_ffu_lsu_data		= `SPARC_CORE0.sparc0.lsu.ffu_lsu_data;
wire		spc0_lsu_ffu_ack		= `SPARC_CORE0.sparc0.lsu.lsu_ffu_ack;
`endif

reg		spc0_ffu_lsu_fpop_rq_vld_d1;
wire		spc0_ffu_lsu_fpop_rq_vld_rise;
reg [80:0]	spc0_ffu_lsu_data_saved;
reg		spc0_ffu_lsu_fpop_rq_vld_check;
wire		spc0_ffu_lsu_fpop_rq_vld_check_error;

always @ (posedge clk)
	 spc0_ffu_lsu_fpop_rq_vld_d1 <= spc0_ffu_lsu_fpop_rq_vld;

assign	spc0_ffu_lsu_fpop_rq_vld_rise = spc0_ffu_lsu_fpop_rq_vld & ~spc0_ffu_lsu_fpop_rq_vld_d1;

always @ (posedge clk)
	if (spc0_ffu_lsu_fpop_rq_vld_rise)
		spc0_ffu_lsu_data_saved <= spc0_ffu_lsu_data;

always @ (posedge clk)
	if (~rst_l)
		spc0_ffu_lsu_fpop_rq_vld_check <= 1'b0;
	else if (spc0_ffu_lsu_fpop_rq_vld_rise)
		spc0_ffu_lsu_fpop_rq_vld_check <= 1'b1;
	else if (spc0_lsu_ffu_ack)
		spc0_ffu_lsu_fpop_rq_vld_check <= 1'b0;

assign	spc0_ffu_lsu_fpop_rq_vld_check_error = spc0_ffu_lsu_fpop_rq_vld_check & (spc0_ffu_lsu_data != spc0_ffu_lsu_data_saved) | (spc0_ffu_lsu_fpop_rq_vld_rise & !spc0_ffu_lsu_data[80]);  // make sure bit[80] is set when req_vld asserts

always @ (posedge clk)
	if (spc0_ffu_lsu_fpop_rq_vld_check_error) begin
		$display("Error @%d : sparc 0 ffu_lsu_fpop_rq_vld_check_error", $time);
		if (lsu_mon_rst_l)
		`MONITOR_PATH.fail("lsu_mon2: ffu_lsu_fpop_rq_vld_check_error");
	end

// Assertion for fp packets going to pcx b2b ===========================================================
`ifndef RTL_SPU
wire [4:0]      spc0_spc_pcx_req_pq     = `SPARC_CORE0.sparc0.lsu.lsu.spc_pcx_req_pq;
wire [`PCX_WIDTH-1:0]   spc0_spc_pcx_data_pa        = `SPARC_CORE0.sparc0.lsu.lsu.spc_pcx_data_pa;
`else
wire [4:0]		spc0_spc_pcx_req_pq		= `SPARC_CORE0.sparc0.lsu.spc_pcx_req_pq;
wire [`PCX_WIDTH-1:0]	spc0_spc_pcx_data_pa		= `SPARC_CORE0.sparc0.lsu.spc_pcx_data_pa;
`endif

reg [4:0]		spc0_spc_pcx_req_pa;
wire			spc0_spc_pcx_req_fp1;
wire			spc0_spc_pcx_req_fp2;
reg			spc0_spc_pcx_req_fp1_d1;
wire 			spc0_spc_pcx_req_fp_b2b_error;

always @ (posedge clk)
	spc0_spc_pcx_req_pa <= spc0_spc_pcx_req_pq;

assign	spc0_spc_pcx_req_fp1 = (|spc0_spc_pcx_req_pa) & (spc0_spc_pcx_data_pa[`PCX_RQ_HI:`PCX_RQ_LO] == 5'b01010);
assign	spc0_spc_pcx_req_fp2 = spc0_spc_pcx_data_pa[`PCX_RQ_HI:`PCX_RQ_LO] == 5'b01011;

always @ (posedge clk)
	spc0_spc_pcx_req_fp1_d1 <= spc0_spc_pcx_req_fp1;

assign	spc0_spc_pcx_req_fp_b2b_error = spc0_spc_pcx_req_fp1_d1 != spc0_spc_pcx_req_fp2;

always @ (posedge clk)
	if (spc0_spc_pcx_req_fp_b2b_error) begin
		$display("Error @%d : sparc 0 spc_pcx_req_fp_b2b_error", $time);
		if (lsu_mon_rst_l)
		`MONITOR_PATH.fail("lsu_mon2: spc_pcx_req_fp_b2b_error");
	end


// Signal for lsu_load_qctl ============================================================================
`ifndef RTL_SPU
wire spc0_ld_sec_hit_l2access_w2 = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.lsu_ld_sec_hit_l2access_w2;


   wire spc0_ld0_pkt_vld_tmp  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_pkt_vld_tmp;
   reg  spc0_ld0_pkt_vld_tmp_d;

   wire spc0_ld0_inst_vld_w2  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_inst_vld_w2;
   wire spc0_ld0_is_sec_w2 = spc0_ld0_inst_vld_w2 ? spc0_ld_sec_hit_l2access_w2 : 0;


   wire spc0_ld1_pkt_vld_tmp  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_pkt_vld_tmp;
   reg  spc0_ld1_pkt_vld_tmp_d;

   wire spc0_ld1_inst_vld_w2  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_inst_vld_w2;
   wire spc0_ld1_is_sec_w2 = spc0_ld1_inst_vld_w2 ? spc0_ld_sec_hit_l2access_w2 : 0;


   wire spc0_ld2_pkt_vld_tmp  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_pkt_vld_tmp;
   reg  spc0_ld2_pkt_vld_tmp_d;

   wire spc0_ld2_inst_vld_w2  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_inst_vld_w2;
   wire spc0_ld2_is_sec_w2 = spc0_ld2_inst_vld_w2 ? spc0_ld_sec_hit_l2access_w2 : 0;


   wire spc0_ld3_pkt_vld_tmp  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_pkt_vld_tmp;
   reg  spc0_ld3_pkt_vld_tmp_d;

   wire spc0_ld3_inst_vld_w2  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_inst_vld_w2;
   wire spc0_ld3_is_sec_w2 = spc0_ld3_inst_vld_w2 ? spc0_ld_sec_hit_l2access_w2 : 0;
`else
wire spc0_ld_sec_hit_l2access_w2 = `SPARC_CORE0.sparc0.lsu.qctl1.lsu_ld_sec_hit_l2access_w2;


   wire spc0_ld0_pkt_vld_tmp  = `SPARC_CORE0.sparc0.lsu.qctl1.ld0_pkt_vld_tmp;
   reg  spc0_ld0_pkt_vld_tmp_d;

   wire spc0_ld0_inst_vld_w2  = `SPARC_CORE0.sparc0.lsu.qctl1.ld0_inst_vld_w2;
   wire spc0_ld0_is_sec_w2 = spc0_ld0_inst_vld_w2 ? spc0_ld_sec_hit_l2access_w2 : 0;


   wire spc0_ld1_pkt_vld_tmp  = `SPARC_CORE0.sparc0.lsu.qctl1.ld1_pkt_vld_tmp;
   reg  spc0_ld1_pkt_vld_tmp_d;

   wire spc0_ld1_inst_vld_w2  = `SPARC_CORE0.sparc0.lsu.qctl1.ld1_inst_vld_w2;
   wire spc0_ld1_is_sec_w2 = spc0_ld1_inst_vld_w2 ? spc0_ld_sec_hit_l2access_w2 : 0;


   wire spc0_ld2_pkt_vld_tmp  = `SPARC_CORE0.sparc0.lsu.qctl1.ld2_pkt_vld_tmp;
   reg  spc0_ld2_pkt_vld_tmp_d;

   wire spc0_ld2_inst_vld_w2  = `SPARC_CORE0.sparc0.lsu.qctl1.ld2_inst_vld_w2;
   wire spc0_ld2_is_sec_w2 = spc0_ld2_inst_vld_w2 ? spc0_ld_sec_hit_l2access_w2 : 0;


   wire spc0_ld3_pkt_vld_tmp  = `SPARC_CORE0.sparc0.lsu.qctl1.ld3_pkt_vld_tmp;
   reg  spc0_ld3_pkt_vld_tmp_d;

   wire spc0_ld3_inst_vld_w2  = `SPARC_CORE0.sparc0.lsu.qctl1.ld3_inst_vld_w2;
   wire spc0_ld3_is_sec_w2 = spc0_ld3_inst_vld_w2 ? spc0_ld_sec_hit_l2access_w2 : 0;
`endif

always @(posedge clk)
begin
   spc0_ld0_pkt_vld_tmp_d <= ~rst_l ? 0 : spc0_ld0_pkt_vld_tmp;
   spc0_ld1_pkt_vld_tmp_d <= ~rst_l ? 0 : spc0_ld1_pkt_vld_tmp;
   spc0_ld2_pkt_vld_tmp_d <= ~rst_l ? 0 : spc0_ld2_pkt_vld_tmp;
   spc0_ld3_pkt_vld_tmp_d <= ~rst_l ? 0 : spc0_ld3_pkt_vld_tmp;
end


// Signals for lsu_exu ================================================================================
`ifndef RTL_SPU
// wire     spc0_l2      = `SPARC_CORE0.sparc0.lsu.lsu.dctl.l2fill_vld_g ;
wire        spc0_unc     = `SPARC_CORE0.sparc0.lsu.lsu.dctl.unc_err_trap_g ;
wire        spc0_fpld    = `SPARC_CORE0.sparc0.lsu.lsu.dctl.l2fill_fpld_g ;
wire        spc0_fpldst  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.fp_ldst_g ;
wire        spc0_unflush = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_unflushed ;
// wire     spc0_ldw     = `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w ;
wire        spc0_byp     = `SPARC_CORE0.sparc0.lsu.lsu.dctl.intld_byp_data_vld ;
wire        spc0_flsh    = `SPARC_CORE0.sparc0.lsu.lsu.lsu_exu_flush_pipe_w ;
// wire     spc0_chm     = `SPARC_CORE0.sparc0.lsu.lsu.dctl.common_ldst_miss_w ;
wire        spc0_ldxa    = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ldxa_internal ;
wire        spc0_ato     = `SPARC_CORE0.sparc0.lsu.lsu.dctl.atomic_g ;
wire        spc0_pref    = `SPARC_CORE0.sparc0.lsu.lsu.dctl.pref_inst_g ;
wire        spc0_chit    = `SPARC_CORE0.sparc0.lsu.lsu.dctl.stb_cam_hit ;
// wire     spc0_dcp     = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_rd_parity_error ;
wire        spc0_dtp     = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dtag_perror_g ;
wire        spc0_mpu     = `SPARC_CORE0.sparc0.lsu.lsu.dctl.tte_data_perror_unc_en ;
`else
// wire     spc0_l2      = `SPARC_CORE0.sparc0.lsu.dctl.l2fill_vld_g ;
wire        spc0_unc     = `SPARC_CORE0.sparc0.lsu.dctl.unc_err_trap_g ;
wire        spc0_fpld    = `SPARC_CORE0.sparc0.lsu.dctl.l2fill_fpld_g ;
wire        spc0_fpldst  = `SPARC_CORE0.sparc0.lsu.dctl.fp_ldst_g ;
wire        spc0_unflush = `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_unflushed ;
// wire     spc0_ldw     = `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w ;
wire        spc0_byp     = `SPARC_CORE0.sparc0.lsu.dctl.intld_byp_data_vld ;
wire        spc0_flsh    = `SPARC_CORE0.sparc0.lsu.lsu_exu_flush_pipe_w ;
// wire     spc0_chm     = `SPARC_CORE0.sparc0.lsu.dctl.common_ldst_miss_w ;
wire        spc0_ldxa    = `SPARC_CORE0.sparc0.lsu.dctl.ldxa_internal ;
wire        spc0_ato     = `SPARC_CORE0.sparc0.lsu.dctl.atomic_g ;
wire        spc0_pref    = `SPARC_CORE0.sparc0.lsu.dctl.pref_inst_g ;
wire        spc0_chit    = `SPARC_CORE0.sparc0.lsu.dctl.stb_cam_hit ;
// wire     spc0_dcp     = `SPARC_CORE0.sparc0.lsu.dctl.dcache_rd_parity_error ;
wire        spc0_dtp     = `SPARC_CORE0.sparc0.lsu.dctl.dtag_perror_g ;
wire        spc0_mpu     = `SPARC_CORE0.sparc0.lsu.dctl.tte_data_perror_unc_en ;
`endif

wire [15:0] spc0_exu_und;
reg  [ 4:0] spc0_exu;
reg spc0_flsh_g;
always @(posedge clk)
begin
`ifndef RTL_SPU
  spc0_flsh_g <= `SPARC_CORE0.sparc0.lsu.lsu.lsu_exu_flush_pipe_w;
`else
  spc0_flsh_g <= `SPARC_CORE0.sparc0.lsu.lsu_exu_flush_pipe_w;
`endif
end

reg spc0_byp_g;
always @(posedge clk)
begin
`ifndef RTL_SPU
  spc0_byp_g <= `SPARC_CORE0.sparc0.lsu.lsu.dctl.intld_byp_data_vld_m;
`else
  spc0_byp_g <= `SPARC_CORE0.sparc0.lsu.dctl.intld_byp_data_vld_m;
`endif
end


assign spc0_exu_und = {
//spc0_l2,
//  spc0_unc,
  spc0_fpld,
  spc0_fpldst,
  spc0_unflush,
//spc0_ldw,
  spc0_byp_g,
  spc0_flsh_g,
//spc0_chm,
  spc0_ldxa,
  spc0_ato,
  spc0_pref,
  spc0_chit,
//spc0_dcp,
  spc0_dtp,
  spc0_mpu
};

always @(spc0_exu_und)
begin
  case (spc0_exu_und)
    16'h0000 : spc0_exu =  5'h00;
    16'h0101 : spc0_exu =  5'h01;
    16'h0102 : spc0_exu =  5'h02;
    16'h0104 : spc0_exu =  5'h03;
    16'h0008 : spc0_exu =  5'h04;
    16'h0110 : spc0_exu =  5'h05;
    16'h0120 : spc0_exu =  5'h06;
    16'h0040 : spc0_exu =  5'h07;
    16'h0080 : spc0_exu =  5'h08;
    16'h0100 : spc0_exu =  5'h09;
    16'h0200 : spc0_exu =  5'h0a;
    16'h0400 : spc0_exu =  5'h0b;
    //16'h0800 : spc0_exu =  5'h0c;
    default  : spc0_exu =  5'h0c;

//  16'h1000 : spc0_exu =  5'h0d;
//  16'h2000 : spc0_exu =  5'h0e;
//  16'h4000 : spc0_exu =  5'h0f;
//  16'h8000 : spc0_exu =  5'h10;
//  default  : spc0_exu =  5'h11;

  endcase
end


// Signals for lsu_exp ================================================================================
`ifndef RTL_SPU
wire        spc0_exp_wtchpt_trp_g             = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_wtchpt_trp_g;
wire        spc0_exp_misalign_addr_ldst_atm_m = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_misalign_addr_ldst_atm_m;
wire        spc0_exp_priv_violtn_g            = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_priv_violtn_g;
wire        spc0_exp_daccess_prot_g           = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_daccess_prot_g;
wire        spc0_exp_priv_action_g            = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_priv_action_g;
wire        spc0_exp_spec_access_epage_g      = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_spec_access_epage_g;
wire        spc0_exp_uncache_atomic_g         = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_uncache_atomic_g;
wire        spc0_exp_illegal_asi_action_g     = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_illegal_asi_action_g;
wire        spc0_exp_flt_ld_nfo_pg_g          = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_flt_ld_nfo_pg_g;
wire        spc0_exp_tlb_data_ue              = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_ifu_tlb_data_ue;
wire        spc0_exp_tlb_tag_ue               = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_ifu_tlb_tag_ue;
wire        spc0_exp_unc                      = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.tte_data_perror_unc;
`else
wire        spc0_exp_wtchpt_trp_g             = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_wtchpt_trp_g;
wire        spc0_exp_misalign_addr_ldst_atm_m = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_misalign_addr_ldst_atm_m;
wire        spc0_exp_priv_violtn_g            = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_priv_violtn_g;
wire        spc0_exp_daccess_prot_g           = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_daccess_prot_g;
wire        spc0_exp_priv_action_g            = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_priv_action_g;
wire        spc0_exp_spec_access_epage_g      = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_spec_access_epage_g;
wire        spc0_exp_uncache_atomic_g         = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_uncache_atomic_g;
wire        spc0_exp_illegal_asi_action_g     = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_illegal_asi_action_g;
wire        spc0_exp_flt_ld_nfo_pg_g          = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_flt_ld_nfo_pg_g;
wire        spc0_exp_tlb_data_ue              = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_ifu_tlb_data_ue;
wire        spc0_exp_tlb_tag_ue               = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_ifu_tlb_tag_ue;
wire        spc0_exp_unc                      = `SPARC_CORE0.sparc0.lsu.excpctl.tte_data_perror_unc;
`endif

wire [11:0] spc0_exp_und;
reg  [ 3:0] spc0_exp;

assign spc0_exp_und = {
  spc0_exp_wtchpt_trp_g,
  spc0_exp_misalign_addr_ldst_atm_m,
  spc0_exp_priv_violtn_g,
  spc0_exp_daccess_prot_g,
  spc0_exp_priv_action_g,
  spc0_exp_spec_access_epage_g,
  spc0_exp_uncache_atomic_g,
  spc0_exp_illegal_asi_action_g,
  spc0_exp_flt_ld_nfo_pg_g,
  spc0_exp_tlb_data_ue,
  spc0_exp_tlb_tag_ue,
  spc0_exp_unc
};

always @(spc0_exp_und)
begin
  case (spc0_exp_und)
    12'h000 : spc0_exp =  4'h0;
    12'h001 : spc0_exp =  4'h1;
    12'h002 : spc0_exp =  4'h2;
    12'h004 : spc0_exp =  4'h3;
    12'h008 : spc0_exp =  4'h4;
    12'h010 : spc0_exp =  4'h5;
    12'h020 : spc0_exp =  4'h6;
    12'h040 : spc0_exp =  4'h7;
    12'h080 : spc0_exp =  4'h8;
    12'h100 : spc0_exp =  4'h9;
    12'h200 : spc0_exp =  4'ha;
    12'h400 : spc0_exp =  4'hb;
    12'h800 : spc0_exp =  4'hc;
    default : spc0_exp =  4'hd;
  endcase
end


// Signals for lsu_ld_inf2 ============================================================================
reg spc0_lsu_ifu_ldst_miss_w2;

always @(posedge clk)
begin
`ifndef RTL_SPU
  spc0_lsu_ifu_ldst_miss_w2 <= ~rst_l ? 0 : `SPARC_CORE0.sparc0.lsu.lsu.lsu_ifu_ldst_miss_w;
`else
  spc0_lsu_ifu_ldst_miss_w2 <= ~rst_l ? 0 : `SPARC_CORE0.sparc0.lsu.lsu_ifu_ldst_miss_w;
`endif
end

// Signals for lsu_bld ================================================================================
wire	spc0_lsu_ld_hit_wb;

`ifndef RTL_SPU
assign  spc0_lsu_ld_hit_wb   =
((|`SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_way_hit[`L1D_WAY_ARRAY_MASK])  & `SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_enable_g & (`SPARC_CORE0.sparc0.lsu.lsu.dctl.tlb_cam_hit_g | `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_dtlb_bypass_g) &  //bug3702
  ~`SPARC_CORE0.sparc0.lsu.lsu.dctl.ldxa_internal & ~`SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_rd_parity_error & ~`SPARC_CORE0.sparc0.lsu.lsu.dctl.dtag_perror_g & ~`SPARC_CORE0.sparc0.lsu.lsu.dctl.endian_mispred_g &
  ~`SPARC_CORE0.sparc0.lsu.lsu.dctl.atomic_g &  ~`SPARC_CORE0.sparc0.lsu.lsu.dctl.ncache_asild_rq_g) &  // remove stb_cam_hit
~((`SPARC_CORE0.sparc0.lsu.lsu.dctl.dc_diagnstc_asi_g & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g)) &
  `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_vld & (~`SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g | (`SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g & `SPARC_CORE0.sparc0.lsu.lsu.dctl.recognized_asi_g)) ;
`else
assign  spc0_lsu_ld_hit_wb   =
((|`SPARC_CORE0.sparc0.lsu.dctl.lsu_way_hit[`L1D_WAY_ARRAY_MASK])  & `SPARC_CORE0.sparc0.lsu.dctl.dcache_enable_g & (`SPARC_CORE0.sparc0.lsu.dctl.tlb_cam_hit_g | `SPARC_CORE0.sparc0.lsu.dctl.lsu_dtlb_bypass_g) &  //bug3702
  ~`SPARC_CORE0.sparc0.lsu.dctl.ldxa_internal & ~`SPARC_CORE0.sparc0.lsu.dctl.dcache_rd_parity_error & ~`SPARC_CORE0.sparc0.lsu.dctl.dtag_perror_g & ~`SPARC_CORE0.sparc0.lsu.dctl.endian_mispred_g &
  ~`SPARC_CORE0.sparc0.lsu.dctl.atomic_g &  ~`SPARC_CORE0.sparc0.lsu.dctl.ncache_asild_rq_g) &  // remove stb_cam_hit
~((`SPARC_CORE0.sparc0.lsu.dctl.dc_diagnstc_asi_g & `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g)) &
  `SPARC_CORE0.sparc0.lsu.dctl.ld_vld & (~`SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g | (`SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g & `SPARC_CORE0.sparc0.lsu.dctl.recognized_asi_g)) ;
`endif

// Pipe signals to w2 stage so that they can be lined up with
// .qctl1.ld4_sec_hit_w2
reg spc0_lsu_bld_vld_w2;
reg spc0_lsu_bld_hit_w2;
reg spc0_lsu_bld_raw_w2;

always @(posedge clk)
begin
`ifndef RTL_SPU
  spc0_lsu_bld_vld_w2 <= `SPARC_CORE0.sparc0.lsu.lsu.qctl1.bld_g ;
  spc0_lsu_bld_hit_w2 <= spc0_lsu_ld_hit_wb ;
  spc0_lsu_bld_raw_w2 <= `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_hit ;
`else
  spc0_lsu_bld_vld_w2 <= `SPARC_CORE0.sparc0.lsu.qctl1.bld_g ;
  spc0_lsu_bld_hit_w2 <= spc0_lsu_ld_hit_wb ;
  spc0_lsu_bld_raw_w2 <= `SPARC_CORE0.sparc0.lsu.stb_cam_hit ;
`endif
end


// exu_lsu_ldst_va_e ==================================================================================
// force x's
`ifndef RTL_SPU
always @(`SPARC_CORE0.sparc0.ifu.ifu.fcl.running_e)
`else
always @(`SPARC_CORE0.sparc0.ifu.fcl.running_e)
`endif
begin
  if (rst_l & forcex_ldst_va) begin
`ifndef RTL_SPU
    if (~`SPARC_CORE0.sparc0.ifu.ifu.fcl.running_e) begin
`else
    if (~`SPARC_CORE0.sparc0.ifu.fcl.running_e) begin
`endif
      force `SPARC_CORE0.sparc0.exu_lsu_ldst_va_e = 48'bx;
    end
`ifndef RTL_SPU
    if (`SPARC_CORE0.sparc0.ifu.ifu.fcl.running_e) begin
`else
    if (`SPARC_CORE0.sparc0.ifu.fcl.running_e) begin
`endif
      release `SPARC_CORE0.sparc0.exu_lsu_ldst_va_e;
    end
  end
end

// force hit
// always @(`SPARC_CORE0.sparc0.ifu.fcl.running_e)
// begin
//   if (~`SPARC_CORE0.sparc0.ifu.fcl.running_e) begin
//     force `SPARC_CORE0.sparc0.exu_lsu_ldst_va_e = 48'h6000_0000;
//   end
//   if (`SPARC_CORE0.sparc0.ifu.fcl.running_e) begin
//     release `SPARC_CORE0.sparc0.exu_lsu_ldst_va_e;
//   end
// end

////////////////////////////////////////////////////////////////////////////////
// Begin dctl section
////////////////////////////////////////////////////////////////////////////////

// Signals for lsu_dctl_tlbr2p ========================================================================
reg spc0_phy_byp_ec_asi_e;
reg spc0_phy_use_ec_asi_e;
reg spc0_quad_ldd_real_e;
reg spc0_quad_ldd_real_little_e;

always @(posedge clk)
begin
`ifndef RTL_SPU
  spc0_phy_byp_ec_asi_e       <= ~rst_l ? 0 : `SPARC_CORE0.sparc0.lsu.lsu.dctl.asi_decode.phy_byp_ec_asi;
  spc0_phy_use_ec_asi_e       <= ~rst_l ? 0 : `SPARC_CORE0.sparc0.lsu.lsu.dctl.asi_decode.phy_use_ec_asi;
  spc0_quad_ldd_real_e        <= ~rst_l ? 0 : `SPARC_CORE0.sparc0.lsu.lsu.dctl.asi_decode.quad_ldd_real;
  spc0_quad_ldd_real_little_e <= ~rst_l ? 0 : `SPARC_CORE0.sparc0.lsu.lsu.dctl.asi_decode.quad_ldd_real_little;
`else
  spc0_phy_byp_ec_asi_e       <= ~rst_l ? 0 : `SPARC_CORE0.sparc0.lsu.dctl.asi_decode.phy_byp_ec_asi;
  spc0_phy_use_ec_asi_e       <= ~rst_l ? 0 : `SPARC_CORE0.sparc0.lsu.dctl.asi_decode.phy_use_ec_asi;
  spc0_quad_ldd_real_e        <= ~rst_l ? 0 : `SPARC_CORE0.sparc0.lsu.dctl.asi_decode.quad_ldd_real;
  spc0_quad_ldd_real_little_e <= ~rst_l ? 0 : `SPARC_CORE0.sparc0.lsu.dctl.asi_decode.quad_ldd_real_little;
`endif
end

// Signals for lsu_dctl_illva =========================================================================
wire spc0_pscxt_ldxa_illgl_va_decode;
wire spc0_lsuctl_illgl_va_decode;
wire spc0_mrgnctl_illgl_va_decode;
wire spc0_asi42_illgl_va_decode;

`ifndef RTL_SPU
assign spc0_pscxt_ldxa_illgl_va_decode = (`SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_asi_state == 8'h21) &
                         `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g &
                         `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w;

assign spc0_lsuctl_illgl_va_decode     = (`SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_asi_state == 8'h45) &
                         `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g &
                         `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w;

assign spc0_mrgnctl_illgl_va_decode    = (`SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_asi_state == 8'h44) &
                         `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g &
                         `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w;

assign spc0_asi42_illgl_va_decode      =  `SPARC_CORE0.sparc0.lsu.lsu.dctl.asi42_g &
                         `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g &
                         `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w;
`else
assign spc0_pscxt_ldxa_illgl_va_decode = (`SPARC_CORE0.sparc0.lsu.dctl.lsu_asi_state == 8'h21) &
					     `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g &
					     `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w;

assign spc0_lsuctl_illgl_va_decode     = (`SPARC_CORE0.sparc0.lsu.dctl.lsu_asi_state == 8'h45) &
					     `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g &
					     `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w;

assign spc0_mrgnctl_illgl_va_decode    = (`SPARC_CORE0.sparc0.lsu.dctl.lsu_asi_state == 8'h44) &
					     `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g &
					     `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w;

assign spc0_asi42_illgl_va_decode      =  `SPARC_CORE0.sparc0.lsu.dctl.asi42_g &
					     `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g &
					     `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w;
`endif

// L2 LD Return Errors Monitor =======================================================================
//`ifndef RTL_SPU
//wire spc0_l2_ld_return_error = `SPARC_CORE0.sparc0.lsu.lsu.dctl.l2_unc_error_e &
//                                  `SPARC_CORE0.sparc0.lsu.lsu.dctl.l2_corr_error_e;
//`else
//wire spc0_l2_ld_return_error = `SPARC_CORE0.sparc0.lsu.dctl.l2_unc_error_e &
//                                  `SPARC_CORE0.sparc0.lsu.dctl.l2_corr_error_e;
//`endif
//always @ (posedge clk)
//begin
//  if (spc0_l2_ld_return_error) begin
//    $display("Error @%d : sparc 0 l2_ld_return_error", $time);
//    if (lsu_mon_rst_l)
//    `MONITOR_PATH.fail("lsu_mon2: l2_ld_return_error");
//  end
//end

//// I commented the above monitor out because it is actually legal for the L2 to set both UE and CE bits in
//// CPX (e.g. LOAD_RET) packets.     -- melvyn, 11/20/03


// IO LD Return Errors Monitor =======================================================================
`ifndef RTL_SPU
wire spc0_io_ld_return_error = `SPARC_CORE0.sparc0.lsu.lsu.dctl.l2_corr_error_w2 &
                                  `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_ifu_err_addr_b39;
`else
wire spc0_io_ld_return_error = `SPARC_CORE0.sparc0.lsu.dctl.l2_corr_error_w2 &
                                  `SPARC_CORE0.sparc0.lsu.dctl.lsu_ifu_err_addr_b39;
`endif

always @ (posedge clk)
begin
  if (spc0_io_ld_return_error) begin
    $display("Error @%d : sparc 0 io_ld_return_error", $time);
    if (lsu_mon_rst_l)
    `MONITOR_PATH.fail("lsu_mon2: io_ld_return_error");
  end
end

////////////////////////////////////////////////////////////////////////////////
// End of dctl section
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Begin stb_ctl section
////////////////////////////////////////////////////////////////////////////////
`ifndef RTL_SPU
wire [7:0] spc0t0_dec_rptr_pcx_noced;

assign  spc0t0_dec_rptr_pcx_noced[7:0] =
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_vld[7:0]) &
(({`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_vld[7]} &
  {`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_ack[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_ack[7]})
| ~{`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_vld[7]}
 | `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.dec_rptr_dfq[7:0]) ;

wire [7:0] spc0t1_dec_rptr_pcx_noced;

assign  spc0t1_dec_rptr_pcx_noced[7:0] =
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_vld[7:0]) &
(({`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_vld[7]} &
  {`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_ack[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_ack[7]})
| ~{`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_vld[7]}
 | `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.dec_rptr_dfq[7:0]) ;

wire [7:0] spc0t2_dec_rptr_pcx_noced;

assign  spc0t2_dec_rptr_pcx_noced[7:0] =
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_vld[7:0]) &
(({`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_vld[7]} &
  {`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_ack[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_ack[7]})
| ~{`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_vld[7]}
 | `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.dec_rptr_dfq[7:0]) ;

wire [7:0] spc0t3_dec_rptr_pcx_noced;

assign  spc0t3_dec_rptr_pcx_noced[7:0] =
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_vld[7:0]) &
(({`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_vld[7]} &
  {`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_ack[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_ack[7]})
| ~{`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_vld[7]}
 | `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.dec_rptr_dfq[7:0]) ;
`else
wire [7:0] spc0t0_dec_rptr_pcx_noced;

assign  spc0t0_dec_rptr_pcx_noced[7:0] =
(`SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_vld[7:0]) &
(({`SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_vld[7]} &
  {`SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_ack[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_ack[7]})
| ~{`SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_vld[7]}
 | `SPARC_CORE0.sparc0.lsu.stb_ctl0.dec_rptr_dfq[7:0]) ;

wire [7:0] spc0t1_dec_rptr_pcx_noced;

assign  spc0t1_dec_rptr_pcx_noced[7:0] =
(`SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_vld[7:0]) &
(({`SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_vld[7]} &
  {`SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_ack[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_ack[7]})
| ~{`SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_vld[7]}
 | `SPARC_CORE0.sparc0.lsu.stb_ctl1.dec_rptr_dfq[7:0]) ;

wire [7:0] spc0t2_dec_rptr_pcx_noced;

assign  spc0t2_dec_rptr_pcx_noced[7:0] =
(`SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_vld[7:0]) &
(({`SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_vld[7]} &
  {`SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_ack[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_ack[7]})
| ~{`SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_vld[7]}
 | `SPARC_CORE0.sparc0.lsu.stb_ctl2.dec_rptr_dfq[7:0]) ;

wire [7:0] spc0t3_dec_rptr_pcx_noced;

assign  spc0t3_dec_rptr_pcx_noced[7:0] =
(`SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_vld[7:0]) &
(({`SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_vld[7]} &
  {`SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_ack[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_ack[7]})
| ~{`SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_vld[6:0],`SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_vld[7]}
 | `SPARC_CORE0.sparc0.lsu.stb_ctl3.dec_rptr_dfq[7:0]) ;
`endif

reg [1:0] spc0_stb_cam_cm_tid_d1;
always @ (posedge clk)
begin
`ifndef RTL_SPU
  spc0_stb_cam_cm_tid_d1 <= `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_cm_tid;
`else
  spc0_stb_cam_cm_tid_d1 <= `SPARC_CORE0.sparc0.lsu.stb_cam_cm_tid;
`endif
end

wire [7:0] spc0_stb_cam_hit_ptr_dec;
`ifndef RTL_SPU
assign spc0_stb_cam_hit_ptr_dec = 1'b1 << `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_hit_ptr;
`else
assign spc0_stb_cam_hit_ptr_dec = 1'b1 << `SPARC_CORE0.sparc0.lsu.stb_cam_hit_ptr;
`endif

`ifndef RTL_SPU
wire [7:0] spc0t0_st_dq1_ld_hit;
assign spc0t0_st_dq1_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.dq_vld_d1 & `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_hit) &
    (spc0_stb_cam_cm_tid_d1 == 2'd0)}} &
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.dqptr_d1 & spc0_stb_cam_hit_ptr_dec);

wire [7:0] spc0t0_st_dq2_ld_hit;
assign spc0t0_st_dq2_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.dq_vld_d2 & `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_hit) &
    (spc0_stb_cam_cm_tid_d1 == 2'd0)}} &
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.dqptr_d2 & spc0_stb_cam_hit_ptr_dec);


wire [7:0] spc0t1_st_dq1_ld_hit;
assign spc0t1_st_dq1_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.dq_vld_d1 & `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_hit) &
    (spc0_stb_cam_cm_tid_d1 == 2'd1)}} &
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.dqptr_d1 & spc0_stb_cam_hit_ptr_dec);

wire [7:0] spc0t1_st_dq2_ld_hit;
assign spc0t1_st_dq2_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.dq_vld_d2 & `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_hit) &
    (spc0_stb_cam_cm_tid_d1 == 2'd1)}} &
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.dqptr_d2 & spc0_stb_cam_hit_ptr_dec);


wire [7:0] spc0t2_st_dq1_ld_hit;
assign spc0t2_st_dq1_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.dq_vld_d1 & `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_hit) &
    (spc0_stb_cam_cm_tid_d1 == 2'd2)}} &
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.dqptr_d1 & spc0_stb_cam_hit_ptr_dec);

wire [7:0] spc0t2_st_dq2_ld_hit;
assign spc0t2_st_dq2_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.dq_vld_d2 & `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_hit) &
    (spc0_stb_cam_cm_tid_d1 == 2'd2)}} &
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.dqptr_d2 & spc0_stb_cam_hit_ptr_dec);


wire [7:0] spc0t3_st_dq1_ld_hit;
assign spc0t3_st_dq1_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.dq_vld_d1 & `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_hit) &
    (spc0_stb_cam_cm_tid_d1 == 2'd3)}} &
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.dqptr_d1 & spc0_stb_cam_hit_ptr_dec);


wire [7:0] spc0t3_st_dq2_ld_hit;
assign spc0t3_st_dq2_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.dq_vld_d2 & `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_hit) &
    (spc0_stb_cam_cm_tid_d1 == 2'd3)}} &
(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.dqptr_d2 & spc0_stb_cam_hit_ptr_dec);


wire spc0_st_atm_blkst_vld;
assign spc0_st_atm_blkst_vld =
((`SPARC_CORE0.sparc0.lsu.lsu.stb_rwctl.st_inst_vld_m | `SPARC_CORE0.sparc0.lsu.lsu.stb_rwctl.atomic_m) & `SPARC_CORE0.sparc0.lsu.lsu.stb_rwctl.ifu_tlu_inst_vld_m_bf0) | `SPARC_CORE0.sparc0.lsu.lsu.stb_rwctl.blkst_m;
`else
wire [7:0] spc0t0_st_dq1_ld_hit;
assign spc0t0_st_dq1_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.stb_ctl0.dq_vld_d1 & `SPARC_CORE0.sparc0.lsu.stb_cam_hit) &
	(spc0_stb_cam_cm_tid_d1 == 2'd0)}} &
(`SPARC_CORE0.sparc0.lsu.stb_ctl0.dqptr_d1 & spc0_stb_cam_hit_ptr_dec);

wire [7:0] spc0t0_st_dq2_ld_hit;
assign spc0t0_st_dq2_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.stb_ctl0.dq_vld_d2 & `SPARC_CORE0.sparc0.lsu.stb_cam_hit) &
	(spc0_stb_cam_cm_tid_d1 == 2'd0)}} &
(`SPARC_CORE0.sparc0.lsu.stb_ctl0.dqptr_d2 & spc0_stb_cam_hit_ptr_dec);


wire [7:0] spc0t1_st_dq1_ld_hit;
assign spc0t1_st_dq1_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.stb_ctl1.dq_vld_d1 & `SPARC_CORE0.sparc0.lsu.stb_cam_hit) &
	(spc0_stb_cam_cm_tid_d1 == 2'd1)}} &
(`SPARC_CORE0.sparc0.lsu.stb_ctl1.dqptr_d1 & spc0_stb_cam_hit_ptr_dec);

wire [7:0] spc0t1_st_dq2_ld_hit;
assign spc0t1_st_dq2_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.stb_ctl1.dq_vld_d2 & `SPARC_CORE0.sparc0.lsu.stb_cam_hit) &
	(spc0_stb_cam_cm_tid_d1 == 2'd1)}} &
(`SPARC_CORE0.sparc0.lsu.stb_ctl1.dqptr_d2 & spc0_stb_cam_hit_ptr_dec);


wire [7:0] spc0t2_st_dq1_ld_hit;
assign spc0t2_st_dq1_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.stb_ctl2.dq_vld_d1 & `SPARC_CORE0.sparc0.lsu.stb_cam_hit) &
	(spc0_stb_cam_cm_tid_d1 == 2'd2)}} &
(`SPARC_CORE0.sparc0.lsu.stb_ctl2.dqptr_d1 & spc0_stb_cam_hit_ptr_dec);

wire [7:0] spc0t2_st_dq2_ld_hit;
assign spc0t2_st_dq2_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.stb_ctl2.dq_vld_d2 & `SPARC_CORE0.sparc0.lsu.stb_cam_hit) &
	(spc0_stb_cam_cm_tid_d1 == 2'd2)}} &
(`SPARC_CORE0.sparc0.lsu.stb_ctl2.dqptr_d2 & spc0_stb_cam_hit_ptr_dec);


wire [7:0] spc0t3_st_dq1_ld_hit;
assign spc0t3_st_dq1_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.stb_ctl3.dq_vld_d1 & `SPARC_CORE0.sparc0.lsu.stb_cam_hit) &
	(spc0_stb_cam_cm_tid_d1 == 2'd3)}} &
(`SPARC_CORE0.sparc0.lsu.stb_ctl3.dqptr_d1 & spc0_stb_cam_hit_ptr_dec);

wire [7:0] spc0t3_st_dq2_ld_hit;
assign spc0t3_st_dq2_ld_hit =
{8{(`SPARC_CORE0.sparc0.lsu.stb_ctl3.dq_vld_d2 & `SPARC_CORE0.sparc0.lsu.stb_cam_hit) &
	(spc0_stb_cam_cm_tid_d1 == 2'd3)}} &
(`SPARC_CORE0.sparc0.lsu.stb_ctl3.dqptr_d2 & spc0_stb_cam_hit_ptr_dec);


wire spc0_st_atm_blkst_vld;
assign spc0_st_atm_blkst_vld =
((`SPARC_CORE0.sparc0.lsu.stb_rwctl.st_inst_vld_m | `SPARC_CORE0.sparc0.lsu.stb_rwctl.atomic_m) & `SPARC_CORE0.sparc0.lsu.stb_rwctl.ifu_tlu_inst_vld_m_bf0) | `SPARC_CORE0.sparc0.lsu.stb_rwctl.blkst_m;
`endif

reg spc0_qctl1_casa_w2;
reg spc0_stb_cam_vld_w;
always @ (posedge clk)
begin
`ifndef RTL_SPU
  spc0_qctl1_casa_w2 <= `SPARC_CORE0.sparc0.lsu.lsu.qctl1.casa_g;
  spc0_stb_cam_vld_w <= `SPARC_CORE0.sparc0.lsu.lsu.stb_cam.stb_cam_vld;
`else
  spc0_qctl1_casa_w2 <= `SPARC_CORE0.sparc0.lsu.qctl1.casa_g;
  spc0_stb_cam_vld_w <= `SPARC_CORE0.sparc0.lsu.stb_cam.stb_cam_vld;
`endif
end

`ifndef RTL_SPU
wire spc0_bw_r_scm_error;
assign spc0_bw_r_scm_error =
((spc0_stb_cam_vld_w
  &  `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_inst_vld_w
  & ~`SPARC_CORE0.sparc0.lsu.lsu.dctl.atomic_g
  & ~`SPARC_CORE0.sparc0.lsu.lsu_exu_flush_pipe_w
  &  `SPARC_CORE0.sparc0.lsu.lsu.stb_rwctl.cam_wptr_vld_g) |

 ((|({`SPARC_CORE0.sparc0.lsu.lsu.qctl1.st3_pcx_rq_vld,
      `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st2_pcx_rq_vld,
      `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st1_pcx_rq_vld,
      `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st0_pcx_rq_vld} &
      `SPARC_CORE0.sparc0.lsu.lsu.qctl1.pcx_rq_for_stb[3:0])) &
  `SPARC_CORE0.sparc0.lsu.lsu.stb_cam.stb_cam_wptr_vld));
`else
wire spc0_bw_r_scm_error;
assign spc0_bw_r_scm_error =
((spc0_stb_cam_vld_w
  &  `SPARC_CORE0.sparc0.lsu.excpctl.lsu_inst_vld_w
  & ~`SPARC_CORE0.sparc0.lsu.dctl.atomic_g
  & ~`SPARC_CORE0.sparc0.lsu.lsu_exu_flush_pipe_w
  &  `SPARC_CORE0.sparc0.lsu.stb_rwctl.cam_wptr_vld_g) |

 ((|({`SPARC_CORE0.sparc0.lsu.qctl1.st3_pcx_rq_vld,
      `SPARC_CORE0.sparc0.lsu.qctl1.st2_pcx_rq_vld,
      `SPARC_CORE0.sparc0.lsu.qctl1.st1_pcx_rq_vld,
      `SPARC_CORE0.sparc0.lsu.qctl1.st0_pcx_rq_vld} &
      `SPARC_CORE0.sparc0.lsu.qctl1.pcx_rq_for_stb[3:0])) &
  `SPARC_CORE0.sparc0.lsu.stb_cam.stb_cam_wptr_vld));
`endif

always @ (posedge clk)
	if (spc0_bw_r_scm_error) begin
		$display("Error @%d : sparc0 LSU bw_r_scm error", $time);
		if (lsu_mon_rst_l)
		`MONITOR_PATH.fail("lsu_mon2: bw_r_scm_error");
	end


////////////////////////////////////////////////////////////////////////////////
// End stb_ctl section
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Begin errors  section
////////////////////////////////////////////////////////////////////////////////
`ifndef RTL_SPU
// tlb data perror without instruction vld
wire spc0_tte_data_perror_unc_wo_vld;
assign spc0_tte_data_perror_unc_wo_vld =
  `SPARC_CORE0.sparc0.lsu.lsu.excpctl.tte_data_parity_error & `SPARC_CORE0.sparc0.lsu.lsu.excpctl.tlb_tte_vld_g &
~((`SPARC_CORE0.sparc0.lsu.lsu.excpctl.ld_inst_vld_unflushed | `SPARC_CORE0.sparc0.lsu.lsu.excpctl.st_inst_vld_unflushed) & `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_inst_vld_w);

// tlb data perror with flush
wire spc0_tte_data_perror_unc_w_flush;
assign spc0_tte_data_perror_unc_w_flush =
  `SPARC_CORE0.sparc0.lsu.lsu.excpctl.tte_data_parity_error & `SPARC_CORE0.sparc0.lsu.lsu.excpctl.tlb_tte_vld_g &
(`SPARC_CORE0.sparc0.lsu.lsu.excpctl.ld_inst_vld_unflushed | `SPARC_CORE0.sparc0.lsu.lsu.excpctl.st_inst_vld_unflushed) & `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_inst_vld_w & `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_flush_pipe_w;

// dcache tag perror w blk asi
wire spc0_lsu_dcache_tag_perror_g_w_blkasi;
assign spc0_lsu_dcache_tag_perror_g_w_blkasi =
  (|(`SPARC_CORE0.sparc0.lsu.lsu.dctl.dtag_parity_error[`L1D_WAY_ARRAY_MASK] & `SPARC_CORE0.sparc0.lsu.lsu.dctl.dva_vld_g[`L1D_WAY_ARRAY_MASK])) & `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w &
  (`SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g & `SPARC_CORE0.sparc0.lsu.lsu.dctl.blk_asi_g);

// dcache tag perror w pgnum39_w_bypass
wire spc0_lsu_dcache_tag_perror_g_w_pgnum39_w_bypass;
assign spc0_lsu_dcache_tag_perror_g_w_pgnum39_w_bypass =
  (|`SPARC_CORE0.sparc0.lsu.lsu.dctl.dtag_parity_error[`L1D_WAY_ARRAY_MASK]) & `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w &
  (`SPARC_CORE0.sparc0.lsu.lsu.dctl.tlb_pgnum[39] & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_dtlb_bypass_g);

// dcache tag perror w pgnum39_wo_bypass
wire spc0_lsu_dcache_tag_perror_g_w_pgnum39_wo_bypass;
assign spc0_lsu_dcache_tag_perror_g_w_pgnum39_wo_bypass =
  (|`SPARC_CORE0.sparc0.lsu.lsu.dctl.dtag_parity_error[`L1D_WAY_ARRAY_MASK]) & `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w &
  (`SPARC_CORE0.sparc0.lsu.lsu.dctl.tlb_pgnum[39] & (~`SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_dtlb_bypass_g & `SPARC_CORE0.sparc0.lsu.lsu.dctl.tlb_cam_hit_g));

// dcache tag perror w atomic
wire spc0_lsu_dcache_tag_perror_g_w_atomic;
assign spc0_lsu_dcache_tag_perror_g_w_atomic =
  (|(`SPARC_CORE0.sparc0.lsu.lsu.dctl.dtag_parity_error[`L1D_WAY_ARRAY_MASK] & `SPARC_CORE0.sparc0.lsu.lsu.dctl.dva_vld_g[`L1D_WAY_ARRAY_MASK])) & `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w &
   `SPARC_CORE0.sparc0.lsu.lsu.dctl.atomic_g;


// dcache data perror wo cacheenable
wire spc0_lsu_dcache_data_perror_g_wo_cacheenable;
assign spc0_lsu_dcache_data_perror_g_wo_cacheenable =
  `SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_rparity_err_wb & `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w &
  ~`SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_enable_g;

// dcache data perror w dtagperror
wire spc0_lsu_dcache_data_perror_g_dtag_perror;
assign spc0_lsu_dcache_data_perror_g_dtag_perror =
  `SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_rd_parity_error & `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w &
  `SPARC_CORE0.sparc0.lsu.lsu.dctl.dtag_perror_g;

// dcache data perror w altspace
wire spc0_lsu_dcache_data_perror_g_w_altspace;
assign spc0_lsu_dcache_data_perror_g_w_altspace =
  `SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_rparity_err_wb & `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w &
  (`SPARC_CORE0.sparc0.lsu.lsu.dctl.asi_internal_g & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g);

// dcache data perror w atomic
wire spc0_lsu_dcache_data_perror_g_w_atomic;
assign spc0_lsu_dcache_data_perror_g_w_atomic =
  `SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_rparity_err_wb & `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w &
  `SPARC_CORE0.sparc0.lsu.lsu.dctl.atomic_g;
`else
// tlb data perror without instruction vld
wire spc0_tte_data_perror_unc_wo_vld;
assign spc0_tte_data_perror_unc_wo_vld =
  `SPARC_CORE0.sparc0.lsu.excpctl.tte_data_parity_error & `SPARC_CORE0.sparc0.lsu.excpctl.tlb_tte_vld_g &
~((`SPARC_CORE0.sparc0.lsu.excpctl.ld_inst_vld_unflushed | `SPARC_CORE0.sparc0.lsu.excpctl.st_inst_vld_unflushed) & `SPARC_CORE0.sparc0.lsu.excpctl.lsu_inst_vld_w);

// tlb data perror with flush
wire spc0_tte_data_perror_unc_w_flush;
assign spc0_tte_data_perror_unc_w_flush =
  `SPARC_CORE0.sparc0.lsu.excpctl.tte_data_parity_error & `SPARC_CORE0.sparc0.lsu.excpctl.tlb_tte_vld_g &
(`SPARC_CORE0.sparc0.lsu.excpctl.ld_inst_vld_unflushed | `SPARC_CORE0.sparc0.lsu.excpctl.st_inst_vld_unflushed) & `SPARC_CORE0.sparc0.lsu.excpctl.lsu_inst_vld_w & `SPARC_CORE0.sparc0.lsu.excpctl.lsu_flush_pipe_w;

// dcache tag perror w blk asi
wire spc0_lsu_dcache_tag_perror_g_w_blkasi;
assign spc0_lsu_dcache_tag_perror_g_w_blkasi =
  (|(`SPARC_CORE0.sparc0.lsu.dctl.dtag_parity_error[3:0] & `SPARC_CORE0.sparc0.lsu.dctl.dva_vld_g[3:0])) & `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w &
  (`SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g & `SPARC_CORE0.sparc0.lsu.dctl.blk_asi_g);

// dcache tag perror w pgnum39_w_bypass
wire spc0_lsu_dcache_tag_perror_g_w_pgnum39_w_bypass;
assign spc0_lsu_dcache_tag_perror_g_w_pgnum39_w_bypass =
  (|`SPARC_CORE0.sparc0.lsu.dctl.dtag_parity_error[3:0]) & `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w &
  (`SPARC_CORE0.sparc0.lsu.dctl.tlb_pgnum[39] & `SPARC_CORE0.sparc0.lsu.dctl.lsu_dtlb_bypass_g);

// dcache tag perror w pgnum39_wo_bypass
wire spc0_lsu_dcache_tag_perror_g_w_pgnum39_wo_bypass;
assign spc0_lsu_dcache_tag_perror_g_w_pgnum39_wo_bypass =
  (|`SPARC_CORE0.sparc0.lsu.dctl.dtag_parity_error[3:0]) & `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w &
  (`SPARC_CORE0.sparc0.lsu.dctl.tlb_pgnum[39] & (~`SPARC_CORE0.sparc0.lsu.dctl.lsu_dtlb_bypass_g & `SPARC_CORE0.sparc0.lsu.dctl.tlb_cam_hit_g));

// dcache tag perror w atomic
wire spc0_lsu_dcache_tag_perror_g_w_atomic;
assign spc0_lsu_dcache_tag_perror_g_w_atomic =
  (|(`SPARC_CORE0.sparc0.lsu.dctl.dtag_parity_error[3:0] & `SPARC_CORE0.sparc0.lsu.dctl.dva_vld_g[3:0])) & `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w &
   `SPARC_CORE0.sparc0.lsu.dctl.atomic_g;


// dcache data perror wo cacheenable
wire spc0_lsu_dcache_data_perror_g_wo_cacheenable;
assign spc0_lsu_dcache_data_perror_g_wo_cacheenable =
  `SPARC_CORE0.sparc0.lsu.dctl.dcache_rparity_err_wb & `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w &
  ~`SPARC_CORE0.sparc0.lsu.dctl.dcache_enable_g;

// dcache data perror w dtagperror
wire spc0_lsu_dcache_data_perror_g_dtag_perror;
assign spc0_lsu_dcache_data_perror_g_dtag_perror =
  `SPARC_CORE0.sparc0.lsu.dctl.dcache_rd_parity_error & `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w &
  `SPARC_CORE0.sparc0.lsu.dctl.dtag_perror_g;

// dcache data perror w altspace
wire spc0_lsu_dcache_data_perror_g_w_altspace;
assign spc0_lsu_dcache_data_perror_g_w_altspace =
  `SPARC_CORE0.sparc0.lsu.dctl.dcache_rparity_err_wb & `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w &
  (`SPARC_CORE0.sparc0.lsu.dctl.asi_internal_g & `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g);

// dcache data perror w atomic
wire spc0_lsu_dcache_data_perror_g_w_atomic;
assign spc0_lsu_dcache_data_perror_g_w_atomic =
  `SPARC_CORE0.sparc0.lsu.dctl.dcache_rparity_err_wb & `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_unflushed & `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w &
  `SPARC_CORE0.sparc0.lsu.dctl.atomic_g;
`endif

////////////////////////////////////////////////////////////////////////////////
// End errors section
////////////////////////////////////////////////////////////////////////////////

`endif

////////////////////////////////////////////////////////////////////////////////
// begin mlim section 1
// (This is intended to be within the "for (0 = 0; 0 < 8; 0++) { ... }" section.)
////////////////////////////////////////////////////////////////////////////////

// lsu_dfq_stalls_2ormore_entries
wire spc0_dfq_2ormore_vld_entries;

// lsu_dva_rdwr_sameaddr
reg  spc0_lsu_dtagv_wr_vld_e_d1, spc0_lsu_dtagv_wr_vld_e_d2;

reg  [4:0] spc0_dva_rdaddr_10to6_d1;
wire [15:0] spc0_dva_rd_en_e;
reg  [15:0] spc0_dva_rd_en_e_d1;
wire [`L1D_VAL_ARRAY_HI:0] spc0_dva_vld_m_expanded;
reg  [4:0] spc0_dva_wraddr_10to6_d1, spc0_dva_wraddr_10to6_d2;
reg  [15:0] spc0_dva_bit_wr_en_e_d1, spc0_dva_bit_wr_en_e_d2;
reg  spc0_dva_din_e_d1, spc0_dva_din_e_d2;

wire spc0_dva_rdwr_sameline_diffvalue;
wire spc0_dva_rd_wr_sameline_diffvalue;
wire spc0_dva_wr_rd_sameline_diffvalue;

reg [144:0] spc0_dfq_byp_ff_data_d1, spc0_dfq_byp_ff_data_d2;

// lsu_traps
reg spc0_ifu_tlu_inst_vld_w;
reg spc0_ifu_tlu_flush_w;
reg spc0_ifu_mmu_trap_w;
//reg spc0_spu_tlu_rsrv_illgl_w;
reg spc0_exu_lsu_priority_trap_w;
reg spc0_ffu_tlu_ill_inst_w;
reg spc0_ifu_tlu_immu_miss_w;
reg spc0_ifu_tlu_priv_violtn_w;
reg spc0_exu_ifu_va_oor_w;

// lsu_sechit
reg spc0_lsu_way_hit_or_w2, spc0_ncache_pcx_rq_w2;
reg  [7:0] spc0_stb_ld_partial_raw_w2, spc0_stb_ld_partial_raw_w3, spc0_stb_ld_partial_raw_w4;
reg  [7:0] spc0_stb_ld_full_raw_w2, spc0_stb_ld_full_raw_w3, spc0_stb_ld_full_raw_w4;
wire [7:0] spc0_stb_cam_rw_ptr_decode_m;
reg  [7:0] spc0_stb_cam_rw_ptr_decode_w, spc0_stb_cam_rw_ptr_decode_w2;
reg  [7:0] spc0_stb_cam_rw_ptr_decode_w3, spc0_stb_cam_rw_ptr_decode_w4;
wire spc0_t0_ld_st_partialraw_hit;
wire spc0_t0_ld_st_fullraw_hit;
wire spc0_t0_st_ld_partialraw_hit;
wire spc0_t0_st_ld_fullraw_hit;
reg  spc0_ld0_inst_vld_w3, spc0_ld0_inst_vld_w4;
wire spc0_t1_ld_st_partialraw_hit;
wire spc0_t1_ld_st_fullraw_hit;
wire spc0_t1_st_ld_partialraw_hit;
wire spc0_t1_st_ld_fullraw_hit;
reg  spc0_ld1_inst_vld_w3, spc0_ld1_inst_vld_w4;
wire spc0_t2_ld_st_partialraw_hit;
wire spc0_t2_ld_st_fullraw_hit;
wire spc0_t2_st_ld_partialraw_hit;
wire spc0_t2_st_ld_fullraw_hit;
reg  spc0_ld2_inst_vld_w3, spc0_ld2_inst_vld_w4;
wire spc0_t3_ld_st_partialraw_hit;
wire spc0_t3_ld_st_fullraw_hit;
wire spc0_t3_st_ld_partialraw_hit;
wire spc0_t3_st_ld_fullraw_hit;
reg  spc0_ld3_inst_vld_w3, spc0_ld3_inst_vld_w4;
reg  spc0_stb_cam_mhit_w3, spc0_stb_cam_mhit_w4;
reg  spc0_io_ld_w3, spc0_io_ld_w4;

// lsu_picker1, lsu_pick_status; pick status monitor
wire [11:0] spc0_pick_valid_raw, spc0_pick_status, spc0_pick_status_error;
reg  [11:0] spc0_pick_valid_raw_d1, spc0_pick_status_d1;
wire [11:0] spc0_pcx_rq_sel_d2;
reg  [11:0] spc0_pcx_rq_sel_d3;

// lsu_picker2
reg         spc0_fwdpkt_valid_raw;
reg  [3:0]  spc0_st_valid_raw;
wire        spc0_fwdpkt_valid, spc0_pcx_req_squash_d1;
wire [3:0]  spc0_st_valid;
wire [11:0] spc0_pick_valid_raw_h, spc0_pick_valid_h, spc0_pick_valid_h_ext;
reg  [11:0] spc0_pick_valid_h_d1, spc0_pick_valid_h_d2;
wire [4:0]  spc0_pre_qwr, spc0_mcycle_mask_qwr_d1;
wire [11:0] spc0_pick_destbusy_unqual, spc0_pick_atompend_unqual;
wire [11:0] spc0_pick_presented, spc0_pick_destbusy, spc0_pick_atompend;
wire [2:0]  spc0_pick_presented_count, spc0_pick_destbusy_count, spc0_pick_atompend_count;

// lsu_fill_ld_b2b_sameaddr
wire [39:4] spc0_ldfill_addr_w, spc0_ldinst_addr_m;
reg  [10:4] spc0_lsu_dcache_fill_addr_m, spc0_lsu_dcache_fill_addr_w;
wire        spc0_filladdrw_eq_ldaddrm;

// lsu_spu_stxa_ack; stream stxa ack monitor
wire [3:0] spc0_strm_stxa_g;
reg  [3:0] spc0_strm_stxa_w2, spc0_lsu_spu_stb_empty_d1;
reg        spc0_strm_stxa_state;
reg  [3:0] spc0_strm_stxa_tid_decode;


`ifdef RTL_SPARC0

    // lsu_dfq_stalls_2ormore_entries

`ifndef RTL_SPU
    assign spc0_dfq_2ormore_vld_entries  = |(`SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_vld_entries[5:1]);
`else
    assign spc0_dfq_2ormore_vld_entries  = |(`SPARC_CORE0.sparc0.lsu.qctl2.dfq_vld_entries[5:1]);
`endif

    // lsu_dva_rdwr_sameaddr

`ifndef RTL_SPU
    assign spc0_dva_rd_en_e[15:12]       = {4{(`SPARC_CORE0.sparc0.lsu.lsu.exu_lsu_early_va_e[5:4] == 2'b11)}};
    assign spc0_dva_rd_en_e[11:8]        = {4{(`SPARC_CORE0.sparc0.lsu.lsu.exu_lsu_early_va_e[5:4] == 2'b10)}};
    assign spc0_dva_rd_en_e[7:4]         = {4{(`SPARC_CORE0.sparc0.lsu.lsu.exu_lsu_early_va_e[5:4] == 2'b01)}};
    assign spc0_dva_rd_en_e[3:0]         = {4{(`SPARC_CORE0.sparc0.lsu.lsu.exu_lsu_early_va_e[5:4] == 2'b00)}};

    assign spc0_dva_vld_m_expanded[`L1D_VAL_ARRAY_HI:0] = {4{`SPARC_CORE0.sparc0.lsu.lsu.dva_vld_m[`L1D_WAY_MASK]}};
`else
    assign spc0_dva_rd_en_e[15:12]       = {4{(`SPARC_CORE0.sparc0.lsu.exu_lsu_early_va_e[5:4] == 2'b11)}};
    assign spc0_dva_rd_en_e[11:8]        = {4{(`SPARC_CORE0.sparc0.lsu.exu_lsu_early_va_e[5:4] == 2'b10)}};
    assign spc0_dva_rd_en_e[7:4]         = {4{(`SPARC_CORE0.sparc0.lsu.exu_lsu_early_va_e[5:4] == 2'b01)}};
    assign spc0_dva_rd_en_e[3:0]         = {4{(`SPARC_CORE0.sparc0.lsu.exu_lsu_early_va_e[5:4] == 2'b00)}};
    
    assign spc0_dva_vld_m_expanded[`L1D_VAL_ARRAY_HI:0] = {4{`SPARC_CORE0.sparc0.lsu.dva_vld_m[`L1D_WAY_MASK]}};
`endif

    assign spc0_dva_rdwr_sameline_diffvalue =
        (spc0_dva_rdaddr_10to6_d1 == spc0_dva_wraddr_10to6_d1) &    // same addr[10:6]
        |( spc0_dva_rd_en_e_d1 & spc0_dva_bit_wr_en_e_d1 &          // same addr[5:4], wrway(s) only
           (spc0_dva_vld_m_expanded ^ {16{spc0_dva_din_e_d1}}) );   // opposite rd and wr value(s)

`ifndef RTL_SPU
    assign spc0_dva_rd_wr_sameline_diffvalue =
        (spc0_dva_rdaddr_10to6_d1 == `SPARC_CORE0.sparc0.lsu.lsu.dva_wr_adr_e[10:6]) &
        |( spc0_dva_rd_en_e_d1 & `SPARC_CORE0.sparc0.lsu.lsu.dva_bit_wr_en_e &
           (spc0_dva_vld_m_expanded ^ {16{`SPARC_CORE0.sparc0.lsu.lsu.dva_din_e}}) );
`else
    assign spc0_dva_rd_wr_sameline_diffvalue =
        (spc0_dva_rdaddr_10to6_d1 == `SPARC_CORE0.sparc0.lsu.dva_wr_adr_e[10:6]) &
        |( spc0_dva_rd_en_e_d1 & `SPARC_CORE0.sparc0.lsu.dva_bit_wr_en_e &
           (spc0_dva_vld_m_expanded ^ {16{`SPARC_CORE0.sparc0.lsu.dva_din_e}}) );
`endif

    assign spc0_dva_wr_rd_sameline_diffvalue =
        (spc0_dva_rdaddr_10to6_d1 == spc0_dva_wraddr_10to6_d2) &
        |( spc0_dva_rd_en_e_d1 & spc0_dva_bit_wr_en_e_d2 &
           (spc0_dva_vld_m_expanded ^ {16{spc0_dva_din_e_d2}}) );

    // lsu_sechit

`ifndef RTL_SPU
    assign spc0_stb_cam_rw_ptr_decode_m[7] = (`SPARC_CORE0.sparc0.lsu.lsu.stb_cam_rw_ptr[2:0] == 3'b111);
    assign spc0_stb_cam_rw_ptr_decode_m[6] = (`SPARC_CORE0.sparc0.lsu.lsu.stb_cam_rw_ptr[2:0] == 3'b110);
    assign spc0_stb_cam_rw_ptr_decode_m[5] = (`SPARC_CORE0.sparc0.lsu.lsu.stb_cam_rw_ptr[2:0] == 3'b101);
    assign spc0_stb_cam_rw_ptr_decode_m[4] = (`SPARC_CORE0.sparc0.lsu.lsu.stb_cam_rw_ptr[2:0] == 3'b100);
    assign spc0_stb_cam_rw_ptr_decode_m[3] = (`SPARC_CORE0.sparc0.lsu.lsu.stb_cam_rw_ptr[2:0] == 3'b011);
    assign spc0_stb_cam_rw_ptr_decode_m[2] = (`SPARC_CORE0.sparc0.lsu.lsu.stb_cam_rw_ptr[2:0] == 3'b010);
    assign spc0_stb_cam_rw_ptr_decode_m[1] = (`SPARC_CORE0.sparc0.lsu.lsu.stb_cam_rw_ptr[2:0] == 3'b001);
    assign spc0_stb_cam_rw_ptr_decode_m[0] = (`SPARC_CORE0.sparc0.lsu.lsu.stb_cam_rw_ptr[2:0] == 3'b000);
`else
    assign spc0_stb_cam_rw_ptr_decode_m[7] = (`SPARC_CORE0.sparc0.lsu.stb_cam_rw_ptr[2:0] == 3'b111);
    assign spc0_stb_cam_rw_ptr_decode_m[6] = (`SPARC_CORE0.sparc0.lsu.stb_cam_rw_ptr[2:0] == 3'b110);
    assign spc0_stb_cam_rw_ptr_decode_m[5] = (`SPARC_CORE0.sparc0.lsu.stb_cam_rw_ptr[2:0] == 3'b101);
    assign spc0_stb_cam_rw_ptr_decode_m[4] = (`SPARC_CORE0.sparc0.lsu.stb_cam_rw_ptr[2:0] == 3'b100);
    assign spc0_stb_cam_rw_ptr_decode_m[3] = (`SPARC_CORE0.sparc0.lsu.stb_cam_rw_ptr[2:0] == 3'b011);
    assign spc0_stb_cam_rw_ptr_decode_m[2] = (`SPARC_CORE0.sparc0.lsu.stb_cam_rw_ptr[2:0] == 3'b010);
    assign spc0_stb_cam_rw_ptr_decode_m[1] = (`SPARC_CORE0.sparc0.lsu.stb_cam_rw_ptr[2:0] == 3'b001);
    assign spc0_stb_cam_rw_ptr_decode_m[0] = (`SPARC_CORE0.sparc0.lsu.stb_cam_rw_ptr[2:0] == 3'b000);
`endif

    assign spc0_t0_ld_st_partialraw_hit    = |( spc0_stb_ld_partial_raw_w4 & spc0_stb_cam_rw_ptr_decode_w4 );
    assign spc0_t0_ld_st_fullraw_hit       = |( spc0_stb_ld_full_raw_w4    & spc0_stb_cam_rw_ptr_decode_w4 );
    assign spc0_t0_st_ld_partialraw_hit    = |( spc0_stb_ld_partial_raw_w2 & spc0_stb_cam_rw_ptr_decode_w2 );
    assign spc0_t0_st_ld_fullraw_hit       = |( spc0_stb_ld_full_raw_w2    & spc0_stb_cam_rw_ptr_decode_w2 );
    assign spc0_t1_ld_st_partialraw_hit    = |( spc0_stb_ld_partial_raw_w4 & spc0_stb_cam_rw_ptr_decode_w4 );
    assign spc0_t1_ld_st_fullraw_hit       = |( spc0_stb_ld_full_raw_w4    & spc0_stb_cam_rw_ptr_decode_w4 );
    assign spc0_t1_st_ld_partialraw_hit    = |( spc0_stb_ld_partial_raw_w2 & spc0_stb_cam_rw_ptr_decode_w2 );
    assign spc0_t1_st_ld_fullraw_hit       = |( spc0_stb_ld_full_raw_w2    & spc0_stb_cam_rw_ptr_decode_w2 );
    assign spc0_t2_ld_st_partialraw_hit    = |( spc0_stb_ld_partial_raw_w4 & spc0_stb_cam_rw_ptr_decode_w4 );
    assign spc0_t2_ld_st_fullraw_hit       = |( spc0_stb_ld_full_raw_w4    & spc0_stb_cam_rw_ptr_decode_w4 );
    assign spc0_t2_st_ld_partialraw_hit    = |( spc0_stb_ld_partial_raw_w2 & spc0_stb_cam_rw_ptr_decode_w2 );
    assign spc0_t2_st_ld_fullraw_hit       = |( spc0_stb_ld_full_raw_w2    & spc0_stb_cam_rw_ptr_decode_w2 );
    assign spc0_t3_ld_st_partialraw_hit    = |( spc0_stb_ld_partial_raw_w4 & spc0_stb_cam_rw_ptr_decode_w4 );
    assign spc0_t3_ld_st_fullraw_hit       = |( spc0_stb_ld_full_raw_w4    & spc0_stb_cam_rw_ptr_decode_w4 );
    assign spc0_t3_st_ld_partialraw_hit    = |( spc0_stb_ld_partial_raw_w2 & spc0_stb_cam_rw_ptr_decode_w2 );
    assign spc0_t3_st_ld_fullraw_hit       = |( spc0_stb_ld_full_raw_w2    & spc0_stb_cam_rw_ptr_decode_w2 );

    // lsu_picker1 coverage object, lsu_pick_status coverage object; pick status monitor

`ifndef RTL_SPU
    assign spc0_pick_valid_raw[11:0] = {`SPARC_CORE0.sparc0.lsu.lsu.qctl1.misc_events_raw[3:0],
                                           `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st_events_raw[3:0],
                                           `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld_events_raw[3:0]};

    assign spc0_pick_status[11:0] = {`SPARC_CORE0.sparc0.lsu.lsu.qctl1.misc_thrd_pick_status[3:0],
                                        `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st_thrd_pick_status[3:0],
                                        `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld_thrd_pick_status[3:0]};

    assign spc0_pcx_rq_sel_d2[11:0] = {`SPARC_CORE0.sparc0.lsu.lsu.qctl1.strm_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.fpop_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.intrpt_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.fwdpkt_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st3_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st2_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st1_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st0_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_pcx_rq_sel_d2};
`else
    assign spc0_pick_valid_raw[11:0] = {`SPARC_CORE0.sparc0.lsu.qctl1.misc_events_raw[3:0],
                                           `SPARC_CORE0.sparc0.lsu.qctl1.st_events_raw[3:0],
                                           `SPARC_CORE0.sparc0.lsu.qctl1.ld_events_raw[3:0]};

    assign spc0_pick_status[11:0] = {`SPARC_CORE0.sparc0.lsu.qctl1.misc_thrd_pick_status[3:0],
                                        `SPARC_CORE0.sparc0.lsu.qctl1.st_thrd_pick_status[3:0],
                                        `SPARC_CORE0.sparc0.lsu.qctl1.ld_thrd_pick_status[3:0]};

    assign spc0_pcx_rq_sel_d2[11:0] = {`SPARC_CORE0.sparc0.lsu.qctl1.strm_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.fpop_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.intrpt_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.fwdpkt_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.st3_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.st2_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.st1_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.st0_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.ld3_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.ld2_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.ld1_pcx_rq_sel_d2,
                                          `SPARC_CORE0.sparc0.lsu.qctl1.ld0_pcx_rq_sel_d2};
`endif

    assign spc0_pick_status_error = ~spc0_pick_valid_raw & spc0_pick_valid_raw_d1 &  // valid_raw negedge
                                       spc0_pcx_rq_sel_d3 &                                // request was picked
                                       ~( spc0_pick_status |                               // pick_status = 1 or -> 1
                                          {12{~|spc0_pick_status}} );                      // pick_status[11:0] -> 0

    // lsu_picker2 coverage object

`ifndef RTL_SPU
    assign spc0_pcx_req_squash_d1 = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.pcx_req_squash_d1;
`else
    assign spc0_pcx_req_squash_d1 = `SPARC_CORE0.sparc0.lsu.qctl1.pcx_req_squash_d1;
`endif

    always @(posedge clk) begin
        if(~lsu_mon_rst_l) begin
            spc0_fwdpkt_valid_raw  <= 1'b0;
            spc0_st_valid_raw[3:0] <= 4'b0;
        end
        else begin
`ifndef RTL_SPU
            spc0_fwdpkt_valid_raw <= (`SPARC_CORE0.sparc0.lsu.lsu.qctl1.lsu_fwdpkt_vld | spc0_fwdpkt_valid_raw) &
                                        ~(`SPARC_CORE0.sparc0.lsu.lsu.qctl1.fwdpkt_pcx_rq_sel_d2 & ~spc0_pcx_req_squash_d1);

            spc0_st_valid_raw[3]  <= (`SPARC_CORE0.sparc0.lsu.lsu.qctl1.stb_rd_for_pcx[3] | spc0_st_valid_raw[3]) &
                                        ~(`SPARC_CORE0.sparc0.lsu.lsu.qctl1.st3_pcx_rq_sel_d2 & ~spc0_pcx_req_squash_d1);
            spc0_st_valid_raw[2]  <= (`SPARC_CORE0.sparc0.lsu.lsu.qctl1.stb_rd_for_pcx[2] | spc0_st_valid_raw[2]) &
                                        ~(`SPARC_CORE0.sparc0.lsu.lsu.qctl1.st2_pcx_rq_sel_d2 & ~spc0_pcx_req_squash_d1);
            spc0_st_valid_raw[1]  <= (`SPARC_CORE0.sparc0.lsu.lsu.qctl1.stb_rd_for_pcx[1] | spc0_st_valid_raw[1]) &
                                        ~(`SPARC_CORE0.sparc0.lsu.lsu.qctl1.st1_pcx_rq_sel_d2 & ~spc0_pcx_req_squash_d1);
            spc0_st_valid_raw[0]  <= (`SPARC_CORE0.sparc0.lsu.lsu.qctl1.stb_rd_for_pcx[0] | spc0_st_valid_raw[0]) &
                                        ~(`SPARC_CORE0.sparc0.lsu.lsu.qctl1.st0_pcx_rq_sel_d2 & ~spc0_pcx_req_squash_d1);
`else
            spc0_fwdpkt_valid_raw <= (`SPARC_CORE0.sparc0.lsu.qctl1.lsu_fwdpkt_vld | spc0_fwdpkt_valid_raw) &
                                        ~(`SPARC_CORE0.sparc0.lsu.qctl1.fwdpkt_pcx_rq_sel_d2 & ~spc0_pcx_req_squash_d1);

            spc0_st_valid_raw[3]  <= (`SPARC_CORE0.sparc0.lsu.qctl1.stb_rd_for_pcx[3] | spc0_st_valid_raw[3]) &
                                        ~(`SPARC_CORE0.sparc0.lsu.qctl1.st3_pcx_rq_sel_d2 & ~spc0_pcx_req_squash_d1);
            spc0_st_valid_raw[2]  <= (`SPARC_CORE0.sparc0.lsu.qctl1.stb_rd_for_pcx[2] | spc0_st_valid_raw[2]) &
                                        ~(`SPARC_CORE0.sparc0.lsu.qctl1.st2_pcx_rq_sel_d2 & ~spc0_pcx_req_squash_d1);
            spc0_st_valid_raw[1]  <= (`SPARC_CORE0.sparc0.lsu.qctl1.stb_rd_for_pcx[1] | spc0_st_valid_raw[1]) &
                                        ~(`SPARC_CORE0.sparc0.lsu.qctl1.st1_pcx_rq_sel_d2 & ~spc0_pcx_req_squash_d1);
            spc0_st_valid_raw[0]  <= (`SPARC_CORE0.sparc0.lsu.qctl1.stb_rd_for_pcx[0] | spc0_st_valid_raw[0]) &
                                        ~(`SPARC_CORE0.sparc0.lsu.qctl1.st0_pcx_rq_sel_d2 & ~spc0_pcx_req_squash_d1);
`endif

            spc0_pick_valid_h_d1  <= spc0_pick_valid_h;
            spc0_pick_valid_h_d2  <= spc0_pick_valid_h_d1;
        end
    end

`ifndef RTL_SPU
    assign spc0_fwdpkt_valid = spc0_fwdpkt_valid_raw & |(`SPARC_CORE0.sparc0.lsu.lsu.qctl1.queue_write[4:0] &
                                                               `SPARC_CORE0.sparc0.lsu.lsu.qctl1.fwdpkt_dest_d1[4:0]);

    assign spc0_st_valid[3]  = spc0_st_valid_raw[3] & |(`SPARC_CORE0.sparc0.lsu.lsu.qctl1.st3_q_wr[4:0] &
                                                              `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st3_l2bnk_dest[4:0]);
    assign spc0_st_valid[2]  = spc0_st_valid_raw[2] & |(`SPARC_CORE0.sparc0.lsu.lsu.qctl1.st2_q_wr[4:0] &
                                                              `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st2_l2bnk_dest[4:0]);
    assign spc0_st_valid[1]  = spc0_st_valid_raw[1] & |(`SPARC_CORE0.sparc0.lsu.lsu.qctl1.st1_q_wr[4:0] &
                                                              `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st1_l2bnk_dest[4:0]);
    assign spc0_st_valid[0]  = spc0_st_valid_raw[0] & |(`SPARC_CORE0.sparc0.lsu.lsu.qctl1.st0_q_wr[4:0] &
                                                              `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st0_l2bnk_dest[4:0]);

    assign spc0_pick_valid_raw_h[11:0] = {`SPARC_CORE0.sparc0.lsu.lsu.qctl1.misc_events_raw[3:1], spc0_fwdpkt_valid_raw,
                                             spc0_st_valid_raw[3:0],
                                             `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld_events_raw[3:0]};

    assign spc0_pick_valid_h[11:0] = {`SPARC_CORE0.sparc0.lsu.lsu.qctl1.strm_pcx_rq_vld,
                                         `SPARC_CORE0.sparc0.lsu.lsu.qctl1.fpop_pcx_rq_vld,
                                         `SPARC_CORE0.sparc0.lsu.lsu.qctl1.intrpt_pcx_rq_vld,
                                         spc0_fwdpkt_valid,
                                         spc0_st_valid[3:0],
                                         `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_pcx_rq_vld,
                                         `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_pcx_rq_vld,
                                         `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_pcx_rq_vld,
                                         `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_pcx_rq_vld};
`else
    assign spc0_fwdpkt_valid = spc0_fwdpkt_valid_raw & |(`SPARC_CORE0.sparc0.lsu.qctl1.queue_write[4:0] &
                                                               `SPARC_CORE0.sparc0.lsu.qctl1.fwdpkt_dest_d1[4:0]);

    assign spc0_st_valid[3]  = spc0_st_valid_raw[3] & |(`SPARC_CORE0.sparc0.lsu.qctl1.st3_q_wr[4:0] &
                                                              `SPARC_CORE0.sparc0.lsu.qctl1.st3_l2bnk_dest[4:0]);
    assign spc0_st_valid[2]  = spc0_st_valid_raw[2] & |(`SPARC_CORE0.sparc0.lsu.qctl1.st2_q_wr[4:0] &
                                                              `SPARC_CORE0.sparc0.lsu.qctl1.st2_l2bnk_dest[4:0]);
    assign spc0_st_valid[1]  = spc0_st_valid_raw[1] & |(`SPARC_CORE0.sparc0.lsu.qctl1.st1_q_wr[4:0] &
                                                              `SPARC_CORE0.sparc0.lsu.qctl1.st1_l2bnk_dest[4:0]);
    assign spc0_st_valid[0]  = spc0_st_valid_raw[0] & |(`SPARC_CORE0.sparc0.lsu.qctl1.st0_q_wr[4:0] &
                                                              `SPARC_CORE0.sparc0.lsu.qctl1.st0_l2bnk_dest[4:0]);

    assign spc0_pick_valid_raw_h[11:0] = {`SPARC_CORE0.sparc0.lsu.qctl1.misc_events_raw[3:1], spc0_fwdpkt_valid_raw,
                                             spc0_st_valid_raw[3:0],
                                             `SPARC_CORE0.sparc0.lsu.qctl1.ld_events_raw[3:0]};

    assign spc0_pick_valid_h[11:0] = {`SPARC_CORE0.sparc0.lsu.qctl1.strm_pcx_rq_vld,
                                         `SPARC_CORE0.sparc0.lsu.qctl1.fpop_pcx_rq_vld,
                                         `SPARC_CORE0.sparc0.lsu.qctl1.intrpt_pcx_rq_vld,
                                         spc0_fwdpkt_valid,
                                         spc0_st_valid[3:0],
                                         `SPARC_CORE0.sparc0.lsu.qctl1.ld3_pcx_rq_vld,
                                         `SPARC_CORE0.sparc0.lsu.qctl1.ld2_pcx_rq_vld,
                                         `SPARC_CORE0.sparc0.lsu.qctl1.ld1_pcx_rq_vld,
                                         `SPARC_CORE0.sparc0.lsu.qctl1.ld0_pcx_rq_vld};
`endif

    assign spc0_pick_valid_h_ext[11:0] = spc0_pick_valid_h | spc0_pick_valid_h_d1 | spc0_pick_valid_h_d2;

`ifndef RTL_SPU
    assign spc0_pre_qwr[4:0] = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.pre_qwr[4:0];
`else
    assign spc0_pre_qwr[4:0] = `SPARC_CORE0.sparc0.lsu.qctl1.pre_qwr[4:0];
`endif

`ifndef RTL_SPU
    assign spc0_pick_destbusy_unqual[11] = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.strm_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[10] = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.fpop_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[9]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.intrpt_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[8]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.fwdpkt_dest_d1[4:0]);
    assign spc0_pick_destbusy_unqual[7]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st3_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[6]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st2_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[5]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st1_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[4]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st0_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[3]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[2]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[1]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[0]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_l2bnk_dest[4:0]);

    assign spc0_mcycle_mask_qwr_d1[4:0] = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.mcycle_mask_qwr_d1[4:0];
    
    assign spc0_pick_atompend_unqual[11] = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.strm_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[10] = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.fpop_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[9]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.intrpt_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[8]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.fwdpkt_dest_d1[4:0]);
    assign spc0_pick_atompend_unqual[7]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st3_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[6]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st2_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[5]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st1_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[4]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st0_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[3]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[2]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[1]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[0]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_l2bnk_dest[4:0]);
`else
    assign spc0_pick_destbusy_unqual[11] = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.strm_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[10] = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.fpop_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[9]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.intrpt_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[8]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.fwdpkt_dest_d1[4:0]);
    assign spc0_pick_destbusy_unqual[7]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.st3_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[6]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.st2_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[5]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.st1_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[4]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.st0_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[3]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.ld3_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[2]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.ld2_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[1]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.ld1_l2bnk_dest[4:0]);
    assign spc0_pick_destbusy_unqual[0]  = ~|(spc0_pre_qwr[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.ld0_l2bnk_dest[4:0]);

    assign spc0_mcycle_mask_qwr_d1[4:0] = `SPARC_CORE0.sparc0.lsu.qctl1.mcycle_mask_qwr_d1[4:0];

    assign spc0_pick_atompend_unqual[11] = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.strm_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[10] = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.fpop_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[9]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.intrpt_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[8]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.fwdpkt_dest_d1[4:0]);
    assign spc0_pick_atompend_unqual[7]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.st3_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[6]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.st2_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[5]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.st1_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[4]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.st0_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[3]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.ld3_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[2]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.ld2_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[1]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.ld1_l2bnk_dest[4:0]);
    assign spc0_pick_atompend_unqual[0]  = ~|(~spc0_mcycle_mask_qwr_d1[4:0] & `SPARC_CORE0.sparc0.lsu.qctl1.ld0_l2bnk_dest[4:0]);
`endif

    assign spc0_pick_presented = spc0_pick_valid_raw_h &  spc0_pick_valid_h_ext;
    assign spc0_pick_destbusy  = spc0_pick_valid_raw_h & ~spc0_pick_valid_h_ext & spc0_pick_destbusy_unqual;
    assign spc0_pick_atompend  = spc0_pick_valid_raw_h & ~spc0_pick_valid_h_ext & spc0_pick_atompend_unqual;

    count12bits C0_presented_count(
        .in  (spc0_pick_presented),
        .out (spc0_pick_presented_count)  // {numbits>2, numbits>1, numbits>0}
    );
    count12bits C0_destbusy_count(
        .in  (spc0_pick_destbusy),
        .out (spc0_pick_destbusy_count)
    );
    count12bits C0_atompend_count(
        .in  (spc0_pick_atompend),
        .out (spc0_pick_atompend_count)
    );

    // lsu_fill_ld_b2b_sameaddr

`ifndef RTL_SPU
    assign spc0_ldfill_addr_w[39:4]    = {`SPARC_CORE0.sparc0.lsu.lsu.dctldp.error_pa_g[28:0],
                                             spc0_lsu_dcache_fill_addr_w[10:4]};
    assign spc0_ldinst_addr_m[39:4]    = {`SPARC_CORE0.sparc0.lsu.lsu.tlb_pgnum_crit[39:10],
                                             `SPARC_CORE0.sparc0.lsu.lsu.dctldp.ldst_va_m[9:4]};
    assign spc0_filladdrw_eq_ldaddrm   = (spc0_ldfill_addr_w[39:4] == spc0_ldinst_addr_m[39:4]);
`else
    assign spc0_ldfill_addr_w[39:4]    = {`SPARC_CORE0.sparc0.lsu.dctldp.error_pa_g[28:0],
                                             spc0_lsu_dcache_fill_addr_w[10:4]};
    assign spc0_ldinst_addr_m[39:4]    = {`SPARC_CORE0.sparc0.lsu.tlb_pgnum_crit[39:10],
                                             `SPARC_CORE0.sparc0.lsu.dctldp.ldst_va_m[9:4]};
    assign spc0_filladdrw_eq_ldaddrm   = (spc0_ldfill_addr_w[39:4] == spc0_ldinst_addr_m[39:4]);
`endif

    // lsu_spu_stxa_ack; stream stxa ack monitor

`ifndef RTL_SPU
    assign spc0_strm_stxa_g[3] = `SPARC_CORE0.sparc0.lsu.lsu.dctl.st_inst_vld_g &
                                    `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g &
                                    `SPARC_CORE0.sparc0.lsu.lsu.dctl.stxa_stall_asi_g &
                                    (`SPARC_CORE0.sparc0.lsu.lsu.qctl1.thrid_g == 2'b11);
    assign spc0_strm_stxa_g[2] = `SPARC_CORE0.sparc0.lsu.lsu.dctl.st_inst_vld_g &
                                    `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g &
                                    `SPARC_CORE0.sparc0.lsu.lsu.dctl.stxa_stall_asi_g &
                                    (`SPARC_CORE0.sparc0.lsu.lsu.qctl1.thrid_g == 2'b10);
    assign spc0_strm_stxa_g[1] = `SPARC_CORE0.sparc0.lsu.lsu.dctl.st_inst_vld_g &
                                    `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g &
                                    `SPARC_CORE0.sparc0.lsu.lsu.dctl.stxa_stall_asi_g &
                                    (`SPARC_CORE0.sparc0.lsu.lsu.qctl1.thrid_g == 2'b01);
    assign spc0_strm_stxa_g[0] = `SPARC_CORE0.sparc0.lsu.lsu.dctl.st_inst_vld_g &
                                    `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g &
                                    `SPARC_CORE0.sparc0.lsu.lsu.dctl.stxa_stall_asi_g &
                                    (`SPARC_CORE0.sparc0.lsu.lsu.qctl1.thrid_g == 2'b00); 
`else
    assign spc0_strm_stxa_g[3] = `SPARC_CORE0.sparc0.lsu.dctl.st_inst_vld_g &
                                    `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g &
                                    `SPARC_CORE0.sparc0.lsu.dctl.stxa_stall_asi_g &
                                    (`SPARC_CORE0.sparc0.lsu.qctl1.thrid_g == 2'b11);
    assign spc0_strm_stxa_g[2] = `SPARC_CORE0.sparc0.lsu.dctl.st_inst_vld_g &
                                    `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g &
                                    `SPARC_CORE0.sparc0.lsu.dctl.stxa_stall_asi_g &
                                    (`SPARC_CORE0.sparc0.lsu.qctl1.thrid_g == 2'b10);
    assign spc0_strm_stxa_g[1] = `SPARC_CORE0.sparc0.lsu.dctl.st_inst_vld_g &
                                    `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g &
                                    `SPARC_CORE0.sparc0.lsu.dctl.stxa_stall_asi_g &
                                    (`SPARC_CORE0.sparc0.lsu.qctl1.thrid_g == 2'b01);
    assign spc0_strm_stxa_g[0] = `SPARC_CORE0.sparc0.lsu.dctl.st_inst_vld_g &
                                    `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g &
                                    `SPARC_CORE0.sparc0.lsu.dctl.stxa_stall_asi_g &
                                    (`SPARC_CORE0.sparc0.lsu.qctl1.thrid_g == 2'b00);
`endif

    // flop signals

    always @(posedge clk) begin
`ifndef RTL_SPU
        spc0_lsu_dtagv_wr_vld_e_d1    <= `SPARC_CORE0.sparc0.lsu.lsu.lsu_dtagv_wr_vld_e;
        spc0_lsu_dtagv_wr_vld_e_d2    <= spc0_lsu_dtagv_wr_vld_e_d1;

        spc0_dva_rdaddr_10to6_d1      <= `SPARC_CORE0.sparc0.lsu.lsu.exu_lsu_early_va_e[10:6];

        spc0_dva_rd_en_e_d1           <= spc0_dva_rd_en_e;

        spc0_dva_wraddr_10to6_d1      <= `SPARC_CORE0.sparc0.lsu.lsu.dva_wr_adr_e[10:6];
        spc0_dva_wraddr_10to6_d2      <= spc0_dva_wraddr_10to6_d1;

        spc0_dva_bit_wr_en_e_d1       <= `SPARC_CORE0.sparc0.lsu.lsu.dva_bit_wr_en_e;
        spc0_dva_bit_wr_en_e_d2       <= spc0_dva_bit_wr_en_e_d1;

        spc0_dva_din_e_d1             <= `SPARC_CORE0.sparc0.lsu.lsu.dva_din_e;
        spc0_dva_din_e_d2             <= spc0_dva_din_e_d1;

        spc0_dfq_byp_ff_data_d1       <= `SPARC_CORE0.sparc0.lsu.lsu.qdp2.dfq_byp_ff_data[144:0];
`else
        spc0_lsu_dtagv_wr_vld_e_d1    <= `SPARC_CORE0.sparc0.lsu.lsu_dtagv_wr_vld_e;
        spc0_lsu_dtagv_wr_vld_e_d2    <= spc0_lsu_dtagv_wr_vld_e_d1;

        spc0_dva_rdaddr_10to6_d1      <= `SPARC_CORE0.sparc0.lsu.exu_lsu_early_va_e[10:6];

        spc0_dva_rd_en_e_d1           <= spc0_dva_rd_en_e;

        spc0_dva_wraddr_10to6_d1      <= `SPARC_CORE0.sparc0.lsu.dva_wr_adr_e[10:6];
        spc0_dva_wraddr_10to6_d2      <= spc0_dva_wraddr_10to6_d1;

        spc0_dva_bit_wr_en_e_d1       <= `SPARC_CORE0.sparc0.lsu.dva_bit_wr_en_e;
        spc0_dva_bit_wr_en_e_d2       <= spc0_dva_bit_wr_en_e_d1;

        spc0_dva_din_e_d1             <= `SPARC_CORE0.sparc0.lsu.dva_din_e;
        spc0_dva_din_e_d2             <= spc0_dva_din_e_d1;

        spc0_dfq_byp_ff_data_d1       <= `SPARC_CORE0.sparc0.lsu.qdp2.dfq_byp_ff_data[144:0];
`endif
        spc0_dfq_byp_ff_data_d2       <= spc0_dfq_byp_ff_data_d1;

        spc0_ifu_tlu_inst_vld_w       <= `SPARC_CORE0.sparc0.ifu_tlu_inst_vld_m;
        spc0_ifu_tlu_flush_w          <= `SPARC_CORE0.sparc0.ifu_tlu_flush_m;
        spc0_ifu_mmu_trap_w           <= `SPARC_CORE0.sparc0.ifu_mmu_trap_m;
//        spc0_spu_tlu_rsrv_illgl_w     <= `SPARC_CORE0.sparc0.spu_tlu_rsrv_illgl_m;
        spc0_exu_lsu_priority_trap_w  <= `SPARC_CORE0.sparc0.exu_lsu_priority_trap_m;
        spc0_ffu_tlu_ill_inst_w       <= `SPARC_CORE0.sparc0.ffu_tlu_ill_inst_m;
        spc0_ifu_tlu_immu_miss_w      <= `SPARC_CORE0.sparc0.ifu_tlu_immu_miss_m;
        spc0_ifu_tlu_priv_violtn_w    <= `SPARC_CORE0.sparc0.ifu_tlu_priv_violtn_m;
        spc0_exu_ifu_va_oor_w         <= `SPARC_CORE0.sparc0.exu_ifu_va_oor_m;

`ifndef RTL_SPU
        spc0_lsu_way_hit_or_w2        <= `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_way_hit_or;
        spc0_ncache_pcx_rq_w2         <= `SPARC_CORE0.sparc0.lsu.lsu.dctl.ncache_pcx_rq_g;

        spc0_stb_ld_partial_raw_w2    <= `SPARC_CORE0.sparc0.lsu.lsu.stb_ld_partial_raw;
        spc0_stb_ld_partial_raw_w3    <= spc0_stb_ld_partial_raw_w2;
        spc0_stb_ld_partial_raw_w4    <= spc0_stb_ld_partial_raw_w3;
        spc0_stb_ld_full_raw_w2       <= `SPARC_CORE0.sparc0.lsu.lsu.stb_ld_full_raw;
`else
        spc0_lsu_way_hit_or_w2        <= `SPARC_CORE0.sparc0.lsu.dctl.lsu_way_hit_or;
        spc0_ncache_pcx_rq_w2         <= `SPARC_CORE0.sparc0.lsu.dctl.ncache_pcx_rq_g;
    
        spc0_stb_ld_partial_raw_w2    <= `SPARC_CORE0.sparc0.lsu.stb_ld_partial_raw;
        spc0_stb_ld_partial_raw_w3    <= spc0_stb_ld_partial_raw_w2;
        spc0_stb_ld_partial_raw_w4    <= spc0_stb_ld_partial_raw_w3;
        spc0_stb_ld_full_raw_w2       <= `SPARC_CORE0.sparc0.lsu.stb_ld_full_raw;
`endif

        spc0_stb_ld_full_raw_w3       <= spc0_stb_ld_full_raw_w2;
        spc0_stb_ld_full_raw_w4       <= spc0_stb_ld_full_raw_w3;
        spc0_stb_cam_rw_ptr_decode_w  <= spc0_stb_cam_rw_ptr_decode_m;
        spc0_stb_cam_rw_ptr_decode_w2 <= spc0_stb_cam_rw_ptr_decode_w;
        spc0_stb_cam_rw_ptr_decode_w3 <= spc0_stb_cam_rw_ptr_decode_w2;
        spc0_stb_cam_rw_ptr_decode_w4 <= spc0_stb_cam_rw_ptr_decode_w3;
`ifndef RTL_SPU
        spc0_ld0_inst_vld_w3       <= `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_inst_vld_w2;
        spc0_ld0_inst_vld_w4       <= spc0_ld0_inst_vld_w3;
        spc0_ld1_inst_vld_w3       <= `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_inst_vld_w2;
        spc0_ld1_inst_vld_w4       <= spc0_ld1_inst_vld_w3;
        spc0_ld2_inst_vld_w3       <= `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_inst_vld_w2;
        spc0_ld2_inst_vld_w4       <= spc0_ld2_inst_vld_w3;
        spc0_ld3_inst_vld_w3       <= `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_inst_vld_w2;
        spc0_ld3_inst_vld_w4       <= spc0_ld3_inst_vld_w3;
        spc0_stb_cam_mhit_w3          <= `SPARC_CORE0.sparc0.lsu.lsu.qctl1.stb_cam_mhit_w2;
        spc0_stb_cam_mhit_w4          <= spc0_stb_cam_mhit_w3;
        spc0_io_ld_w3                 <= `SPARC_CORE0.sparc0.lsu.lsu.qctl1.io_ld_w2;
`else
        spc0_ld0_inst_vld_w3       <= `SPARC_CORE0.sparc0.lsu.qctl1.ld0_inst_vld_w2;
        spc0_ld0_inst_vld_w4       <= spc0_ld0_inst_vld_w3;
        spc0_ld1_inst_vld_w3       <= `SPARC_CORE0.sparc0.lsu.qctl1.ld1_inst_vld_w2;
        spc0_ld1_inst_vld_w4       <= spc0_ld1_inst_vld_w3;
        spc0_ld2_inst_vld_w3       <= `SPARC_CORE0.sparc0.lsu.qctl1.ld2_inst_vld_w2;
        spc0_ld2_inst_vld_w4       <= spc0_ld2_inst_vld_w3;
        spc0_ld3_inst_vld_w3       <= `SPARC_CORE0.sparc0.lsu.qctl1.ld3_inst_vld_w2;
        spc0_ld3_inst_vld_w4       <= spc0_ld3_inst_vld_w3;
        spc0_stb_cam_mhit_w3          <= `SPARC_CORE0.sparc0.lsu.qctl1.stb_cam_mhit_w2;
        spc0_stb_cam_mhit_w4          <= spc0_stb_cam_mhit_w3;
        spc0_io_ld_w3                 <= `SPARC_CORE0.sparc0.lsu.qctl1.io_ld_w2;
`endif
        spc0_io_ld_w4                 <= spc0_io_ld_w3;

        spc0_pick_valid_raw_d1        <= spc0_pick_valid_raw;
        spc0_pick_status_d1           <= spc0_pick_status;
        spc0_pcx_rq_sel_d3            <= spc0_pcx_rq_sel_d2;

`ifndef RTL_SPU
        spc0_lsu_dcache_fill_addr_m[10:4] <= `SPARC_CORE0.sparc0.lsu.lsu.lsu_dcache_fill_addr_e[10:4];
`else
        spc0_lsu_dcache_fill_addr_m[10:4] <= `SPARC_CORE0.sparc0.lsu.lsu_dcache_fill_addr_e[10:4];
`endif
        spc0_lsu_dcache_fill_addr_w[10:4] <= spc0_lsu_dcache_fill_addr_m[10:4];

        spc0_strm_stxa_w2             <= spc0_strm_stxa_g;
`ifndef RTL_SPU
        spc0_lsu_spu_stb_empty_d1     <= `SPARC_CORE0.sparc0.lsu.lsu.lsu_spu_stb_empty;
`else
        spc0_lsu_spu_stb_empty_d1     <= `SPARC_CORE0.sparc0.lsu.lsu_spu_stb_empty;
`endif
    end


    // pick status monitor

    always @(posedge clk) begin
        // if negedge valid_raw[N] 2 cycles after source N is picked, then either
        // pick_status[N] must be already high or pick_status[N] becomes high or
        // pick_status[11:0] must be reset
        if( |spc0_pick_status_error ) begin
          $display("Error @%d : sparc 0 pick_status not set properly: %b", $time, spc0_pick_status_error);
          if(lsu_mon_rst_l)
              `MONITOR_PATH.fail("lsu_mon2: pick_status not set properly");
        end

        // if (valid_raw & ~pick_status) == 0, pick_status should be reset
        if( ~|(spc0_pick_valid_raw_d1 & ~spc0_pick_status_d1) & |spc0_pick_status ) begin
          $display("Error @%d : sparc 0 pick_status not reset properly", $time);
          if(lsu_mon_rst_l)
              `MONITOR_PATH.fail("lsu_mon2: pick_status not reset properly");
        end

        // all bits of pick_status should be reset simultaneously
        if( |(~spc0_pick_status & spc0_pick_status_d1) & |spc0_pick_status ) begin
          $display("Error @%d : sparc 0 pick_status bits not reset simultaneously", $time);
          if(lsu_mon_rst_l)
              `MONITOR_PATH.fail("lsu_mon2: pick_status bits not reset simultaneously");
        end
    end


    // stream stxa ack monitor

    always @(posedge clk) begin
        if(~lsu_mon_rst_l) begin
            spc0_strm_stxa_state      <= 1'b0;
            spc0_strm_stxa_tid_decode <= 4'b0;
        end
        else begin
            // IDLE state (1'b0)
            if(spc0_strm_stxa_state == 1'b0) begin
                // Stream stxa from thread whose STB is not empty
                if( |(spc0_strm_stxa_w2 & ~spc0_lsu_spu_stb_empty_d1) ) begin
                    spc0_strm_stxa_state      <= 1'b1;
                    spc0_strm_stxa_tid_decode <= spc0_strm_stxa_w2;
                end
            end

            // ACK_WAIT state (1'b1)
            else begin
`ifndef RTL_SPU
`else
                // stxa ack received from SPU (in g2/w2)
                if(`SPARC_CORE0.sparc0.spu.spu_ctl.spu_mactl.spu_lsu_stxa_ack_g2) begin
                    // stream operation aborted
                    if(|spc0_strm_stxa_w2) begin
                        // check that the correct thread is being acked
                        if( `SPARC_CORE0.sparc0.spu.spu_ctl.spu_mactl.spu_lsu_stxa_ack_tid !=
                            {(spc0_strm_stxa_tid_decode[3] | spc0_strm_stxa_tid_decode[2]),
                             (spc0_strm_stxa_tid_decode[3] | spc0_strm_stxa_tid_decode[1])} ) begin
                            $display("Error @%d : sparc 0 spu_lsu_stxa_ack_tid is wrong", $time);
                            if(lsu_mon_rst_l)
                                `MONITOR_PATH.fail("lsu_mon2: spu_lsu_stxa_ack_tid is wrong");
                        end
                        spc0_strm_stxa_tid_decode = spc0_strm_stxa_w2;
                    end
                    // stream operation not aborted
                    else begin
                        // check that the STB of the thread being acked is empty
                        if( |(spc0_strm_stxa_tid_decode & ~spc0_lsu_spu_stb_empty_d1) ) begin
                            $display("Error @%d : sparc 0 spu_lsu_stxa_ack=1 when STB is not empty", $time);
                            if(lsu_mon_rst_l)
                                `MONITOR_PATH.fail("lsu_mon2: spu_lsu_stxa_ack=1 when STB is not empty");
                        end
                        // check that the correct thread is being acked
                        if( `SPARC_CORE0.sparc0.spu.spu_ctl.spu_mactl.spu_lsu_stxa_ack_tid !=
                            {(spc0_strm_stxa_tid_decode[3] | spc0_strm_stxa_tid_decode[2]),
                             (spc0_strm_stxa_tid_decode[3] | spc0_strm_stxa_tid_decode[1])} ) begin
                            $display("Error @%d : sparc 0 spu_lsu_stxa_ack_tid is wrong", $time);
                            if(lsu_mon_rst_l)
                                `MONITOR_PATH.fail("lsu_mon2: spu_lsu_stxa_ack_tid is wrong");
                        end
                        spc0_strm_stxa_state      = 1'b0;
                        spc0_strm_stxa_tid_decode = 4'b0;
                    end
                end
`endif
            end
        end
    end


    // coverage cases for logic related to Bug 6372 (lsu_ifill_pkt_vld)
    always @(posedge clk) begin
`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_ifill_pkt_vld &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[4] &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_invwy_vld &
           ~`SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_byp_ff_en ) begin
            $display("@%d Error: C0 lsu_ifill_pkt_vld=1 for IFILL with dinv while dfq_byp_ff_en=0", $time);
            if(lsu_mon_rst_l)
                `MONITOR_PATH.fail("lsu_mon2: C0 lsu_ifill_pkt_vld=1 for IFILL with dinv while dfq_byp_ff_en=0");
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.lsu_ifill_pkt_vld &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[4] &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_invwy_vld &
           ~`SPARC_CORE0.sparc0.lsu.qctl2.dfq_byp_ff_en ) begin
            $display("@%d Error: C0 lsu_ifill_pkt_vld=1 for IFILL with dinv while dfq_byp_ff_en=0", $time);
            if(lsu_mon_rst_l)
                `MONITOR_PATH.fail("lsu_mon2: C0 lsu_ifill_pkt_vld=1 for IFILL with dinv while dfq_byp_ff_en=0");
        end
`endif
/*
`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rptr_vld_d1 &
           ~(`SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_rdata_st_ack_type &
             `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_rdata_stack_dcfill_vld) ) begin
            $display("@%d bug6372_1a: C0 dfq_rptr_vld_d1 & ~(lsu_dfq_rdata_st_ack_type & lsu_dfq_rdata_stack_dcfill_vld)", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rptr_vld_d1 &
           ~(`SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_rdata_st_ack_type &
             `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_rdata_stack_dcfill_vld) ) begin
            $display("@%d bug6372_1a: C0 dfq_rptr_vld_d1 & ~(lsu_dfq_rdata_st_ack_type & lsu_dfq_rdata_stack_dcfill_vld)", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rptr_vld_d1 &
           ~`SPARC_CORE0.sparc0.lsu.lsu.qctl2.ifill_dinv_head_of_dfq_pend ) begin
            $display("@%d bug6372_1b: C0 dfq_rptr_vld_d1 & ~ifill_dinv_head_of_dfq_pend", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rptr_vld_d1 &
           ~`SPARC_CORE0.sparc0.lsu.qctl2.ifill_dinv_head_of_dfq_pend ) begin
            $display("@%d bug6372_1b: C0 dfq_rptr_vld_d1 & ~ifill_dinv_head_of_dfq_pend", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rptr_vld_d1 &
           ~`SPARC_CORE0.sparc0.lsu.lsu.qctl2.ifill_pkt_fwd_done_d1 ) begin
            $display("@%d bug6372_1c: C0 dfq_rptr_vld_d1 & ~ifill_pkt_fwd_done_d1", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rptr_vld_d1 &
           ~`SPARC_CORE0.sparc0.lsu.qctl2.ifill_pkt_fwd_done_d1 ) begin
            $display("@%d bug6372_1c: C0 dfq_rptr_vld_d1 & ~ifill_pkt_fwd_done_d1", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_ifill_pkt_vld &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.ifill_pkt_fwd_done &
           ~`SPARC_CORE0.sparc0.lsu.lsu.qctl2.ifill_pkt_fwd_done_d1 ) begin
            $display("@%d bug6372_2: C0 lsu_ifill_pkt_vld & ifill_pkt_fwd_done & ~ifill_pkt_fwd_done_d1", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.lsu_ifill_pkt_vld &
            `SPARC_CORE0.sparc0.lsu.qctl2.ifill_pkt_fwd_done &
           ~`SPARC_CORE0.sparc0.lsu.qctl2.ifill_pkt_fwd_done_d1 ) begin
            $display("@%d bug6372_2: C0 lsu_ifill_pkt_vld & ifill_pkt_fwd_done & ~ifill_pkt_fwd_done_d1", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_st_vld & // local store in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[2] &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.local_pkt ) begin
            $display("@%d bug6372_3a: C0 Local store in dfq_byp_ff, Local store at head of DFQ", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_st_vld & // local store in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[2] &
            `SPARC_CORE0.sparc0.lsu.qctl2.local_pkt ) begin
            $display("@%d bug6372_3a: C0 Local store in dfq_byp_ff, Local store at head of DFQ", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_st_vld & // local store in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[2] &
           ~`SPARC_CORE0.sparc0.lsu.lsu.qctl2.local_pkt ) begin
            $display("@%d bug6372_3b: C0 Local store in dfq_byp_ff, foreign store at head of DFQ", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_st_vld & // local store in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[2] &
           ~`SPARC_CORE0.sparc0.lsu.qctl2.local_pkt ) begin
            $display("@%d bug6372_3b: C0 Local store in dfq_byp_ff, foreign store at head of DFQ", $time);
        end
`else

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_st_vld & // local store in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[4] &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_invwy_vld ) begin
            $display("@%d bug6372_3c: C0 Local store in dfq_byp_ff, Ifill_dinv at head of DFQ", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_st_vld & // local store in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[4] &
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_invwy_vld ) begin
            $display("@%d bug6372_3c: C0 Local store in dfq_byp_ff, Ifill_dinv at head of DFQ", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_st_vld & // local store in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[0] &
           ~`SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_flush ) begin
            $display("@%d bug6372_3d: C0 Local store in dfq_byp_ff, Int at head of DFQ", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_st_vld & // local store in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[0] &
           ~`SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_flush ) begin
            $display("@%d bug6372_3d: C0 Local store in dfq_byp_ff, Int at head of DFQ", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_st_vld & // local store in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[0] &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_flush ) begin
            $display("@%d bug6372_3e: C0 Local store in dfq_byp_ff, Flush at head of DFQ", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_st_vld & // local store in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[0] &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_flush ) begin
            $display("@%d bug6372_3e: C0 Local store in dfq_byp_ff, Flush at head of DFQ", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_inv_vld & // ifill_dinv,evict,foreign st,strst_inv in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[2] &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.local_pkt ) begin
            $display("@%d bug6372_4a: C0 Invalidate in dfq_byp_ff, Local store at head of DFQ", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.dfq_inv_vld & // ifill_dinv,evict,foreign st,strst_inv in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[2] &
            `SPARC_CORE0.sparc0.lsu.qctl2.local_pkt ) begin
            $display("@%d bug6372_4a: C0 Invalidate in dfq_byp_ff, Local store at head of DFQ", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_inv_vld & // ifill_dinv,evict,foreign st,strst_inv in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[2] &
           ~`SPARC_CORE0.sparc0.lsu.lsu.qctl2.local_pkt ) begin
            $display("@%d bug6372_4b: C0 Invalidate in dfq_byp_ff, foreign store at head of DFQ", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.dfq_inv_vld & // ifill_dinv,evict,foreign st,strst_inv in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[2] &
           ~`SPARC_CORE0.sparc0.lsu.qctl2.local_pkt ) begin
            $display("@%d bug6372_4b: C0 Invalidate in dfq_byp_ff, foreign store at head of DFQ", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_inv_vld & // ifill_dinv,evict,foreign st,strst_inv in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[4] &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_invwy_vld ) begin
            $display("@%d bug6372_4c: C0 Invalidate in dfq_byp_ff, Ifill_dinv at head of DFQ", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.dfq_inv_vld & // ifill_dinv,evict,foreign st,strst_inv in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[4] &
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_invwy_vld ) begin
            $display("@%d bug6372_4c: C0 Invalidate in dfq_byp_ff, Ifill_dinv at head of DFQ", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_inv_vld & // ifill_dinv,evict,foreign st,strst_inv in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[0] &
           ~`SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_flush ) begin
            $display("@%d bug6372_4d: C0 Invalidate in dfq_byp_ff, Int at head of DFQ", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.dfq_inv_vld & // ifill_dinv,evict,foreign st,strst_inv in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[0] &
           ~`SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_flush ) begin
            $display("@%d bug6372_4d: C0 Invalidate in dfq_byp_ff, Int at head of DFQ", $time);
        end
`endif

`ifndef RTL_SPU
        if( `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_inv_vld & // ifill_dinv,evict,foreign st,strst_inv in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_type[0] &
            `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_flush ) begin
            $display("@%d bug6372_4e: C0 Invalidate in dfq_byp_ff, Flush at head of DFQ", $time);
        end
`else
        if( `SPARC_CORE0.sparc0.lsu.qctl2.dfq_inv_vld & // ifill_dinv,evict,foreign st,strst_inv in dfq_byp_ff
            `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rd_vld_d1 &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_type[0] &
            `SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_flush ) begin
            $display("@%d bug6372_4e: C0 Invalidate in dfq_byp_ff, Flush at head of DFQ", $time);
        end
`endif
*/
    end


    // checks for Bugs 7018, 7117 (RMO store pended by TSO store but RMO store clears STB valid bit first)
    reg [3:0] spc0_i, spc0_j;
    wire [7:0] spc0_stb0_valid, spc0_stb1_valid, spc0_stb2_valid, spc0_stb3_valid;

`ifndef RTL_SPU
    assign spc0_stb0_valid[7:0] = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_vld[7:0];
    assign spc0_stb1_valid[7:0] = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_vld[7:0];
    assign spc0_stb2_valid[7:0] = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_vld[7:0];
    assign spc0_stb3_valid[7:0] = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_vld[7:0];
`else
    assign spc0_stb0_valid[7:0] = `SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_vld[7:0];
    assign spc0_stb1_valid[7:0] = `SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_vld[7:0];
    assign spc0_stb2_valid[7:0] = `SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_vld[7:0];
    assign spc0_stb3_valid[7:0] = `SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_vld[7:0];
`endif


    wire spc0_st0_rd_advance, spc0_st1_rd_advance, spc0_st2_rd_advance, spc0_st3_rd_advance;
    reg spc0_flshinst0_rst_d1, spc0_flshinst1_rst_d1, spc0_flshinst2_rst_d1, spc0_flshinst3_rst_d1;
    reg spc0_st0_rd_advance_d1, spc0_st1_rd_advance_d1, spc0_st2_rd_advance_d1, spc0_st3_rd_advance_d1;
    reg spc0_st0_rd_advance_d2, spc0_st1_rd_advance_d2, spc0_st2_rd_advance_d2, spc0_st3_rd_advance_d2;
    reg spc0_st0_rd_advance_d3, spc0_st1_rd_advance_d3, spc0_st2_rd_advance_d3, spc0_st3_rd_advance_d3;
    reg spc0_st0_rd_advance_d4, spc0_st1_rd_advance_d4, spc0_st2_rd_advance_d4, spc0_st3_rd_advance_d4;

/***************************
`ifndef RTL_SPU
    assign spc0_st0_rd_advance =  `SPARC_CORE0.sparc0.lsu.lsu.qctl2.st_rd_advance &
                                     `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rptr_vld_d1 &
                                   ~(`SPARC_CORE0.sparc0.lsu.lsu.qctl2.reset) &
                                    (`SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_tid[1:0] == 0);
    assign spc0_st1_rd_advance =  `SPARC_CORE0.sparc0.lsu.lsu.qctl2.st_rd_advance &
                                     `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rptr_vld_d1 &
                                   ~(`SPARC_CORE0.sparc0.lsu.lsu.qctl2.reset) &
                                    (`SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_tid[1:0] == 1);
    assign spc0_st2_rd_advance =  `SPARC_CORE0.sparc0.lsu.lsu.qctl2.st_rd_advance &
                                     `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rptr_vld_d1 &
                                   ~(`SPARC_CORE0.sparc0.lsu.lsu.qctl2.reset) &
                                    (`SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_tid[1:0] == 2);
    assign spc0_st3_rd_advance =  `SPARC_CORE0.sparc0.lsu.lsu.qctl2.st_rd_advance &
                                     `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_rptr_vld_d1 &
                                   ~(`SPARC_CORE0.sparc0.lsu.lsu.qctl2.reset) &
                                    (`SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_dfq_byp_tid[1:0] == 3);
`else
    assign spc0_st0_rd_advance =  `SPARC_CORE0.sparc0.lsu.qctl2.st_rd_advance &
                                     `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rptr_vld_d1 &
                                   ~(`SPARC_CORE0.sparc0.lsu.qctl2.reset) &
                                    (`SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_tid[1:0] == 0);
    assign spc0_st1_rd_advance =  `SPARC_CORE0.sparc0.lsu.qctl2.st_rd_advance &
                                     `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rptr_vld_d1 &
                                   ~(`SPARC_CORE0.sparc0.lsu.qctl2.reset) &
                                    (`SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_tid[1:0] == 1);
    assign spc0_st2_rd_advance =  `SPARC_CORE0.sparc0.lsu.qctl2.st_rd_advance &
                                     `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rptr_vld_d1 &
                                   ~(`SPARC_CORE0.sparc0.lsu.qctl2.reset) &
                                    (`SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_tid[1:0] == 2);
    assign spc0_st3_rd_advance =  `SPARC_CORE0.sparc0.lsu.qctl2.st_rd_advance &
                                     `SPARC_CORE0.sparc0.lsu.qctl2.dfq_rptr_vld_d1 &
                                   ~(`SPARC_CORE0.sparc0.lsu.qctl2.reset) &
                                    (`SPARC_CORE0.sparc0.lsu.qctl2.lsu_dfq_byp_tid[1:0] == 3);
`endif

***************************/

`ifndef RTL_SPU
    assign spc0_st0_rd_advance =  `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.st_ack_dq_stb;
    assign spc0_st1_rd_advance =  `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.st_ack_dq_stb;
    assign spc0_st2_rd_advance =  `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.st_ack_dq_stb;
    assign spc0_st3_rd_advance =  `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.st_ack_dq_stb;
`else
    assign spc0_st0_rd_advance =  `SPARC_CORE0.sparc0.lsu.stb_ctl0.st_ack_dq_stb;
    assign spc0_st1_rd_advance =  `SPARC_CORE0.sparc0.lsu.stb_ctl1.st_ack_dq_stb;
    assign spc0_st2_rd_advance =  `SPARC_CORE0.sparc0.lsu.stb_ctl2.st_ack_dq_stb;
    assign spc0_st3_rd_advance =  `SPARC_CORE0.sparc0.lsu.stb_ctl3.st_ack_dq_stb;
`endif

    always @(posedge clk) begin
        if(~lsu_mon_rst_l) begin
            spc0_flshinst0_rst_d1  <= 1'b0;
            spc0_st0_rd_advance_d1 <= 1'b0;
            spc0_st0_rd_advance_d2 <= 1'b0;
            spc0_st0_rd_advance_d3 <= 1'b0;
            spc0_st0_rd_advance_d4 <= 1'b0;

            spc0_flshinst1_rst_d1  <= 1'b0;
            spc0_st1_rd_advance_d1 <= 1'b0;
            spc0_st1_rd_advance_d2 <= 1'b0;
            spc0_st1_rd_advance_d3 <= 1'b0;
            spc0_st1_rd_advance_d4 <= 1'b0;

            spc0_flshinst2_rst_d1  <= 1'b0;
            spc0_st2_rd_advance_d1 <= 1'b0;
            spc0_st2_rd_advance_d2 <= 1'b0;
            spc0_st2_rd_advance_d3 <= 1'b0;
            spc0_st2_rd_advance_d4 <= 1'b0;

            spc0_flshinst3_rst_d1  <= 1'b0;
            spc0_st3_rd_advance_d1 <= 1'b0;
            spc0_st3_rd_advance_d2 <= 1'b0;
            spc0_st3_rd_advance_d3 <= 1'b0;
            spc0_st3_rd_advance_d4 <= 1'b0;

        end
        else begin
`ifndef RTL_SPU
            spc0_flshinst0_rst_d1  <= `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.flshinst_rst;
`else
            spc0_flshinst0_rst_d1  <= `SPARC_CORE0.sparc0.lsu.stb_ctl0.flshinst_rst;
`endif
            spc0_st0_rd_advance_d1 <= spc0_st0_rd_advance;
            spc0_st0_rd_advance_d2 <= spc0_st0_rd_advance_d1;
            spc0_st0_rd_advance_d3 <= spc0_st0_rd_advance_d2;
            spc0_st0_rd_advance_d4 <= spc0_st0_rd_advance_d3;

`ifndef RTL_SPU
            spc0_flshinst1_rst_d1  <= `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.flshinst_rst;
`else
            spc0_flshinst1_rst_d1  <= `SPARC_CORE0.sparc0.lsu.stb_ctl1.flshinst_rst;
`endif
            spc0_st1_rd_advance_d1 <= spc0_st1_rd_advance;
            spc0_st1_rd_advance_d2 <= spc0_st1_rd_advance_d1;
            spc0_st1_rd_advance_d3 <= spc0_st1_rd_advance_d2;
            spc0_st1_rd_advance_d4 <= spc0_st1_rd_advance_d3;

`ifndef RTL_SPU
            spc0_flshinst2_rst_d1  <= `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.flshinst_rst;
`else
            spc0_flshinst2_rst_d1  <= `SPARC_CORE0.sparc0.lsu.stb_ctl2.flshinst_rst;
`endif
            spc0_st2_rd_advance_d1 <= spc0_st2_rd_advance;
            spc0_st2_rd_advance_d2 <= spc0_st2_rd_advance_d1;
            spc0_st2_rd_advance_d3 <= spc0_st2_rd_advance_d2;
            spc0_st2_rd_advance_d4 <= spc0_st2_rd_advance_d3;

`ifndef RTL_SPU
            spc0_flshinst3_rst_d1  <= `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.flshinst_rst;
`else
            spc0_flshinst3_rst_d1  <= `SPARC_CORE0.sparc0.lsu.stb_ctl3.flshinst_rst;
`endif
            spc0_st3_rd_advance_d1 <= spc0_st3_rd_advance;
            spc0_st3_rd_advance_d2 <= spc0_st3_rd_advance_d1;
            spc0_st3_rd_advance_d3 <= spc0_st3_rd_advance_d2;
            spc0_st3_rd_advance_d4 <= spc0_st3_rd_advance_d3;


            // check that STB valid bits are contiguous
            spc0_j = 0;
            for(spc0_i=0; spc0_i<7; spc0_i=spc0_i+1) begin
                if(spc0_stb0_valid[spc0_i+1] != spc0_stb0_valid[spc0_i]) begin
                    spc0_j = spc0_j + 1;
                end
            end
            if(spc0_j > 2) begin
                $display("@%d Bug 7117: Error: C0 STB0 valid bits not contiguous: %b", $time, spc0_stb0_valid);
                `MONITOR_PATH.fail("Bug 7117: C0 STB0 valid bits not contiguous");
            end

            spc0_j = 0;
            for(spc0_i=0; spc0_i<7; spc0_i=spc0_i+1) begin
                if(spc0_stb1_valid[spc0_i+1] != spc0_stb1_valid[spc0_i]) begin
                    spc0_j = spc0_j + 1;
                end
            end
            if(spc0_j > 2) begin
                $display("@%d Bug 7117: Error: C0 STB1 valid bits not contiguous: %b", $time, spc0_stb1_valid);
                `MONITOR_PATH.fail("Bug 7117: C0 STB1 valid bits not contiguous");
            end

            spc0_j = 0;
            for(spc0_i=0; spc0_i<7; spc0_i=spc0_i+1) begin
                if(spc0_stb2_valid[spc0_i+1] != spc0_stb2_valid[spc0_i]) begin
                    spc0_j = spc0_j + 1;
                end
            end
            if(spc0_j > 2) begin
                $display("@%d Bug 7117: Error: C0 STB2 valid bits not contiguous: %b", $time, spc0_stb2_valid);
                `MONITOR_PATH.fail("Bug 7117: C0 STB2 valid bits not contiguous");
            end

            spc0_j = 0;
            for(spc0_i=0; spc0_i<7; spc0_i=spc0_i+1) begin
                if(spc0_stb3_valid[spc0_i+1] != spc0_stb3_valid[spc0_i]) begin
                    spc0_j = spc0_j + 1;
                end
            end
            if(spc0_j > 2) begin
                $display("@%d Bug 7117: Error: C0 STB3 valid bits not contiguous: %b", $time, spc0_stb3_valid);
                `MONITOR_PATH.fail("Bug 7117: C0 STB3 valid bits not contiguous");
            end


            // check that the STB valid bit being reset is equal to 1
`ifndef RTL_SPU
            if( `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.rst_l &
                ~spc0_flshinst0_rst_d1 &
                ~(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.st_vld_squash_w2) &
                |(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_rst) &
               ~|(spc0_stb0_valid & `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_rst) ) begin
                $display("@%d Bug 7117: Error: C0 STB0 resetting valid bit that is not 1: valid=%b, reset=%b",
                          $time, spc0_stb0_valid, `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_rst);
                `MONITOR_PATH.fail("Bug 7117: C0 STB0 resetting valid bit that is not 1");
            end

            if( `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.rst_l &
                ~spc0_flshinst1_rst_d1 &
                ~(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.st_vld_squash_w2) &
                |(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_rst) &
               ~|(spc0_stb1_valid & `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_rst) ) begin
                $display("@%d Bug 7117: Error: C0 STB1 resetting valid bit that is not 1: valid=%b, reset=%b",
                          $time, spc0_stb1_valid, `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_rst);
                `MONITOR_PATH.fail("Bug 7117: C0 STB1 resetting valid bit that is not 1");
            end

            if( `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.rst_l &
                ~spc0_flshinst2_rst_d1 &
                ~(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.st_vld_squash_w2) &
                |(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_rst) &
               ~|(spc0_stb2_valid & `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_rst) ) begin
                $display("@%d Bug 7117: Error: C0 STB2 resetting valid bit that is not 1: valid=%b, reset=%b",
                          $time, spc0_stb2_valid, `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_rst);
                `MONITOR_PATH.fail("Bug 7117: C0 STB2 resetting valid bit that is not 1");
            end

            if( `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.rst_l &
                ~spc0_flshinst3_rst_d1 &
                ~(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.st_vld_squash_w2) &
                |(`SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_rst) &
               ~|(spc0_stb3_valid & `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_rst) ) begin
                $display("@%d Bug 7117: Error: C0 STB3 resetting valid bit that is not 1: valid=%b, reset=%b",
                          $time, spc0_stb3_valid, `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_rst);
                `MONITOR_PATH.fail("Bug 7117: C0 STB3 resetting valid bit that is not 1");
            end
`else
            if( `SPARC_CORE0.sparc0.lsu.stb_ctl0.rst_l &
                ~spc0_flshinst0_rst_d1 &
                ~(`SPARC_CORE0.sparc0.lsu.stb_ctl0.st_vld_squash_w2) &
                |(`SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_rst) &
               ~|(spc0_stb0_valid & `SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_rst) ) begin
                $display("@%d Bug 7117: Error: C0 STB0 resetting valid bit that is not 1: valid=%b, reset=%b",
                          $time, spc0_stb0_valid, `SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_rst);
                `MONITOR_PATH.fail("Bug 7117: C0 STB0 resetting valid bit that is not 1");
            end

            if( `SPARC_CORE0.sparc0.lsu.stb_ctl1.rst_l &
                ~spc0_flshinst1_rst_d1 &
                ~(`SPARC_CORE0.sparc0.lsu.stb_ctl1.st_vld_squash_w2) &
                |(`SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_rst) &
               ~|(spc0_stb1_valid & `SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_rst) ) begin
                $display("@%d Bug 7117: Error: C0 STB1 resetting valid bit that is not 1: valid=%b, reset=%b",
                          $time, spc0_stb1_valid, `SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_rst);
                `MONITOR_PATH.fail("Bug 7117: C0 STB1 resetting valid bit that is not 1");
            end

            if( `SPARC_CORE0.sparc0.lsu.stb_ctl2.rst_l &
                ~spc0_flshinst2_rst_d1 &
                ~(`SPARC_CORE0.sparc0.lsu.stb_ctl2.st_vld_squash_w2) &
                |(`SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_rst) &
               ~|(spc0_stb2_valid & `SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_rst) ) begin
                $display("@%d Bug 7117: Error: C0 STB2 resetting valid bit that is not 1: valid=%b, reset=%b",
                          $time, spc0_stb2_valid, `SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_rst);
                `MONITOR_PATH.fail("Bug 7117: C0 STB2 resetting valid bit that is not 1");
            end

            if( `SPARC_CORE0.sparc0.lsu.stb_ctl3.rst_l &
                ~spc0_flshinst3_rst_d1 &
                ~(`SPARC_CORE0.sparc0.lsu.stb_ctl3.st_vld_squash_w2) &
                |(`SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_rst) &
               ~|(spc0_stb3_valid & `SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_rst) ) begin
                $display("@%d Bug 7117: Error: C0 STB3 resetting valid bit that is not 1: valid=%b, reset=%b",
                          $time, spc0_stb3_valid, `SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_rst);
                `MONITOR_PATH.fail("Bug 7117: C0 STB3 resetting valid bit that is not 1");
            end
`endif


            // detect local store acks from the same thread popping off the DFQ 0, 1, 2, or 3 cycles apart
            if(spc0_st0_rd_advance_d1 & spc0_st0_rd_advance) begin
                $display("@%d Bug 7117: C0T0 store acks exit DFQ 0 cycles apart", $time);
            end
            if(spc0_st0_rd_advance_d2 & spc0_st0_rd_advance) begin
                $display("@%d Bug 7117: C0T0 store acks exit DFQ 1 cycle apart", $time);
            end
            if(spc0_st0_rd_advance_d3 & spc0_st0_rd_advance) begin
                $display("@%d Bug 7117: C0T0 store acks exit DFQ 2 cycles apart", $time);
            end
            if(spc0_st0_rd_advance_d4 & spc0_st0_rd_advance) begin
                $display("@%d Bug 7117: C0T0 store acks exit DFQ 3 cycles apart", $time);
            end

            if(spc0_st1_rd_advance_d1 & spc0_st1_rd_advance) begin
                $display("@%d Bug 7117: C0T1 store acks exit DFQ 0 cycles apart", $time);
            end
            if(spc0_st1_rd_advance_d2 & spc0_st1_rd_advance) begin
                $display("@%d Bug 7117: C0T1 store acks exit DFQ 1 cycle apart", $time);
            end
            if(spc0_st1_rd_advance_d3 & spc0_st1_rd_advance) begin
                $display("@%d Bug 7117: C0T1 store acks exit DFQ 2 cycles apart", $time);
            end
            if(spc0_st1_rd_advance_d4 & spc0_st1_rd_advance) begin
                $display("@%d Bug 7117: C0T1 store acks exit DFQ 3 cycles apart", $time);
            end

            if(spc0_st2_rd_advance_d1 & spc0_st2_rd_advance) begin
                $display("@%d Bug 7117: C0T2 store acks exit DFQ 0 cycles apart", $time);
            end
            if(spc0_st2_rd_advance_d2 & spc0_st2_rd_advance) begin
                $display("@%d Bug 7117: C0T2 store acks exit DFQ 1 cycle apart", $time);
            end
            if(spc0_st2_rd_advance_d3 & spc0_st2_rd_advance) begin
                $display("@%d Bug 7117: C0T2 store acks exit DFQ 2 cycles apart", $time);
            end
            if(spc0_st2_rd_advance_d4 & spc0_st2_rd_advance) begin
                $display("@%d Bug 7117: C0T2 store acks exit DFQ 3 cycles apart", $time);
            end

            if(spc0_st3_rd_advance_d1 & spc0_st3_rd_advance) begin
                $display("@%d Bug 7117: C0T3 store acks exit DFQ 0 cycles apart", $time);
            end
            if(spc0_st3_rd_advance_d2 & spc0_st3_rd_advance) begin
                $display("@%d Bug 7117: C0T3 store acks exit DFQ 1 cycle apart", $time);
            end
            if(spc0_st3_rd_advance_d3 & spc0_st3_rd_advance) begin
                $display("@%d Bug 7117: C0T3 store acks exit DFQ 2 cycles apart", $time);
            end
            if(spc0_st3_rd_advance_d4 & spc0_st3_rd_advance) begin
                $display("@%d Bug 7117: C0T3 store acks exit DFQ 3 cycles apart", $time);
            end

        end
    end

`endif




////////////////////////////////////////////////////////////////////////////////
// end mlim section 1
// (This is intended to be within the "for (0 = 0; 0 < 8; 0++) { ... }" section.)
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// begin mlim section 2
// (DO NOT place within the "for (8 = 0; 8 < 8; 8++) { ... }" section.)
////////////////////////////////////////////////////////////////////////////////

wire [`NUM_TILES-1:0] cpx_spc_data_cx2_local;
wire [`NUM_TILES-1:0] cpx_spc_data_cx2_Dinv;
wire [`NUM_TILES-1:0] cpx_spc_data_cx2_Iinv;

ack_evict_decode cpx_spc_data_cx2_decode(

        .in0   (`SPARC_CORE0.cpx_spc0_data_cx2[127:0]),


    .local (cpx_spc_data_cx2_local),
    .Dinv  (cpx_spc_data_cx2_Dinv),
    .Iinv  (cpx_spc_data_cx2_Iinv)
);



wire [`NUM_TILES-1:0] dfq_byp_mx_data_local;
wire [`NUM_TILES-1:0] dfq_byp_mx_data_Dinv;
wire [`NUM_TILES-1:0] dfq_byp_mx_data_Iinv;

ack_evict_decode dfq_byp_mx_data_decode(

    `ifndef RTL_SPU
    .in0   (`SPARC_CORE0.sparc0.lsu.lsu.qdp2.dfq_byp_mx_data[127:0]),
    `else
    .in0   (`SPARC_CORE0.sparc0.lsu.qdp2.dfq_byp_mx_data[127:0]),
    `endif


    .local (dfq_byp_mx_data_local),
    .Dinv  (dfq_byp_mx_data_Dinv),
    .Iinv  (dfq_byp_mx_data_Iinv)
);



wire [`NUM_TILES-1:0] dfq_cpx_raw_wdata_local;
wire [`NUM_TILES-1:0] dfq_cpx_raw_wdata_Dinv;
wire [`NUM_TILES-1:0] dfq_cpx_raw_wdata_Iinv;

ack_evict_decode dfq_cpx_raw_wdata_decode(

    `ifndef RTL_SPU
    .in0   (`SPARC_CORE0.sparc0.lsu.lsu.qdp2.dfq_cpx_raw_wdata[127:0]),
    `else
    .in0   (`SPARC_CORE0.sparc0.lsu.qdp2.dfq_cpx_raw_wdata[127:0]),
    `endif


    .local (dfq_cpx_raw_wdata_local),
    .Dinv  (dfq_cpx_raw_wdata_Dinv),
    .Iinv  (dfq_cpx_raw_wdata_Iinv)
);



wire [`NUM_TILES-1:0] dfq_byp_ff_data_local;
reg  [`NUM_TILES-1:0] dfq_byp_ff_data_local_d1, dfq_byp_ff_data_local_d2;
wire [`NUM_TILES-1:0] dfq_byp_ff_data_Dinv;
reg  [`NUM_TILES-1:0] dfq_byp_ff_data_Dinv_d1, dfq_byp_ff_data_Dinv_d2;
wire [`NUM_TILES-1:0] dfq_byp_ff_data_Iinv;
reg  [`NUM_TILES-1:0] dfq_byp_ff_data_Iinv_d1, dfq_byp_ff_data_Iinv_d2;

always @(posedge clk) begin
    dfq_byp_ff_data_local_d1 <= dfq_byp_ff_data_local;
    dfq_byp_ff_data_local_d2 <= dfq_byp_ff_data_local_d1;
    dfq_byp_ff_data_Dinv_d1  <= dfq_byp_ff_data_Dinv;
    dfq_byp_ff_data_Dinv_d2  <= dfq_byp_ff_data_Dinv_d1;
    dfq_byp_ff_data_Iinv_d1  <= dfq_byp_ff_data_Iinv;
    dfq_byp_ff_data_Iinv_d2  <= dfq_byp_ff_data_Iinv_d1;
end

ack_evict_decode dfq_byp_ff_data_decode(

    `ifndef RTL_SPU
    .in0   (`SPARC_CORE0.sparc0.lsu.lsu.qdp2.dfq_byp_ff_data[127:0]),
    `else
    .in0   (`SPARC_CORE0.sparc0.lsu.qdp2.dfq_byp_ff_data[127:0]),
    `endif


    .local (dfq_byp_ff_data_local),
    .Dinv  (dfq_byp_ff_data_Dinv),
    .Iinv  (dfq_byp_ff_data_Iinv)
);

////////////////////////////////////////////////////////////////////////////////
// end mlim section 2
// (DO NOT place within the "for (8 = 0; 8 < 8; 8++) { ... }" section.)
////////////////////////////////////////////////////////////////////////////////

endmodule



module ack_evict_decode(in0, 

local, Dinv, Iinv);


input [127:0] in0;


output [`NUM_TILES-1:0]  local;
output [`NUM_TILES-1:0]  Dinv;
output [`NUM_TILES-1:0]  Iinv;


    assign local[0] = (in0[`CPX_CPUID_HI:`CPX_CPUID_LO] == 3'h0);
    assign Dinv[0]  = in0[0]  | in0[32] | in0[56] | in0[88] ;
    assign Iinv[0]  = in0[1]  | in0[57] ;



endmodule



module count12bits(in, out);

input  [11:0] in;
output [2:0]  out;
wire   [3:0]  count;

    assign count = ( in[0] + in[1] + in[2] + in[3] + in[4]  + in[5] +
                     in[6] + in[7] + in[8] + in[9] + in[10] + in[11] );

    assign out[0] = (count > 4'h0);
    assign out[1] = (count > 4'h1);
    assign out[2] = (count > 4'h2);

endmodule


