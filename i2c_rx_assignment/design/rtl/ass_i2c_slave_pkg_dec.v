module ass_i2c_slave_pkg_dec (
	input clk,  
	input rstb,
	input rdy,
	input req,
	input start,
	input stop_nack,
	input [7:0] rx_data,
	
	output reg [7:0] addr,
	output we
);
//=============================================================================
//FSM
localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam READ  = 2'd2;
localparam WRITE = 2'd3;

reg [1:0] cstate;
reg [1:0] nstate;
//=============================================================================
// current state logic
always @(posedge clk or negedge rstb) begin
	if(~rstb) begin
		cstate <= IDLE;
	end else begin
		cstate <= nstate;
	end
end
//=============================================================================
// next state logic
always @(*) begin
	nstate = cstate;

	// exit READ state
	if(stop_nack) begin
		nstate = IDLE;
	end
	else if(start) begin
		nstate = START;
	end 
	else begin
		case(cstate)
			IDLE  : nstate = IDLE;
			START : nstate = req ? READ : (rdy ? WRITE : START);
			READ  : nstate = READ;
			WRITE : nstate = WRITE;
		endcase
	end
end
//=============================================================================
// output logic
assign addr_inc = req || (rdy && (cstate == WRITE));
assign we       = (cstate == WRITE) && rdy;
//=============================================================================
// addr setting logic
always @(posedge clk or negedge rstb) begin
    if (~rstb)
        addr <= 8'b0;
    else if ((cstate == START) && rdy) begin
        addr <= rx_data;
    end    
    else if (addr_inc) begin
        addr <= addr + 1'b1;
	end
end
//=============================================================================

endmodule //: ass_i2c_slave_pkg_dec