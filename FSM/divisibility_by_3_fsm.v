module divisibility_by_3_fsm (
    input clk,
    input rst,
    input din,             // Serial binary input (MSB first)
    output reg divisible   // High if number is divisible by 3
);

    // State Encoding
    parameter S0 = 2'b00; // Remainder 0
    parameter S1 = 2'b01; // Remainder 1
    parameter S2 = 2'b10; // Remainder 2

    reg [1:0] current_state, next_state;

    // 1. State Register Sequential Block
    always @(posedge clk or posedge rst) begin
        if (rst) 
            current_state <= S0; 
        else 
            current_state <= next_state;
    end

    // 2. Next State Combinational Logic Block
    always @(*) begin
        case (current_state)
            S0: begin
                if (din == 1'b0) next_state = S0;
                else             next_state = S1;
            end
            S1: begin
                if (din == 1'b0) next_state = S2;
                else             next_state = S0;
            end
            S2: begin
                if (din == 1'b0) next_state = S1;
                else             next_state = S2;
            end
            default: next_state = S0;
        endcase
    end

    // 3. Output Logic Block (Moore Style: Dependent only on state)
    always @(*) begin
        if (current_state == S0)
            divisible = 1'b1;
        else
            divisible = 1'b0;
    end

endmodule
