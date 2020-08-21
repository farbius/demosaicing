
////////////////////////////////////////////////////////////////////////////////
// Company:     Riftek
// Engineer:    Aleksei Rostov
// Email:       farbius@protonmail.com
// Create Date: 05/05/18
// Design Name: demosaicing
////////////////////////////////////////////////////////////////////////////////

module kernel_3x3 #(
parameter Nrows = 349,
parameter Ncol  = 349
)
(
    input clk,
    input rst,
// slave axi stream interface   
    input s_axis_tvalid,
    input s_axis_tuser,
    input s_axis_tlast,
    input [8 - 1  : 0] s_axis_tdata,
// master axi stream interface    
    output m_axis_tvalid,
    output m_axis_tuser,
    output m_axis_tlast,
    output [23 : 0] m_axis_tdata
    );
	
    localparam RAM_ADDR_BITS = 11; 
    
    reg [RAM_ADDR_BITS-1:0] read_addr, write_adr_1st;
	
    reg [RAM_ADDR_BITS-1:0] write_adr_2nd;
    reg [RAM_ADDR_BITS-1:0] write_adr_3rd;
	
    wire a_wr_1st, a_wr_2nd, a_wr_3rd;

    reg [2 : 0] mux;
      
    wire  [7 : 0] m_axis_tdata_1streg;
    wire  [7 : 0] m_axis_tdata_2ndreg;
    wire  [7 : 0] m_axis_tdata_3rdreg;
  
//// count of five lines  
    always @(posedge clk)begin
        if(rst | s_axis_tuser)begin
            mux <= 0;
        end else if(s_axis_tlast)begin
            if(mux == 3'b010)begin
            mux <= 0;
            end else begin
            mux <= mux + 1;
            end
        end
    end // always block
 
//// generarte write addresses              
     always @(posedge clk)
            if (a_wr_1st)write_adr_1st <= write_adr_1st + 1;
            else if(rst | s_axis_tlast) write_adr_1st <= 0; 
			
     always @(posedge clk)
            if (a_wr_2nd)write_adr_2nd <= write_adr_2nd + 1;
            else if(rst | s_axis_tlast)write_adr_2nd <= 0;
			
     always @(posedge clk)
            if (a_wr_3rd)write_adr_3rd <= write_adr_3rd + 1;
            else if(rst | s_axis_tlast)write_adr_3rd <= 0;	
 
//// generarte read addresses  
		reg [RAM_ADDR_BITS-1:0] address;
        always @(posedge clk)
           if (s_axis_tvalid & !s_axis_tlast) address <= address + 1; //read_adr_2nd + 1;
		   else if (s_axis_tvalid & s_axis_tlast) address <= 0;
		   else if(rst)address <= 0;
       
        always @(posedge clk)
           if (s_axis_tvalid)read_addr <= address; //read_adr_2nd + 1;      
                           
   assign a_wr_1st   = (mux == 3'b000 & s_axis_tvalid) ? 1'b1 : 1'b0;
   assign a_wr_2nd   = (mux == 3'b001 & s_axis_tvalid) ? 1'b1 : 1'b0;
   assign a_wr_3rd   = (mux == 3'b010 & s_axis_tvalid) ? 1'b1 : 1'b0;
  
    // 3 buffers for keeping lines    
   BRAM_Memory_24x24 #(11) i0 (.a_clk(clk), .a_wr(a_wr_1st), .a_addr(write_adr_1st), .a_data_in(s_axis_tdata), .a_data_out(), 
   .b_clk(clk), .b_wr(1'b0), .b_addr(read_addr), .b_data_in(), .b_data_out(m_axis_tdata_1streg), .b_data_en(1'b1));
   
   BRAM_Memory_24x24 #(11) i1 (.a_clk(clk), .a_wr(a_wr_2nd), .a_addr(write_adr_2nd), .a_data_in(s_axis_tdata), .a_data_out(), 
   .b_clk(clk), .b_wr(1'b0), .b_addr(read_addr), .b_data_in(), .b_data_out(m_axis_tdata_2ndreg), .b_data_en(1'b1));
   
   BRAM_Memory_24x24 #(11) i2 (.a_clk(clk), .a_wr(a_wr_3rd), .a_addr(write_adr_3rd), .a_data_in(s_axis_tdata), .a_data_out(), 
   .b_clk(clk), .b_wr(1'b0), .b_addr(read_addr), .b_data_in(), .b_data_out(m_axis_tdata_3rdreg), .b_data_en(1'b1));
   
   localparam WSize = 3;
   
   reg  [8*WSize - 1 : 0] shift_1streg_Ip;
   reg  [8*WSize - 1 : 0] shift_2ndreg_Ip;
   reg  [8*WSize - 1 : 0] shift_3rdreg_Ip;
   
    // registers for  Green layer
   reg  [11 : 0]     G_I;
   reg  [11 : 0]   G_I1p,   G_I2p;
   reg  [11 : 0]   G_I3p,   G_I4p;
   
   
    // registers for Blue layer
   reg [11 : 0]              B_I;
   reg [11 : 0]   B_I1p,   B_I2p;
   reg [11 : 0]   B_I3p,   B_I4p;
   
   reg [11 : 0]              B_II;
   reg [11 : 0]   B_II1p,   B_II2p;
   reg [11 : 0]   B_II3p,   B_II4p;
   
   reg [11 : 0]              B_III;
   reg [11 : 0]   B_III1p,   B_III2p;
   reg [11 : 0]   B_III3p,   B_III4p;
   
    // registers for Red layer
   reg [11 : 0]     R_I;
   reg [11 : 0]   R_I1p,   R_I2p;
   reg [11 : 0]   R_I3p,   R_I4p;
   
   reg [11 : 0]     R_II;
   reg [11 : 0]   R_II1p,   R_II2p;
   reg [11 : 0]   R_II3p,   R_II4p;
   
   reg [11 : 0]     R_III;
   reg [11 : 0]   R_III1p,   R_III2p;
   reg [11 : 0]   R_III3p,   R_III4p;   
   
   reg [8*3  - 1 : 0] Pixel_shift_register;
   reg [24*1 - 1 : 0] Pixel_output_register;
   
   localparam B  = 16;
   localparam G  =  8;
   localparam R  = 16;
   

   reg  [12 - 1 : 0]   row_counter, row_counterR;  // counter for rows
   reg  [12 - 1 : 0]   col_counter, col_counterR;  // counter for columns
  
   reg  [12*7 - 1 : 0] row_counter_shift;  // shift counter for rows
   reg  [12*7 - 1 : 0] col_counter_shift;  // shift counter for columns
  
   wire [1 : 0]        pixel_mux;
 
	// track for rows and columns
	  always @(posedge clk) begin
		if (rst)begin
				row_counter <= 0;
				col_counter <= 0;
		end else if(s_axis_tvalid)begin
			if(s_axis_tuser)begin
				row_counter <= 0;
				col_counter <= 0;
			end else if (s_axis_tlast) begin
			    row_counter <= 0;
				col_counter <= col_counter + 1;
			end else begin
			    row_counter <= row_counter + 1;
			end // tvalid		
		end  // rst	  
	  end
	  
		always @(posedge clk) begin
           if (s_axis_tvalid)begin
		// read from memory lines to shift registers		   
				case(mux)
					3'b000 : begin
				  shift_1streg_Ip <= {shift_1streg_Ip[8*WSize - 2 : 0], m_axis_tdata_2ndreg};
				  shift_2ndreg_Ip <= {shift_2ndreg_Ip[8*WSize - 2 : 0], m_axis_tdata_3rdreg};
				  shift_3rdreg_Ip <= {shift_3rdreg_Ip[8*WSize - 2 : 0], m_axis_tdata_1streg};				  
							end	
							
					3'b001 : begin
				  shift_1streg_Ip <= {shift_1streg_Ip[8*WSize - 2 : 0], m_axis_tdata_3rdreg};
				  shift_2ndreg_Ip <= {shift_2ndreg_Ip[8*WSize - 2 : 0], m_axis_tdata_1streg};
				  shift_3rdreg_Ip <= {shift_3rdreg_Ip[8*WSize - 2 : 0], m_axis_tdata_2ndreg};				 				  
							end
							
				    3'b010 : begin
				  shift_1streg_Ip <= {shift_1streg_Ip[8*WSize - 2 : 0], m_axis_tdata_1streg};
				  shift_2ndreg_Ip <= {shift_2ndreg_Ip[8*WSize - 2 : 0], m_axis_tdata_2ndreg};
				  shift_3rdreg_Ip <= {shift_3rdreg_Ip[8*WSize - 2 : 0], m_axis_tdata_3rdreg};				  		  
							end				
							
				    default : begin
				  shift_1streg_Ip <= {shift_1streg_Ip[8*WSize - 2 : 0], m_axis_tdata_1streg};
				  shift_2ndreg_Ip <= {shift_2ndreg_Ip[8*WSize - 2 : 0], m_axis_tdata_2ndreg};
				  shift_3rdreg_Ip <= {shift_3rdreg_Ip[8*WSize - 2 : 0], m_axis_tdata_3rdreg};			 			  
							  end				
				endcase
				  row_counterR    <= row_counter;
				  col_counterR    <= col_counter;
				  
				  /***** RGB in pixels position *********/
				  //    G2                                     R1 r2 R3   	r2 = (R1 + R3)/2
				  // G4 g5 G6   g5 = (G4 + G6 + G2 + G8) / 4   r4 r5 r6   	r4 = (R1 + R7)/2
				  //    G8                                     R7 r8 R9   	r5 = (R1 + R3 + R7 + R9)/4
				  
				  /******************************************************/
				  //                               I pipline
				  R_I1p    <= shift_1streg_Ip[8*2 - 1 : 8*1] + shift_3rdreg_Ip[8*2 - 1 : 8*1];     // R1 + R7
				  R_II1p   <= shift_2ndreg_Ip[8*3 - 1 : 8*2] + shift_2ndreg_Ip[8*1 - 1 : 8*0];     // R1 + R3
				  
				  R_III1p  <= shift_1streg_Ip[8*3 - 1 : 8*2] + shift_1streg_Ip[8*1 - 1 : 8*0];	    // R1 + R3
				  R_III2p  <= shift_3rdreg_Ip[8*3 - 1 : 8*2] + shift_3rdreg_Ip[8*1 - 1 : 8*0];	    // R7 + R9
				  
				  G_I1p    <= shift_2ndreg_Ip[8*3 - 1 : 8*2] + shift_2ndreg_Ip[8*1 - 1 : 8*0];	    // G4 + G6
				  G_I2p    <= shift_1streg_Ip[8*2 - 1 : 8*1] + shift_3rdreg_Ip[8*2 - 1 : 8*1];	    // G2 + G8
				  
				  
				  B_I1p    <= shift_1streg_Ip[8*2 - 1 : 8*1] + shift_3rdreg_Ip[8*2 - 1 : 8*1];     // B1 + B7
				  B_II1p   <= shift_2ndreg_Ip[8*3 - 1 : 8*2] + shift_2ndreg_Ip[8*1 - 1 : 8*0];     // B1 + B3
				  
				  B_III1p  <= shift_1streg_Ip[8*3 - 1 : 8*2] + shift_1streg_Ip[8*1 - 1 : 8*0];	    // B1 + B3
				  B_III2p  <= shift_3rdreg_Ip[8*3 - 1 : 8*2] + shift_3rdreg_Ip[8*1 - 1 : 8*0];	    // B7 + B9
				  
				  /******************************************************/
				  //                                II pipline
				  R_I2p    <= R_I1p;
				  R_II2p   <= R_II1p;
				  R_III3p  <= R_III1p + R_III2p;
				  
				  G_I3p    <= G_I1p   + G_I2p;
				  
				  B_I2p    <= B_I1p;
				  B_II2p   <= B_II1p;
				  B_III3p  <= B_III1p + B_III2p;
				  
				  /******************************************************/
				  //                                III pipline
				  R_I3p    <= R_I2p   >> 1;
				  R_II3p   <= R_II2p  >> 1;
				  R_III4p  <= R_III3p >> 2;
				  
				  G_I4p    <= G_I3p   >> 2;
				  
				  B_I3p    <= B_I2p   >> 1;
				  B_II3p   <= B_II2p  >> 1;
				  B_III4p  <= B_III3p >> 2;
				  
			  
				  Pixel_shift_register <= {Pixel_shift_register[8*2 - 1 : 0], shift_2ndreg_Ip[8*2 - 1 : 8*1]};   // III piplines for pure color
				  
				  row_counter_shift    <= {row_counter_shift[12*6 - 1 : 0], row_counter};
				  col_counter_shift    <= {col_counter_shift[12*6 - 1 : 0], col_counter};
				
		   end // s_axis_tvalid
	end
	  
	assign pixel_mux = {col_counter_shift[12*5], row_counter_shift[12*5]}; // difine new pixel position
	
	always @(posedge clk) begin
	            if(row_counter_shift[12*6 - 1 : 12*5] < 12'd3 | col_counter_shift[12*6 - 1 : 12*5] < 10'd2)begin	
                                      Pixel_output_register <= 0;
				end else if (row_counter_shift[12*6 - 1 : 12*5] > Nrows - 2 | col_counter_shift[12*6 - 1 : 12*5] > Ncol - 3) begin
				                      Pixel_output_register <= 0;
				end else begin 
						 case (pixel_mux)
							2'b11:    Pixel_output_register <= {R_I3p[7 : 0],   Pixel_shift_register[8*3 - 1 : 8*2],  B_II3p[7 : 0]};
							2'b10:    Pixel_output_register <= {R_III4p[7 : 0], G_I4p[7 : 0], Pixel_shift_register[8*3 - 1 : 8*2]};
							2'b01:    Pixel_output_register <= {Pixel_shift_register[8*3 - 1 : 8*2], G_I4p[7 : 0],    B_III4p[7 : 0]};
							2'b00:    Pixel_output_register <= {R_II3p[7 : 0], Pixel_shift_register[8*3 - 1 : 8*2],   B_I3p[7 : 0]};
							default:  Pixel_output_register <= Pixel_shift_register[8*3 - 1 : 8*2]; 
						endcase
			    end  // padding by zeros 				
	end						
	
	//*********************************************************************************************************//
	//***************** blue and red layers calculating********************************************************/
	 reg [7 : 0] s_axis_tvalid_shift; // piplined s_axis_tvalid
	 always @(posedge clk) 
	 if(rst)s_axis_tvalid_shift <= 0;
	 else   s_axis_tvalid_shift <= {s_axis_tvalid_shift[6 : 0], s_axis_tvalid};
	 
	 reg [7 : 0] s_axis_tlast_shift; // piplined s_axis_tlast
	 always @(posedge clk) 
	 if(rst)s_axis_tlast_shift <= 0;
	 else   s_axis_tlast_shift <= {s_axis_tlast_shift[6 : 0], s_axis_tlast};
	 
	 reg [7 : 0] s_axis_tuser_shift; // piplined s_axis_tuser
	 always @(posedge clk) 
	 if(rst)s_axis_tuser_shift <= 0;
	 else   s_axis_tuser_shift <= {s_axis_tuser_shift[6 : 0], s_axis_tuser};	 
	 
	 // piplined axi stream interface
	 assign m_axis_tvalid   = s_axis_tvalid_shift[7];
	 assign m_axis_tlast    = s_axis_tlast_shift[7];
	 assign m_axis_tuser    = s_axis_tuser_shift[7];
	 assign m_axis_tdata    = {Pixel_output_register[7 : 0], Pixel_output_register[15 : 8], Pixel_output_register[23 : 16]};
	 
	  
	
	
	
endmodule
