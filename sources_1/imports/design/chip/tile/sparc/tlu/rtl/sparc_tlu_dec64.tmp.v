// Modified by Princeton University on June 9th, 2015
// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_tlu_dec64.v
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
//  Module Name: sparc_tlu_dec64
//  Description:    
//    6 -> 64 decoder
*/

module sparc_tlu_dec64(/*AUTOARG*/
   // Outputs
   out, 
   // Inputs
   in
   );

   input [5:0] in;

   output [63:0] out;


   wire [5:0] 	 in;
   reg [63:0] 	 out;

/*   integer 	 i;
   
   always @ (in)
     begin
	for (i=0;i<64;i=i+1)
	  begin
	     if (i[5:0] == in[5:0])
	       out[i] = 1'b1;
	     else
	       out[i] = 1'b0;
	  end
     end
*/

always @ (in)
begin
    case (in)
       6'h00: out = 64'h0000000000000001;
       6'h01: out = 64'h0000000000000002;
       6'h02: out = 64'h0000000000000004;
       6'h03: out = 64'h0000000000000008;
       6'h04: out = 64'h0000000000000010;
       6'h05: out = 64'h0000000000000020;
       6'h06: out = 64'h0000000000000040;
       6'h07: out = 64'h0000000000000080;
       6'h08: out = 64'h0000000000000100;
       6'h09: out = 64'h0000000000000200;
       6'h0a: out = 64'h0000000000000400;
       6'h0b: out = 64'h0000000000000800;
       6'h0c: out = 64'h0000000000001000;
       6'h0d: out = 64'h0000000000002000;
       6'h0e: out = 64'h0000000000004000;
       6'h0f: out = 64'h0000000000008000;
       6'h10: out = 64'h0000000000010000;
       6'h11: out = 64'h0000000000020000;
       6'h12: out = 64'h0000000000040000;
       6'h13: out = 64'h0000000000080000;
       6'h14: out = 64'h0000000000100000;
       6'h15: out = 64'h0000000000200000;
       6'h16: out = 64'h0000000000400000;
       6'h17: out = 64'h0000000000800000;
       6'h18: out = 64'h0000000001000000;
       6'h19: out = 64'h0000000002000000;
       6'h1a: out = 64'h0000000004000000;
       6'h1b: out = 64'h0000000008000000;
       6'h1c: out = 64'h0000000010000000;
       6'h1d: out = 64'h0000000020000000;
       6'h1e: out = 64'h0000000040000000;
       6'h1f: out = 64'h0000000080000000;
       6'h20: out = 64'h0000000100000000;
       6'h21: out = 64'h0000000200000000;
       6'h22: out = 64'h0000000400000000;
       6'h23: out = 64'h0000000800000000;
       6'h24: out = 64'h0000001000000000;
       6'h25: out = 64'h0000002000000000;
       6'h26: out = 64'h0000004000000000;
       6'h27: out = 64'h0000008000000000;
       6'h28: out = 64'h0000010000000000;
       6'h29: out = 64'h0000020000000000;
       6'h2a: out = 64'h0000040000000000;
       6'h2b: out = 64'h0000080000000000;
       6'h2c: out = 64'h0000100000000000;
       6'h2d: out = 64'h0000200000000000;
       6'h2e: out = 64'h0000400000000000;
       6'h2f: out = 64'h0000800000000000;
       6'h30: out = 64'h0001000000000000;
       6'h31: out = 64'h0002000000000000;
       6'h32: out = 64'h0004000000000000;
       6'h33: out = 64'h0008000000000000;
       6'h34: out = 64'h0010000000000000;
       6'h35: out = 64'h0020000000000000;
       6'h36: out = 64'h0040000000000000;
       6'h37: out = 64'h0080000000000000;
       6'h38: out = 64'h0100000000000000;
       6'h39: out = 64'h0200000000000000;
       6'h3a: out = 64'h0400000000000000;
       6'h3b: out = 64'h0800000000000000;
       6'h3c: out = 64'h1000000000000000;
       6'h3d: out = 64'h2000000000000000;
       6'h3e: out = 64'h4000000000000000;
       6'h3f: out = 64'h8000000000000000;

    endcase
end

endmodule // sparc_tlu_dec64

	
