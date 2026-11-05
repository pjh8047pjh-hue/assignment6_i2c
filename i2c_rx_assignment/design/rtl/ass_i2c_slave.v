`timescale 1ns / 1ps

module ass_i2c_slave #(
    parameter [6:0] device_address = 7'h45
) (
    input clk,
    input rstb,
    input scl,
    inout sda
);

wire sda_oe;

assign sda = sda_oe ? 1'b0 : 1'bz;


//=============================================================================
wire start;
wire stop;
wire stop_nack;
wire [7:0] tx_data;
wire [7:0] rx_data;

ass_i2c_slave_serdes #(.device_address(device_address)) u_serdes(
    .clk       (clk), 
    .rstb      (rstb),
    .scl       (scl),
    .sda       (sda),

    .start     (start),
    .stop      (stop),
    .tx_data_in(tx_data),
    .rdy       (rdy),
    .req       (req),
    .stop_nack (stop_nack),
    .rx_data   (rx_data),
    .sda_oe    (sda_oe)
);
//=============================================================================

//=============================================================================
wire we;
wire [7:0] addr;

ass_i2c_slave_pkg_dec u_pkg_dec(
    .clk       (clk),  
    .rstb      (rstb),
    .rdy       (rdy),
    .req       (req),
    .start     (start),
    .stop_nack (stop_nack),
    .rx_data   (rx_data),
    
    .addr      (addr),
    .we        (we)
);
//=============================================================================

//=============================================================================
ass_i2c_slave_rf_v2 u_rf (
    .clk   (clk),
    .addr  (addr[6:0]),
    .wdata (rx_data),
    .we    (we),
    .rdata (tx_data)
);
//=============================================================================
endmodule
