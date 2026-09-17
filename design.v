// Compiled with edaplayground.com
// Tools & Simulators = Icarus Verilog 12.0
// -Wall -g2012
// CHECK Open EPWave after run

module avg_calc(
	input clk, 
	input rst,
	input [15:0] sample, // 16 bits 
  	input [7:0] block_length, 
  	output [15:0] max,
	output [15:0] min,
	output [15:0] avg,
	output [6:0] remainder
);
  
  // Assumptions:
  // 1. block_length can be increased, decreasing it will terminate the program earlier with the avg being calculated with internal length variable
  // 2. A new sample is presented on every active processing clock cycle.
  // 3. No sample is accepted during the one-cycle result/reset period.
  
  wire block_done; // If/Else driver of combinational logic
  wire [14:0] scaled_remainder;
  
  reg [23:0] sum; // Max possible value 
  reg [15:0] min_sample;
  reg [15:0] max_sample;
  reg [7:0] sample_count; // Just in case there are errors with block length



  always @(posedge clk or negedge rst) begin
    if(!rst || block_length == 0 || sample_count >= block_length)  begin
      sum <= 0;
      min_sample <= 65535; // 2^16 (65536) - 1
      max_sample <= 0;
      sample_count <= 0;
      
    end else begin
		sum <= sum + sample;
        if (min_sample > sample) begin
          min_sample <= sample;
        end 
        if (max_sample < sample) begin
          max_sample <= sample;
        end
      	sample_count <= sample_count + 1;
    end
  end
  
  // Combinational output logic using continuous assignments
  
  assign block_done = (block_length != 0) && (sample_count >= block_length); // If/Else
  
  assign avg = block_done ? sum / sample_count : 0; // Driven by reg sample_count to avoid faulty block_length values corrupting avg
  assign scaled_remainder = block_done ? (sum % sample_count) * 100 : 0; // Resets on else
  assign max = block_done ? max_sample : 0; 
  assign min = block_done ? min_sample : 0;
  assign remainder = block_done ? scaled_remainder / sample_count : 0;
  
endmodule