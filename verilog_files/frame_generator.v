`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company:     Riftek
// Engineer:    Aleksei Rostov
// Email:       farbius@protonmail.com
// Create Date: 05/05/18
// Design Name: demosaicing
////////////////////////////////////////////////////////////////////////////////

module frame_generator #(
parameter Nrows = 349,
parameter Ncol  = 349) // parameter for size of picture
(
input   clk,
input   rst,
output  SOF, 
output  EOL,
output DVAL,
output  read_done,
output [8 - 1 : 0] pixel
    );
    
    function integer clogb2 (input integer depth);
     begin
         depth = depth -1;
        for(clogb2 = 0; depth > 0;clogb2 = clogb2 + 1)begin
         depth = depth >> 1;
        end
     end
     endfunction
	 
	 function integer multply (input integer row, input integer column);
     begin
         multply = row * column;       
     end
     endfunction
     
    localparam Naddr = clogb2(N);
	localparam N     = multply(Nrows, Ncol);
    
    reg  [7:0] BayerData [0 : N -1];
    
    
     reg  [7:0] BayerData_reg;
    
     
     // address  
     reg [22-1 : 0] address;
	 reg data_valid;
	 reg data_last;
	 reg [12 - 1 : 0] row;
	 reg [12 - 1 : 0] column;
	 
	 reg [23 : 0] test_data;
    
    assign pixel     =  BayerData_reg;
    assign read_done = (address == N)?1'b1 : 1'b0;
	assign SOF       = (row == 12'd1 & column == 12'd0)?1'b1 : 1'b0;
	assign EOL       = (row == Nrows)?1'b1 : 1'b0;
	assign DVAL      =  data_valid;
    
    initial $readmemh("BayerData.txt", BayerData, 0, N -1);
    

   always @(posedge clk)begin    
    if(rst)begin
        address    <= 0;
		data_valid <= 0;
		row        <= 0;
		column     <= 0;  
        test_data  <= 0;	
    end else begin
	
		if(row == Nrows)begin
		    row <= 1;
				   if(column == Ncol - 1) begin 
						column <= 0;
					   address <= 0;
                   end else begin 
						column <= column + 1;
					   address <= address + 1;
				   end				   
		end else begin
		         row   <= row + 1;
		    address    <= address + 1;
			data_valid <= 1;
		end
		
		test_data <= test_data + 1;
		
		
	end
   end // always
    
 // read example from memory   
   always @(posedge clk)
        if(rst)
         BayerData_reg <= 0;
        else
         BayerData_reg <= BayerData[address];
             
    
    
endmodule
