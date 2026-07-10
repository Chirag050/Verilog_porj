module tb_syncFIFO;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;
    parameter ALMOST_FULL = 12;
    parameter ALMOST_EMPTY = 4;
    
    // Inputs
    reg clk;
    reg rst_n;
    reg wr_en;
    reg [DATA_WIDTH-1:0] din;
    reg rd_en;
    
    // Outputs
    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;
    wire almost_full;
    wire almost_empty;
    
    // Instantiate the RTL
    syncFIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .ALMOST_FULL(ALMOST_FULL),
        .ALMOST_EMPTY(ALMOST_EMPTY)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .din(din),
        .rd_en(rd_en),
        .dout(dout),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty)
    );
    
    // Clock Generation (50MHz)
    always #10 clk = ~clk;
    
    // --- SYSTEMVERILOG ASSERTIONS (SVA) ---
    
    // 1. Reset Check: Flags should immediately evaluate to expected values upon reset
    property p_reset_state;
        @(posedge clk) !rst_n |-> (empty && !full && !almost_full && almost_empty && (uut.wr_ptr == 0) && (uut.rd_ptr == 0));
    endproperty
    a_reset_state: assert property(p_reset_state) else $error("Reset state failed!");

    // 2. Updated Full Flag Check: Matches your concatenation and comparison format
    property p_full_flag;
        @(posedge clk) disable iff (!rst_n)
        ({~uut.wr_ptr[uut.PTR_WIDTH], uut.wr_ptr[uut.PTR_WIDTH-1:0]} == uut.rd_ptr) |-> full;
    endproperty
    a_full_flag: assert property(p_full_flag) else $error("Full flag assertion failed!");

    // 3. Empty Flag Check: Both pointers completely equal
    property p_empty_flag;
        @(posedge clk) disable iff (!rst_n)
        (uut.wr_ptr == uut.rd_ptr) |-> empty;
    endproperty
    a_empty_flag: assert property(p_empty_flag) else $error("Empty flag assertion failed!");

    // 4. Overflow Prevention: Pointer must not advance if write happens while full
    property p_no_overflow;
        @(posedge clk) disable iff (!rst_n)
        (full && wr_en) |=> $stable(uut.wr_ptr);
    endproperty
    a_no_overflow: assert property(p_no_overflow) else $error("FIFO Overflow occurred! wr_ptr changed when full.");

    // 5. Underflow Prevention: Pointer must not advance if read happens while empty
    property p_no_underflow;
        @(posedge clk) disable iff (!rst_n)
        (empty && rd_en) |=> $stable(uut.rd_ptr);
    endproperty
    a_no_underflow: assert property(p_no_underflow) else $error("FIFO Underflow occurred! rd_ptr changed when empty.");

    // 6. Almost Full Flag Check
    property p_almost_full;
        @(posedge clk) disable iff (!rst_n)
        ((uut.current_count >= ALMOST_FULL) && !full) |-> almost_full;
    endproperty
    a_almost_full: assert property(p_almost_full) else $error("Almost Full flag mismatch!");

    // 7. Almost Empty Flag Check
    property p_almost_empty;
        @(posedge clk) disable iff (!rst_n)
        ((uut.current_count <= ALMOST_EMPTY) && !empty) |-> almost_empty;
    endproperty
    a_almost_empty: assert property(p_almost_empty) else $error("Almost Empty flag mismatch!");


    // --- STIMULUS STAGE ---
    initial begin
        // Initialize Signals
        clk = 0;
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        din = 0;
        
        // Hold reset for 2 cycles
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        
        $display("--- Starting FIFO Test Matrix ---");
        
        // Scenario 1: Fill up the FIFO to trigger ALMOST_FULL and FULL flags
        $display("Writing to FIFO until full...");
        while (!full) begin
            @(posedge clk);
            wr_en = 1;
            din = $urandom_range(10, 99);
        end
        @(posedge clk);
        wr_en = 0; // Stop writing
        
        // Scenario 2: Try to write to a FULL FIFO (Testing Overflow Guard)
        $display("Testing overflow exception handling...");
        @(posedge clk);
        wr_en = 1;
        din = 8'hFF;
        @(posedge clk);
        wr_en = 0;

        // Scenario 3: Empty the FIFO completely to trigger ALMOST_EMPTY and EMPTY flags
        $display("Reading from FIFO until empty...");
        while (!empty) begin
            @(posedge clk);
            rd_en = 1;
        end
        @(posedge clk);
        rd_en = 0; // Stop reading

        // Scenario 4: Try to read from an EMPTY FIFO (Testing Underflow Guard)
        $display("Testing underflow exception handling...");
        @(posedge clk);
        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
        
        // Scenario 5: Simultaneous Read and Write
        $display("Testing simultaneous read and write actions...");
        repeat(5) begin
            @(posedge clk);
            wr_en = 1; din = $urandom;
        end
        repeat(10) begin
            @(posedge clk);
            wr_en = 1; rd_en = 1;
            din = $urandom;
        end
        @(posedge clk);
        wr_en = 0; rd_en = 0;

        repeat(5) @(posedge clk);
        $display("--- Test Matrix Completed Successfully! Check console for SVA errors. ---");
        $finish;
    end

endmodule
