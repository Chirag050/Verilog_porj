module syncFIFO #(          // USING HASH MAKES THE DESIGN REUSABLE AS WE NEED TO JUST USE #(...) TO RECONFIGURE PARAMETER THE VALUES.
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16,
    parameter ALMOST_FULL = 12,
    parameter ALMOST_EMPTY = 4
   )(
    input clk,
    input rst_n,  // Asychronous active low reset
    // Write interface
    input wr_en,
    input [DATA_WIDTH-1:0] din, // Data input 
    // Read interface
    input rd_en,
    output reg [DATA_WIDTH-1:0] dout, // Data Output
    
    // Status Flags
    output full,
    output empty,
    output almost_full,
    output almost_empty
    );
    
    // Local parameter to calculate pointer width: ceiling log base 2(16) = 4 Bits
    localparam PTR_WIDTH = $clog2(FIFO_DEPTH);
    /* Dual Port RAM configuration; fifo ram is the name of the mem matrix var, and this overall forms
       a memory grid capable of holding 16 distinct 8-bit packets simulataneously*/
    reg [DATA_WIDTH-1:0] fifo_ram [FIFO_DEPTH-1:0];
    
    // wr_ptr holds the binary address of the next empty slot where new incoming data will be saved
    reg [PTR_WIDTH:0] wr_ptr;
    // rd_ptr holds the binary address of the oldest dat slot that hasn't been read out yet
    reg [PTR_WIDTH:0] rd_ptr;
    
//    // counter to track the number of items inside the FIFO
//    // For depth 16 there are 17 cases and hence we need to acknowledge the same and make it capable to hold 31 bits
//    reg [PTR_WIDTH:0] count;
    
//    // Status flag assignment
//    assign empty = (count == 0);
//    assign full  = (count == FIFO_DEPTH);
/*    wire valid_write = we_en && !full;
      wire valid_read = rd_en && !empty;  */
      wire [PTR_WIDTH:0] current_count = wr_ptr - rd_ptr;

      assign almost_full  = (current_count >= ALMOST_FULL) && !full;
      assign almost_empty = (current_count <= ALMOST_EMPTY)&& !empty;
      
      assign empty = (wr_ptr == rd_ptr);
      // full is when wr_ptr = 4'b1000 && rd_ptr = 4'b0000
      assign full = ({~wr_ptr[PTR_WIDTH],wr_ptr[PTR_WIDTH-1:0]} == rd_ptr);
                  /*(wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]) &&
                    (wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]);*/
                    
      // 
                    
    // Sequential memory and pointer managemnt block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            dout   <= 0;
        end else begin
            // Write operation: check if write is requested and FIFO is not full
            if (wr_en && !full) begin
                fifo_ram[wr_ptr[PTR_WIDTH-1:0]] <= din;
                wr_ptr           <= wr_ptr + 1;
            end
            
            // Read operation: check if read is requested and FIFO is not empty
            if (rd_en && !empty) begin
                dout    <= fifo_ram[rd_ptr[PTR_WIDTH-1:0]];
                rd_ptr  <= rd_ptr + 1;
            end
            
            // Counter logic: Tracks the balance of inputs vs output
//            case ({wr_en & !full, rd_en && !empty})
//                2'b10: count <= count + 1; // Write only
//                2'b01: count <= count - 1; // Read only
//                2'b11: count <= count;     // Concurrent Read and Write (No net change)
//                2'b00: count <= count;     // No action
//            endcase
        end
    end          
endmodule
