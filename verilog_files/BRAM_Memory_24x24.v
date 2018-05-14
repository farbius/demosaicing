
////////////////////////////////////////////////////////////////////////////////
// Company:     Riftek
// Engineer:    Alexey Rostov
// Email:       a.rostov@riftek.com 
// Create Date: 05/05/18
// Design Name: demosaicing
////////////////////////////////////////////////////////////////////////////////

module BRAM_Memory_24x24
#(
	parameter								ADDR_BITS		= 11
)
(
	input									a_clk,
	input									a_wr,
	input		[ADDR_BITS-1 : 0]			a_addr,
	input		[8-1 : 0]					a_data_in,
	output reg	[8-1 : 0]					a_data_out,
	
	input									b_clk,
	input									b_wr,
	input		[ADDR_BITS-1 : 0]			b_addr,
	input		[8-1 : 0]					b_data_in,
	output reg	[8-1 : 0]					b_data_out,
	input									b_data_en
);

//ќсновной регистр, в котором хран¤тс¤ данные
(* ram_style = "bram" *)
reg			[8-1 : 0]						Memory[(2**ADDR_BITS)-1 : 0];

integer										Idx;

initial
begin
	for (Idx = 0; Idx < ((2**ADDR_BITS)-1); Idx=Idx+1)	Memory[Idx]		<= 0;
	b_data_out		<= 0;
end

always @(posedge a_clk)
begin
	a_data_out		<= Memory[a_addr];
	if (a_wr)	Memory[a_addr]	<= a_data_in;
end

always @(posedge b_clk)
begin
	b_data_out		<= (b_data_en) ? Memory[b_addr] : b_data_out;
	if (b_wr)	Memory[b_addr]	<= a_data_in;
end


endmodule