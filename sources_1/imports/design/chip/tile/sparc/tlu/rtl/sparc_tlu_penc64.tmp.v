// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_tlu_penc64.v
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
//  Module Name: sparc_tlu_penc64
//  Description:    
//    64 -> 6 priority encoder
//    Bit 63 has the highest priority
//
*/

module sparc_tlu_penc64 (/*AUTOARG*/
   // Outputs
   out, 
   // Inputs
   in
   );

   input [63:0] in;

   output [5:0] out;


   reg [5:0] 	out;
//   integer 	i;
   
always @ (in)
begin
//
// code modified for verplex to avoid inferred latches
//	     if (in == 64'b0) // don't want a latch
	out = 6'b0;
//	else 
//	for (i=0;i<64;i=i+1)
//	    begin

	       if (in[0])
		   out[5:0] = 6'd0;
    

	       if (in[1])
		   out[5:0] = 6'd1;
    

	       if (in[2])
		   out[5:0] = 6'd2;
    

	       if (in[3])
		   out[5:0] = 6'd3;
    

	       if (in[4])
		   out[5:0] = 6'd4;
    

	       if (in[5])
		   out[5:0] = 6'd5;
    

	       if (in[6])
		   out[5:0] = 6'd6;
    

	       if (in[7])
		   out[5:0] = 6'd7;
    

	       if (in[8])
		   out[5:0] = 6'd8;
    

	       if (in[9])
		   out[5:0] = 6'd9;
    

	       if (in[10])
		   out[5:0] = 6'd10;
    

	       if (in[11])
		   out[5:0] = 6'd11;
    

	       if (in[12])
		   out[5:0] = 6'd12;
    

	       if (in[13])
		   out[5:0] = 6'd13;
    

	       if (in[14])
		   out[5:0] = 6'd14;
    

	       if (in[15])
		   out[5:0] = 6'd15;
    

	       if (in[16])
		   out[5:0] = 6'd16;
    

	       if (in[17])
		   out[5:0] = 6'd17;
    

	       if (in[18])
		   out[5:0] = 6'd18;
    

	       if (in[19])
		   out[5:0] = 6'd19;
    

	       if (in[20])
		   out[5:0] = 6'd20;
    

	       if (in[21])
		   out[5:0] = 6'd21;
    

	       if (in[22])
		   out[5:0] = 6'd22;
    

	       if (in[23])
		   out[5:0] = 6'd23;
    

	       if (in[24])
		   out[5:0] = 6'd24;
    

	       if (in[25])
		   out[5:0] = 6'd25;
    

	       if (in[26])
		   out[5:0] = 6'd26;
    

	       if (in[27])
		   out[5:0] = 6'd27;
    

	       if (in[28])
		   out[5:0] = 6'd28;
    

	       if (in[29])
		   out[5:0] = 6'd29;
    

	       if (in[30])
		   out[5:0] = 6'd30;
    

	       if (in[31])
		   out[5:0] = 6'd31;
    

	       if (in[32])
		   out[5:0] = 6'd32;
    

	       if (in[33])
		   out[5:0] = 6'd33;
    

	       if (in[34])
		   out[5:0] = 6'd34;
    

	       if (in[35])
		   out[5:0] = 6'd35;
    

	       if (in[36])
		   out[5:0] = 6'd36;
    

	       if (in[37])
		   out[5:0] = 6'd37;
    

	       if (in[38])
		   out[5:0] = 6'd38;
    

	       if (in[39])
		   out[5:0] = 6'd39;
    

	       if (in[40])
		   out[5:0] = 6'd40;
    

	       if (in[41])
		   out[5:0] = 6'd41;
    

	       if (in[42])
		   out[5:0] = 6'd42;
    

	       if (in[43])
		   out[5:0] = 6'd43;
    

	       if (in[44])
		   out[5:0] = 6'd44;
    

	       if (in[45])
		   out[5:0] = 6'd45;
    

	       if (in[46])
		   out[5:0] = 6'd46;
    

	       if (in[47])
		   out[5:0] = 6'd47;
    

	       if (in[48])
		   out[5:0] = 6'd48;
    

	       if (in[49])
		   out[5:0] = 6'd49;
    

	       if (in[50])
		   out[5:0] = 6'd50;
    

	       if (in[51])
		   out[5:0] = 6'd51;
    

	       if (in[52])
		   out[5:0] = 6'd52;
    

	       if (in[53])
		   out[5:0] = 6'd53;
    

	       if (in[54])
		   out[5:0] = 6'd54;
    

	       if (in[55])
		   out[5:0] = 6'd55;
    

	       if (in[56])
		   out[5:0] = 6'd56;
    

	       if (in[57])
		   out[5:0] = 6'd57;
    

	       if (in[58])
		   out[5:0] = 6'd58;
    

	       if (in[59])
		   out[5:0] = 6'd59;
    

	       if (in[60])
		   out[5:0] = 6'd60;
    

	       if (in[61])
		   out[5:0] = 6'd61;
    

	       if (in[62])
		   out[5:0] = 6'd62;
    

	       if (in[63])
		   out[5:0] = 6'd63;
    

//	    end
end
   
endmodule // sparc_tlu_penc64

