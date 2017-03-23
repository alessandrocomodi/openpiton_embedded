// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
//
// OpenSPARC T1 Processor File: lsu_mon.v
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
// lsu_mon.vpal
//
// Description: LSU Monitor for monitoring some coverage conditions
// 		as well as some checkers. Run pal to get .v
// 		like pal -r -o lsu_mon.v lsu_mon.vpal
////////////////////////////////////////////////////////

`include "cross_module.tmp.h"
`include "sys.h"
`include "iop.h"



module lsu_mon ( clk, rst_l);
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


//============================================================================================
`ifndef RTL_SPU
wire       spc0_dva_ren             = `SPARC_CORE0.sparc0.lsu.lsu.ifu_lsu_ld_inst_e;
wire       spc0_dva_wen             = `SPARC_CORE0.sparc0.lsu.lsu.lsu_dtagv_wr_vld_e;
wire       spc0_dva_din             = `SPARC_CORE0.sparc0.lsu.lsu.dva_din_e;
wire [`L1D_WAY_ARRAY_MASK] spc0_dva_dout            = `SPARC_CORE0.sparc0.lsu.lsu.dva_vld_m[`L1D_WAY_ARRAY_MASK];
wire [`L1D_ADDRESS_HI-4:0] spc0_dva_raddr           = `SPARC_CORE0.sparc0.lsu.lsu.exu_lsu_early_va_e[`L1D_ADDRESS_HI:4];
wire [4:0] spc0_dva_waddr           = `SPARC_CORE0.sparc0.lsu.lsu.dva_wr_adr_e[10:6];
wire       spc0_dva_dtag_perror     = `SPARC_CORE0.sparc0.lsu.lsu.lsu_cpx_ld_dtag_perror_e;
wire       spc0_dva_dcache_perror   = `SPARC_CORE0.sparc0.lsu.lsu.lsu_cpx_ld_dcache_perror_e;
wire       spc0_dva_inv_perror  = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_cpx_pkt_perror_dinv;
wire       spc0_ld_miss             = `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_ld_miss_wb;
reg        spc0_ld_miss_capture;

wire       spc0_atomic_g            = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.atomic_g;
wire [1:0] spc0_atm_type0   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.stb0_atm_rq_type[2:1];

wire [1:0] spc0_atm_type1   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.stb1_atm_rq_type[2:1];

wire [1:0] spc0_atm_type2   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.stb2_atm_rq_type[2:1];

wire [1:0] spc0_atm_type3   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.stb3_atm_rq_type[2:1];



wire [3:0] spc0_dctl_lsu_way_hit    = `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_way_hit;
wire       spc0_dctl_dcache_enable_g    = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_enable_g;
wire       spc0_dctl_ldxa_internal  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ldxa_internal;
wire       spc0_dctl_ldst_dbl_g     = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ldst_dbl_g;
wire       spc0_dctl_atomic_g   = `SPARC_CORE0.sparc0.lsu.lsu.dctl.atomic_g;
wire       spc0_dctl_stb_cam_hit    = `SPARC_CORE0.sparc0.lsu.lsu.dctl.stb_cam_hit;
wire       spc0_dctl_endian_mispred_g   = `SPARC_CORE0.sparc0.lsu.lsu.dctl.endian_mispred_g;
wire       spc0_dctl_dcache_rd_parity_error     = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_rd_parity_error;
wire       spc0_dctl_dtag_perror_g  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dtag_perror_g;
wire       spc0_dctl_tte_data_perror_unc    = `SPARC_CORE0.sparc0.lsu.lsu.dctl.tte_data_perror_unc;
wire       spc0_dctl_ld_inst_vld_g  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_g;
wire       spc0_dctl_lsu_alt_space_g    = `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_alt_space_g;
wire       spc0_dctl_recognized_asi_g   = `SPARC_CORE0.sparc0.lsu.lsu.dctl.recognized_asi_g;
wire       spc0_dctl_ncache_asild_rq_g  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ncache_asild_rq_g ;
wire       spc0_dctl_bld_hit;
wire       spc0_dctl_bld_stb_hit;
// interfaces
// ifu
wire       spc0_ixinv0  = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.imiss0_inv_en;
wire       spc0_ixinv1  = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.imiss1_inv_en;
wire       spc0_ixinv2  = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.imiss2_inv_en;
wire       spc0_ixinv3  = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.imiss3_inv_en;

wire       spc0_ifill  = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_ifill_pkt_vld ;
wire       spc0_inv  = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_cpx_spc_inv_vld ;
wire       spc0_inv_clr  = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.ifu_lsu_inv_clear;
wire       spc0_ibuf_busy  = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.ifu_lsu_ibuf_busy;
//exu

wire       spc0_l2  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.l2fill_vld_g ;
wire       spc0_unc  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.unc_err_trap_g ;
wire       spc0_fpld  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.l2fill_fpld_g ;
wire       spc0_fpldst  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.fp_ldst_g ;
wire       spc0_unflush  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ld_inst_vld_unflushed ;
wire       spc0_ldw  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_inst_vld_w ;
wire       spc0_byp  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.intld_byp_data_vld_m ;
wire       spc0_flsh  = `SPARC_CORE0.sparc0.lsu.lsu.lsu_exu_flush_pipe_w ;
wire       spc0_chm  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.common_ldst_miss_w ;
wire       spc0_ldxa  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ldxa_internal ;
wire       spc0_ato  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.atomic_g ;
wire       spc0_pref  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.pref_inst_g ;
wire       spc0_chit  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.stb_cam_hit ;
wire       spc0_dcp  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dcache_rd_parity_error ;
wire       spc0_dtp  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dtag_perror_g ;
//wire       spc0_mpc  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.tte_data_perror_corr_en ;
// Combine sanjay's change in lsu_mon.v hack 1.21 to 1.24
wire       spc0_mpc  = 1'b0;
wire       spc0_mpu  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.tte_data_perror_unc_en ;
`else
wire 	   spc0_dva_ren 	        = `SPARC_CORE0.sparc0.lsu.ifu_lsu_ld_inst_e;
wire 	   spc0_dva_wen 	        = `SPARC_CORE0.sparc0.lsu.lsu_dtagv_wr_vld_e;
wire 	   spc0_dva_din 	        = `SPARC_CORE0.sparc0.lsu.dva_din_e;
wire [`L1D_WAY_ARRAY_MASK] spc0_dva_dout 	        = `SPARC_CORE0.sparc0.lsu.dva_vld_m[`L1D_WAY_ARRAY_MASK];
wire [`L1D_ADDRESS_HI-4:0] spc0_dva_raddr 	        = `SPARC_CORE0.sparc0.lsu.exu_lsu_early_va_e[`L1D_ADDRESS_HI:4];
wire [4:0] spc0_dva_waddr 	        = `SPARC_CORE0.sparc0.lsu.dva_wr_adr_e[10:6];
wire       spc0_dva_dtag_perror 	= `SPARC_CORE0.sparc0.lsu.lsu_cpx_ld_dtag_perror_e;
wire       spc0_dva_dcache_perror 	= `SPARC_CORE0.sparc0.lsu.lsu_cpx_ld_dcache_perror_e;
wire       spc0_dva_inv_perror 	= `SPARC_CORE0.sparc0.lsu.qctl2.lsu_cpx_pkt_perror_dinv;
wire 	   spc0_ld_miss 	        = `SPARC_CORE0.sparc0.lsu.dctl.lsu_ld_miss_wb;
reg        spc0_ld_miss_capture;

wire 	   spc0_atomic_g 	        = `SPARC_CORE0.sparc0.lsu.qctl1.atomic_g;
wire [1:0] spc0_atm_type0 	= `SPARC_CORE0.sparc0.lsu.qctl1.stb0_atm_rq_type[2:1];

wire [1:0] spc0_atm_type1 	= `SPARC_CORE0.sparc0.lsu.qctl1.stb1_atm_rq_type[2:1];

wire [1:0] spc0_atm_type2 	= `SPARC_CORE0.sparc0.lsu.qctl1.stb2_atm_rq_type[2:1];

wire [1:0] spc0_atm_type3 	= `SPARC_CORE0.sparc0.lsu.qctl1.stb3_atm_rq_type[2:1];



wire [3:0] spc0_dctl_lsu_way_hit 	= `SPARC_CORE0.sparc0.lsu.dctl.lsu_way_hit;
wire       spc0_dctl_dcache_enable_g 	= `SPARC_CORE0.sparc0.lsu.dctl.dcache_enable_g;
wire       spc0_dctl_ldxa_internal 	= `SPARC_CORE0.sparc0.lsu.dctl.ldxa_internal;
wire       spc0_dctl_ldst_dbl_g 	= `SPARC_CORE0.sparc0.lsu.dctl.ldst_dbl_g;
wire       spc0_dctl_atomic_g 	= `SPARC_CORE0.sparc0.lsu.dctl.atomic_g;
wire       spc0_dctl_stb_cam_hit 	= `SPARC_CORE0.sparc0.lsu.dctl.stb_cam_hit;
wire       spc0_dctl_endian_mispred_g 	= `SPARC_CORE0.sparc0.lsu.dctl.endian_mispred_g;
wire       spc0_dctl_dcache_rd_parity_error 	= `SPARC_CORE0.sparc0.lsu.dctl.dcache_rd_parity_error;
wire       spc0_dctl_dtag_perror_g 	= `SPARC_CORE0.sparc0.lsu.dctl.dtag_perror_g;
wire       spc0_dctl_tte_data_perror_unc 	= `SPARC_CORE0.sparc0.lsu.dctl.tte_data_perror_unc;
wire       spc0_dctl_ld_inst_vld_g 	= `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_g;
wire       spc0_dctl_lsu_alt_space_g 	= `SPARC_CORE0.sparc0.lsu.dctl.lsu_alt_space_g;
wire       spc0_dctl_recognized_asi_g 	= `SPARC_CORE0.sparc0.lsu.dctl.recognized_asi_g;
wire       spc0_dctl_ncache_asild_rq_g  = `SPARC_CORE0.sparc0.lsu.dctl.ncache_asild_rq_g ;
wire       spc0_dctl_bld_hit;
wire       spc0_dctl_bld_stb_hit;
// interfaces
// ifu
wire       spc0_ixinv0  = `SPARC_CORE0.sparc0.lsu.qctl2.imiss0_inv_en;
wire       spc0_ixinv1  = `SPARC_CORE0.sparc0.lsu.qctl2.imiss1_inv_en;
wire       spc0_ixinv2  = `SPARC_CORE0.sparc0.lsu.qctl2.imiss2_inv_en;
wire       spc0_ixinv3  = `SPARC_CORE0.sparc0.lsu.qctl2.imiss3_inv_en;

wire       spc0_ifill  = `SPARC_CORE0.sparc0.lsu.qctl2.lsu_ifill_pkt_vld ;
wire       spc0_inv  = `SPARC_CORE0.sparc0.lsu.qctl2.lsu_cpx_spc_inv_vld ;
wire       spc0_inv_clr  = `SPARC_CORE0.sparc0.lsu.qctl2.ifu_lsu_inv_clear;
wire       spc0_ibuf_busy  = `SPARC_CORE0.sparc0.lsu.qctl2.ifu_lsu_ibuf_busy;
//exu

wire       spc0_l2  = `SPARC_CORE0.sparc0.lsu.dctl.l2fill_vld_g ;
wire       spc0_unc  = `SPARC_CORE0.sparc0.lsu.dctl.unc_err_trap_g ;
wire       spc0_fpld  = `SPARC_CORE0.sparc0.lsu.dctl.l2fill_fpld_g ;
wire       spc0_fpldst  = `SPARC_CORE0.sparc0.lsu.dctl.fp_ldst_g ;
wire       spc0_unflush  = `SPARC_CORE0.sparc0.lsu.dctl.ld_inst_vld_unflushed ;
wire       spc0_ldw  = `SPARC_CORE0.sparc0.lsu.dctl.lsu_inst_vld_w ;
wire       spc0_byp  = `SPARC_CORE0.sparc0.lsu.dctl.intld_byp_data_vld_m ;
wire       spc0_flsh  = `SPARC_CORE0.sparc0.lsu.lsu_exu_flush_pipe_w ;
wire       spc0_chm  = `SPARC_CORE0.sparc0.lsu.dctl.common_ldst_miss_w ;
wire       spc0_ldxa  = `SPARC_CORE0.sparc0.lsu.dctl.ldxa_internal ;
wire       spc0_ato  = `SPARC_CORE0.sparc0.lsu.dctl.atomic_g ;
wire       spc0_pref  = `SPARC_CORE0.sparc0.lsu.dctl.pref_inst_g ;
wire       spc0_chit  = `SPARC_CORE0.sparc0.lsu.dctl.stb_cam_hit ;
wire       spc0_dcp  = `SPARC_CORE0.sparc0.lsu.dctl.dcache_rd_parity_error ;
wire       spc0_dtp  = `SPARC_CORE0.sparc0.lsu.dctl.dtag_perror_g ;
//wire       spc0_mpc  = `SPARC_CORE0.sparc0.lsu.dctl.tte_data_perror_corr_en ;
// Combine sanjay's change in lsu_mon.v hack 1.21 to 1.24
wire       spc0_mpc  = 1'b0;
wire       spc0_mpu  = `SPARC_CORE0.sparc0.lsu.dctl.tte_data_perror_unc_en ;
`endif

wire [17:0] spc0_exu_und;
reg  [4:0] spc0_exu;

`ifndef RTL_SPU
// excptn
wire spc0_exp_wtchpt_trp_g                    = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_wtchpt_trp_g ;
wire spc0_exp_misalign_addr_ldst_atm_m         = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_misalign_addr_ldst_atm_m ;
wire spc0_exp_priv_violtn_g                    = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_priv_violtn_g;
wire spc0_exp_daccess_excptn_g                 = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_daccess_excptn_g;
wire spc0_exp_daccess_prot_g                   = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_daccess_prot_g;
wire spc0_exp_priv_action_g                    = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_priv_action_g;
wire spc0_exp_spec_access_epage_g              = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_spec_access_epage_g;
wire spc0_exp_uncache_atomic_g                 = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_uncache_atomic_g;
wire spc0_exp_illegal_asi_action_g             = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_illegal_asi_action_g;
wire spc0_exp_flt_ld_nfo_pg_g                  = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_flt_ld_nfo_pg_g;
// Combine sanjay's change in lsu_mon.v hack 1.21 to 1.24
// wire spc0_exp_asi_rd_unc                       = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_tlu_asi_rd_unc;
// wire spc0_exp_tlb_data_ce                     = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_ifu_tlb_data_ce ;
wire spc0_exp_asi_rd_unc                       = 1'b0;
wire spc0_exp_tlb_data_ce                     =  1'b0;

wire spc0_exp_tlb_data_ue                     = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_ifu_tlb_data_ue ;
wire spc0_exp_tlb_tag_ue                      = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.lsu_ifu_tlb_tag_ue ;
wire spc0_exp_unc                  = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.tte_data_perror_unc;
// Combine sanjay's change in lsu_mon.v hack 1.21 to 1.24
// wire spc0_exp_corr                 = `SPARC_CORE0.sparc0.lsu.lsu.excpctl.tte_data_perror_corr;
wire spc0_exp_corr                 = 1'b0;
wire [15:0] spc0_exp_und;
reg  [4:0] spc0_exp;
// dctl cmplt

wire       spc0_dctl_stxa_internal_d2  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.stxa_internal_d2;
wire       spc0_dctl_lsu_l2fill_vld  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_l2fill_vld;
wire       spc0_dctl_atomic_ld_squash_e  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.atomic_ld_squash_e;
wire       spc0_dctl_lsu_ignore_fill  = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.lsu_ignore_fill;
wire       spc0_dctl_l2fill_fpld_e  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.l2fill_fpld_e;
// wire       spc0_dctl_lsu_atm_st_cmplt_e  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_atm_st_cmplt_e;
wire       spc0_dctl_fill_err_trap_e  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.fill_err_trap_e;
wire       spc0_dctl_l2_corr_error_e  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.l2_corr_error_e;
wire [3:0] spc0_dctl_intld_byp_cmplt  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.intld_byp_cmplt;
wire [3:0] spc0_dctl_lsu_intrpt_cmplt  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_intrpt_cmplt;
wire [3:0] spc0_dctl_ldxa_illgl_va_cmplt_d1  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ldxa_illgl_va_cmplt_d1;
wire [3:0] spc0_dctl_pref_tlbmiss_cmplt_d2  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.pref_tlbmiss_cmplt_d2;
wire [3:0] spc0_dctl_lsu_pcx_pref_issue  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_pcx_pref_issue;
wire [3:0] spc0_dctl_lsu_ifu_ldst_cmplt  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.lsu_ifu_ldst_cmplt;
reg  [3:0] spc0_dctl_lsu_ifu_ldst_cmplt_d;
reg  [3:0] spc0_ldstcond_cmplt_d;

wire       spc0_qctl1_ld_sec_hit_thrd0  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld_sec_hit_thrd0;
wire       spc0_qctl1_ld0_inst_vld_g  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_inst_vld_g;
wire       spc0_ld0_pkt_vld_unmasked  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_pkt_vld_unmasked;
reg        spc0_ld0_pkt_vld_unmasked_d;
reg    spc0_qctl1_ld_sec_hit_thrd0_w2;

wire       spc0_dctl_thread0_w3  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.thread0_w3;
wire       spc0_dctl_dfill_thread0  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dfill_thread0;
wire       spc0_dctl_stxa_stall_wr_cmplt0_d1  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.stxa_stall_wr_cmplt0_d1;
wire       spc0_dctl_diag_wr_cmplt0  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.diag_wr_cmplt0;
wire       spc0_dctl_bsync0_reset  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.bsync0_reset;
wire       spc0_dctl_late_cmplt0  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ldst_cmplt_late_0_d1;
`else
// excptn
wire spc0_exp_wtchpt_trp_g                    = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_wtchpt_trp_g ;
wire spc0_exp_misalign_addr_ldst_atm_m         = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_misalign_addr_ldst_atm_m ;
wire spc0_exp_priv_violtn_g                    = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_priv_violtn_g;
wire spc0_exp_daccess_excptn_g                 = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_daccess_excptn_g;
wire spc0_exp_daccess_prot_g                   = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_daccess_prot_g;
wire spc0_exp_priv_action_g                    = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_priv_action_g;
wire spc0_exp_spec_access_epage_g              = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_spec_access_epage_g;
wire spc0_exp_uncache_atomic_g                 = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_uncache_atomic_g;
wire spc0_exp_illegal_asi_action_g             = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_illegal_asi_action_g;
wire spc0_exp_flt_ld_nfo_pg_g                  = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_flt_ld_nfo_pg_g;
// Combine sanjay's change in lsu_mon.v hack 1.21 to 1.24
// wire spc0_exp_asi_rd_unc                       = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_tlu_asi_rd_unc;
// wire spc0_exp_tlb_data_ce                     = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_ifu_tlb_data_ce ;
wire spc0_exp_asi_rd_unc                       = 1'b0;
wire spc0_exp_tlb_data_ce                     =  1'b0;

wire spc0_exp_tlb_data_ue                     = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_ifu_tlb_data_ue ;
wire spc0_exp_tlb_tag_ue                      = `SPARC_CORE0.sparc0.lsu.excpctl.lsu_ifu_tlb_tag_ue ;
wire spc0_exp_unc                  = `SPARC_CORE0.sparc0.lsu.excpctl.tte_data_perror_unc;
// Combine sanjay's change in lsu_mon.v hack 1.21 to 1.24
// wire spc0_exp_corr                 = `SPARC_CORE0.sparc0.lsu.excpctl.tte_data_perror_corr;
wire spc0_exp_corr                 = 1'b0;
wire [15:0] spc0_exp_und;
reg  [4:0] spc0_exp;
// dctl cmplt

wire       spc0_dctl_stxa_internal_d2  = `SPARC_CORE0.sparc0.lsu.dctl.stxa_internal_d2;
wire       spc0_dctl_lsu_l2fill_vld  = `SPARC_CORE0.sparc0.lsu.dctl.lsu_l2fill_vld;
wire       spc0_dctl_atomic_ld_squash_e  = `SPARC_CORE0.sparc0.lsu.dctl.atomic_ld_squash_e;
wire       spc0_dctl_lsu_ignore_fill  = `SPARC_CORE0.sparc0.lsu.qctl2.lsu_ignore_fill;
wire       spc0_dctl_l2fill_fpld_e  = `SPARC_CORE0.sparc0.lsu.dctl.l2fill_fpld_e;
// wire       spc0_dctl_lsu_atm_st_cmplt_e  = `SPARC_CORE0.sparc0.lsu.dctl.lsu_atm_st_cmplt_e;
wire       spc0_dctl_fill_err_trap_e  = `SPARC_CORE0.sparc0.lsu.dctl.fill_err_trap_e;
wire       spc0_dctl_l2_corr_error_e  = `SPARC_CORE0.sparc0.lsu.dctl.l2_corr_error_e;
wire [3:0] spc0_dctl_intld_byp_cmplt  = `SPARC_CORE0.sparc0.lsu.dctl.intld_byp_cmplt;
wire [3:0] spc0_dctl_lsu_intrpt_cmplt  = `SPARC_CORE0.sparc0.lsu.dctl.lsu_intrpt_cmplt;
wire [3:0] spc0_dctl_ldxa_illgl_va_cmplt_d1  = `SPARC_CORE0.sparc0.lsu.dctl.ldxa_illgl_va_cmplt_d1;
wire [3:0] spc0_dctl_pref_tlbmiss_cmplt_d2  = `SPARC_CORE0.sparc0.lsu.dctl.pref_tlbmiss_cmplt_d2;
wire [3:0] spc0_dctl_lsu_pcx_pref_issue  = `SPARC_CORE0.sparc0.lsu.dctl.lsu_pcx_pref_issue;
wire [3:0] spc0_dctl_lsu_ifu_ldst_cmplt  = `SPARC_CORE0.sparc0.lsu.dctl.lsu_ifu_ldst_cmplt;
reg  [3:0] spc0_dctl_lsu_ifu_ldst_cmplt_d;
reg  [3:0] spc0_ldstcond_cmplt_d;

wire       spc0_qctl1_ld_sec_hit_thrd0  = `SPARC_CORE0.sparc0.lsu.qctl1.ld_sec_hit_thrd0;
wire       spc0_qctl1_ld0_inst_vld_g  = `SPARC_CORE0.sparc0.lsu.qctl1.ld0_inst_vld_g;
wire       spc0_ld0_pkt_vld_unmasked  = `SPARC_CORE0.sparc0.lsu.qctl1.ld0_pkt_vld_unmasked;
reg        spc0_ld0_pkt_vld_unmasked_d;
reg	   spc0_qctl1_ld_sec_hit_thrd0_w2;

wire       spc0_dctl_thread0_w3  = `SPARC_CORE0.sparc0.lsu.dctl.thread0_w3;
wire       spc0_dctl_dfill_thread0  = `SPARC_CORE0.sparc0.lsu.dctl.dfill_thread0;
wire       spc0_dctl_stxa_stall_wr_cmplt0_d1  = `SPARC_CORE0.sparc0.lsu.dctl.stxa_stall_wr_cmplt0_d1;
wire       spc0_dctl_diag_wr_cmplt0  = `SPARC_CORE0.sparc0.lsu.dctl.diag_wr_cmplt0;
wire       spc0_dctl_bsync0_reset  = `SPARC_CORE0.sparc0.lsu.dctl.bsync0_reset;
wire       spc0_dctl_late_cmplt0  = `SPARC_CORE0.sparc0.lsu.dctl.ldst_cmplt_late_0_d1;
`endif
wire       spc0_dctl_stxa_cmplt0;
wire       spc0_dctl_l2fill_cmplt0;
wire       spc0_dctl_atm_cmplt0;
wire       spc0_dctl_fillerr0;
wire [4:0] spc0_cmplt0;
wire [5:0] spc0_dctl_ldst_cond_cmplt0;
reg  [3:0] spc0_ldstcond_cmplt0;
reg  [3:0] spc0_ldstcond_cmplt0_d;

`ifndef RTL_SPU
wire       spc0_qctl1_ld_sec_hit_thrd1  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld_sec_hit_thrd1;
wire       spc0_qctl1_ld1_inst_vld_g  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_inst_vld_g;
wire       spc0_ld1_pkt_vld_unmasked  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_pkt_vld_unmasked;
`else
wire       spc0_qctl1_ld_sec_hit_thrd1  = `SPARC_CORE0.sparc0.lsu.qctl1.ld_sec_hit_thrd1;
wire       spc0_qctl1_ld1_inst_vld_g  = `SPARC_CORE0.sparc0.lsu.qctl1.ld1_inst_vld_g;
wire       spc0_ld1_pkt_vld_unmasked  = `SPARC_CORE0.sparc0.lsu.qctl1.ld1_pkt_vld_unmasked;
`endif
reg        spc0_ld1_pkt_vld_unmasked_d;
reg	   spc0_qctl1_ld_sec_hit_thrd1_w2;

`ifndef RTL_SPU
wire       spc0_dctl_thread1_w3  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.thread1_w3;
wire       spc0_dctl_dfill_thread1  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dfill_thread1;
wire       spc0_dctl_stxa_stall_wr_cmplt1_d1  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.stxa_stall_wr_cmplt1_d1;
wire       spc0_dctl_diag_wr_cmplt1  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.diag_wr_cmplt1;
wire       spc0_dctl_bsync1_reset  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.bsync1_reset;
wire       spc0_dctl_late_cmplt1  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ldst_cmplt_late_1_d1;
`else
wire       spc0_dctl_thread1_w3  = `SPARC_CORE0.sparc0.lsu.dctl.thread1_w3;
wire       spc0_dctl_dfill_thread1  = `SPARC_CORE0.sparc0.lsu.dctl.dfill_thread1;
wire       spc0_dctl_stxa_stall_wr_cmplt1_d1  = `SPARC_CORE0.sparc0.lsu.dctl.stxa_stall_wr_cmplt1_d1;
wire       spc0_dctl_diag_wr_cmplt1  = `SPARC_CORE0.sparc0.lsu.dctl.diag_wr_cmplt1;
wire       spc0_dctl_bsync1_reset  = `SPARC_CORE0.sparc0.lsu.dctl.bsync1_reset;
wire       spc0_dctl_late_cmplt1  = `SPARC_CORE0.sparc0.lsu.dctl.ldst_cmplt_late_1_d1;
`endif
wire       spc0_dctl_stxa_cmplt1;
wire       spc0_dctl_l2fill_cmplt1;
wire       spc0_dctl_atm_cmplt1;
wire       spc0_dctl_fillerr1;
wire [4:0] spc0_cmplt1;
wire [5:0] spc0_dctl_ldst_cond_cmplt1;
reg  [3:0] spc0_ldstcond_cmplt1;
reg  [3:0] spc0_ldstcond_cmplt1_d;

`ifndef RTL_SPU
wire       spc0_qctl1_ld_sec_hit_thrd2  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld_sec_hit_thrd2;
wire       spc0_qctl1_ld2_inst_vld_g  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_inst_vld_g;
wire       spc0_ld2_pkt_vld_unmasked  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_pkt_vld_unmasked;
`else
wire       spc0_qctl1_ld_sec_hit_thrd2  = `SPARC_CORE0.sparc0.lsu.qctl1.ld_sec_hit_thrd2;
wire       spc0_qctl1_ld2_inst_vld_g  = `SPARC_CORE0.sparc0.lsu.qctl1.ld2_inst_vld_g;
wire       spc0_ld2_pkt_vld_unmasked  = `SPARC_CORE0.sparc0.lsu.qctl1.ld2_pkt_vld_unmasked;
`endif
reg        spc0_ld2_pkt_vld_unmasked_d;
reg	   spc0_qctl1_ld_sec_hit_thrd2_w2;

`ifndef RTL_SPU
wire       spc0_dctl_thread2_w3  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.thread2_w3;
wire       spc0_dctl_dfill_thread2  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dfill_thread2;
wire       spc0_dctl_stxa_stall_wr_cmplt2_d1  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.stxa_stall_wr_cmplt2_d1;
wire       spc0_dctl_diag_wr_cmplt2  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.diag_wr_cmplt2;
wire       spc0_dctl_bsync2_reset  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.bsync2_reset;
wire       spc0_dctl_late_cmplt2  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ldst_cmplt_late_2_d1;
`else
wire       spc0_dctl_thread2_w3  = `SPARC_CORE0.sparc0.lsu.dctl.thread2_w3;
wire       spc0_dctl_dfill_thread2  = `SPARC_CORE0.sparc0.lsu.dctl.dfill_thread2;
wire       spc0_dctl_stxa_stall_wr_cmplt2_d1  = `SPARC_CORE0.sparc0.lsu.dctl.stxa_stall_wr_cmplt2_d1;
wire       spc0_dctl_diag_wr_cmplt2  = `SPARC_CORE0.sparc0.lsu.dctl.diag_wr_cmplt2;
wire       spc0_dctl_bsync2_reset  = `SPARC_CORE0.sparc0.lsu.dctl.bsync2_reset;
wire       spc0_dctl_late_cmplt2  = `SPARC_CORE0.sparc0.lsu.dctl.ldst_cmplt_late_2_d1;
`endif
wire       spc0_dctl_stxa_cmplt2;
wire       spc0_dctl_l2fill_cmplt2;
wire       spc0_dctl_atm_cmplt2;
wire       spc0_dctl_fillerr2;
wire [4:0] spc0_cmplt2;
wire [5:0] spc0_dctl_ldst_cond_cmplt2;
reg  [3:0] spc0_ldstcond_cmplt2;
reg  [3:0] spc0_ldstcond_cmplt2_d;

`ifndef RTL_SPU
wire       spc0_qctl1_ld_sec_hit_thrd3  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld_sec_hit_thrd3;
wire       spc0_qctl1_ld3_inst_vld_g  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_inst_vld_g;
wire       spc0_ld3_pkt_vld_unmasked  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_pkt_vld_unmasked;
`else
wire       spc0_qctl1_ld_sec_hit_thrd3  = `SPARC_CORE0.sparc0.lsu.qctl1.ld_sec_hit_thrd3;
wire       spc0_qctl1_ld3_inst_vld_g  = `SPARC_CORE0.sparc0.lsu.qctl1.ld3_inst_vld_g;
wire       spc0_ld3_pkt_vld_unmasked  = `SPARC_CORE0.sparc0.lsu.qctl1.ld3_pkt_vld_unmasked;
`endif
reg        spc0_ld3_pkt_vld_unmasked_d;
reg	   spc0_qctl1_ld_sec_hit_thrd3_w2;

`ifndef RTL_SPU
wire       spc0_dctl_thread3_w3  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.thread3_w3;
wire       spc0_dctl_dfill_thread3  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.dfill_thread3;
wire       spc0_dctl_stxa_stall_wr_cmplt3_d1  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.stxa_stall_wr_cmplt3_d1;
wire       spc0_dctl_diag_wr_cmplt3  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.diag_wr_cmplt3;
wire       spc0_dctl_bsync3_reset  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.bsync3_reset;
wire       spc0_dctl_late_cmplt3  = `SPARC_CORE0.sparc0.lsu.lsu.dctl.ldst_cmplt_late_3_d1;
`else
wire       spc0_dctl_thread3_w3  = `SPARC_CORE0.sparc0.lsu.dctl.thread3_w3;
wire       spc0_dctl_dfill_thread3  = `SPARC_CORE0.sparc0.lsu.dctl.dfill_thread3;
wire       spc0_dctl_stxa_stall_wr_cmplt3_d1  = `SPARC_CORE0.sparc0.lsu.dctl.stxa_stall_wr_cmplt3_d1;
wire       spc0_dctl_diag_wr_cmplt3  = `SPARC_CORE0.sparc0.lsu.dctl.diag_wr_cmplt3;
wire       spc0_dctl_bsync3_reset  = `SPARC_CORE0.sparc0.lsu.dctl.bsync3_reset;
wire       spc0_dctl_late_cmplt3  = `SPARC_CORE0.sparc0.lsu.dctl.ldst_cmplt_late_3_d1;
`endif
wire       spc0_dctl_stxa_cmplt3;
wire       spc0_dctl_l2fill_cmplt3;
wire       spc0_dctl_atm_cmplt3;
wire       spc0_dctl_fillerr3;
wire [4:0] spc0_cmplt3;
wire [5:0] spc0_dctl_ldst_cond_cmplt3;
reg  [3:0] spc0_ldstcond_cmplt3;
reg  [3:0] spc0_ldstcond_cmplt3_d;

`ifndef RTL_SPU
wire       spc0_qctl1_bld_g     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.bld_g;
wire       spc0_qctl1_bld_reset     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.bld_reset;
wire [1:0] spc0_qctl1_bld_cnt   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.bld_cnt;
`else
wire       spc0_qctl1_bld_g 	= `SPARC_CORE0.sparc0.lsu.qctl1.bld_g;
wire       spc0_qctl1_bld_reset 	= `SPARC_CORE0.sparc0.lsu.qctl1.bld_reset;
wire [1:0] spc0_qctl1_bld_cnt 	= `SPARC_CORE0.sparc0.lsu.qctl1.bld_cnt;
`endif


reg  [9:0] spc0_bld0_full_cntr;
reg  [1:0] spc0_bld0_full_d;
reg 	   spc0_bld0_full_capture;
reg  [9:0] spc0_bld1_full_cntr;
reg  [1:0] spc0_bld1_full_d;
reg 	   spc0_bld1_full_capture;
reg  [9:0] spc0_bld2_full_cntr;
reg  [1:0] spc0_bld2_full_d;
reg 	   spc0_bld2_full_capture;
reg  [9:0] spc0_bld3_full_cntr;
reg  [1:0] spc0_bld3_full_d;
reg 	   spc0_bld3_full_capture;

`ifndef RTL_SPU
wire       spc0_ipick   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.imiss_pcx_rq_vld;
wire       spc0_lpick   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld_pcx_rq_all;
wire       spc0_spick   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st_pcx_rq_all;
wire       spc0_mpick   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.misc_pcx_rq_all;
wire [3:0] spc0_apick   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.all_pcx_rq_pick;
wire       spc0_msquash     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.mcycle_squash_d1;
`else
wire       spc0_ipick 	= `SPARC_CORE0.sparc0.lsu.qctl1.imiss_pcx_rq_vld;
wire       spc0_lpick 	= `SPARC_CORE0.sparc0.lsu.qctl1.ld_pcx_rq_all;
wire       spc0_spick 	= `SPARC_CORE0.sparc0.lsu.qctl1.st_pcx_rq_all;
wire       spc0_mpick 	= `SPARC_CORE0.sparc0.lsu.qctl1.misc_pcx_rq_all;
wire [3:0] spc0_apick 	= `SPARC_CORE0.sparc0.lsu.qctl1.all_pcx_rq_pick;
wire       spc0_msquash 	= `SPARC_CORE0.sparc0.lsu.qctl1.mcycle_squash_d1;
`endif

reg       spc0_fpicko;
wire [3:0] spc0_fpick;

`ifndef RTL_SPU
wire [39:0] spc0_imiss_pa   = `SPARC_CORE0.sparc0.lsu.lsu.ifu_lsu_pcxpkt_e[39:0];
wire       spc0_imiss_vld   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.imiss_pcx_rq_vld;
reg       spc0_imiss_vld_d;
wire [39:0] spc0_lmiss_pa0  = `SPARC_CORE0.sparc0.lsu.lsu.qdp1.lmq0_pcx_pkt[39:0];
wire       spc0_lmiss_vld0  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_pcx_rq_vld;
wire       spc0_ld_pkt_vld0     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_pkt_vld;
wire       spc0_st_pkt_vld0     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st0_pkt_vld;
`else
wire [39:0] spc0_imiss_pa 	= `SPARC_CORE0.sparc0.lsu.ifu_lsu_pcxpkt_e[39:0];
wire       spc0_imiss_vld 	= `SPARC_CORE0.sparc0.lsu.qctl1.imiss_pcx_rq_vld;
reg       spc0_imiss_vld_d;
wire [39:0] spc0_lmiss_pa0 	= `SPARC_CORE0.sparc0.lsu.qdp1.lmq0_pcx_pkt[39:0];
wire       spc0_lmiss_vld0 	= `SPARC_CORE0.sparc0.lsu.qctl1.ld0_pcx_rq_vld;
wire       spc0_ld_pkt_vld0 	= `SPARC_CORE0.sparc0.lsu.qctl1.ld0_pkt_vld;
wire       spc0_st_pkt_vld0 	= `SPARC_CORE0.sparc0.lsu.qctl1.st0_pkt_vld;
`endif

reg       spc0_lmiss_eq0;
reg             spc0_atm_imiss_eq0;
`ifndef RTL_SPU
wire [39:0] spc0_lmiss_pa1  = `SPARC_CORE0.sparc0.lsu.lsu.qdp1.lmq1_pcx_pkt[39:0];
wire       spc0_lmiss_vld1  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_pcx_rq_vld;
wire       spc0_ld_pkt_vld1     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_pkt_vld;
wire       spc0_st_pkt_vld1     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st1_pkt_vld;

reg       spc0_lmiss_eq1;
reg             spc0_atm_imiss_eq1;
wire [39:0] spc0_lmiss_pa2  = `SPARC_CORE0.sparc0.lsu.lsu.qdp1.lmq2_pcx_pkt[39:0];
wire       spc0_lmiss_vld2  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_pcx_rq_vld;
wire       spc0_ld_pkt_vld2     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_pkt_vld;
wire       spc0_st_pkt_vld2     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st2_pkt_vld;

reg       spc0_lmiss_eq2;
reg             spc0_atm_imiss_eq2;
wire [39:0] spc0_lmiss_pa3  = `SPARC_CORE0.sparc0.lsu.lsu.qdp1.lmq3_pcx_pkt[39:0];
wire       spc0_lmiss_vld3  = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_pcx_rq_vld;
wire       spc0_ld_pkt_vld3     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_pkt_vld;
wire       spc0_st_pkt_vld3     = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.st3_pkt_vld;
`else
wire [39:0] spc0_lmiss_pa1 	= `SPARC_CORE0.sparc0.lsu.qdp1.lmq1_pcx_pkt[39:0];
wire       spc0_lmiss_vld1 	= `SPARC_CORE0.sparc0.lsu.qctl1.ld1_pcx_rq_vld;
wire       spc0_ld_pkt_vld1 	= `SPARC_CORE0.sparc0.lsu.qctl1.ld1_pkt_vld;
wire       spc0_st_pkt_vld1 	= `SPARC_CORE0.sparc0.lsu.qctl1.st1_pkt_vld;

reg       spc0_lmiss_eq1;
reg             spc0_atm_imiss_eq1;
wire [39:0] spc0_lmiss_pa2 	= `SPARC_CORE0.sparc0.lsu.qdp1.lmq2_pcx_pkt[39:0];
wire       spc0_lmiss_vld2 	= `SPARC_CORE0.sparc0.lsu.qctl1.ld2_pcx_rq_vld;
wire       spc0_ld_pkt_vld2 	= `SPARC_CORE0.sparc0.lsu.qctl1.ld2_pkt_vld;
wire       spc0_st_pkt_vld2 	= `SPARC_CORE0.sparc0.lsu.qctl1.st2_pkt_vld;

reg       spc0_lmiss_eq2;
reg             spc0_atm_imiss_eq2;
wire [39:0] spc0_lmiss_pa3 	= `SPARC_CORE0.sparc0.lsu.qdp1.lmq3_pcx_pkt[39:0];
wire       spc0_lmiss_vld3 	= `SPARC_CORE0.sparc0.lsu.qctl1.ld3_pcx_rq_vld;
wire       spc0_ld_pkt_vld3 	= `SPARC_CORE0.sparc0.lsu.qctl1.ld3_pkt_vld;
wire       spc0_st_pkt_vld3 	= `SPARC_CORE0.sparc0.lsu.qctl1.st3_pkt_vld;
`endif

reg       spc0_lmiss_eq3;
reg             spc0_atm_imiss_eq3;

`ifndef RTL_SPU
wire [44:0] spc0_wdata_ramc = `SPARC_CORE0.sparc0.lsu.lsu.stb_cam.wdata_ramc;
wire        spc0_wptr_vld   = `SPARC_CORE0.sparc0.lsu.lsu.stb_cam.wptr_vld;
wire [75:0] spc0_wdata_ramd = {`SPARC_CORE0.sparc0.lsu.lsu.stb_wdata_ramd_b75_b64[75:64],`SPARC_CORE0.sparc0.lsu.lsu.lsu_stb_st_data_g[63:0]};

wire       spc0_stb_cam_hit             = `SPARC_CORE0.sparc0.lsu.lsu.stb_rwctl.stb_cam_hit;
wire [2:0] spc0_stb_cam_hit_ptr     = `SPARC_CORE0.sparc0.lsu.lsu.stb_rwctl.stb_cam_hit_ptr;
wire [7:0] spc0_stb_ld_full_raw = `SPARC_CORE0.sparc0.lsu.lsu.stb_ld_full_raw[7:0];
wire [7:0] spc0_stb_ld_partial_raw  = `SPARC_CORE0.sparc0.lsu.lsu.stb_ld_partial_raw[7:0];
wire       spc0_stb_cam_mhit        = `SPARC_CORE0.sparc0.lsu.lsu.stb_cam_mhit;

wire [3:0] spc0_dfq_vld_entries     = `SPARC_CORE0.sparc0.lsu.lsu.qctl2.dfq_vld_entries;
`else
wire [44:0]	spc0_wdata_ramc = `SPARC_CORE0.sparc0.lsu.stb_cam.wdata_ramc;
wire		spc0_wptr_vld   = `SPARC_CORE0.sparc0.lsu.stb_cam.wptr_vld;
wire [75:0]	spc0_wdata_ramd = {`SPARC_CORE0.sparc0.lsu.stb_wdata_ramd_b75_b64[75:64],`SPARC_CORE0.sparc0.lsu.lsu_stb_st_data_g[63:0]};

wire 	   spc0_stb_cam_hit 	        = `SPARC_CORE0.sparc0.lsu.stb_rwctl.stb_cam_hit;
wire [2:0] spc0_stb_cam_hit_ptr 	= `SPARC_CORE0.sparc0.lsu.stb_rwctl.stb_cam_hit_ptr;
wire [7:0] spc0_stb_ld_full_raw	= `SPARC_CORE0.sparc0.lsu.stb_ld_full_raw[7:0];
wire [7:0] spc0_stb_ld_partial_raw	= `SPARC_CORE0.sparc0.lsu.stb_ld_partial_raw[7:0];
wire       spc0_stb_cam_mhit		= `SPARC_CORE0.sparc0.lsu.stb_cam_mhit;

wire [3:0] spc0_dfq_vld_entries 	= `SPARC_CORE0.sparc0.lsu.qctl2.dfq_vld_entries;
`endif
wire 	   spc0_dfq_full;
reg  [9:0] spc0_dfq_full_cntr;
reg        spc0_dfq_full_d;
reg 	   spc0_dfq_full_capture;

reg  [9:0] spc0_dfq_full_cntr1;
reg        spc0_dfq_full_d1;
wire 	   spc0_dfq_full1;
reg 	   spc0_dfq_full_capture1;
reg  [9:0] spc0_dfq_full_cntr2;
reg        spc0_dfq_full_d2;
wire 	   spc0_dfq_full2;
reg 	   spc0_dfq_full_capture2;
reg  [9:0] spc0_dfq_full_cntr3;
reg        spc0_dfq_full_d3;
wire 	   spc0_dfq_full3;
reg 	   spc0_dfq_full_capture3;
reg  [9:0] spc0_dfq_full_cntr4;
reg        spc0_dfq_full_d4;
wire 	   spc0_dfq_full4;
reg 	   spc0_dfq_full_capture4;
reg  [9:0] spc0_dfq_full_cntr5;
reg        spc0_dfq_full_d5;
wire 	   spc0_dfq_full5;
reg 	   spc0_dfq_full_capture5;
reg  [9:0] spc0_dfq_full_cntr6;
reg        spc0_dfq_full_d6;
wire 	   spc0_dfq_full6;
reg 	   spc0_dfq_full_capture6;
reg  [9:0] spc0_dfq_full_cntr7;
reg        spc0_dfq_full_d7;
wire 	   spc0_dfq_full7;
reg 	   spc0_dfq_full_capture7;

wire 	   spc0_dva_rdwrhit;
reg  [9:0] spc0_dva_full_cntr;
reg        spc0_dva_full_d;
reg 	   spc0_dva_full_capture;
reg 	   spc0_dva_inv;
reg 	   spc0_dva_inv_d;
reg 	   spc0_dva_vld;
reg 	   spc0_dva_vld_d;
reg  [9:0] spc0_dva_vfull_cntr;
reg        spc0_dva_vfull_d;
reg 	   spc0_dva_vfull_capture;
reg        spc0_dva_collide;
reg        spc0_dva_vld2lkup;
reg        spc0_dva_invld2lkup;
reg        spc0_dva_invld_err;

reg  [9:0] spc0_dva_efull_cntr;
reg        spc0_dva_efull_d;

reg        spc0_dva_vlddtag_err;
reg        spc0_dva_vlddcache_err;
reg        spc0_dva_err;
reg [6:0] spc0_dva_raddr_d;
reg [4:0] spc0_dva_waddr_d;
reg [4:0] spc0_dva_invwaddr_d;

reg  	        spc0_ld0_lt_1;
reg  	        spc0_ld0_lt_2;
reg  	        spc0_ld0_lt_3;
reg  	        spc0_ld1_lt_0;
reg  	        spc0_ld1_lt_2;
reg  	        spc0_ld1_lt_3;
reg  	        spc0_ld2_lt_0;
reg  	        spc0_ld2_lt_1;
reg  	        spc0_ld2_lt_3;
reg  	        spc0_ld3_lt_0;
reg  	        spc0_ld3_lt_1;
reg  	        spc0_ld3_lt_2;

reg  	        spc0_st0_lt_1;
reg  	        spc0_st0_lt_2;
reg  	        spc0_st0_lt_3;
reg  	        spc0_st1_lt_0;
reg  	        spc0_st1_lt_2;
reg  	        spc0_st1_lt_3;
reg  	        spc0_st2_lt_0;
reg  	        spc0_st2_lt_1;
reg  	        spc0_st2_lt_3;
reg  	        spc0_st3_lt_0;
reg  	        spc0_st3_lt_1;
reg  	        spc0_st3_lt_2;

wire [11:0]      spc0_ld_ooo_ret;
wire [11:0]      spc0_st_ooo_ret;

`ifndef RTL_SPU
wire [7:0]  spc0_stb_state_vld0      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_vld;
wire [7:0]  spc0_stb_state_ack0      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_ack;
wire [7:0]  spc0_stb_state_ced0      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_ced;
wire [7:0]  spc0_stb_state_rst0      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_state_rst;
wire            spc0_stb_ack_vld0    = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.ack_vld;
wire            spc0_ld0_inst_vld_g      = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_inst_vld_g;
wire            spc0_intrpt0_cmplt   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.lsu_intrpt_cmplt[0];
wire            spc0_stb0_full           = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_full;
wire            spc0_stb0_full_w2    = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl0.stb_full_w2;
wire            spc0_lmq0_full           = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_pcx_rq_vld;
wire            spc0_mbar_vld0           = `SPARC_CORE0.sparc0.lsu.lsu.dctl.mbar_vld0;
wire            spc0_ld0_unfilled    = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld0_unfilled;
wire            spc0_flsh_vld0           = `SPARC_CORE0.sparc0.lsu.lsu.dctl.flsh_vld0;
`else
wire [7:0]	spc0_stb_state_vld0 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_vld;
wire [7:0]	spc0_stb_state_ack0 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_ack;
wire [7:0]	spc0_stb_state_ced0 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_ced;
wire [7:0]	spc0_stb_state_rst0 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_state_rst;
wire 	        spc0_stb_ack_vld0 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl0.ack_vld;
wire 	        spc0_ld0_inst_vld_g 	 = `SPARC_CORE0.sparc0.lsu.qctl1.ld0_inst_vld_g;
wire 	        spc0_intrpt0_cmplt 	 = `SPARC_CORE0.sparc0.lsu.qctl1.lsu_intrpt_cmplt[0];
wire 	        spc0_stb0_full 	         = `SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_full;
wire 	        spc0_stb0_full_w2 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl0.stb_full_w2;
wire 	        spc0_lmq0_full 	         = `SPARC_CORE0.sparc0.lsu.qctl1.ld0_pcx_rq_vld;
wire 	        spc0_mbar_vld0 	         = `SPARC_CORE0.sparc0.lsu.dctl.mbar_vld0;
wire 	        spc0_ld0_unfilled 	 = `SPARC_CORE0.sparc0.lsu.qctl1.ld0_unfilled;
wire 	        spc0_flsh_vld0	         = `SPARC_CORE0.sparc0.lsu.dctl.flsh_vld0;
`endif

reg  [9:0]	spc0_ld0_unf_cntr;
reg  	        spc0_ld0_unfilled_d;

reg  [9:0]	spc0_st0_unf_cntr;
reg  	        spc0_st0_unfilled_d;
reg  	        spc0_st0_unfilled;

reg 	        spc0_mbar_vld_d0;
reg 	        spc0_flsh_vld_d0;

reg 	        spc0_lmq0_full_d;
reg  [9:0]	spc0_lmq_full_cntr0;
reg             spc0_lmq_full_capture0;

reg  [9:0]	spc0_stb_full_cntr0;
reg 		spc0_stb_full_capture0;

reg  [9:0]	spc0_mbar_vld_cntr0;
reg 		spc0_mbar_vld_capture0;

reg  [9:0]	spc0_flsh_vld_cntr0;
reg 		spc0_flsh_vld_capture0;

reg 		spc0_stb_head_hit0;
wire 		spc0_raw_ack_capture0;
reg  [9:0]	spc0_stb_ack_cntr0;

reg  [9:0]	spc0_stb_ced_cntr0;
reg  	        spc0_stb_ced0_d;
reg  	        spc0_stb_ced_capture0;
wire  	        spc0_stb_ced0;

reg 	        spc0_atm0_d;
reg  [9:0]	spc0_atm_cntr0;
reg             spc0_atm_intrpt_capture0;
reg             spc0_atm_intrpt_b4capture0;
reg             spc0_atm_inv_capture0;


reg  [39:0]     spc0_stb_wr_addr0;
reg  [39:0]     spc0_stb_atm_addr0;
reg             spc0_atm_lmiss_eq0;
`ifndef RTL_SPU
wire [7:0]  spc0_stb_state_vld1      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_vld;
wire [7:0]  spc0_stb_state_ack1      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_ack;
wire [7:0]  spc0_stb_state_ced1      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_ced;
wire [7:0]  spc0_stb_state_rst1      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_state_rst;
wire            spc0_stb_ack_vld1    = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.ack_vld;
wire            spc0_ld1_inst_vld_g      = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_inst_vld_g;
wire            spc0_intrpt1_cmplt   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.lsu_intrpt_cmplt[1];
wire            spc0_stb1_full           = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_full;
wire            spc0_stb1_full_w2    = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl1.stb_full_w2;
wire            spc0_lmq1_full           = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_pcx_rq_vld;
wire            spc0_mbar_vld1           = `SPARC_CORE0.sparc0.lsu.lsu.dctl.mbar_vld1;
wire            spc0_ld1_unfilled    = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld1_unfilled;
wire            spc0_flsh_vld1           = `SPARC_CORE0.sparc0.lsu.lsu.dctl.flsh_vld1;
`else
wire [7:0]	spc0_stb_state_vld1 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_vld;
wire [7:0]	spc0_stb_state_ack1 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_ack;
wire [7:0]	spc0_stb_state_ced1 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_ced;
wire [7:0]	spc0_stb_state_rst1 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_state_rst;
wire 	        spc0_stb_ack_vld1 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl1.ack_vld;
wire 	        spc0_ld1_inst_vld_g 	 = `SPARC_CORE0.sparc0.lsu.qctl1.ld1_inst_vld_g;
wire 	        spc0_intrpt1_cmplt 	 = `SPARC_CORE0.sparc0.lsu.qctl1.lsu_intrpt_cmplt[1];
wire 	        spc0_stb1_full 	         = `SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_full;
wire 	        spc0_stb1_full_w2 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl1.stb_full_w2;
wire 	        spc0_lmq1_full 	         = `SPARC_CORE0.sparc0.lsu.qctl1.ld1_pcx_rq_vld;
wire 	        spc0_mbar_vld1 	         = `SPARC_CORE0.sparc0.lsu.dctl.mbar_vld1;
wire 	        spc0_ld1_unfilled 	 = `SPARC_CORE0.sparc0.lsu.qctl1.ld1_unfilled;
wire 	        spc0_flsh_vld1	         = `SPARC_CORE0.sparc0.lsu.dctl.flsh_vld1;
`endif

reg  [9:0]	spc0_ld1_unf_cntr;
reg  	        spc0_ld1_unfilled_d;

reg  [9:0]	spc0_st1_unf_cntr;
reg  	        spc0_st1_unfilled_d;
reg  	        spc0_st1_unfilled;

reg 	        spc0_mbar_vld_d1;
reg 	        spc0_flsh_vld_d1;

reg 	        spc0_lmq1_full_d;
reg  [9:0]	spc0_lmq_full_cntr1;
reg             spc0_lmq_full_capture1;

reg  [9:0]	spc0_stb_full_cntr1;
reg 		spc0_stb_full_capture1;

reg  [9:0]	spc0_mbar_vld_cntr1;
reg 		spc0_mbar_vld_capture1;

reg  [9:0]	spc0_flsh_vld_cntr1;
reg 		spc0_flsh_vld_capture1;

reg 		spc0_stb_head_hit1;
wire 		spc0_raw_ack_capture1;
reg  [9:0]	spc0_stb_ack_cntr1;

reg  [9:0]	spc0_stb_ced_cntr1;
reg  	        spc0_stb_ced1_d;
reg  	        spc0_stb_ced_capture1;
wire  	        spc0_stb_ced1;

reg 	        spc0_atm1_d;
reg  [9:0]	spc0_atm_cntr1;
reg             spc0_atm_intrpt_capture1;
reg             spc0_atm_intrpt_b4capture1;
reg             spc0_atm_inv_capture1;


reg  [39:0]     spc0_stb_wr_addr1;
reg  [39:0]     spc0_stb_atm_addr1;
reg             spc0_atm_lmiss_eq1;
`ifndef RTL_SPU
wire [7:0]  spc0_stb_state_vld2      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_vld;
wire [7:0]  spc0_stb_state_ack2      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_ack;
wire [7:0]  spc0_stb_state_ced2      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_ced;
wire [7:0]  spc0_stb_state_rst2      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_state_rst;
wire            spc0_stb_ack_vld2    = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.ack_vld;
wire            spc0_ld2_inst_vld_g      = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_inst_vld_g;
wire            spc0_intrpt2_cmplt   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.lsu_intrpt_cmplt[2];
wire            spc0_stb2_full           = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_full;
wire            spc0_stb2_full_w2    = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl2.stb_full_w2;
wire            spc0_lmq2_full           = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_pcx_rq_vld;
wire            spc0_mbar_vld2           = `SPARC_CORE0.sparc0.lsu.lsu.dctl.mbar_vld2;
wire            spc0_ld2_unfilled    = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld2_unfilled;
wire            spc0_flsh_vld2           = `SPARC_CORE0.sparc0.lsu.lsu.dctl.flsh_vld2;
`else
wire [7:0]	spc0_stb_state_vld2 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_vld;
wire [7:0]	spc0_stb_state_ack2 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_ack;
wire [7:0]	spc0_stb_state_ced2 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_ced;
wire [7:0]	spc0_stb_state_rst2 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_state_rst;
wire 	        spc0_stb_ack_vld2 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl2.ack_vld;
wire 	        spc0_ld2_inst_vld_g 	 = `SPARC_CORE0.sparc0.lsu.qctl1.ld2_inst_vld_g;
wire 	        spc0_intrpt2_cmplt 	 = `SPARC_CORE0.sparc0.lsu.qctl1.lsu_intrpt_cmplt[2];
wire 	        spc0_stb2_full 	         = `SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_full;
wire 	        spc0_stb2_full_w2 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl2.stb_full_w2;
wire 	        spc0_lmq2_full 	         = `SPARC_CORE0.sparc0.lsu.qctl1.ld2_pcx_rq_vld;
wire 	        spc0_mbar_vld2 	         = `SPARC_CORE0.sparc0.lsu.dctl.mbar_vld2;
wire 	        spc0_ld2_unfilled 	 = `SPARC_CORE0.sparc0.lsu.qctl1.ld2_unfilled;
wire 	        spc0_flsh_vld2	         = `SPARC_CORE0.sparc0.lsu.dctl.flsh_vld2;
`endif

reg  [9:0]	spc0_ld2_unf_cntr;
reg  	        spc0_ld2_unfilled_d;

reg  [9:0]	spc0_st2_unf_cntr;
reg  	        spc0_st2_unfilled_d;
reg  	        spc0_st2_unfilled;

reg 	        spc0_mbar_vld_d2;
reg 	        spc0_flsh_vld_d2;

reg 	        spc0_lmq2_full_d;
reg  [9:0]	spc0_lmq_full_cntr2;
reg             spc0_lmq_full_capture2;

reg  [9:0]	spc0_stb_full_cntr2;
reg 		spc0_stb_full_capture2;

reg  [9:0]	spc0_mbar_vld_cntr2;
reg 		spc0_mbar_vld_capture2;

reg  [9:0]	spc0_flsh_vld_cntr2;
reg 		spc0_flsh_vld_capture2;

reg 		spc0_stb_head_hit2;
wire 		spc0_raw_ack_capture2;
reg  [9:0]	spc0_stb_ack_cntr2;

reg  [9:0]	spc0_stb_ced_cntr2;
reg  	        spc0_stb_ced2_d;
reg  	        spc0_stb_ced_capture2;
wire  	        spc0_stb_ced2;

reg 	        spc0_atm2_d;
reg  [9:0]	spc0_atm_cntr2;
reg             spc0_atm_intrpt_capture2;
reg             spc0_atm_intrpt_b4capture2;
reg             spc0_atm_inv_capture2;


reg  [39:0]     spc0_stb_wr_addr2;
reg  [39:0]     spc0_stb_atm_addr2;
reg             spc0_atm_lmiss_eq2;
`ifndef RTL_SPU
wire [7:0]  spc0_stb_state_vld3      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_vld;
wire [7:0]  spc0_stb_state_ack3      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_ack;
wire [7:0]  spc0_stb_state_ced3      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_ced;
wire [7:0]  spc0_stb_state_rst3      = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_state_rst;
wire            spc0_stb_ack_vld3    = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.ack_vld;
wire            spc0_ld3_inst_vld_g      = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_inst_vld_g;
wire            spc0_intrpt3_cmplt   = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.lsu_intrpt_cmplt[3];
wire            spc0_stb3_full           = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_full;
wire            spc0_stb3_full_w2    = `SPARC_CORE0.sparc0.lsu.lsu.stb_ctl3.stb_full_w2;
wire            spc0_lmq3_full           = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_pcx_rq_vld;
wire            spc0_mbar_vld3           = `SPARC_CORE0.sparc0.lsu.lsu.dctl.mbar_vld3;
wire            spc0_ld3_unfilled    = `SPARC_CORE0.sparc0.lsu.lsu.qctl1.ld3_unfilled;
wire            spc0_flsh_vld3           = `SPARC_CORE0.sparc0.lsu.lsu.dctl.flsh_vld3;
`else
wire [7:0]	spc0_stb_state_vld3 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_vld;
wire [7:0]	spc0_stb_state_ack3 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_ack;
wire [7:0]	spc0_stb_state_ced3 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_ced;
wire [7:0]	spc0_stb_state_rst3 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_state_rst;
wire 	        spc0_stb_ack_vld3 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl3.ack_vld;
wire 	        spc0_ld3_inst_vld_g 	 = `SPARC_CORE0.sparc0.lsu.qctl1.ld3_inst_vld_g;
wire 	        spc0_intrpt3_cmplt 	 = `SPARC_CORE0.sparc0.lsu.qctl1.lsu_intrpt_cmplt[3];
wire 	        spc0_stb3_full 	         = `SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_full;
wire 	        spc0_stb3_full_w2 	 = `SPARC_CORE0.sparc0.lsu.stb_ctl3.stb_full_w2;
wire 	        spc0_lmq3_full 	         = `SPARC_CORE0.sparc0.lsu.qctl1.ld3_pcx_rq_vld;
wire 	        spc0_mbar_vld3 	         = `SPARC_CORE0.sparc0.lsu.dctl.mbar_vld3;
wire 	        spc0_ld3_unfilled 	 = `SPARC_CORE0.sparc0.lsu.qctl1.ld3_unfilled;
wire 	        spc0_flsh_vld3	         = `SPARC_CORE0.sparc0.lsu.dctl.flsh_vld3;
`endif

reg  [9:0]	spc0_ld3_unf_cntr;
reg  	        spc0_ld3_unfilled_d;

reg  [9:0]	spc0_st3_unf_cntr;
reg  	        spc0_st3_unfilled_d;
reg  	        spc0_st3_unfilled;

reg 	        spc0_mbar_vld_d3;
reg 	        spc0_flsh_vld_d3;

reg 	        spc0_lmq3_full_d;
reg  [9:0]	spc0_lmq_full_cntr3;
reg             spc0_lmq_full_capture3;

reg  [9:0]	spc0_stb_full_cntr3;
reg 		spc0_stb_full_capture3;

reg  [9:0]	spc0_mbar_vld_cntr3;
reg 		spc0_mbar_vld_capture3;

reg  [9:0]	spc0_flsh_vld_cntr3;
reg 		spc0_flsh_vld_capture3;

reg 		spc0_stb_head_hit3;
wire 		spc0_raw_ack_capture3;
reg  [9:0]	spc0_stb_ack_cntr3;

reg  [9:0]	spc0_stb_ced_cntr3;
reg  	        spc0_stb_ced3_d;
reg  	        spc0_stb_ced_capture3;
wire  	        spc0_stb_ced3;

reg 	        spc0_atm3_d;
reg  [9:0]	spc0_atm_cntr3;
reg             spc0_atm_intrpt_capture3;
reg             spc0_atm_intrpt_b4capture3;
reg             spc0_atm_inv_capture3;


reg  [39:0]     spc0_stb_wr_addr3;
reg  [39:0]     spc0_stb_atm_addr3;
reg             spc0_atm_lmiss_eq3;
// bug 3967
// The following bad_states needs to be added in lsu_mon.
// <   bad_state s_not_ipick (8'bxxx1xxx0);
// <   bad_state s_not_lpick (8'bxx10xx0x);
// <   bad_state s_not_spick (8'bx100x0xx);
// <   bad_state s_not_mpick (8'b10000xxx);

assign spc0_fpick = {spc0_mpick,spc0_spick,spc0_lpick,spc0_ipick};

// Sanjay mentioned, that the final picker is just
// priority encoded for i miss but ld/st/misc are round robin.
// At some point he as to communicate this thru either in a spec.
// or a mail.
always @(negedge clk)
begin
    if(rst_l)
     begin
       casex ({spc0_msquash,spc0_apick,spc0_fpick})
         9'b000000000 : spc0_fpicko = 1'b0;
         9'b0xxx1xxx1 : spc0_fpicko = 1'b0;
         9'b1xxxxxxxx : spc0_fpicko = 1'b0;
         9'b0xxx0xxx0 : spc0_fpicko = 1'b0;
	 default:
	  begin
		spc0_fpicko =  1'b1;
		$display("%0d ERROR: lsu_mon1 final picker imiss not picked", $time);
		repeat(100) @(posedge clk);
		$finish;
	  end
       endcase
     end
end

// interface
//exu
assign spc0_exu_und = {spc0_l2,
			  spc0_unc,
			  spc0_fpld,
			  spc0_fpldst,
			  spc0_unflush,
			  spc0_ldw,
			  spc0_byp,
			  spc0_flsh,
			  spc0_chm,
			  spc0_ldxa,
			  spc0_ato,
			  spc0_pref,
			  spc0_chit,
			  spc0_dcp,
			  spc0_dtp,
			  spc0_mpc,
			  spc0_mpu};

always @(spc0_exu_und)
begin
       case (spc0_exu_und)
         17'h00000 : spc0_exu =  5'h00;
         17'h00001 : spc0_exu =  5'h01;
         17'h00002 : spc0_exu =  5'h02;
         17'h00004 : spc0_exu =  5'h03;
         17'h00008 : spc0_exu =  5'h04;
         17'h00010 : spc0_exu =  5'h05;
         17'h00020 : spc0_exu =  5'h06;
         17'h00040 : spc0_exu =  5'h07;
         17'h00080 : spc0_exu =  5'h08;
         17'h00100 : spc0_exu =  5'h09;
         17'h00200 : spc0_exu =  5'h0a;
         17'h00400 : spc0_exu =  5'h0b;
         17'h00800 : spc0_exu =  5'h0c;
         17'h01000 : spc0_exu =  5'h0d;
         17'h02000 : spc0_exu =  5'h0e;
         17'h04000 : spc0_exu =  5'h0f;
         17'h08000 : spc0_exu =  5'h10;
         17'h10000 : spc0_exu =  5'h11;
	 default: spc0_exu =  5'h12;
       endcase
end
//excp
assign spc0_exp_und = {spc0_exp_wtchpt_trp_g,
			  spc0_exp_misalign_addr_ldst_atm_m,
			  spc0_exp_priv_violtn_g,
			  spc0_exp_daccess_excptn_g,
			  spc0_exp_daccess_prot_g,
			  spc0_exp_priv_action_g,
			  spc0_exp_spec_access_epage_g,
			  spc0_exp_uncache_atomic_g,
			  spc0_exp_illegal_asi_action_g,
			  spc0_exp_flt_ld_nfo_pg_g,
			  spc0_exp_asi_rd_unc,
			  spc0_exp_tlb_data_ce,
			  spc0_exp_tlb_data_ue,
			  spc0_exp_tlb_tag_ue,
			  spc0_exp_unc,
			  spc0_exp_corr};

always @(spc0_exp_und)
begin
       case (spc0_exp_und)
         16'h0000 : spc0_exp =  5'h00;
         16'h0001 : spc0_exp =  5'h01;
         16'h0002 : spc0_exp =  5'h02;
         16'h0004 : spc0_exp =  5'h03;
         16'h0008 : spc0_exp =  5'h04;
         16'h0010 : spc0_exp =  5'h05;
         16'h0020 : spc0_exp =  5'h06;
         16'h0040 : spc0_exp =  5'h07;
         16'h0080 : spc0_exp =  5'h08;
         16'h0100 : spc0_exp =  5'h09;
         16'h0200 : spc0_exp =  5'h0a;
         16'h0400 : spc0_exp =  5'h0b;
         16'h0800 : spc0_exp =  5'h0c;
         16'h1000 : spc0_exp =  5'h0d;
         16'h2000 : spc0_exp =  5'h0e;
         16'h4000 : spc0_exp =  5'h0f;
         16'h8000 : spc0_exp =  5'h10;
	 default: spc0_exp =  5'h11;
       endcase
end

//dctl cmplt compact
// Change for rtl timing fix :
// assign  lsu_ifu_ldst_cmplt[0] =
//     // * can be early or
//     ((stxa_internal_d2 & thread0_w3) | stxa_stall_wr_cmplt0_d1) |
//     // * late signal and critical.
//     // Can this be snapped earlier ?
//     (((l2fill_vld_e & ~atomic_ld_squash_e & ~ignore_fill))
//       & ~l2fill_fpld_e & ~lsu_cpx_pkt_ld_err[1] & dfill_thread0)  |// 1st fill for ldd.
//       //& ~l2fill_fpld_e & ~fill_err_trap_e & dfill_thread0)  |// 1st fill for ldd.
//     intld_byp_cmplt[0] |
//     // * early-or signals
//     ldst_cmplt_late_0_d1 ;
// assign	ldst_cmplt_late_0 =
//     (lsu_atm_st_cmplt_e & ~fill_err_trap_e & dfill_thread0) |
//     bsync0_reset    |
//     lsu_intrpt_cmplt[0]   |
//     diag_wr_cmplt0 |
//     dc0_diagnstc_rd_w2 |
//     ldxa_illgl_va_cmplt_d1[0] |
//     pref_tlbmiss_cmplt_d2[0] |
//     lsu_pcx_pref_issue[0];


assign spc0_dctl_stxa_cmplt0 = ((spc0_dctl_stxa_internal_d2 & spc0_dctl_thread0_w3) |
				       spc0_dctl_stxa_stall_wr_cmplt0_d1);
assign spc0_dctl_l2fill_cmplt0 = (((spc0_dctl_lsu_l2fill_vld & ~spc0_dctl_atomic_ld_squash_e &
					    ~spc0_dctl_lsu_ignore_fill)) & ~spc0_dctl_l2fill_fpld_e &
					  ~spc0_dctl_fill_err_trap_e & spc0_dctl_dfill_thread0);

assign spc0_dctl_fillerr0 = spc0_dctl_l2_corr_error_e & spc0_dctl_dfill_thread0;
// Rolling in changes due to bug 3624
// assign spc0_dctl_atm_cmplt0 = (spc0_dctl_lsu_atm_st_cmplt_e & ~spc0_dctl_fill_err_trap_e & spc0_dctl_dfill_thread0);

assign spc0_dctl_ldst_cond_cmplt0 = { spc0_dctl_stxa_cmplt0, spc0_dctl_l2fill_cmplt0,
					    spc0_dctl_atomic_ld_squash_e, spc0_dctl_intld_byp_cmplt[0],
					    spc0_dctl_bsync0_reset, spc0_dctl_lsu_intrpt_cmplt[0]
					     };

assign spc0_cmplt0 = { spc0_dctl_ldxa_illgl_va_cmplt_d1, spc0_dctl_pref_tlbmiss_cmplt_d2,
			      spc0_dctl_lsu_pcx_pref_issue, spc0_dctl_diag_wr_cmplt0, spc0_dctl_l2fill_fpld_e};


always @(spc0_cmplt0 or spc0_dctl_ldst_cond_cmplt0)
begin
       case ({spc0_dctl_fillerr0,spc0_dctl_ldst_cond_cmplt0,spc0_cmplt0})
         12'h000 : spc0_ldstcond_cmplt0 =  4'h0;
         12'h001 : spc0_ldstcond_cmplt0 =  4'h1; // fp
         12'h002 : spc0_ldstcond_cmplt0 =  4'h2; // dwr
         12'h004 : spc0_ldstcond_cmplt0 =  4'h3; // pref
         12'h008 : spc0_ldstcond_cmplt0 =  4'h4; // ptlb
         12'h010 : spc0_ldstcond_cmplt0 =  4'h5; // va
         12'h020 : spc0_ldstcond_cmplt0 =  4'h6; // intr
         12'h040 : spc0_ldstcond_cmplt0 =  4'h7; // bsyn
         12'h080 : spc0_ldstcond_cmplt0 =  4'h8; // intld
         12'h100 : spc0_ldstcond_cmplt0 =  4'h9; // atm
         12'h200 : spc0_ldstcond_cmplt0 =  4'ha; // l2
         12'h400 : spc0_ldstcond_cmplt0 =  4'hb; // stxa
         12'h800 : spc0_ldstcond_cmplt0 =  4'hc; // err
         12'ha00 : spc0_ldstcond_cmplt0 =  4'hd; // err & l2
	 default:
	   begin
		spc0_ldstcond_cmplt0 =  4'hd;
		// Got filter out fp ld and err and check one hot
	   end
       endcase
end


assign spc0_dctl_stxa_cmplt1 = ((spc0_dctl_stxa_internal_d2 & spc0_dctl_thread1_w3) |
				       spc0_dctl_stxa_stall_wr_cmplt1_d1);
assign spc0_dctl_l2fill_cmplt1 = (((spc0_dctl_lsu_l2fill_vld & ~spc0_dctl_atomic_ld_squash_e &
					    ~spc0_dctl_lsu_ignore_fill)) & ~spc0_dctl_l2fill_fpld_e &
					  ~spc0_dctl_fill_err_trap_e & spc0_dctl_dfill_thread1);

assign spc0_dctl_fillerr1 = spc0_dctl_l2_corr_error_e & spc0_dctl_dfill_thread1;
// Rolling in changes due to bug 3624
// assign spc0_dctl_atm_cmplt1 = (spc0_dctl_lsu_atm_st_cmplt_e & ~spc0_dctl_fill_err_trap_e & spc0_dctl_dfill_thread1);

assign spc0_dctl_ldst_cond_cmplt1 = { spc0_dctl_stxa_cmplt1, spc0_dctl_l2fill_cmplt1,
					    spc0_dctl_atomic_ld_squash_e, spc0_dctl_intld_byp_cmplt[1],
					    spc0_dctl_bsync1_reset, spc0_dctl_lsu_intrpt_cmplt[1]
					     };

assign spc0_cmplt1 = { spc0_dctl_ldxa_illgl_va_cmplt_d1, spc0_dctl_pref_tlbmiss_cmplt_d2,
			      spc0_dctl_lsu_pcx_pref_issue, spc0_dctl_diag_wr_cmplt1, spc0_dctl_l2fill_fpld_e};


always @(spc0_cmplt1 or spc0_dctl_ldst_cond_cmplt1)
begin
       case ({spc0_dctl_fillerr1,spc0_dctl_ldst_cond_cmplt1,spc0_cmplt1})
         12'h000 : spc0_ldstcond_cmplt1 =  4'h0;
         12'h001 : spc0_ldstcond_cmplt1 =  4'h1; // fp
         12'h002 : spc0_ldstcond_cmplt1 =  4'h2; // dwr
         12'h004 : spc0_ldstcond_cmplt1 =  4'h3; // pref
         12'h008 : spc0_ldstcond_cmplt1 =  4'h4; // ptlb
         12'h010 : spc0_ldstcond_cmplt1 =  4'h5; // va
         12'h020 : spc0_ldstcond_cmplt1 =  4'h6; // intr
         12'h040 : spc0_ldstcond_cmplt1 =  4'h7; // bsyn
         12'h080 : spc0_ldstcond_cmplt1 =  4'h8; // intld
         12'h100 : spc0_ldstcond_cmplt1 =  4'h9; // atm
         12'h200 : spc0_ldstcond_cmplt1 =  4'ha; // l2
         12'h400 : spc0_ldstcond_cmplt1 =  4'hb; // stxa
         12'h800 : spc0_ldstcond_cmplt1 =  4'hc; // err
         12'ha00 : spc0_ldstcond_cmplt1 =  4'hd; // err & l2
	 default:
	   begin
		spc0_ldstcond_cmplt1 =  4'hd;
		// Got filter out fp ld and err and check one hot
	   end
       endcase
end


assign spc0_dctl_stxa_cmplt2 = ((spc0_dctl_stxa_internal_d2 & spc0_dctl_thread2_w3) |
				       spc0_dctl_stxa_stall_wr_cmplt2_d1);
assign spc0_dctl_l2fill_cmplt2 = (((spc0_dctl_lsu_l2fill_vld & ~spc0_dctl_atomic_ld_squash_e &
					    ~spc0_dctl_lsu_ignore_fill)) & ~spc0_dctl_l2fill_fpld_e &
					  ~spc0_dctl_fill_err_trap_e & spc0_dctl_dfill_thread2);

assign spc0_dctl_fillerr2 = spc0_dctl_l2_corr_error_e & spc0_dctl_dfill_thread2;
// Rolling in changes due to bug 3624
// assign spc0_dctl_atm_cmplt2 = (spc0_dctl_lsu_atm_st_cmplt_e & ~spc0_dctl_fill_err_trap_e & spc0_dctl_dfill_thread2);

assign spc0_dctl_ldst_cond_cmplt2 = { spc0_dctl_stxa_cmplt2, spc0_dctl_l2fill_cmplt2,
					    spc0_dctl_atomic_ld_squash_e, spc0_dctl_intld_byp_cmplt[2],
					    spc0_dctl_bsync2_reset, spc0_dctl_lsu_intrpt_cmplt[2]
					     };

assign spc0_cmplt2 = { spc0_dctl_ldxa_illgl_va_cmplt_d1, spc0_dctl_pref_tlbmiss_cmplt_d2,
			      spc0_dctl_lsu_pcx_pref_issue, spc0_dctl_diag_wr_cmplt2, spc0_dctl_l2fill_fpld_e};


always @(spc0_cmplt2 or spc0_dctl_ldst_cond_cmplt2)
begin
       case ({spc0_dctl_fillerr2,spc0_dctl_ldst_cond_cmplt2,spc0_cmplt2})
         12'h000 : spc0_ldstcond_cmplt2 =  4'h0;
         12'h001 : spc0_ldstcond_cmplt2 =  4'h1; // fp
         12'h002 : spc0_ldstcond_cmplt2 =  4'h2; // dwr
         12'h004 : spc0_ldstcond_cmplt2 =  4'h3; // pref
         12'h008 : spc0_ldstcond_cmplt2 =  4'h4; // ptlb
         12'h010 : spc0_ldstcond_cmplt2 =  4'h5; // va
         12'h020 : spc0_ldstcond_cmplt2 =  4'h6; // intr
         12'h040 : spc0_ldstcond_cmplt2 =  4'h7; // bsyn
         12'h080 : spc0_ldstcond_cmplt2 =  4'h8; // intld
         12'h100 : spc0_ldstcond_cmplt2 =  4'h9; // atm
         12'h200 : spc0_ldstcond_cmplt2 =  4'ha; // l2
         12'h400 : spc0_ldstcond_cmplt2 =  4'hb; // stxa
         12'h800 : spc0_ldstcond_cmplt2 =  4'hc; // err
         12'ha00 : spc0_ldstcond_cmplt2 =  4'hd; // err & l2
	 default:
	   begin
		spc0_ldstcond_cmplt2 =  4'hd;
		// Got filter out fp ld and err and check one hot
	   end
       endcase
end


assign spc0_dctl_stxa_cmplt3 = ((spc0_dctl_stxa_internal_d2 & spc0_dctl_thread3_w3) |
				       spc0_dctl_stxa_stall_wr_cmplt3_d1);
assign spc0_dctl_l2fill_cmplt3 = (((spc0_dctl_lsu_l2fill_vld & ~spc0_dctl_atomic_ld_squash_e &
					    ~spc0_dctl_lsu_ignore_fill)) & ~spc0_dctl_l2fill_fpld_e &
					  ~spc0_dctl_fill_err_trap_e & spc0_dctl_dfill_thread3);

assign spc0_dctl_fillerr3 = spc0_dctl_l2_corr_error_e & spc0_dctl_dfill_thread3;
// Rolling in changes due to bug 3624
// assign spc0_dctl_atm_cmplt3 = (spc0_dctl_lsu_atm_st_cmplt_e & ~spc0_dctl_fill_err_trap_e & spc0_dctl_dfill_thread3);

assign spc0_dctl_ldst_cond_cmplt3 = { spc0_dctl_stxa_cmplt3, spc0_dctl_l2fill_cmplt3,
					    spc0_dctl_atomic_ld_squash_e, spc0_dctl_intld_byp_cmplt[3],
					    spc0_dctl_bsync3_reset, spc0_dctl_lsu_intrpt_cmplt[3]
					     };

assign spc0_cmplt3 = { spc0_dctl_ldxa_illgl_va_cmplt_d1, spc0_dctl_pref_tlbmiss_cmplt_d2,
			      spc0_dctl_lsu_pcx_pref_issue, spc0_dctl_diag_wr_cmplt3, spc0_dctl_l2fill_fpld_e};


always @(spc0_cmplt3 or spc0_dctl_ldst_cond_cmplt3)
begin
       case ({spc0_dctl_fillerr3,spc0_dctl_ldst_cond_cmplt3,spc0_cmplt3})
         12'h000 : spc0_ldstcond_cmplt3 =  4'h0;
         12'h001 : spc0_ldstcond_cmplt3 =  4'h1; // fp
         12'h002 : spc0_ldstcond_cmplt3 =  4'h2; // dwr
         12'h004 : spc0_ldstcond_cmplt3 =  4'h3; // pref
         12'h008 : spc0_ldstcond_cmplt3 =  4'h4; // ptlb
         12'h010 : spc0_ldstcond_cmplt3 =  4'h5; // va
         12'h020 : spc0_ldstcond_cmplt3 =  4'h6; // intr
         12'h040 : spc0_ldstcond_cmplt3 =  4'h7; // bsyn
         12'h080 : spc0_ldstcond_cmplt3 =  4'h8; // intld
         12'h100 : spc0_ldstcond_cmplt3 =  4'h9; // atm
         12'h200 : spc0_ldstcond_cmplt3 =  4'ha; // l2
         12'h400 : spc0_ldstcond_cmplt3 =  4'hb; // stxa
         12'h800 : spc0_ldstcond_cmplt3 =  4'hc; // err
         12'ha00 : spc0_ldstcond_cmplt3 =  4'hd; // err & l2
	 default:
	   begin
		spc0_ldstcond_cmplt3 =  4'hd;
		// Got filter out fp ld and err and check one hot
	   end
       endcase
end



always @(spc0_ldstcond_cmplt0 or spc0_ldstcond_cmplt1 or spc0_ldstcond_cmplt2
	 or spc0_ldstcond_cmplt3 or spc0_dctl_lsu_ifu_ldst_cmplt
	 or spc0_dctl_late_cmplt0 or spc0_dctl_late_cmplt1 or spc0_dctl_late_cmplt2 or spc0_dctl_late_cmplt3)
begin
       case (spc0_dctl_lsu_ifu_ldst_cmplt)
         4'b0000 : spc0_ldstcond_cmplt_d = 4'h0;
         4'b0001 : spc0_ldstcond_cmplt_d = spc0_dctl_late_cmplt0 ? spc0_ldstcond_cmplt0_d : spc0_ldstcond_cmplt0;
         4'b0010 : spc0_ldstcond_cmplt_d = spc0_dctl_late_cmplt1 ? spc0_ldstcond_cmplt1_d : spc0_ldstcond_cmplt1;
         4'b0100 : spc0_ldstcond_cmplt_d = spc0_dctl_late_cmplt2 ? spc0_ldstcond_cmplt2_d : spc0_ldstcond_cmplt2;
         4'b1000 : spc0_ldstcond_cmplt_d = spc0_dctl_late_cmplt3 ? spc0_ldstcond_cmplt3_d : spc0_ldstcond_cmplt3;
         4'b0011 : spc0_ldstcond_cmplt_d = 4'he;
         4'b0101 : spc0_ldstcond_cmplt_d = 4'he;
         4'b1001 : spc0_ldstcond_cmplt_d = 4'he;
         4'b0110 : spc0_ldstcond_cmplt_d = 4'he;
         4'b1010 : spc0_ldstcond_cmplt_d = 4'he;
         4'b1100 : spc0_ldstcond_cmplt_d = 4'he;
	 default:
	  	begin
			spc0_ldstcond_cmplt_d =  4'hf;
		end
       endcase
end


// st returns ooo
assign spc0_st_ooo_ret = { spc0_st0_lt_1, spc0_st0_lt_2, spc0_st0_lt_3,
			      spc0_st1_lt_0, spc0_st1_lt_2, spc0_st1_lt_3,
			      spc0_st2_lt_0, spc0_st2_lt_1, spc0_st2_lt_3,
			      spc0_st3_lt_0, spc0_st3_lt_1, spc0_st3_lt_2};

always @(posedge clk)
begin
    if(~spc0_st0_unfilled || ~rst_l)
      spc0_st0_unfilled_d <= 1'b0;
    else
      spc0_st0_unfilled_d <= spc0_st0_unfilled;

    if(~rst_l)
      spc0_ldstcond_cmplt0_d <= 4'h0;
    else
      spc0_ldstcond_cmplt0_d <= spc0_ldstcond_cmplt0;

    if(~spc0_ld0_pkt_vld_unmasked || ~rst_l)
      spc0_ld0_pkt_vld_unmasked_d <= 1'b0;
    else
      spc0_ld0_pkt_vld_unmasked_d <= spc0_ld0_pkt_vld_unmasked;

    if(~rst_l)
      spc0_qctl1_ld_sec_hit_thrd0_w2 <= 1'b0;
    else if(spc0_qctl1_ld_sec_hit_thrd0 && spc0_qctl1_ld0_inst_vld_g)
      spc0_qctl1_ld_sec_hit_thrd0_w2 <= 1'b1;
    else
      spc0_qctl1_ld_sec_hit_thrd0_w2 <= 1'b0;
    if(~spc0_st1_unfilled || ~rst_l)
      spc0_st1_unfilled_d <= 1'b0;
    else
      spc0_st1_unfilled_d <= spc0_st1_unfilled;

    if(~rst_l)
      spc0_ldstcond_cmplt1_d <= 4'h0;
    else
      spc0_ldstcond_cmplt1_d <= spc0_ldstcond_cmplt1;

    if(~spc0_ld1_pkt_vld_unmasked || ~rst_l)
      spc0_ld1_pkt_vld_unmasked_d <= 1'b0;
    else
      spc0_ld1_pkt_vld_unmasked_d <= spc0_ld1_pkt_vld_unmasked;

    if(~rst_l)
      spc0_qctl1_ld_sec_hit_thrd1_w2 <= 1'b0;
    else if(spc0_qctl1_ld_sec_hit_thrd1 && spc0_qctl1_ld1_inst_vld_g)
      spc0_qctl1_ld_sec_hit_thrd1_w2 <= 1'b1;
    else
      spc0_qctl1_ld_sec_hit_thrd1_w2 <= 1'b0;
    if(~spc0_st2_unfilled || ~rst_l)
      spc0_st2_unfilled_d <= 1'b0;
    else
      spc0_st2_unfilled_d <= spc0_st2_unfilled;

    if(~rst_l)
      spc0_ldstcond_cmplt2_d <= 4'h0;
    else
      spc0_ldstcond_cmplt2_d <= spc0_ldstcond_cmplt2;

    if(~spc0_ld2_pkt_vld_unmasked || ~rst_l)
      spc0_ld2_pkt_vld_unmasked_d <= 1'b0;
    else
      spc0_ld2_pkt_vld_unmasked_d <= spc0_ld2_pkt_vld_unmasked;

    if(~rst_l)
      spc0_qctl1_ld_sec_hit_thrd2_w2 <= 1'b0;
    else if(spc0_qctl1_ld_sec_hit_thrd2 && spc0_qctl1_ld2_inst_vld_g)
      spc0_qctl1_ld_sec_hit_thrd2_w2 <= 1'b1;
    else
      spc0_qctl1_ld_sec_hit_thrd2_w2 <= 1'b0;
    if(~spc0_st3_unfilled || ~rst_l)
      spc0_st3_unfilled_d <= 1'b0;
    else
      spc0_st3_unfilled_d <= spc0_st3_unfilled;

    if(~rst_l)
      spc0_ldstcond_cmplt3_d <= 4'h0;
    else
      spc0_ldstcond_cmplt3_d <= spc0_ldstcond_cmplt3;

    if(~spc0_ld3_pkt_vld_unmasked || ~rst_l)
      spc0_ld3_pkt_vld_unmasked_d <= 1'b0;
    else
      spc0_ld3_pkt_vld_unmasked_d <= spc0_ld3_pkt_vld_unmasked;

    if(~rst_l)
      spc0_qctl1_ld_sec_hit_thrd3_w2 <= 1'b0;
    else if(spc0_qctl1_ld_sec_hit_thrd3 && spc0_qctl1_ld3_inst_vld_g)
      spc0_qctl1_ld_sec_hit_thrd3_w2 <= 1'b1;
    else
      spc0_qctl1_ld_sec_hit_thrd3_w2 <= 1'b0;
end

always @(posedge clk)
begin
    if( ((|spc0_stb_state_ced0) && (|spc0_stb_state_rst0)) || ~rst_l)
      spc0_st0_unfilled <= 1'b0;
    else if( ((|spc0_stb_state_ced0) && ~(|spc0_stb_state_rst0)))
      spc0_st0_unfilled <= 1'b1;
    else
      spc0_st0_unfilled <= spc0_st0_unfilled;
    if( ((|spc0_stb_state_ced1) && (|spc0_stb_state_rst1)) || ~rst_l)
      spc0_st1_unfilled <= 1'b0;
    else if( ((|spc0_stb_state_ced1) && ~(|spc0_stb_state_rst1)))
      spc0_st1_unfilled <= 1'b1;
    else
      spc0_st1_unfilled <= spc0_st1_unfilled;
    if( ((|spc0_stb_state_ced2) && (|spc0_stb_state_rst2)) || ~rst_l)
      spc0_st2_unfilled <= 1'b0;
    else if( ((|spc0_stb_state_ced2) && ~(|spc0_stb_state_rst2)))
      spc0_st2_unfilled <= 1'b1;
    else
      spc0_st2_unfilled <= spc0_st2_unfilled;
    if( ((|spc0_stb_state_ced3) && (|spc0_stb_state_rst3)) || ~rst_l)
      spc0_st3_unfilled <= 1'b0;
    else if( ((|spc0_stb_state_ced3) && ~(|spc0_stb_state_rst3)))
      spc0_st3_unfilled <= 1'b1;
    else
      spc0_st3_unfilled <= spc0_st3_unfilled;
end

always @(posedge clk)
begin
    if((~spc0_st0_unfilled && spc0_st0_unfilled_d)|| ~rst_l)
      begin
        spc0_st0_unf_cntr <= 9'h000;
      end
    else if(spc0_st0_unfilled)
      begin
        spc0_st0_unf_cntr <= spc0_st0_unf_cntr + 1;
      end
    else
      begin
        spc0_st0_unf_cntr <= spc0_st0_unf_cntr;
      end
    if((~spc0_st1_unfilled && spc0_st1_unfilled_d)|| ~rst_l)
      begin
        spc0_st1_unf_cntr <= 9'h000;
      end
    else if(spc0_st1_unfilled)
      begin
        spc0_st1_unf_cntr <= spc0_st1_unf_cntr + 1;
      end
    else
      begin
        spc0_st1_unf_cntr <= spc0_st1_unf_cntr;
      end
    if((~spc0_st2_unfilled && spc0_st2_unfilled_d)|| ~rst_l)
      begin
        spc0_st2_unf_cntr <= 9'h000;
      end
    else if(spc0_st2_unfilled)
      begin
        spc0_st2_unf_cntr <= spc0_st2_unf_cntr + 1;
      end
    else
      begin
        spc0_st2_unf_cntr <= spc0_st2_unf_cntr;
      end
    if((~spc0_st3_unfilled && spc0_st3_unfilled_d)|| ~rst_l)
      begin
        spc0_st3_unf_cntr <= 9'h000;
      end
    else if(spc0_st3_unfilled)
      begin
        spc0_st3_unf_cntr <= spc0_st3_unf_cntr + 1;
      end
    else
      begin
        spc0_st3_unf_cntr <= spc0_st3_unf_cntr;
      end
end

always @(spc0_st0_unfilled or spc0_st1_unfilled or spc0_st2_unfilled or spc0_st3_unfilled
	 or spc0_st0_unfilled_d or spc0_st1_unfilled_d or spc0_st2_unfilled_d or spc0_st3_unfilled_d)
begin
if(~spc0_st0_unfilled && spc0_st0_unfilled_d && spc0_st1_unfilled)
 spc0_st0_lt_1 <= (spc0_st1_unf_cntr > spc0_st0_unf_cntr);
else
 spc0_st0_lt_1 <= 1'b0;
if(~spc0_st0_unfilled && spc0_st0_unfilled_d && spc0_st2_unfilled)
 spc0_st0_lt_2 <= (spc0_st2_unf_cntr > spc0_st0_unf_cntr);
else
 spc0_st0_lt_2 <= 1'b0;
if(~spc0_st0_unfilled && spc0_st0_unfilled_d && spc0_st3_unfilled)
 spc0_st0_lt_3 <= (spc0_st3_unf_cntr > spc0_st0_unf_cntr);
else
 spc0_st0_lt_3 <= 1'b0;
// get thr 1
if(~spc0_st1_unfilled && spc0_st1_unfilled_d && spc0_st0_unfilled)
 spc0_st1_lt_0 <= (spc0_st0_unf_cntr > spc0_st1_unf_cntr);
else
 spc0_st1_lt_0 <= 1'b0;
if(~spc0_st1_unfilled && spc0_st1_unfilled_d && spc0_st2_unfilled)
 spc0_st1_lt_2 <= (spc0_st2_unf_cntr > spc0_st1_unf_cntr);
else
 spc0_st1_lt_2 <= 1'b0;
if(~spc0_st1_unfilled && spc0_st1_unfilled_d && spc0_st3_unfilled)
 spc0_st1_lt_3 <= (spc0_st3_unf_cntr > spc0_st1_unf_cntr);
else
 spc0_st1_lt_3 <= 1'b0;
// get thr 2
if(~spc0_st2_unfilled && spc0_st2_unfilled_d && spc0_st0_unfilled)
 spc0_st2_lt_0 <= (spc0_st0_unf_cntr > spc0_st2_unf_cntr);
else
 spc0_st2_lt_0 <= 1'b0;
if(~spc0_st2_unfilled && spc0_st2_unfilled_d && spc0_st1_unfilled)
 spc0_st2_lt_1 <= (spc0_st1_unf_cntr > spc0_st2_unf_cntr);
else
 spc0_st2_lt_1 <= 1'b0;
if(~spc0_st2_unfilled && spc0_st2_unfilled_d && spc0_st3_unfilled)
 spc0_st2_lt_3 <= (spc0_st3_unf_cntr > spc0_st2_unf_cntr);
else
 spc0_st2_lt_3 <= 1'b0;
// get thr 3
if(~spc0_st3_unfilled && spc0_st3_unfilled_d && spc0_st0_unfilled)
 spc0_st3_lt_0 <= (spc0_st0_unf_cntr > spc0_st3_unf_cntr);
else
 spc0_st3_lt_0 <= 1'b0;
if(~spc0_st3_unfilled && spc0_st3_unfilled_d && spc0_st1_unfilled)
 spc0_st3_lt_1 <= (spc0_st1_unf_cntr > spc0_st3_unf_cntr);
else
 spc0_st3_lt_1 <= 1'b0;
if(~spc0_st3_unfilled && spc0_st3_unfilled_d && spc0_st2_unfilled)
 spc0_st3_lt_2 <= (spc0_st2_unf_cntr > spc0_st3_unf_cntr);
else
 spc0_st3_lt_2 <= 1'b0;				      //
end
// load returns ooo
assign spc0_ld_ooo_ret = { spc0_ld0_lt_1, spc0_ld0_lt_2, spc0_ld0_lt_3,
			      spc0_ld1_lt_0, spc0_ld1_lt_2, spc0_ld1_lt_3,
			      spc0_ld2_lt_0, spc0_ld2_lt_1, spc0_ld2_lt_3,
			      spc0_ld3_lt_0, spc0_ld3_lt_1, spc0_ld3_lt_2};
always @(posedge clk)
begin
    if((~spc0_ld0_unfilled && spc0_ld0_unfilled_d)|| ~rst_l)
      begin
        spc0_ld0_unf_cntr <= 9'h000;
      end
    else if(spc0_ld0_unfilled)
      begin
        spc0_ld0_unf_cntr <= spc0_ld0_unf_cntr + 1;
      end
    else
      begin
        spc0_ld0_unf_cntr <= spc0_ld0_unf_cntr;
      end
    if((~spc0_ld1_unfilled && spc0_ld1_unfilled_d)|| ~rst_l)
      begin
        spc0_ld1_unf_cntr <= 9'h000;
      end
    else if(spc0_ld1_unfilled)
      begin
        spc0_ld1_unf_cntr <= spc0_ld1_unf_cntr + 1;
      end
    else
      begin
        spc0_ld1_unf_cntr <= spc0_ld1_unf_cntr;
      end
    if((~spc0_ld2_unfilled && spc0_ld2_unfilled_d)|| ~rst_l)
      begin
        spc0_ld2_unf_cntr <= 9'h000;
      end
    else if(spc0_ld2_unfilled)
      begin
        spc0_ld2_unf_cntr <= spc0_ld2_unf_cntr + 1;
      end
    else
      begin
        spc0_ld2_unf_cntr <= spc0_ld2_unf_cntr;
      end
    if((~spc0_ld3_unfilled && spc0_ld3_unfilled_d)|| ~rst_l)
      begin
        spc0_ld3_unf_cntr <= 9'h000;
      end
    else if(spc0_ld3_unfilled)
      begin
        spc0_ld3_unf_cntr <= spc0_ld3_unf_cntr + 1;
      end
    else
      begin
        spc0_ld3_unf_cntr <= spc0_ld3_unf_cntr;
      end
end

always @(spc0_ld0_unfilled or spc0_ld1_unfilled or spc0_ld2_unfilled or spc0_ld3_unfilled
	 or spc0_ld0_unfilled_d or spc0_ld1_unfilled_d or spc0_ld2_unfilled_d or spc0_ld3_unfilled_d)
begin
if(~spc0_ld0_unfilled && spc0_ld0_unfilled_d && spc0_ld1_unfilled)
 spc0_ld0_lt_1 <= (spc0_ld1_unf_cntr > spc0_ld0_unf_cntr);
else
 spc0_ld0_lt_1 <= 1'b0;
if(~spc0_ld0_unfilled && spc0_ld0_unfilled_d && spc0_ld2_unfilled)
 spc0_ld0_lt_2 <= (spc0_ld2_unf_cntr > spc0_ld0_unf_cntr);
else
 spc0_ld0_lt_2 <= 1'b0;
if(~spc0_ld0_unfilled && spc0_ld0_unfilled_d && spc0_ld3_unfilled)
 spc0_ld0_lt_3 <= (spc0_ld3_unf_cntr > spc0_ld0_unf_cntr);
else
 spc0_ld0_lt_3 <= 1'b0;
// get thr 1
if(~spc0_ld1_unfilled && spc0_ld1_unfilled_d && spc0_ld0_unfilled)
 spc0_ld1_lt_0 <= (spc0_ld0_unf_cntr > spc0_ld1_unf_cntr);
else
 spc0_ld1_lt_0 <= 1'b0;
if(~spc0_ld1_unfilled && spc0_ld1_unfilled_d && spc0_ld2_unfilled)
 spc0_ld1_lt_2 <= (spc0_ld2_unf_cntr > spc0_ld1_unf_cntr);
else
 spc0_ld1_lt_2 <= 1'b0;
if(~spc0_ld1_unfilled && spc0_ld1_unfilled_d && spc0_ld3_unfilled)
 spc0_ld1_lt_3 <= (spc0_ld3_unf_cntr > spc0_ld1_unf_cntr);
else
 spc0_ld1_lt_3 <= 1'b0;
// get thr 2
if(~spc0_ld2_unfilled && spc0_ld2_unfilled_d && spc0_ld0_unfilled)
 spc0_ld2_lt_0 <= (spc0_ld0_unf_cntr > spc0_ld2_unf_cntr);
else
 spc0_ld2_lt_0 <= 1'b0;
if(~spc0_ld2_unfilled && spc0_ld2_unfilled_d && spc0_ld1_unfilled)
 spc0_ld2_lt_1 <= (spc0_ld1_unf_cntr > spc0_ld2_unf_cntr);
else
 spc0_ld2_lt_1 <= 1'b0;
if(~spc0_ld2_unfilled && spc0_ld2_unfilled_d && spc0_ld3_unfilled)
 spc0_ld2_lt_3 <= (spc0_ld3_unf_cntr > spc0_ld2_unf_cntr);
else
 spc0_ld2_lt_3 <= 1'b0;
// get thr 3
if(~spc0_ld3_unfilled && spc0_ld3_unfilled_d && spc0_ld0_unfilled)
 spc0_ld3_lt_0 <= (spc0_ld0_unf_cntr > spc0_ld3_unf_cntr);
else
 spc0_ld3_lt_0 <= 1'b0;
if(~spc0_ld3_unfilled && spc0_ld3_unfilled_d && spc0_ld1_unfilled)
 spc0_ld3_lt_1 <= (spc0_ld1_unf_cntr > spc0_ld3_unf_cntr);
else
 spc0_ld3_lt_1 <= 1'b0;
if(~spc0_ld3_unfilled && spc0_ld3_unfilled_d && spc0_ld2_unfilled)
 spc0_ld3_lt_2 <= (spc0_ld2_unf_cntr > spc0_ld3_unf_cntr);
else
 spc0_ld3_lt_2 <= 1'b0;				      //
end

// bld checks note it has stb_cam hit, ldst_dbl and asi terms removed from the dctl hit equation
assign spc0_dctl_bld_hit =
((|spc0_dctl_lsu_way_hit[3:0])  & spc0_dctl_dcache_enable_g &
  ~spc0_dctl_ldxa_internal & ~spc0_dctl_dcache_rd_parity_error & ~spc0_dctl_dtag_perror_g &
  ~spc0_dctl_endian_mispred_g &
  ~spc0_dctl_atomic_g & ~spc0_dctl_ncache_asild_rq_g) & ~spc0_dctl_tte_data_perror_unc &
  spc0_dctl_ld_inst_vld_g & spc0_qctl1_bld_g ;

assign spc0_dctl_bld_stb_hit = spc0_dctl_bld_hit & spc0_dctl_stb_cam_hit;

always @(posedge clk)
begin
    if(~rst_l)
     begin
      spc0_bld0_full_d <= 2'b00;
      spc0_ld0_unfilled_d <= 4'b0000;
     end
    else
     begin
      spc0_bld0_full_d <= spc0_qctl1_bld_cnt;
      spc0_ld0_unfilled_d <= spc0_ld0_unfilled;
     end
    if(~rst_l)
     begin
      spc0_bld1_full_d <= 2'b00;
      spc0_ld1_unfilled_d <= 4'b0000;
     end
    else
     begin
      spc0_bld1_full_d <= spc0_qctl1_bld_cnt;
      spc0_ld1_unfilled_d <= spc0_ld1_unfilled;
     end
    if(~rst_l)
     begin
      spc0_bld2_full_d <= 2'b00;
      spc0_ld2_unfilled_d <= 4'b0000;
     end
    else
     begin
      spc0_bld2_full_d <= spc0_qctl1_bld_cnt;
      spc0_ld2_unfilled_d <= spc0_ld2_unfilled;
     end
    if(~rst_l)
     begin
      spc0_bld3_full_d <= 2'b00;
      spc0_ld3_unfilled_d <= 4'b0000;
     end
    else
     begin
      spc0_bld3_full_d <= spc0_qctl1_bld_cnt;
      spc0_ld3_unfilled_d <= spc0_ld3_unfilled;
     end
end
always @(spc0_bld0_full_d or spc0_qctl1_bld_cnt)
begin
 if( (spc0_bld0_full_d != spc0_qctl1_bld_cnt) && (spc0_bld0_full_d == 2'd0))
    spc0_bld0_full_capture <= 1'b1;
 else
    spc0_bld0_full_capture <= 1'b0;
end
always @(spc0_bld1_full_d or spc0_qctl1_bld_cnt)
begin
 if( (spc0_bld1_full_d != spc0_qctl1_bld_cnt) && (spc0_bld1_full_d == 2'd1))
    spc0_bld1_full_capture <= 1'b1;
 else
    spc0_bld1_full_capture <= 1'b0;
end
always @(spc0_bld2_full_d or spc0_qctl1_bld_cnt)
begin
 if( (spc0_bld2_full_d != spc0_qctl1_bld_cnt) && (spc0_bld2_full_d == 2'd2))
    spc0_bld2_full_capture <= 1'b1;
 else
    spc0_bld2_full_capture <= 1'b0;
end
always @(spc0_bld3_full_d or spc0_qctl1_bld_cnt)
begin
 if( (spc0_bld3_full_d != spc0_qctl1_bld_cnt) && (spc0_bld3_full_d == 2'd3))
    spc0_bld3_full_capture <= 1'b1;
 else
    spc0_bld3_full_capture <= 1'b0;
end
always @(posedge clk)
begin
    if( ( (spc0_qctl1_bld_cnt != 2'b00) && (spc0_bld0_full_cntr != 9'h000))   || ~rst_l)
      begin
        spc0_bld0_full_cntr <= 9'h000;
      end
    else if(spc0_qctl1_bld_g && (spc0_qctl1_bld_cnt == 2'b00))
      begin
        spc0_bld0_full_cntr <= spc0_bld0_full_cntr + 1;
      end
    else if( (spc0_qctl1_bld_cnt == 2'b00) && (spc0_bld0_full_cntr != 9'h000))
      begin
        spc0_bld0_full_cntr <= spc0_bld0_full_cntr + 1;
      end
    else
      begin
        spc0_bld0_full_cntr <= spc0_bld0_full_cntr;
      end
end

always @(posedge clk)
begin
    if( ( (spc0_qctl1_bld_cnt != 2'b01) && (spc0_bld1_full_cntr != 9'h000))   || ~rst_l)
      begin
        spc0_bld1_full_cntr <= 9'h000;
      end
    else if(spc0_qctl1_bld_cnt == 2'b01)
      begin
        spc0_bld1_full_cntr <= spc0_bld1_full_cntr + 1;
      end
    else if( (spc0_qctl1_bld_cnt == 2'b01) && (spc0_bld1_full_cntr != 9'h000))
      begin
        spc0_bld1_full_cntr <= spc0_bld1_full_cntr + 1;
      end
    else
      begin
        spc0_bld1_full_cntr <= spc0_bld1_full_cntr;
      end
end


always @(posedge clk)
begin
    if( ( (spc0_qctl1_bld_cnt != 2'b10) && (spc0_bld2_full_cntr != 9'h000))   || ~rst_l)
      begin
        spc0_bld2_full_cntr <= 9'h000;
      end
    else if(spc0_qctl1_bld_cnt == 2'b10)
      begin
        spc0_bld2_full_cntr <= spc0_bld2_full_cntr + 1;
      end
    else if( (spc0_qctl1_bld_cnt == 2'b10) && (spc0_bld2_full_cntr != 9'h000))
      begin
        spc0_bld2_full_cntr <= spc0_bld2_full_cntr + 1;
      end
    else
      begin
        spc0_bld2_full_cntr <= spc0_bld2_full_cntr;
      end
end

always @(posedge clk)
begin
    if( ( (spc0_qctl1_bld_cnt != 2'b11) && (spc0_bld3_full_cntr != 9'h000))   || ~rst_l)
      begin
        spc0_bld3_full_cntr <= 9'h000;
      end
    else if(spc0_qctl1_bld_cnt == 2'b11)
      begin
        spc0_bld3_full_cntr <= spc0_bld3_full_cntr + 1;
      end
    else if( (spc0_qctl1_bld_cnt == 2'b11) && (spc0_bld3_full_cntr != 9'h000))
      begin
        spc0_bld3_full_cntr <= spc0_bld3_full_cntr + 1;
      end
    else
      begin
        spc0_bld3_full_cntr <= spc0_bld3_full_cntr;
      end
end

// Capture atomic address until it's retired
// Used for comparing colliding address
always @(posedge clk)
begin
    if( ( ~(|spc0_stb_state_vld0) && ~spc0_atomic_g) || ~rst_l)
      begin
        spc0_stb_atm_addr0 <= 40'h0000000000;
      end
    else if(spc0_atomic_g && (spc0_atm_type0 != 8'h00) && spc0_wptr_vld)
      begin
        spc0_stb_atm_addr0 <= {spc0_wdata_ramc[44:9],spc0_wdata_ramd[67:64]};
      end
    else
      begin
        spc0_stb_atm_addr0 <= spc0_stb_atm_addr0;
      end
    if( ( ~(|spc0_stb_state_vld1) && ~spc0_atomic_g) || ~rst_l)
      begin
        spc0_stb_atm_addr1 <= 40'h0000000000;
      end
    else if(spc0_atomic_g && (spc0_atm_type1 != 8'h00) && spc0_wptr_vld)
      begin
        spc0_stb_atm_addr1 <= {spc0_wdata_ramc[44:9],spc0_wdata_ramd[67:64]};
      end
    else
      begin
        spc0_stb_atm_addr1 <= spc0_stb_atm_addr1;
      end
    if( ( ~(|spc0_stb_state_vld2) && ~spc0_atomic_g) || ~rst_l)
      begin
        spc0_stb_atm_addr2 <= 40'h0000000000;
      end
    else if(spc0_atomic_g && (spc0_atm_type2 != 8'h00) && spc0_wptr_vld)
      begin
        spc0_stb_atm_addr2 <= {spc0_wdata_ramc[44:9],spc0_wdata_ramd[67:64]};
      end
    else
      begin
        spc0_stb_atm_addr2 <= spc0_stb_atm_addr2;
      end
    if( ( ~(|spc0_stb_state_vld3) && ~spc0_atomic_g) || ~rst_l)
      begin
        spc0_stb_atm_addr3 <= 40'h0000000000;
      end
    else if(spc0_atomic_g && (spc0_atm_type3 != 8'h00) && spc0_wptr_vld)
      begin
        spc0_stb_atm_addr3 <= {spc0_wdata_ramc[44:9],spc0_wdata_ramd[67:64]};
      end
    else
      begin
        spc0_stb_atm_addr3 <= spc0_stb_atm_addr3;
      end
end

 assign spc0_dfq_full = (spc0_dfq_vld_entries >= 3'd4);


assign spc0_dfq_full1 = (spc0_dfq_vld_entries >= (3'd4 + 1));

always @(spc0_dfq_full_d1 or spc0_dfq_full1)
begin
  if (spc0_dfq_full_d1 && ~spc0_dfq_full1)
    spc0_dfq_full_capture1 <= 1'b1;
  else
    spc0_dfq_full_capture1 <= 1'b0;
end

assign spc0_dfq_full2 = (spc0_dfq_vld_entries >= (3'd4 + 2));

always @(spc0_dfq_full_d2 or spc0_dfq_full2)
begin
  if (spc0_dfq_full_d2 && ~spc0_dfq_full2)
    spc0_dfq_full_capture2 <= 1'b1;
  else
    spc0_dfq_full_capture2 <= 1'b0;
end

assign spc0_dfq_full3 = (spc0_dfq_vld_entries >= (3'd4 + 3));

always @(spc0_dfq_full_d3 or spc0_dfq_full3)
begin
  if (spc0_dfq_full_d3 && ~spc0_dfq_full3)
    spc0_dfq_full_capture3 <= 1'b1;
  else
    spc0_dfq_full_capture3 <= 1'b0;
end

assign spc0_dfq_full4 = (spc0_dfq_vld_entries >= (3'd4 + 4));

always @(spc0_dfq_full_d4 or spc0_dfq_full4)
begin
  if (spc0_dfq_full_d4 && ~spc0_dfq_full4)
    spc0_dfq_full_capture4 <= 1'b1;
  else
    spc0_dfq_full_capture4 <= 1'b0;
end

assign spc0_dfq_full5 = (spc0_dfq_vld_entries >= (3'd4 + 5));

always @(spc0_dfq_full_d5 or spc0_dfq_full5)
begin
  if (spc0_dfq_full_d5 && ~spc0_dfq_full5)
    spc0_dfq_full_capture5 <= 1'b1;
  else
    spc0_dfq_full_capture5 <= 1'b0;
end

assign spc0_dfq_full6 = (spc0_dfq_vld_entries >= (3'd4 + 6));

always @(spc0_dfq_full_d6 or spc0_dfq_full6)
begin
  if (spc0_dfq_full_d6 && ~spc0_dfq_full6)
    spc0_dfq_full_capture6 <= 1'b1;
  else
    spc0_dfq_full_capture6 <= 1'b0;
end

assign spc0_dfq_full7 = (spc0_dfq_vld_entries >= (3'd4 + 7));

always @(spc0_dfq_full_d7 or spc0_dfq_full7)
begin
  if (spc0_dfq_full_d7 && ~spc0_dfq_full7)
    spc0_dfq_full_capture7 <= 1'b1;
  else
    spc0_dfq_full_capture7 <= 1'b0;
end

always @(spc0_mbar_vld_d0 or spc0_mbar_vld0)
begin
  if (spc0_mbar_vld_d0 && ~spc0_mbar_vld0)
    spc0_mbar_vld_capture0 <= 1'b1;
  else
    spc0_mbar_vld_capture0 <= 1'b0;
end
always @(spc0_mbar_vld_d1 or spc0_mbar_vld1)
begin
  if (spc0_mbar_vld_d1 && ~spc0_mbar_vld1)
    spc0_mbar_vld_capture1 <= 1'b1;
  else
    spc0_mbar_vld_capture1 <= 1'b0;
end
always @(spc0_mbar_vld_d2 or spc0_mbar_vld2)
begin
  if (spc0_mbar_vld_d2 && ~spc0_mbar_vld2)
    spc0_mbar_vld_capture2 <= 1'b1;
  else
    spc0_mbar_vld_capture2 <= 1'b0;
end
always @(spc0_mbar_vld_d3 or spc0_mbar_vld3)
begin
  if (spc0_mbar_vld_d3 && ~spc0_mbar_vld3)
    spc0_mbar_vld_capture3 <= 1'b1;
  else
    spc0_mbar_vld_capture3 <= 1'b0;
end



always @(posedge clk)
begin
    if( ( ~spc0_dfq_full1 && (spc0_dfq_full_cntr1 != 9'h000)) || ~rst_l)
      begin
       spc0_dfq_full_cntr1 <= 9'h000;
       spc0_dfq_full_d1 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_dfq_full_counter = %d", spc0_dfq_full_cntr1);
      end
    else if( spc0_dfq_full1)
      begin
       spc0_dfq_full_cntr1 <= spc0_dfq_full_cntr1 + 1;
       spc0_dfq_full_d1 <= spc0_dfq_full1;
      end
    else
      begin
       spc0_dfq_full_cntr1 <= spc0_dfq_full_cntr1;
       spc0_dfq_full_d1 <= spc0_dfq_full1;
      end
    if( ( ~spc0_dfq_full2 && (spc0_dfq_full_cntr2 != 9'h000)) || ~rst_l)
      begin
       spc0_dfq_full_cntr2 <= 9'h000;
       spc0_dfq_full_d2 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_dfq_full_counter = %d", spc0_dfq_full_cntr2);
      end
    else if( spc0_dfq_full2)
      begin
       spc0_dfq_full_cntr2 <= spc0_dfq_full_cntr2 + 1;
       spc0_dfq_full_d2 <= spc0_dfq_full2;
      end
    else
      begin
       spc0_dfq_full_cntr2 <= spc0_dfq_full_cntr2;
       spc0_dfq_full_d2 <= spc0_dfq_full2;
      end
    if( ( ~spc0_dfq_full3 && (spc0_dfq_full_cntr3 != 9'h000)) || ~rst_l)
      begin
       spc0_dfq_full_cntr3 <= 9'h000;
       spc0_dfq_full_d3 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_dfq_full_counter = %d", spc0_dfq_full_cntr3);
      end
    else if( spc0_dfq_full3)
      begin
       spc0_dfq_full_cntr3 <= spc0_dfq_full_cntr3 + 1;
       spc0_dfq_full_d3 <= spc0_dfq_full3;
      end
    else
      begin
       spc0_dfq_full_cntr3 <= spc0_dfq_full_cntr3;
       spc0_dfq_full_d3 <= spc0_dfq_full3;
      end
    if( ( ~spc0_dfq_full4 && (spc0_dfq_full_cntr4 != 9'h000)) || ~rst_l)
      begin
       spc0_dfq_full_cntr4 <= 9'h000;
       spc0_dfq_full_d4 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_dfq_full_counter = %d", spc0_dfq_full_cntr4);
      end
    else if( spc0_dfq_full4)
      begin
       spc0_dfq_full_cntr4 <= spc0_dfq_full_cntr4 + 1;
       spc0_dfq_full_d4 <= spc0_dfq_full4;
      end
    else
      begin
       spc0_dfq_full_cntr4 <= spc0_dfq_full_cntr4;
       spc0_dfq_full_d4 <= spc0_dfq_full4;
      end
    if( ( ~spc0_dfq_full5 && (spc0_dfq_full_cntr5 != 9'h000)) || ~rst_l)
      begin
       spc0_dfq_full_cntr5 <= 9'h000;
       spc0_dfq_full_d5 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_dfq_full_counter = %d", spc0_dfq_full_cntr5);
      end
    else if( spc0_dfq_full5)
      begin
       spc0_dfq_full_cntr5 <= spc0_dfq_full_cntr5 + 1;
       spc0_dfq_full_d5 <= spc0_dfq_full5;
      end
    else
      begin
       spc0_dfq_full_cntr5 <= spc0_dfq_full_cntr5;
       spc0_dfq_full_d5 <= spc0_dfq_full5;
      end
    if( ( ~spc0_dfq_full6 && (spc0_dfq_full_cntr6 != 9'h000)) || ~rst_l)
      begin
       spc0_dfq_full_cntr6 <= 9'h000;
       spc0_dfq_full_d6 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_dfq_full_counter = %d", spc0_dfq_full_cntr6);
      end
    else if( spc0_dfq_full6)
      begin
       spc0_dfq_full_cntr6 <= spc0_dfq_full_cntr6 + 1;
       spc0_dfq_full_d6 <= spc0_dfq_full6;
      end
    else
      begin
       spc0_dfq_full_cntr6 <= spc0_dfq_full_cntr6;
       spc0_dfq_full_d6 <= spc0_dfq_full6;
      end
    if( ( ~spc0_dfq_full7 && (spc0_dfq_full_cntr7 != 9'h000)) || ~rst_l)
      begin
       spc0_dfq_full_cntr7 <= 9'h000;
       spc0_dfq_full_d7 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_dfq_full_counter = %d", spc0_dfq_full_cntr7);
      end
    else if( spc0_dfq_full7)
      begin
       spc0_dfq_full_cntr7 <= spc0_dfq_full_cntr7 + 1;
       spc0_dfq_full_d7 <= spc0_dfq_full7;
      end
    else
      begin
       spc0_dfq_full_cntr7 <= spc0_dfq_full_cntr7;
       spc0_dfq_full_d7 <= spc0_dfq_full7;
      end
end // always @ (posedge clk)

//Capture b4 atomic is sent to pcx
always @(spc0_intrpt0_cmplt or spc0_atm_cntr0 or spc0_stb_state_ced0)
begin
  if (spc0_intrpt0_cmplt && (spc0_atm_cntr0 != 9'h000) && ~(|spc0_stb_state_ced0))
    spc0_atm_intrpt_b4capture0 <= 1'b1;
  else
    spc0_atm_intrpt_b4capture0 <= 1'b0;
end
always @(spc0_intrpt1_cmplt or spc0_atm_cntr1 or spc0_stb_state_ced1)
begin
  if (spc0_intrpt1_cmplt && (spc0_atm_cntr1 != 9'h000) && ~(|spc0_stb_state_ced1))
    spc0_atm_intrpt_b4capture1 <= 1'b1;
  else
    spc0_atm_intrpt_b4capture1 <= 1'b0;
end
always @(spc0_intrpt2_cmplt or spc0_atm_cntr2 or spc0_stb_state_ced2)
begin
  if (spc0_intrpt2_cmplt && (spc0_atm_cntr2 != 9'h000) && ~(|spc0_stb_state_ced2))
    spc0_atm_intrpt_b4capture2 <= 1'b1;
  else
    spc0_atm_intrpt_b4capture2 <= 1'b0;
end
always @(spc0_intrpt3_cmplt or spc0_atm_cntr3 or spc0_stb_state_ced3)
begin
  if (spc0_intrpt3_cmplt && (spc0_atm_cntr3 != 9'h000) && ~(|spc0_stb_state_ced3))
    spc0_atm_intrpt_b4capture3 <= 1'b1;
  else
    spc0_atm_intrpt_b4capture3 <= 1'b0;
end
//Capture after atomic is sent to pcx
always @(spc0_intrpt0_cmplt or spc0_atm_cntr0 or spc0_stb_state_ced0)
begin
  if (spc0_intrpt0_cmplt && (spc0_atm_cntr0 != 9'h000) && (|spc0_stb_state_ced0))
    spc0_atm_intrpt_capture0 <= 1'b1;
  else
    spc0_atm_intrpt_capture0 <= 1'b0;
end
always @(spc0_intrpt1_cmplt or spc0_atm_cntr1 or spc0_stb_state_ced1)
begin
  if (spc0_intrpt1_cmplt && (spc0_atm_cntr1 != 9'h000) && (|spc0_stb_state_ced1))
    spc0_atm_intrpt_capture1 <= 1'b1;
  else
    spc0_atm_intrpt_capture1 <= 1'b0;
end
always @(spc0_intrpt2_cmplt or spc0_atm_cntr2 or spc0_stb_state_ced2)
begin
  if (spc0_intrpt2_cmplt && (spc0_atm_cntr2 != 9'h000) && (|spc0_stb_state_ced2))
    spc0_atm_intrpt_capture2 <= 1'b1;
  else
    spc0_atm_intrpt_capture2 <= 1'b0;
end
always @(spc0_intrpt3_cmplt or spc0_atm_cntr3 or spc0_stb_state_ced3)
begin
  if (spc0_intrpt3_cmplt && (spc0_atm_cntr3 != 9'h000) && (|spc0_stb_state_ced3))
    spc0_atm_intrpt_capture3 <= 1'b1;
  else
    spc0_atm_intrpt_capture3 <= 1'b0;
end

//Capture after atomic is sent to pcx
always @(spc0_atm_cntr0 or spc0_dva_din or spc0_dva_wen)
begin
  if (~spc0_dva_din && spc0_dva_wen && (spc0_atm_cntr0 != 9'h000))
    spc0_atm_inv_capture0 <= 1'b1;
  else
    spc0_atm_inv_capture0 <= 1'b0;
end
always @(spc0_atm_cntr1 or spc0_dva_din or spc0_dva_wen)
begin
  if (~spc0_dva_din && spc0_dva_wen && (spc0_atm_cntr1 != 9'h000))
    spc0_atm_inv_capture1 <= 1'b1;
  else
    spc0_atm_inv_capture1 <= 1'b0;
end
always @(spc0_atm_cntr2 or spc0_dva_din or spc0_dva_wen)
begin
  if (~spc0_dva_din && spc0_dva_wen && (spc0_atm_cntr2 != 9'h000))
    spc0_atm_inv_capture2 <= 1'b1;
  else
    spc0_atm_inv_capture2 <= 1'b0;
end
always @(spc0_atm_cntr3 or spc0_dva_din or spc0_dva_wen)
begin
  if (~spc0_dva_din && spc0_dva_wen && (spc0_atm_cntr3 != 9'h000))
    spc0_atm_inv_capture3 <= 1'b1;
  else
    spc0_atm_inv_capture3 <= 1'b0;
end

always @(posedge clk)
begin
    if( ( ~(|spc0_stb_state_vld0) && (spc0_atm_cntr0 != 9'h000)) || ~rst_l)
      begin
       spc0_atm_cntr0 <= 9'h000;
       spc0_atm0_d <= 1'b0;
      end
    else if( spc0_atomic_g && (spc0_atm_type0 != 8'h00))
      begin
       spc0_atm_cntr0 <= spc0_atm_cntr0 + 1;
       spc0_atm0_d <= 1'b1;
      end
    else if( spc0_atm0_d && (|spc0_stb_state_vld0))
      begin
       spc0_atm_cntr0 <= spc0_atm_cntr0 + 1;
       spc0_atm0_d <= spc0_atm0_d;
      end
    else
      begin
       spc0_atm_cntr0 <= spc0_atm_cntr0;
       spc0_atm0_d <= spc0_atm0_d;
      end
    if( ( ~(|spc0_stb_state_vld1) && (spc0_atm_cntr1 != 9'h000)) || ~rst_l)
      begin
       spc0_atm_cntr1 <= 9'h000;
       spc0_atm1_d <= 1'b0;
      end
    else if( spc0_atomic_g && (spc0_atm_type1 != 8'h00))
      begin
       spc0_atm_cntr1 <= spc0_atm_cntr1 + 1;
       spc0_atm1_d <= 1'b1;
      end
    else if( spc0_atm1_d && (|spc0_stb_state_vld1))
      begin
       spc0_atm_cntr1 <= spc0_atm_cntr1 + 1;
       spc0_atm1_d <= spc0_atm1_d;
      end
    else
      begin
       spc0_atm_cntr1 <= spc0_atm_cntr1;
       spc0_atm1_d <= spc0_atm1_d;
      end
    if( ( ~(|spc0_stb_state_vld2) && (spc0_atm_cntr2 != 9'h000)) || ~rst_l)
      begin
       spc0_atm_cntr2 <= 9'h000;
       spc0_atm2_d <= 1'b0;
      end
    else if( spc0_atomic_g && (spc0_atm_type2 != 8'h00))
      begin
       spc0_atm_cntr2 <= spc0_atm_cntr2 + 1;
       spc0_atm2_d <= 1'b1;
      end
    else if( spc0_atm2_d && (|spc0_stb_state_vld2))
      begin
       spc0_atm_cntr2 <= spc0_atm_cntr2 + 1;
       spc0_atm2_d <= spc0_atm2_d;
      end
    else
      begin
       spc0_atm_cntr2 <= spc0_atm_cntr2;
       spc0_atm2_d <= spc0_atm2_d;
      end
    if( ( ~(|spc0_stb_state_vld3) && (spc0_atm_cntr3 != 9'h000)) || ~rst_l)
      begin
       spc0_atm_cntr3 <= 9'h000;
       spc0_atm3_d <= 1'b0;
      end
    else if( spc0_atomic_g && (spc0_atm_type3 != 8'h00))
      begin
       spc0_atm_cntr3 <= spc0_atm_cntr3 + 1;
       spc0_atm3_d <= 1'b1;
      end
    else if( spc0_atm3_d && (|spc0_stb_state_vld3))
      begin
       spc0_atm_cntr3 <= spc0_atm_cntr3 + 1;
       spc0_atm3_d <= spc0_atm3_d;
      end
    else
      begin
       spc0_atm_cntr3 <= spc0_atm_cntr3;
       spc0_atm3_d <= spc0_atm3_d;
      end
end

 assign spc0_raw_ack_capture0 = spc0_stb_ack_vld0 && (spc0_stb_ack_cntr0 != 9'h000);
 assign spc0_stb_ced0 = |spc0_stb_state_ced0;
 assign spc0_raw_ack_capture1 = spc0_stb_ack_vld1 && (spc0_stb_ack_cntr1 != 9'h000);
 assign spc0_stb_ced1 = |spc0_stb_state_ced1;
 assign spc0_raw_ack_capture2 = spc0_stb_ack_vld2 && (spc0_stb_ack_cntr2 != 9'h000);
 assign spc0_stb_ced2 = |spc0_stb_state_ced2;
 assign spc0_raw_ack_capture3 = spc0_stb_ack_vld3 && (spc0_stb_ack_cntr3 != 9'h000);
 assign spc0_stb_ced3 = |spc0_stb_state_ced3;

always @(posedge clk)
begin
    if( ( ~spc0_stb_ced0 && (spc0_stb_ced_cntr0 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_ced_cntr0 <= 9'h000;
       spc0_stb_ced0_d <= 1'b0;
      end
    else if( spc0_stb_ced0 && (spc0_stb_state_ack0 == 8'h00))
      begin
       spc0_stb_ced_cntr0 <= spc0_stb_ced_cntr0 + 1;
       spc0_stb_ced0_d <= spc0_stb_ced0;
      end
    else
      begin
       spc0_stb_ced_cntr0 <= spc0_stb_ced_cntr0;
       spc0_stb_ced0_d <= spc0_stb_ced0_d;
      end

    if( ( ~spc0_mbar_vld0 && (spc0_mbar_vld_cntr0 != 9'h000)) || ~rst_l)
      begin
       spc0_mbar_vld_cntr0 <= 9'h000;
       spc0_mbar_vld_d0 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_mbar_vld_counter = %d", spc0_mbar_vld_cntr0);
      end
    else if( spc0_mbar_vld0)
      begin
       spc0_mbar_vld_cntr0 <= spc0_mbar_vld_cntr0 + 1;
       spc0_mbar_vld_d0 <= spc0_mbar_vld0;
      end
    else
      begin
       spc0_mbar_vld_cntr0 <= spc0_mbar_vld_cntr0;
       spc0_mbar_vld_d0 <= spc0_mbar_vld0;
      end

    if( ( ~spc0_flsh_vld0 && (spc0_flsh_vld_cntr0 != 9'h000)) || ~rst_l)
      begin
       spc0_flsh_vld_cntr0 <= 9'h000;
       spc0_flsh_vld_d0 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_flsh_vld_counter = %d", spc0_flsh_vld_cntr0);
      end
    else if( spc0_flsh_vld0)
      begin
       spc0_flsh_vld_cntr0 <= spc0_flsh_vld_cntr0 + 1;
       spc0_flsh_vld_d0 <= spc0_flsh_vld0;
      end
    else
      begin
       spc0_flsh_vld_cntr0 <= spc0_flsh_vld_cntr0;
       spc0_flsh_vld_d0 <= spc0_flsh_vld0;
      end

    if( ( ~spc0_stb_ced1 && (spc0_stb_ced_cntr1 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_ced_cntr1 <= 9'h000;
       spc0_stb_ced1_d <= 1'b0;
      end
    else if( spc0_stb_ced1 && (spc0_stb_state_ack1 == 8'h00))
      begin
       spc0_stb_ced_cntr1 <= spc0_stb_ced_cntr1 + 1;
       spc0_stb_ced1_d <= spc0_stb_ced1;
      end
    else
      begin
       spc0_stb_ced_cntr1 <= spc0_stb_ced_cntr1;
       spc0_stb_ced1_d <= spc0_stb_ced1_d;
      end

    if( ( ~spc0_mbar_vld1 && (spc0_mbar_vld_cntr1 != 9'h000)) || ~rst_l)
      begin
       spc0_mbar_vld_cntr1 <= 9'h000;
       spc0_mbar_vld_d1 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_mbar_vld_counter = %d", spc0_mbar_vld_cntr1);
      end
    else if( spc0_mbar_vld1)
      begin
       spc0_mbar_vld_cntr1 <= spc0_mbar_vld_cntr1 + 1;
       spc0_mbar_vld_d1 <= spc0_mbar_vld1;
      end
    else
      begin
       spc0_mbar_vld_cntr1 <= spc0_mbar_vld_cntr1;
       spc0_mbar_vld_d1 <= spc0_mbar_vld1;
      end

    if( ( ~spc0_flsh_vld1 && (spc0_flsh_vld_cntr1 != 9'h000)) || ~rst_l)
      begin
       spc0_flsh_vld_cntr1 <= 9'h000;
       spc0_flsh_vld_d1 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_flsh_vld_counter = %d", spc0_flsh_vld_cntr1);
      end
    else if( spc0_flsh_vld1)
      begin
       spc0_flsh_vld_cntr1 <= spc0_flsh_vld_cntr1 + 1;
       spc0_flsh_vld_d1 <= spc0_flsh_vld1;
      end
    else
      begin
       spc0_flsh_vld_cntr1 <= spc0_flsh_vld_cntr1;
       spc0_flsh_vld_d1 <= spc0_flsh_vld1;
      end

    if( ( ~spc0_stb_ced2 && (spc0_stb_ced_cntr2 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_ced_cntr2 <= 9'h000;
       spc0_stb_ced2_d <= 1'b0;
      end
    else if( spc0_stb_ced2 && (spc0_stb_state_ack2 == 8'h00))
      begin
       spc0_stb_ced_cntr2 <= spc0_stb_ced_cntr2 + 1;
       spc0_stb_ced2_d <= spc0_stb_ced2;
      end
    else
      begin
       spc0_stb_ced_cntr2 <= spc0_stb_ced_cntr2;
       spc0_stb_ced2_d <= spc0_stb_ced2_d;
      end

    if( ( ~spc0_mbar_vld2 && (spc0_mbar_vld_cntr2 != 9'h000)) || ~rst_l)
      begin
       spc0_mbar_vld_cntr2 <= 9'h000;
       spc0_mbar_vld_d2 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_mbar_vld_counter = %d", spc0_mbar_vld_cntr2);
      end
    else if( spc0_mbar_vld2)
      begin
       spc0_mbar_vld_cntr2 <= spc0_mbar_vld_cntr2 + 1;
       spc0_mbar_vld_d2 <= spc0_mbar_vld2;
      end
    else
      begin
       spc0_mbar_vld_cntr2 <= spc0_mbar_vld_cntr2;
       spc0_mbar_vld_d2 <= spc0_mbar_vld2;
      end

    if( ( ~spc0_flsh_vld2 && (spc0_flsh_vld_cntr2 != 9'h000)) || ~rst_l)
      begin
       spc0_flsh_vld_cntr2 <= 9'h000;
       spc0_flsh_vld_d2 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_flsh_vld_counter = %d", spc0_flsh_vld_cntr2);
      end
    else if( spc0_flsh_vld2)
      begin
       spc0_flsh_vld_cntr2 <= spc0_flsh_vld_cntr2 + 1;
       spc0_flsh_vld_d2 <= spc0_flsh_vld2;
      end
    else
      begin
       spc0_flsh_vld_cntr2 <= spc0_flsh_vld_cntr2;
       spc0_flsh_vld_d2 <= spc0_flsh_vld2;
      end

    if( ( ~spc0_stb_ced3 && (spc0_stb_ced_cntr3 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_ced_cntr3 <= 9'h000;
       spc0_stb_ced3_d <= 1'b0;
      end
    else if( spc0_stb_ced3 && (spc0_stb_state_ack3 == 8'h00))
      begin
       spc0_stb_ced_cntr3 <= spc0_stb_ced_cntr3 + 1;
       spc0_stb_ced3_d <= spc0_stb_ced3;
      end
    else
      begin
       spc0_stb_ced_cntr3 <= spc0_stb_ced_cntr3;
       spc0_stb_ced3_d <= spc0_stb_ced3_d;
      end

    if( ( ~spc0_mbar_vld3 && (spc0_mbar_vld_cntr3 != 9'h000)) || ~rst_l)
      begin
       spc0_mbar_vld_cntr3 <= 9'h000;
       spc0_mbar_vld_d3 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_mbar_vld_counter = %d", spc0_mbar_vld_cntr3);
      end
    else if( spc0_mbar_vld3)
      begin
       spc0_mbar_vld_cntr3 <= spc0_mbar_vld_cntr3 + 1;
       spc0_mbar_vld_d3 <= spc0_mbar_vld3;
      end
    else
      begin
       spc0_mbar_vld_cntr3 <= spc0_mbar_vld_cntr3;
       spc0_mbar_vld_d3 <= spc0_mbar_vld3;
      end

    if( ( ~spc0_flsh_vld3 && (spc0_flsh_vld_cntr3 != 9'h000)) || ~rst_l)
      begin
       spc0_flsh_vld_cntr3 <= 9'h000;
       spc0_flsh_vld_d3 <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_flsh_vld_counter = %d", spc0_flsh_vld_cntr3);
      end
    else if( spc0_flsh_vld3)
      begin
       spc0_flsh_vld_cntr3 <= spc0_flsh_vld_cntr3 + 1;
       spc0_flsh_vld_d3 <= spc0_flsh_vld3;
      end
    else
      begin
       spc0_flsh_vld_cntr3 <= spc0_flsh_vld_cntr3;
       spc0_flsh_vld_d3 <= spc0_flsh_vld3;
      end

end

always @(spc0_flsh_vld_d0 or spc0_flsh_vld0)
begin
  if (spc0_flsh_vld_d0 && ~spc0_flsh_vld0)
    spc0_flsh_vld_capture0 <= 1'b1;
  else
    spc0_flsh_vld_capture0 <= 1'b0;
end
always @(spc0_flsh_vld_d1 or spc0_flsh_vld1)
begin
  if (spc0_flsh_vld_d1 && ~spc0_flsh_vld1)
    spc0_flsh_vld_capture1 <= 1'b1;
  else
    spc0_flsh_vld_capture1 <= 1'b0;
end
always @(spc0_flsh_vld_d2 or spc0_flsh_vld2)
begin
  if (spc0_flsh_vld_d2 && ~spc0_flsh_vld2)
    spc0_flsh_vld_capture2 <= 1'b1;
  else
    spc0_flsh_vld_capture2 <= 1'b0;
end
always @(spc0_flsh_vld_d3 or spc0_flsh_vld3)
begin
  if (spc0_flsh_vld_d3 && ~spc0_flsh_vld3)
    spc0_flsh_vld_capture3 <= 1'b1;
  else
    spc0_flsh_vld_capture3 <= 1'b0;
end

always @(spc0_lmiss_pa0 or spc0_imiss_pa or spc0_imiss_vld_d or spc0_lmiss_vld0)
begin
if((spc0_lmiss_pa0 == spc0_imiss_pa) && spc0_imiss_vld_d && spc0_lmiss_vld0)
 spc0_lmiss_eq0 = 1'b1;
else
 spc0_lmiss_eq0 = 1'b0;
end
always @(spc0_lmiss_pa1 or spc0_imiss_pa or spc0_imiss_vld_d or spc0_lmiss_vld1)
begin
if((spc0_lmiss_pa1 == spc0_imiss_pa) && spc0_imiss_vld_d && spc0_lmiss_vld1)
 spc0_lmiss_eq1 = 1'b1;
else
 spc0_lmiss_eq1 = 1'b0;
end
always @(spc0_lmiss_pa2 or spc0_imiss_pa or spc0_imiss_vld_d or spc0_lmiss_vld2)
begin
if((spc0_lmiss_pa2 == spc0_imiss_pa) && spc0_imiss_vld_d && spc0_lmiss_vld2)
 spc0_lmiss_eq2 = 1'b1;
else
 spc0_lmiss_eq2 = 1'b0;
end
always @(spc0_lmiss_pa3 or spc0_imiss_pa or spc0_imiss_vld_d or spc0_lmiss_vld3)
begin
if((spc0_lmiss_pa3 == spc0_imiss_pa) && spc0_imiss_vld_d && spc0_lmiss_vld3)
 spc0_lmiss_eq3 = 1'b1;
else
 spc0_lmiss_eq3 = 1'b0;
end

always @(spc0_lmiss_pa0 or spc0_stb_atm_addr0 or spc0_atm_cntr0 or spc0_lmiss_vld0)
begin
if ( ((spc0_lmiss_pa0 == spc0_stb_atm_addr0) && (spc0_atm_cntr0 != 9'h000) && spc0_lmiss_vld0) ||
     ((spc0_lmiss_pa1 == spc0_stb_atm_addr0) && (spc0_atm_cntr0 != 9'h000) && spc0_lmiss_vld1) ||
     ((spc0_lmiss_pa2 == spc0_stb_atm_addr0) && (spc0_atm_cntr0 != 9'h000) && spc0_lmiss_vld2) ||
     ((spc0_lmiss_pa3 == spc0_stb_atm_addr0) && (spc0_atm_cntr0 != 9'h000) && spc0_lmiss_vld3) )

 spc0_atm_lmiss_eq0 = 1'b1;
else
 spc0_atm_lmiss_eq0 = 1'b0;
end
always @(spc0_lmiss_pa1 or spc0_stb_atm_addr1 or spc0_atm_cntr1 or spc0_lmiss_vld1)
begin
if ( ((spc0_lmiss_pa0 == spc0_stb_atm_addr1) && (spc0_atm_cntr1 != 9'h000) && spc0_lmiss_vld0) ||
     ((spc0_lmiss_pa1 == spc0_stb_atm_addr1) && (spc0_atm_cntr1 != 9'h000) && spc0_lmiss_vld1) ||
     ((spc0_lmiss_pa2 == spc0_stb_atm_addr1) && (spc0_atm_cntr1 != 9'h000) && spc0_lmiss_vld2) ||
     ((spc0_lmiss_pa3 == spc0_stb_atm_addr1) && (spc0_atm_cntr1 != 9'h000) && spc0_lmiss_vld3) )

 spc0_atm_lmiss_eq1 = 1'b1;
else
 spc0_atm_lmiss_eq1 = 1'b0;
end
always @(spc0_lmiss_pa2 or spc0_stb_atm_addr2 or spc0_atm_cntr2 or spc0_lmiss_vld2)
begin
if ( ((spc0_lmiss_pa0 == spc0_stb_atm_addr2) && (spc0_atm_cntr2 != 9'h000) && spc0_lmiss_vld0) ||
     ((spc0_lmiss_pa1 == spc0_stb_atm_addr2) && (spc0_atm_cntr2 != 9'h000) && spc0_lmiss_vld1) ||
     ((spc0_lmiss_pa2 == spc0_stb_atm_addr2) && (spc0_atm_cntr2 != 9'h000) && spc0_lmiss_vld2) ||
     ((spc0_lmiss_pa3 == spc0_stb_atm_addr2) && (spc0_atm_cntr2 != 9'h000) && spc0_lmiss_vld3) )

 spc0_atm_lmiss_eq2 = 1'b1;
else
 spc0_atm_lmiss_eq2 = 1'b0;
end
always @(spc0_lmiss_pa3 or spc0_stb_atm_addr3 or spc0_atm_cntr3 or spc0_lmiss_vld3)
begin
if ( ((spc0_lmiss_pa0 == spc0_stb_atm_addr3) && (spc0_atm_cntr3 != 9'h000) && spc0_lmiss_vld0) ||
     ((spc0_lmiss_pa1 == spc0_stb_atm_addr3) && (spc0_atm_cntr3 != 9'h000) && spc0_lmiss_vld1) ||
     ((spc0_lmiss_pa2 == spc0_stb_atm_addr3) && (spc0_atm_cntr3 != 9'h000) && spc0_lmiss_vld2) ||
     ((spc0_lmiss_pa3 == spc0_stb_atm_addr3) && (spc0_atm_cntr3 != 9'h000) && spc0_lmiss_vld3) )

 spc0_atm_lmiss_eq3 = 1'b1;
else
 spc0_atm_lmiss_eq3 = 1'b0;
end

always @(spc0_imiss_pa or spc0_stb_atm_addr0 or spc0_atm_cntr0 or spc0_imiss_vld_d)
begin
if((spc0_imiss_pa == spc0_stb_atm_addr0) && (spc0_atm_cntr0 != 9'h000) && spc0_imiss_vld_d)
 spc0_atm_imiss_eq0 = 1'b1;
else
 spc0_atm_imiss_eq0 = 1'b0;
end
always @(spc0_imiss_pa or spc0_stb_atm_addr1 or spc0_atm_cntr1 or spc0_imiss_vld_d)
begin
if((spc0_imiss_pa == spc0_stb_atm_addr1) && (spc0_atm_cntr1 != 9'h000) && spc0_imiss_vld_d)
 spc0_atm_imiss_eq1 = 1'b1;
else
 spc0_atm_imiss_eq1 = 1'b0;
end
always @(spc0_imiss_pa or spc0_stb_atm_addr2 or spc0_atm_cntr2 or spc0_imiss_vld_d)
begin
if((spc0_imiss_pa == spc0_stb_atm_addr2) && (spc0_atm_cntr2 != 9'h000) && spc0_imiss_vld_d)
 spc0_atm_imiss_eq2 = 1'b1;
else
 spc0_atm_imiss_eq2 = 1'b0;
end
always @(spc0_imiss_pa or spc0_stb_atm_addr3 or spc0_atm_cntr3 or spc0_imiss_vld_d)
begin
if((spc0_imiss_pa == spc0_stb_atm_addr3) && (spc0_atm_cntr3 != 9'h000) && spc0_imiss_vld_d)
 spc0_atm_imiss_eq3 = 1'b1;
else
 spc0_atm_imiss_eq3 = 1'b0;
end

always @(posedge clk)
begin
 if( ~spc0_imiss_vld || ~rst_l)
   spc0_imiss_vld_d <= 1'b0;
 else
   spc0_imiss_vld_d <= spc0_imiss_vld;

 if( ~spc0_ld_miss || ~rst_l)
   spc0_ld_miss_capture <= 1'b0;
 else
   spc0_ld_miss_capture <= spc0_ld_miss;

end

always @(spc0_stb_ced0 or spc0_stb_ced0_d)
begin
if (~spc0_stb_ced0 && spc0_stb_ced0_d)
spc0_stb_ced_capture0 <= 1'b1;
else
spc0_stb_ced_capture0 <= 1'b0;

end
always @(spc0_stb_ced1 or spc0_stb_ced1_d)
begin
if (~spc0_stb_ced1 && spc0_stb_ced1_d)
spc0_stb_ced_capture1 <= 1'b1;
else
spc0_stb_ced_capture1 <= 1'b0;

end
always @(spc0_stb_ced2 or spc0_stb_ced2_d)
begin
if (~spc0_stb_ced2 && spc0_stb_ced2_d)
spc0_stb_ced_capture2 <= 1'b1;
else
spc0_stb_ced_capture2 <= 1'b0;

end
always @(spc0_stb_ced3 or spc0_stb_ced3_d)
begin
if (~spc0_stb_ced3 && spc0_stb_ced3_d)
spc0_stb_ced_capture3 <= 1'b1;
else
spc0_stb_ced_capture3 <= 1'b0;

end

always @(posedge clk)
begin

    if( (spc0_stb_state_ack0 != 8'h00 && (spc0_stb_ack_cntr0 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_ack_cntr0 <= 9'h000;
       if(lsu_mon_msg) $display("lsu_mon: spc0_stb_ack_counter0 = %d", spc0_stb_ack_cntr0);
      end
    else if(spc0_stb_cam_hit && spc0_ld0_inst_vld_g && (spc0_stb_state_ack0 == 8'h00))
      begin
       spc0_stb_ack_cntr0 <= spc0_stb_ack_cntr0 + 1;
      end
    else if( (spc0_stb_state_ack0 == 8'h00 ) && (spc0_stb_ack_cntr0 != 9'h000))
      begin
       spc0_stb_ack_cntr0 <= spc0_stb_ack_cntr0 + 1;
      end // if ( (spc0_stb_state_ack0 == 8'h00 ) && (spc0_stb_ack_cntr0 != 9'h000))
    else
      begin
       spc0_stb_ack_cntr0 <= spc0_stb_ack_cntr0;
      end

    if( (spc0_stb_state_ack1 != 8'h00 && (spc0_stb_ack_cntr1 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_ack_cntr1 <= 9'h000;
       if(lsu_mon_msg) $display("lsu_mon: spc0_stb_ack_counter1 = %d", spc0_stb_ack_cntr1);
      end
    else if(spc0_stb_cam_hit && spc0_ld1_inst_vld_g && (spc0_stb_state_ack1 == 8'h00))
      begin
       spc0_stb_ack_cntr1 <= spc0_stb_ack_cntr1 + 1;
      end
    else if( (spc0_stb_state_ack1 == 8'h00 ) && (spc0_stb_ack_cntr1 != 9'h000))
      begin
       spc0_stb_ack_cntr1 <= spc0_stb_ack_cntr1 + 1;
      end // if ( (spc0_stb_state_ack1 == 8'h00 ) && (spc0_stb_ack_cntr1 != 9'h000))
    else
      begin
       spc0_stb_ack_cntr1 <= spc0_stb_ack_cntr1;
      end

    if( (spc0_stb_state_ack2 != 8'h00 && (spc0_stb_ack_cntr2 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_ack_cntr2 <= 9'h000;
       if(lsu_mon_msg) $display("lsu_mon: spc0_stb_ack_counter2 = %d", spc0_stb_ack_cntr2);
      end
    else if(spc0_stb_cam_hit && spc0_ld2_inst_vld_g && (spc0_stb_state_ack2 == 8'h00))
      begin
       spc0_stb_ack_cntr2 <= spc0_stb_ack_cntr2 + 1;
      end
    else if( (spc0_stb_state_ack2 == 8'h00 ) && (spc0_stb_ack_cntr2 != 9'h000))
      begin
       spc0_stb_ack_cntr2 <= spc0_stb_ack_cntr2 + 1;
      end // if ( (spc0_stb_state_ack2 == 8'h00 ) && (spc0_stb_ack_cntr2 != 9'h000))
    else
      begin
       spc0_stb_ack_cntr2 <= spc0_stb_ack_cntr2;
      end

    if( (spc0_stb_state_ack3 != 8'h00 && (spc0_stb_ack_cntr3 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_ack_cntr3 <= 9'h000;
       if(lsu_mon_msg) $display("lsu_mon: spc0_stb_ack_counter3 = %d", spc0_stb_ack_cntr3);
      end
    else if(spc0_stb_cam_hit && spc0_ld3_inst_vld_g && (spc0_stb_state_ack3 == 8'h00))
      begin
       spc0_stb_ack_cntr3 <= spc0_stb_ack_cntr3 + 1;
      end
    else if( (spc0_stb_state_ack3 == 8'h00 ) && (spc0_stb_ack_cntr3 != 9'h000))
      begin
       spc0_stb_ack_cntr3 <= spc0_stb_ack_cntr3 + 1;
      end // if ( (spc0_stb_state_ack3 == 8'h00 ) && (spc0_stb_ack_cntr3 != 9'h000))
    else
      begin
       spc0_stb_ack_cntr3 <= spc0_stb_ack_cntr3;
      end
end // always @ (posedge clk)


// stb full coverage window
always @(spc0_stb0_full_w2 or spc0_stb0_full)
begin
if (~spc0_stb0_full_w2 && spc0_stb0_full)
spc0_stb_full_capture0 <= 1'b1;
else
spc0_stb_full_capture0 <= 1'b0;

end
always @(spc0_stb1_full_w2 or spc0_stb1_full)
begin
if (~spc0_stb1_full_w2 && spc0_stb1_full)
spc0_stb_full_capture1 <= 1'b1;
else
spc0_stb_full_capture1 <= 1'b0;

end
always @(spc0_stb2_full_w2 or spc0_stb2_full)
begin
if (~spc0_stb2_full_w2 && spc0_stb2_full)
spc0_stb_full_capture2 <= 1'b1;
else
spc0_stb_full_capture2 <= 1'b0;

end
always @(spc0_stb3_full_w2 or spc0_stb3_full)
begin
if (~spc0_stb3_full_w2 && spc0_stb3_full)
spc0_stb_full_capture3 <= 1'b1;
else
spc0_stb_full_capture3 <= 1'b0;

end
always @(posedge clk)
begin
    if( ( ~spc0_stb0_full && (spc0_stb_full_cntr0 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_full_cntr0 <= 9'h000;
       if(lsu_mon_msg) $display("lsu_mon: spc0_stb_full_counter0 = %d", spc0_stb_full_cntr0);
      end
    else if( spc0_stb0_full)
      begin
       spc0_stb_full_cntr0 <= spc0_stb_full_cntr0 + 1;
      end
    else
      begin
       spc0_stb_full_cntr0 <= spc0_stb_full_cntr0;
      end
    if( ( ~spc0_stb1_full && (spc0_stb_full_cntr1 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_full_cntr1 <= 9'h000;
       if(lsu_mon_msg) $display("lsu_mon: spc0_stb_full_counter1 = %d", spc0_stb_full_cntr1);
      end
    else if( spc0_stb1_full)
      begin
       spc0_stb_full_cntr1 <= spc0_stb_full_cntr1 + 1;
      end
    else
      begin
       spc0_stb_full_cntr1 <= spc0_stb_full_cntr1;
      end
    if( ( ~spc0_stb2_full && (spc0_stb_full_cntr2 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_full_cntr2 <= 9'h000;
       if(lsu_mon_msg) $display("lsu_mon: spc0_stb_full_counter2 = %d", spc0_stb_full_cntr2);
      end
    else if( spc0_stb2_full)
      begin
       spc0_stb_full_cntr2 <= spc0_stb_full_cntr2 + 1;
      end
    else
      begin
       spc0_stb_full_cntr2 <= spc0_stb_full_cntr2;
      end
    if( ( ~spc0_stb3_full && (spc0_stb_full_cntr3 != 9'h000)) || ~rst_l)
      begin
       spc0_stb_full_cntr3 <= 9'h000;
       if(lsu_mon_msg) $display("lsu_mon: spc0_stb_full_counter3 = %d", spc0_stb_full_cntr3);
      end
    else if( spc0_stb3_full)
      begin
       spc0_stb_full_cntr3 <= spc0_stb_full_cntr3 + 1;
      end
    else
      begin
       spc0_stb_full_cntr3 <= spc0_stb_full_cntr3;
      end
end // always @ (posedge clk)


// lmq full coverage window
always @(spc0_lmq0_full_d or spc0_lmq0_full)
begin
if (spc0_lmq0_full_d && ~spc0_lmq0_full)
spc0_lmq_full_capture0 <= 1'b1;
else
spc0_lmq_full_capture0 <= 1'b0;

end
always @(spc0_lmq1_full_d or spc0_lmq1_full)
begin
if (spc0_lmq1_full_d && ~spc0_lmq1_full)
spc0_lmq_full_capture1 <= 1'b1;
else
spc0_lmq_full_capture1 <= 1'b0;

end
always @(spc0_lmq2_full_d or spc0_lmq2_full)
begin
if (spc0_lmq2_full_d && ~spc0_lmq2_full)
spc0_lmq_full_capture2 <= 1'b1;
else
spc0_lmq_full_capture2 <= 1'b0;

end
always @(spc0_lmq3_full_d or spc0_lmq3_full)
begin
if (spc0_lmq3_full_d && ~spc0_lmq3_full)
spc0_lmq_full_capture3 <= 1'b1;
else
spc0_lmq_full_capture3 <= 1'b0;

end
always @(posedge clk)
begin
    if( ( ~spc0_lmq0_full && (spc0_lmq_full_cntr0 != 9'h000)) || ~rst_l)
      begin
       spc0_lmq_full_cntr0 <= 9'h000;
       spc0_lmq0_full_d <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_lmq_full_counter0 = %d", spc0_lmq_full_cntr0);
      end
    else if( spc0_lmq0_full)
      begin
       spc0_lmq_full_cntr0 <= spc0_lmq_full_cntr0 + 1;
       spc0_lmq0_full_d <= spc0_lmq0_full;
      end
    else
      begin
       spc0_lmq_full_cntr0 <= spc0_lmq_full_cntr0;
       spc0_lmq0_full_d <= spc0_lmq0_full;
      end

    if( ( ~spc0_lmq1_full && (spc0_lmq_full_cntr1 != 9'h000)) || ~rst_l)
      begin
       spc0_lmq_full_cntr1 <= 9'h000;
       spc0_lmq1_full_d <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_lmq_full_counter1 = %d", spc0_lmq_full_cntr1);
      end
    else if( spc0_lmq1_full)
      begin
       spc0_lmq_full_cntr1 <= spc0_lmq_full_cntr1 + 1;
       spc0_lmq1_full_d <= spc0_lmq1_full;
      end
    else
      begin
       spc0_lmq_full_cntr1 <= spc0_lmq_full_cntr1;
       spc0_lmq1_full_d <= spc0_lmq1_full;
      end

    if( ( ~spc0_lmq2_full && (spc0_lmq_full_cntr2 != 9'h000)) || ~rst_l)
      begin
       spc0_lmq_full_cntr2 <= 9'h000;
       spc0_lmq2_full_d <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_lmq_full_counter2 = %d", spc0_lmq_full_cntr2);
      end
    else if( spc0_lmq2_full)
      begin
       spc0_lmq_full_cntr2 <= spc0_lmq_full_cntr2 + 1;
       spc0_lmq2_full_d <= spc0_lmq2_full;
      end
    else
      begin
       spc0_lmq_full_cntr2 <= spc0_lmq_full_cntr2;
       spc0_lmq2_full_d <= spc0_lmq2_full;
      end

    if( ( ~spc0_lmq3_full && (spc0_lmq_full_cntr3 != 9'h000)) || ~rst_l)
      begin
       spc0_lmq_full_cntr3 <= 9'h000;
       spc0_lmq3_full_d <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_lmq_full_counter3 = %d", spc0_lmq_full_cntr3);
      end
    else if( spc0_lmq3_full)
      begin
       spc0_lmq_full_cntr3 <= spc0_lmq_full_cntr3 + 1;
       spc0_lmq3_full_d <= spc0_lmq3_full;
      end
    else
      begin
       spc0_lmq_full_cntr3 <= spc0_lmq_full_cntr3;
       spc0_lmq3_full_d <= spc0_lmq3_full;
      end

end // always @ (posedge clk)


// dfq full coverage window
always @(spc0_dfq_full_d or spc0_dfq_full)
begin
  if (spc0_dfq_full_d && ~spc0_dfq_full)
    spc0_dfq_full_capture <= 1'b1;
  else
    spc0_dfq_full_capture <= 1'b0;
end

always @(posedge clk)
begin
    if( ( ~spc0_dfq_full && (spc0_dfq_full_cntr != 9'h000)) || ~rst_l)
      begin
       spc0_dfq_full_cntr <= 9'h000;
       spc0_dfq_full_d <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_dfq_full_counter = %d", spc0_dfq_full_cntr);
      end
    else if( spc0_dfq_full)
      begin
       spc0_dfq_full_cntr <= spc0_dfq_full_cntr + 1;
       spc0_dfq_full_d <= spc0_dfq_full;
      end
    else
      begin
       spc0_dfq_full_cntr <= spc0_dfq_full_cntr;
       spc0_dfq_full_d <= spc0_dfq_full;
      end
end // always @ (posedge clk)

// dva valid/invalidate coverage window
always @(spc0_dva_full_d or spc0_dva_inv)
begin
  if (spc0_dva_full_d && ~spc0_dva_inv)
    spc0_dva_full_capture <= 1'b1;
  else
    spc0_dva_full_capture <= 1'b0;
end

always @(posedge clk)
begin
  if (spc0_dva_din && spc0_dva_wen)
    begin
     spc0_dva_inv <= 1'b1;
     spc0_dva_waddr_d <= spc0_dva_waddr;
    end
  else if(~spc0_dva_din && spc0_dva_wen)
    begin
     spc0_dva_inv <= 1'b0;
     spc0_dva_waddr_d <= 5'b00000;
    end
  else
    begin
     spc0_dva_inv <= spc0_dva_inv;
     spc0_dva_waddr_d <= spc0_dva_waddr_d;
    end
end

always @(spc0_dva_raddr or spc0_dva_ren or spc0_dva_inv)
begin
  if (spc0_dva_inv && spc0_dva_ren && (spc0_dva_raddr[`L1D_ADDRESS_HI-4:2] == spc0_dva_waddr_d))
    spc0_dva_vld2lkup <= 1'b1;
  else
    spc0_dva_vld2lkup <= 1'b0;
end

always @(posedge clk)
begin
    if( ( ~spc0_dva_inv && (spc0_dva_full_cntr != 9'h000)) || ~rst_l)
      begin
       spc0_dva_full_cntr <= 9'h000;
       spc0_dva_full_d <= 1'b0;
       if(lsu_mon_msg) $display("lsu_mon: spc0_dva_full_counter = %d", spc0_dva_full_cntr);
      end
    else if( spc0_dva_inv)
      begin
       spc0_dva_full_cntr <= spc0_dva_full_cntr + 1;
       spc0_dva_full_d <= spc0_dva_inv;
      end
    else
      begin
       spc0_dva_full_cntr <= spc0_dva_full_cntr;
       spc0_dva_full_d <= spc0_dva_full_d;
      end
end // always @ (posedge clk)

// dva valid/invalidate coverage window
always @(spc0_dva_vfull_d or spc0_dva_vld)
begin
  if (spc0_dva_vfull_d && ~spc0_dva_vld)
    spc0_dva_vfull_capture <= 1'b1;
  else
    spc0_dva_vfull_capture <= 1'b0;

end


always @(posedge clk)
begin
  if (~spc0_dva_din && spc0_dva_wen)
   begin
    spc0_dva_vld <= 1'b1;
    spc0_dva_invwaddr_d <= spc0_dva_waddr;
    spc0_dva_invld_err <= spc0_dva_inv_perror;
   end
  else if(spc0_dva_din && spc0_dva_wen)
    begin
     spc0_dva_vld <= 1'b0;
     spc0_dva_invwaddr_d <= 5'b00000;
     spc0_dva_invld_err <= 1'b0;
    end
  else
    begin
     spc0_dva_vld <= spc0_dva_vld;
     spc0_dva_invwaddr_d <= spc0_dva_invwaddr_d;
     spc0_dva_invld_err <= spc0_dva_invld_err;
    end
end


always @(spc0_dva_raddr or spc0_dva_ren or spc0_dva_vld)
begin
  if (spc0_dva_vld && spc0_dva_ren && (spc0_dva_raddr[`L1D_ADDRESS_HI-4:2] == spc0_dva_waddr_d))
    spc0_dva_invld2lkup <= 1'b1;
  else
    spc0_dva_invld2lkup <= 1'b0;
end


always @(posedge clk)
begin
  if( ( ~spc0_dva_vld && (spc0_dva_vfull_cntr != 9'h000)) || ~rst_l)
  begin
    spc0_dva_vfull_cntr <= 9'h000;
    spc0_dva_vfull_d <= 1'b0;
    if(lsu_mon_msg) $display("lsu_mon: spc0_dva_vfull_counter = %d", spc0_dva_vfull_cntr);
  end
    else if( spc0_dva_vld)
    begin
      spc0_dva_vfull_cntr <= spc0_dva_vfull_cntr + 1;
      spc0_dva_vfull_d <= spc0_dva_vld;
    end
    else
    begin
      spc0_dva_vfull_cntr <= spc0_dva_vfull_cntr;
      spc0_dva_vfull_d <= spc0_dva_vfull_d;
    end
end // always @ (posedge clk)

// Can this ever happen/Might have to flag this as an error..
always @(spc0_dva_raddr or spc0_dva_waddr or spc0_dva_ren or spc0_dva_wen)
begin
  if ( spc0_dva_ren && spc0_dva_wen && (spc0_dva_raddr[`L1D_ADDRESS_HI-4:2] == spc0_dva_waddr))
    spc0_dva_collide <= 1'b1;
  else
    spc0_dva_collide <= 1'b0;
end

// dva error cases

always @(spc0_dva_raddr or spc0_dva_ren or spc0_dva_dtag_perror or spc0_dva_dtag_perror)
begin
  if (spc0_dva_ren && (spc0_dva_dtag_perror || spc0_dva_dtag_perror))
    spc0_dva_err <= 1'b1;
  else
    spc0_dva_err <= 1'b0;
end

always @(posedge clk)
begin

  if(spc0_dva_err)
     spc0_dva_efull_d <= 1'b1;
  else
     spc0_dva_efull_d <= 1'b0;

end
always @(posedge clk)
begin
  if( (spc0_dva_ren && ~(spc0_dva_dtag_perror || spc0_dva_dtag_perror ) &&
       (spc0_dva_efull_cntr != 9'h000)) || ~rst_l)
    begin
     spc0_dva_efull_cntr <= 9'h000;
     spc0_dva_raddr_d <= spc0_dva_raddr;
     if(lsu_mon_msg) $display("lsu_mon: spc0_dva_efull_counter = %d", spc0_dva_efull_cntr);
    end
  else if(spc0_dva_efull_d)
    begin
      spc0_dva_efull_cntr <= spc0_dva_efull_cntr + 1;
      spc0_dva_raddr_d <= spc0_dva_raddr_d;
    end
  else
    begin
      spc0_dva_efull_cntr <= spc0_dva_efull_cntr;
      spc0_dva_raddr_d <= spc0_dva_raddr_d;
    end
end // always @ (posedge clk)




endmodule

