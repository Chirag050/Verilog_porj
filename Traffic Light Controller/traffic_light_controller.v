module traffic_light_controller (
    input wire clk,
    input wire reset,
    output reg [2:0] light_NS, // [Red, Yellow, Green]
    output reg [2:0] light_EW  // [Red, Yellow, Green]
);

    // State Encoding
    parameter NS_GREEN  = 2'b00,
              NS_YELLOW = 2'b01,
              EW_GREEN  = 2'b10,
              EW_YELLOW = 2'b11;

    // Output Bit Encoding
    parameter RED    = 3'b100,
              YELLOW = 3'b010,
              GREEN  = 3'b001;

    // Timing Constants (adjust based on your clock frequency)
    // For simulation/demonstration, we use small cycles
    parameter GREEN_DURATION = 4'd10; // 10 clock cycles
    parameter YELLOW_DURATION = 4'd3;  // 3 clock cycles

    reg [1:0] current_state, next_state;
    reg [3:0] timer;

    // 1. Sequential State and Timer Register Block
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= NS_GREEN;
            timer <= 0;
        end else begin
            // Increment timer or reset it on state change
            if (current_state != next_state) begin
                timer <= 0;
            end else begin
                timer <= timer + 1;
            end
            current_state <= next_state;
        end
    end

    // 2. Combinational Next-State Logic Block
    always @(*) begin
        case (current_state)
            NS_GREEN: begin
                if (timer >= GREEN_DURATION - 1)
                    next_state = NS_YELLOW;
                else
                    next_state = NS_GREEN;
            end
            
            NS_YELLOW: begin
                if (timer >= YELLOW_DURATION - 1)
                    next_state = EW_GREEN;
                else
                    next_state = NS_YELLOW;
            end
            
            EW_GREEN: begin
                if (timer >= GREEN_DURATION - 1)
                    next_state = EW_YELLOW;
                else
                    next_state = EW_GREEN;
            end
            
            EW_YELLOW: begin
                if (timer >= YELLOW_DURATION - 1)
                    next_state = NS_GREEN;
                else
                    next_state = EW_YELLOW;
            end
            
            default: next_state = NS_GREEN;
        endcase
    end

    // 3. Combinational Output Logic Block
    always @(*) begin
        case (current_state)
            NS_GREEN: begin
                light_NS = GREEN;
                light_EW = RED;
            end
            NS_YELLOW: begin
                light_NS = YELLOW;
                light_EW = RED;
            end
            EW_GREEN: begin
                light_NS = RED;
                light_EW = GREEN;
            end
            EW_YELLOW: begin
                light_NS = RED;
                light_EW = YELLOW;
            end
            default: begin
                light_NS = RED;
                light_EW = RED;
            end
        endcase
    end

endmodule
