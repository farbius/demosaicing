
////////////////////////////////////////////////////////////////////////////////
// Company:     Riftek
// Engineer:    Alexey Rostov
// Email:       a.rostov@riftek.com 
// Create Date: 05/05/18
// Design Name: demosaicing
////////////////////////////////////////////////////////////////////////////////

module demosaicing#(
parameter Nrows = 349,
parameter Ncol  = 349) //  amount of lines in the frame
(
    input clk,
    input rst,
// slave axi stream interface   
    input s_axis_tvalid,
    input s_axis_tuser,
    input s_axis_tlast,
    input [8 - 1 : 0] s_axis_tdata,
    output s_axis_tready,
// master axi stream interface    
    output m_axis_tvalid,
    output m_axis_tuser,
    output m_axis_tlast,
    output [23 : 0] m_axis_tdata,
    input  m_axis_tready 
    );
    
  
	  kernel_3x3 #(Nrows, Ncol)  i1 (.clk(clk),.rst(rst),.s_axis_tvalid(s_axis_tvalid),.s_axis_tuser(s_axis_tuser),.s_axis_tlast(s_axis_tlast),
	       .s_axis_tdata(s_axis_tdata),.s_axis_tready(s_axis_tready),  .m_axis_tvalid(m_axis_tvalid),.m_axis_tuser(m_axis_tuser),
			 .m_axis_tlast(m_axis_tlast),.m_axis_tdata(m_axis_tdata),    .m_axis_tready(m_axis_tready)); 
			  
//	kernel_5x5 #(Nrows, Ncol)  i1 (.clk(clk),.rst(rst),.s_axis_tvalid(s_axis_tvalid),.s_axis_tuser(s_axis_tuser),.s_axis_tlast(s_axis_tlast),
//	       .s_axis_tdata(s_axis_tdata),.s_axis_tready(s_axis_tready),  .m_axis_tvalid(m_axis_tvalid),.m_axis_tuser(m_axis_tuser),
//			 .m_axis_tlast(m_axis_tlast),.m_axis_tdata(m_axis_tdata),    .m_axis_tready(m_axis_tready));    

	  
    
endmodule