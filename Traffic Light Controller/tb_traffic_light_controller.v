`timescale 1ns / 1ps

module tb_traffic_light_controller();

    // 1. Inputs to the Design Under Test (DUT) declared as registers (reg)
    reg clk;
    reg reset;

    // 2. Outputs from the DUT declared as wires
    wire [2:0] light_NS;
    wire [2:0] light_EW;

    // 3. Instantiate the Traffic Light Controller (DUT)
    traffic_light_controller uut (
        .clk(clk),
        .reset(reset),
        .light_NS(light_NS),
        .light_EW(light_EW)
    );

    // 4. Clock Generation (100MHz clock -> 10ns period)
    // Toggles every 5ns
    always begin
        #5 clk = ~clk;
    end

    // 5. Stimulus Block
    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;

        // Apply Reset
        $display("[TIME: %0t] Applying Reset...", $time);
        reset = 1;
        #20;             // Hold reset for 2 clock cycles
        reset = 0;       // Release reset
        $display("[TIME: %0t] Reset Released. System Started.", $time);

        // Let the simulation run long enough to observe full cycles
        // Green duration is 10 cycles (100ns), Yellow is 3 cycles (30ns)
        // Full loop = (10 + 3 + 10 + 3) * 10ns = 260ns
        #300;

        // Apply reset midway to test robustness/emergency reset
        $display("[TIME: %0t] Testing mid-cycle Reset...", $time);
        reset = 1;
        #20;
        reset = 0;

        // Run further to see it recover from reset
        #200;

        // End Simulation
        $display("[TIME: %0t] Simulation Completed.", $time);
        $finish;
    end
      
    // 6. Optional: Monitor output changes in the Tcl Console
    initial begin
        $monitor("Time=%0t | Reset=%b | NS Light [R,Y,G]=%b | EW Light [R,Y,G]=%b", 
                 $time, reset, light_NS, light_EW);
    end

endmodule
