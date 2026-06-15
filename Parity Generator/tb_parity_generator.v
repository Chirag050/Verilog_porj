`timescale 1ns / 1ps

module tb_parity_generator();
    reg [7:0] tb_data_in;
    wire tb_even_bit;
    wire tb_odd_bit;

    parity_generator uut (
        .data_in(tb_data_in),
        .even_bit(tb_even_bit),
        .odd_bit(tb_odd_bit)
    );

    initial begin

        tb_data_in = 8'b00000000;
        #10;
        
        tb_data_in = 8'b00000001;
        #10;
        
        tb_data_in = 8'b00000011;
        #10;
        
        tb_data_in = 8'b01000101;
        #10;
        
        tb_data_in = 8'b10101010;
        #10;
        
        tb_data_in = 8'b11111111;
        #10;

        $finish; // End simulation
    end
endmodule
