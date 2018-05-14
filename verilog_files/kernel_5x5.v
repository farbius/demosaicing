
module kernel_5x5#(
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
   input [8-1 : 0] s_axis_tdata,
   output s_axis_tready,
// master axi stream interface    
   output m_axis_tvalid,
   output m_axis_tuser,
   output m_axis_tlast,
   output [23 : 0] m_axis_tdata,
   input  m_axis_tready 
    );
	
	
    localparam RAM_ADDR_BITS = 11; 
    
    reg [RAM_ADDR_BITS-1:0] read_addr, write_adr_1st;
	
    reg [RAM_ADDR_BITS-1:0] write_adr_4th, write_adr_2nd;
    reg [RAM_ADDR_BITS-1:0] write_adr_5th, write_adr_3rd;
	
    wire a_wr_1st, a_wr_2nd, a_wr_3rd, a_wr_4th, a_wr_5th;

    reg [2 : 0] mux;
      
    wire  [8-1 : 0] m_axis_tdata_1streg;
    wire  [8-1 : 0] m_axis_tdata_2ndreg;
    wire  [8-1 : 0] m_axis_tdata_3rdreg;
	wire  [8-1 : 0] m_axis_tdata_4threg;
    wire  [8-1 : 0] m_axis_tdata_5threg;

 
  
//// count of five lines  
    always @(posedge clk)begin
        if(rst | s_axis_tuser)begin
            mux <= 0;
        end else if(s_axis_tlast)begin
            if(mux == 3'b100)begin
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
			
     always @(posedge clk)
            if (a_wr_4th)write_adr_4th <= write_adr_4th + 1;
            else if(rst | s_axis_tlast)write_adr_4th <= 0;
			
     always @(posedge clk)
            if (a_wr_5th)write_adr_5th <= write_adr_5th + 1;
            else if(rst | s_axis_tlast)write_adr_5th <= 0;
 
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
   assign a_wr_4th   = (mux == 3'b011 & s_axis_tvalid) ? 1'b1 : 1'b0;
   assign a_wr_5th   = (mux == 3'b100 & s_axis_tvalid) ? 1'b1 : 1'b0;

   // 5 buffers for keeping lines   
   BRAM_Memory_24x24 #(11) i0 (.a_clk(clk), .a_wr(a_wr_1st), .a_addr(write_adr_1st), .a_data_in(s_axis_tdata), .a_data_out(), 
   .b_clk(clk), .b_wr(1'b0), .b_addr(read_addr), .b_data_in(), .b_data_out(m_axis_tdata_1streg), .b_data_en(1'b1));
   
   BRAM_Memory_24x24 #(11) i1 (.a_clk(clk), .a_wr(a_wr_2nd), .a_addr(write_adr_2nd), .a_data_in(s_axis_tdata), .a_data_out(), 
   .b_clk(clk), .b_wr(1'b0), .b_addr(read_addr), .b_data_in(), .b_data_out(m_axis_tdata_2ndreg), .b_data_en(1'b1));
   
   BRAM_Memory_24x24 #(11) i2 (.a_clk(clk), .a_wr(a_wr_3rd), .a_addr(write_adr_3rd), .a_data_in(s_axis_tdata), .a_data_out(), 
   .b_clk(clk), .b_wr(1'b0), .b_addr(read_addr), .b_data_in(), .b_data_out(m_axis_tdata_3rdreg), .b_data_en(1'b1));
   
   BRAM_Memory_24x24 #(11) i3 (.a_clk(clk), .a_wr(a_wr_4th), .a_addr(write_adr_4th), .a_data_in(s_axis_tdata), .a_data_out(), 
   .b_clk(clk), .b_wr(1'b0), .b_addr(read_addr), .b_data_in(), .b_data_out(m_axis_tdata_4threg), .b_data_en(1'b1));
   
   BRAM_Memory_24x24 #(11) i4 (.a_clk(clk), .a_wr(a_wr_5th), .a_addr(write_adr_5th), .a_data_in(s_axis_tdata), .a_data_out(), 
   .b_clk(clk), .b_wr(1'b0), .b_addr(read_addr), .b_data_in(), .b_data_out(m_axis_tdata_5threg), .b_data_en(1'b1));
   
   localparam WSize = 5;
   
   reg  [8*WSize - 1 : 0] shift_1streg_Ip;
   reg  [8*WSize - 1 : 0] shift_2ndreg_Ip;
   reg  [8*WSize - 1 : 0] shift_3rdreg_Ip;
   reg  [8*WSize - 1 : 0] shift_4threg_Ip;
   reg  [8*WSize - 1 : 0] shift_5threg_Ip;
   
   reg  [8*WSize - 1 : 0] shift_1streg_IIp;
   reg  [8*WSize - 1 : 0] shift_2ndreg_IIp;
   reg  [8*WSize - 1 : 0] shift_3rdreg_IIp;
   reg  [8*WSize - 1 : 0] shift_4threg_IIp;
   reg  [8*WSize - 1 : 0] shift_5threg_IIp;
   
   reg  [7 + 4 : 0] DeltaH_I1p,   DeltaV_I1p;   // 5 adds or substractions
   reg  [7 + 4 : 0] DeltaH_I2p,   DeltaV_I2p;   // 5 adds or substractions
   reg  [7 + 4 : 0] DeltaH_I3p,   DeltaV_I3p;   // 5 adds or substractions
   reg  [7 + 4 : 0] DeltaH_I4p,   DeltaV_I4p;   // 5 adds or substractions
   reg  [7 + 4 : 0] DeltaH_I5p,   DeltaV_I5p;   // 5 adds or substractions
   reg  [7 + 4 : 0] DeltaH_I6p,   DeltaV_I6p;   // 5 adds or substractions
   reg  [7 + 4 : 0] DeltaH_I7p,   DeltaV_I7p;   // 5 adds or substractions
   reg  [7 + 4 : 0] DeltaH_Ip,     DeltaV_Ip;   // 5 adds or substractions
   // registers for Green layer
   reg signed [7 + 4 : 0]              G_I,    G_II,   G_III;
   reg signed [7 + 4 : 0]   G_I1p,   G_I2p;
   reg signed [7 + 4 : 0]   G_I3p,   G_I4p,   G_I5p, G_I6p;
   reg signed [7 + 4 : 0]  G_II1p,  G_II2p;
   reg signed [7 + 4 : 0]  G_II3p,  G_II4p,  G_II5p, G_II6p;
   reg signed [7 + 4 : 0] G_III1p, G_III2p, G_III3p, G_III4p, G_III5p;
   
   reg [7 + 0 : 0] G_out1p; 
   reg [24 - 1: 0] G_out;
   
   reg [8*5 - 1 : 0] Pixel_shift_register;
   
   localparam B = 16;
   localparam G =  8;
   localparam R = 16;

   
   // function for compuiting abs of substraction
   function [11 : 0] abs_sub;
     input  [11 : 0] a_Value;      
        begin
          if(a_Value[11] == 1'b1) abs = ~(a_Value) + 1;
          else abs = a_Value;
        end
  endfunction
  
  reg  [12 - 1 : 0] row_counter, row_counterR;  // counter for rows
  reg  [12 - 1 : 0] col_counter, col_counterR;  // counter for columns
  
  reg [12*7 - 1 : 0] row_counter_shift;  // shift counter for rows
  reg [12*7 - 1 : 0] col_counter_shift;  // shift counter for columns
 
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
				  shift_3rdreg_Ip <= {shift_3rdreg_Ip[8*WSize - 2 : 0], m_axis_tdata_4threg};
				  shift_4threg_Ip <= {shift_4threg_Ip[8*WSize - 2 : 0], m_axis_tdata_5threg};
				  shift_5threg_Ip <= {shift_5threg_Ip[8*WSize - 2 : 0], m_axis_tdata_1streg};
							end	
							
					3'b001 : begin
				  shift_1streg_Ip <= {shift_1streg_Ip[8*WSize - 2 : 0], m_axis_tdata_3rdreg};
				  shift_2ndreg_Ip <= {shift_2ndreg_Ip[8*WSize - 2 : 0], m_axis_tdata_4threg};
				  shift_3rdreg_Ip <= {shift_3rdreg_Ip[8*WSize - 2 : 0], m_axis_tdata_5threg};
				  shift_4threg_Ip <= {shift_4threg_Ip[8*WSize - 2 : 0], m_axis_tdata_1streg};
				  shift_5threg_Ip <= {shift_5threg_Ip[8*WSize - 2 : 0], m_axis_tdata_2ndreg};				  
							end
							
				    3'b010 : begin
				  shift_1streg_Ip <= {shift_1streg_Ip[8*WSize - 2 : 0], m_axis_tdata_4threg};
				  shift_2ndreg_Ip <= {shift_2ndreg_Ip[8*WSize - 2 : 0], m_axis_tdata_5threg};
				  shift_3rdreg_Ip <= {shift_3rdreg_Ip[8*WSize - 2 : 0], m_axis_tdata_1streg};
				  shift_4threg_Ip <= {shift_4threg_Ip[8*WSize - 2 : 0], m_axis_tdata_2ndreg};
				  shift_5threg_Ip <= {shift_5threg_Ip[8*WSize - 2 : 0], m_axis_tdata_3rdreg};			  
							end
							
					3'b011 : begin
				  shift_1streg_Ip <= {shift_1streg_Ip[8*WSize - 2 : 0], m_axis_tdata_5threg};
				  shift_2ndreg_Ip <= {shift_2ndreg_Ip[8*WSize - 2 : 0], m_axis_tdata_1streg};
				  shift_3rdreg_Ip <= {shift_3rdreg_Ip[8*WSize - 2 : 0], m_axis_tdata_2ndreg};
				  shift_4threg_Ip <= {shift_4threg_Ip[8*WSize - 2 : 0], m_axis_tdata_3rdreg};
				  shift_5threg_Ip <= {shift_5threg_Ip[8*WSize - 2 : 0], m_axis_tdata_4threg};				  
							end
							
					3'b100 : begin
				  shift_1streg_Ip <= {shift_1streg_Ip[8*WSize - 2 : 0], m_axis_tdata_1streg};
				  shift_2ndreg_Ip <= {shift_2ndreg_Ip[8*WSize - 2 : 0], m_axis_tdata_2ndreg};
				  shift_3rdreg_Ip <= {shift_3rdreg_Ip[8*WSize - 2 : 0], m_axis_tdata_3rdreg};
				  shift_4threg_Ip <= {shift_4threg_Ip[8*WSize - 2 : 0], m_axis_tdata_4threg};
				  shift_5threg_Ip <= {shift_5threg_Ip[8*WSize - 2 : 0], m_axis_tdata_5threg};				  
							end
							
				    default : begin
				  shift_1streg_Ip <= {shift_1streg_Ip[8*WSize - 2 : 0], m_axis_tdata_4threg};
				  shift_2ndreg_Ip <= {shift_2ndreg_Ip[8*WSize - 2 : 0], m_axis_tdata_5threg};
				  shift_3rdreg_Ip <= {shift_3rdreg_Ip[8*WSize - 2 : 0], m_axis_tdata_1streg};
				  shift_4threg_Ip <= {shift_4threg_Ip[8*WSize - 2 : 0], m_axis_tdata_2ndreg};
				  shift_5threg_Ip <= {shift_5threg_Ip[8*WSize - 2 : 0], m_axis_tdata_3rdreg};				  
							  end				
				endcase
				// I pipline stage								  
				  row_counterR     <= row_counter;
				  col_counterR     <= col_counter;
				  				  
				  /******deltaH/deltaV calculating*********/
					if(col_counterR[0] == 1'b0)begin // define red or blue layer
				  // B layer
				  DeltaH_I1p <= shift_3rdreg_Ip[8*3 - 1 : 8*2] - shift_3rdreg_Ip[8*5 - 1 : 8*4];		    // I   pipline
				  DeltaH_I2p <= shift_3rdreg_Ip[8*3 - 1 : 8*2] - shift_3rdreg_Ip[8   - 1 : 0];	            // I   pipline
				    end else begin
				  // R layer
				  DeltaH_I1p <= shift_3rdreg_Ip[8*3 - 1 : 8*2] - shift_3rdreg_Ip[8*5 - 1 : 8*4];		    // I   pipline
				  DeltaH_I2p <= shift_3rdreg_Ip[8*3 - 1 : 8*2] - shift_3rdreg_Ip[8   - 1 : 0];		        // I   pipline
					end				  
				  DeltaH_I3p <= shift_3rdreg_Ip[8*4 - 1 : 8*3] - shift_3rdreg_Ip[8*2 - 1 : 8];	            // I   pipline
				  DeltaH_I4p <= abs_sub(DeltaH_I3p);													    // II  pipline
				  DeltaH_I5p <= abs_sub(DeltaH_I1p);								   				        // II  pipline
				  DeltaH_I6p <= abs_sub(DeltaH_I2p);														// II  pipline
				  DeltaH_I7p <= DeltaH_I4p + DeltaH_I5p;													// III pipline
				  DeltaH_Ip  <= DeltaH_I6p + DeltaH_I7p;													// IV  pipline
				  
					if(col_counterR[0] == 1'b0)begin // define red or blue layer
				  // B layer
				  DeltaV_I1p <= shift_3rdreg_Ip[8*3 - 1 : 8*2]  - shift_1streg_Ip[8*3 - 1 : 8*2];			// I   pipline
				  DeltaV_I2p <= shift_3rdreg_Ip[8*3 - 1 : 8*2]  - shift_5threg_Ip[8*3 - 1 : 8*2];			// I   pipline
					end else begin
				  // R layer
				  DeltaV_I1p <= shift_3rdreg_Ip[8*3 - 1  : 8*2] - shift_1streg_Ip[8*3 - 1 : 8*2];			// I   pipline
				  DeltaV_I2p <= shift_3rdreg_Ip[8*3 - 1  : 8*2] - shift_5threg_Ip[8*3 - 1 : 8*2];			// I   pipline
				    end
				  
				  DeltaV_I3p <= shift_2ndreg_Ip[8*3 - 1  : 8*2] - shift_4threg_Ip[8*3 - 1 : 8*2];			// I   pipline	
                  
				  DeltaV_I4p <= abs_sub(DeltaV_I3p);				  										// II  pipline
				  DeltaV_I5p <= abs_sub(DeltaV_I1p);									                    // II  pipline
				  DeltaV_I6p <= abs_sub(DeltaV_I2p);														// II  pipline
				  DeltaV_I7p <= DeltaV_I4p + DeltaV_I5p;													// III pipline
				  DeltaV_Ip  <= DeltaV_I6p + DeltaV_I7p;													// IV  pipline
				  /****************************************/
				  
				  /******G color calculating**************/
				  
				  // case DeltaH_Ip < DeltaV_Ip
				  
				  if(col_counterR[0] == 1'b0)begin // define red or blue layer
				  // B layer
				  G_I1p <= shift_3rdreg_Ip[8*3 - 1 : 8*2] - shift_3rdreg_Ip[8*5 - 1 : 8*4];					// I   pipline
				  G_I2p <= shift_3rdreg_Ip[8*3 - 1 : 8*2] - shift_3rdreg_Ip[8   - 1 : 0];					// I   pipline
				  end else begin
				  // R layer
				  G_I1p <= shift_3rdreg_Ip[8*3 - 1 : 8*2] - shift_3rdreg_Ip[8*5 - 1 : 8*4];					// I   pipline
				  G_I2p <= shift_3rdreg_Ip[8*3 - 1 : 8*2] - shift_3rdreg_Ip[8   - 1 :   0];					// I   pipline
				  end
				  
				  G_I3p <= shift_3rdreg_Ip[8*4 - 1 : 8*3] + shift_3rdreg_Ip[8*2 - 1 : 8];					// I   pipline
				  G_I4p <= G_I1p + G_I2p;																	// II  pipline
				  G_I5p <= G_I3p >> 1; 																		// II  pipline
				  G_I6p <= G_I5p + (G_I4p >> 2);															// III pipline
				  G_I   <= G_I6p;																			// IV  pipline
				  // case DeltaH_Ip > DeltaV_Ip
				  
				  if(col_counterR[0] == 1'b0)begin // define red or blue layer
				  // B layer
				  G_II1p <= shift_3rdreg_Ip[8*3 - 1 : 8*2] - shift_1streg_Ip[8*3 - 1 : 8*2];    			// I   pipline
				  G_II2p <= shift_3rdreg_Ip[8*3 - 1 : 8*2] - shift_5threg_Ip[8*3 - 1 : 8*2];		        // I   pipline
				  end else begin
				  // R layer
				  G_II1p <= shift_3rdreg_Ip[8*3 - 1  : 8*2] - shift_1streg_Ip[8*3 - 1 : 8*2];				// I   pipline
				  G_II2p <= shift_3rdreg_Ip[8*3 - 1  : 8*2] - shift_5threg_Ip[8*3 - 1 : 8*2];				// I   pipline
				  end
				  
				  
				  G_II3p <= shift_2ndreg_Ip[8*3 - 1 : 8*2] + shift_4threg_Ip[8*3 - 1 : 8*2];				// I   pipline
				  G_II4p <= G_II1p + G_II2p;																// II  pipline
				  G_II5p <= G_II3p >> 1;                                                                    // II  pipline
				  G_II6p <= G_II5p + (G_II4p >> 2);															// III pipline
				  G_II   <= G_II6p;																			// IV  pipline
				  // case DeltaH_Ip = DeltaV_Ip
				  
				  G_III1p <= G_I3p +  G_II3p;																// II   pipline
				  G_III2p <= G_I1p  + G_I2p;																// II   pipline
				  G_III3p <= G_II1p + G_II2p;																// II   pipline
				  G_III4p <= (G_III2p) + (G_III3p);															// III  pipline
				  G_III5p <= G_III1p << 1;																	// III  pipline
				  G_III   <= G_III5p + G_III4p;																// IV   pipline
				  
				  row_counter_shift <= {row_counter_shift[12*6 - 1 : 0], row_counter};
				  col_counter_shift <= {col_counter_shift[12*6 - 1 : 0], col_counter};
				  			  			  
				  /****************************************/
				  //         G output	                 */	
				  Pixel_shift_register <= {Pixel_shift_register[8*4 - 1 : 0], shift_3rdreg_IIp[8*3 - 1 : 8*2]};   	// V piplines for pure G color
				  
				  if(DeltaH_Ip < DeltaV_Ip)      G_out1p <=   G_I[7 : 0];											// V    pipline
				  else if (DeltaH_Ip > DeltaV_Ip)G_out1p <=  G_II[7 : 0];											// V    pipline
				  else                           G_out1p <=  G_III >> 3;											// V    pipline
				  
				 

                if(row_counter_shift[12*7 - 1 : 12*6] < 12'd6 | col_counter_shift[12*7 - 1 : 12*6] < 12'd4)begin	
                                G_out <= 0;
				end else if (row_counter_shift[12*7 - 1 : 12*6] > Nrows - 2 | col_counter_shift[12*7 - 1 : 12*6] > Ncol - 4) begin
				                G_out <= 0;
				end else begin	 
				
					 if(row_counter_shift[12*6] == 1'b0 & col_counter_shift[12*6] == 1'b0)begin
							G_out <= Pixel_shift_register[8*5 - 1 : 8*4];												   // VI pipline
					 end else if(row_counter_shift[12*6] == 1'b1 & col_counter_shift[12*6] == 1'b0)begin
							G_out <= {Pixel_shift_register[8*5 - 1 : 8*4],G_out1p,Pixel_shift_register[8*5 - 1 : 8*4]};    // VI pipline
					 end else if(row_counter_shift[12*6] == 1'b0 & col_counter_shift[12*6] == 1'b1)begin
							G_out <= {Pixel_shift_register[8*5 - 1 : 8*4],G_out1p,Pixel_shift_register[8*5 - 1 : 8*4]};    // VI pipline
					 end else begin
							G_out <= Pixel_shift_register[8*5 - 1 : 8*4];												   // VI pipline
					 end
				  
				end // padding by zeros
			  				  
		   end // s_axis_tvalid
	end
	
	//*********************************************************************************************************//
	//***************** blue and red layers calculating********************************************************/
	 reg [13 : 0] s_axis_tvalid_shift; // piplined s_axis_tvalid
	 always @(posedge clk) 
	 if(rst)s_axis_tvalid_shift <= 0;
	 else   s_axis_tvalid_shift <= {s_axis_tvalid_shift[12 : 0], s_axis_tvalid};
	 
	 reg [13 : 0] s_axis_tlast_shift; // piplined s_axis_tlast
	 always @(posedge clk) 
	 if(rst)s_axis_tlast_shift <= 0;
	 else   s_axis_tlast_shift <= {s_axis_tlast_shift[12 : 0], s_axis_tlast};
	 
	 reg [13 : 0] s_axis_tuser_shift; // piplined s_axis_tuser
	 always @(posedge clk) 
	 if(rst)s_axis_tuser_shift <= 0;
	 else   s_axis_tuser_shift <= {s_axis_tuser_shift[12 : 0], s_axis_tuser};	 
	
	 
	 // piplined axi stream interface
	 assign m_axis_tvalid   = s_axis_tvalid_shift[10];
	 assign m_axis_tlast    = s_axis_tlast_shift[10];
	 assign m_axis_tuser    = s_axis_tuser_shift[10];
	 assign m_axis_tdata    = G_out;
    
    
    
    
endmodule
