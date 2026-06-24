module apb3_slave (
    input  wire        PCLK,           
    input  wire        PRESETn,        
    
    // APB Bus Inputs
    input  wire [31:0] PADDR,          
    input  wire        PSEL,           
    input  wire        PENABLE,        
    input  wire        PWRITE,         
    input  wire [31:0] PWDATA,         
    
    // APB Bus Outputs
    output reg  [31:0] PRDATA,         
    output wire        PREADY,         // Converted to continuous wire
    output reg         PSLVERR         
);

    // Using a 2D array (memory array) instead of 4 unique variables.
    // This allows the synthesis tool to use highly optimized structure/MUX loops.
    reg [31:0] regs [0:3]; 

    // Address Decode Indexing: Look at bits [3:2] to differentiate 0x00, 0x04, 0x08, 0x0C
    wire [1:0] reg_idx       = PADDR[3:2];
    // Optimized Address validation: Valid if lower 2 bits are 0 (word-aligned) and address is <= 0x0C
    wire       valid_address = (PADDR[7:4] == 4'h0) && (PADDR[1:0] == 2'b00);

    // Optimization: Tie PREADY directly to PSEL to save logic and timing paths
    assign PREADY = PSEL;

    // Combinational Logic for PRDATA and PSLVERR
    always @(*) begin
        PSLVERR = 1'b0;
        PRDATA  = 32'h0;
        
        if (PSEL) begin
            if (valid_address) begin
                if (!PWRITE) begin
                    PRDATA = regs[reg_idx]; // Clean array access instead of case statement
                end
            end else begin
                PSLVERR = 1'b1;
                PRDATA  = 32'hFFFFFFFF; // Combined error data assignment here
            end
        end
    end

    // Sequential Write Block (Updated with Case Logic)
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            regs[0] <= 32'h0;
            regs[1] <= 32'h0;
            regs[2] <= 32'h0;
            regs[3] <= 32'h0;
        end else if (PSEL && PENABLE && PWRITE && valid_address) begin
            case (reg_idx)
                2'b00:   regs[0] <= PWDATA; // Corresponds to PADDR = 32'h00
                2'b01:   regs[1] <= PWDATA; // Corresponds to PADDR = 32'h04
                2'b10:   regs[2] <= PWDATA; // Corresponds to PADDR = 32'h08
                2'b11:   regs[3] <= PWDATA; // Corresponds to PADDR = 32'h0C
                default: ;                  // Handled by valid_address check
            endcase
        end
    end
endmodule
