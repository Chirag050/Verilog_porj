`timescale 1ns / 1ps

module tb_even_parity_fsm;

    // Inputs to the FSM
    reg clk;
    reg rst_n;
    reg data_in;

    // Output from the FSM
    wire even_out;

    // Instantiate the FSM module
    even_parity_fsm uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .data_in(data_in), 
        .even_out(even_out)
    );

    // Clock Generator: Toggles every 10ns (Creates a 20ns clock cycle period)
    always #10 clk = ~clk;

    // -------------------------------------------------------------
    // Task to automatically send an 8-bit pattern to the FSM
    // -------------------------------------------------------------
    task send_8bit_pattern(input [7:0] pattern);
        integer i;
        begin
            $display("---------------------------------------");
            $display("Testing 8-bit Pattern: %b", pattern);
            
            // 1. Reset the FSM before starting a new pattern
            rst_n = 0; 
            #20; 
            rst_n = 1;

            // 2. Feed each bit sequentially (from right/LSB to left/MSB)
            for (i = 0; i < 8; i = i + 1) begin
                data_in = pattern[i];
                #20; // Wait 1 clock cycle for the FSM to read the bit
            end
            
            // 3. Print the final result after 8 clock cycles
            if (even_out == 1'b1)
                $display("Result: EVEN number of 1s detected! [HIGH Output]");
            else
                $display("Result: ODD number of 1s detected!  [LOW Output]");
        end
    endtask

    // -------------------------------------------------------------
    // Main Test Stimulus
    // -------------------------------------------------------------
    initial begin
        // Initialize Signals
        clk = 0;
        rst_n = 0;
        data_in = 0;

        // Wait a brief moment for setup
        #20;

        // Directly test 5 different 8-bit patterns line-by-line
        send_8bit_pattern(8'b00000000); // 0 ones -> Even (Should be HIGH)
        send_8bit_pattern(8'b10101010); // 4 ones -> Even (Should be HIGH)
        send_8bit_pattern(8'b11111111); // 8 ones -> Even (Should be HIGH)
        send_8bit_pattern(8'b00000001); // 1 one  -> Odd  (Should be LOW)
        send_8bit_pattern(8'b11010011); // 5 ones -> Odd  (Should be LOW)

        // End the simulation
        #40;
        $finish;
    end
      
endmodule
