`timescale 1ns/1ps

module testbench;

    // Inputs to game_top
    reg clk;
    reg rst;
    reg [15:0] sample;
    reg [7:0] block_length;

    // Outputs from game_top
    wire [15:0] max;
    wire [15:0] min;
    wire [15:0] avg;
    wire [6:0] remainder;


    // Initialising
  avg_calc shd ( // synthesizable hardware module
        .clk(clk),
        .rst(rst),
        .sample(sample),
        .block_length(block_length),
        .max(max),
        .min(min),
        .avg(avg),
        .remainder(remainder)
    );


    // 10 ns clock period
    always #5 clk = ~clk;


    initial begin

        clk = 0;
        sample = 0;
        block_length = 4;

        rst = 0; // Reset between tests because every active clock cycle is treated as a valid sample, so excess gaps can be treated as valid results
        @(negedge clk);
        rst = 1;

		// TEST 1 - STANDARD INPUT

        sample = 10;

        @(negedge clk);
        sample = 20;

        @(negedge clk);
        sample = 30;

        @(negedge clk);
        sample = 41;

        @(negedge clk);

        $display("");
        $display("TEST 1: STANDARD INPUT");
        $display("MAX       = %0d (expected 41)", max);
        $display("MIN       = %0d (expected 10)", min);
        $display("AVG       = %0d (expected 25)", avg);
        $display("REMAINDER = %0d (expected 25)", remainder);


		rst = 0;
        @(negedge clk);
        rst = 1;


        // TEST 2 - BLOCK LENGTH OF 1 + MAX VALUE

        block_length = 1;
        sample = 65535;

      	@(negedge clk); // Only 1 cycle

        $display("");
        $display("TEST 2: BLOCK LENGTH OF 1 + MAX VALUE");
        $display("MAX       = %0d (expected 65535)", max);
        $display("MIN       = %0d (expected 65535)", min);
        $display("AVG       = %0d (expected 65535)", avg);
        $display("REMAINDER = %0d (expected 0)", remainder);


        rst = 0;
        @(negedge clk);
        rst = 1;


        // TEST 3 - EXTREME VALUES + FRACTION


        block_length = 3;

        sample = 0;

        @(negedge clk);
        sample = 65535;

        @(negedge clk);
        sample = 1;

        @(negedge clk);

        $display("");
		$display("TEST 3: EXTREME VALUES + FRACTION");
        $display("MAX       = %0d (expected 65535)", max);
        $display("MIN       = %0d (expected 0)", min);
        $display("AVG       = %0d (expected 21845)", avg);
        $display("REMAINDER = %0d (expected 33)", remainder);

        rst = 0;
        @(negedge clk);
        rst = 1;


        // TEST 4 - BLOCK LENGTH DECREASED MID-BLOCK

        block_length = 5;

        sample = 10;

        @(negedge clk);
        sample = 20;

        @(negedge clk);
        sample = 30;

        @(negedge clk);

        // sum = 60, sample_count = 3
        // Decreasing block length below sample_count terminates the block
        block_length = 2;

        #1; // Allow combinational outputs to update otherwise doesn't work

      	// This test is to show that the internal calculations are insulated from changes to block_length
      
        $display("");
        $display("TEST 4: BLOCK LENGTH DECREASED MID-BLOCK");
        $display("MAX       = %0d (expected 30)", max);
        $display("MIN       = %0d (expected 10)", min);
        $display("AVG       = %0d (expected 20)", avg);
        $display("REMAINDER = %0d (expected 0)", remainder);
      

        $display("");
        $display("ALL TESTS COMPLETE");

        #10;
        $finish;

    end


    // Waveform output
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
    end

endmodule