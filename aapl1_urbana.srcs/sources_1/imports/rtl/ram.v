/* modified using bram */

module ram #(
    parameter RAM_FILENAME = "ram.hex" // Hex file for initialization
) (
    input clk,              // Clock signal
    input [12:0] address,   // Address bus
    input w_en,             // Active high write enable strobe
    input [7:0] din,        // 8-bit data bus (input)
    output reg [7:0] dout   // 8-bit data bus (output)
);

    // Declare RAM as a 2D register array
    (* ram_style = "distributed" *) reg [7:0] ram_data [0:8191];

    // Initialize RAM with $readmemh
    initial begin
        $readmemh(RAM_FILENAME, ram_data, 0, 8191);
    end

    // Read/Write Logic
    always @(posedge clk) begin
        dout <= ram_data[address];  // Synchronous read
        if (w_en)                  // Write enable logic
            ram_data[address] <= din;
    end

endmodule
