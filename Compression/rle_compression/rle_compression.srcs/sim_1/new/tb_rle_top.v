`timescale 1ns/1ps
//=====================================================================
// tb_rle_top.v
// Testbench for rle_top: reads characters from "input.txt", feeds them
// one per clock cycle into the DUT, and writes each emitted run
// (char + count) to "output.txt" as it appears.
//
// Place input.txt in the same directory you run the simulator from.
//=====================================================================
module tb_rle_top;

    // ---------------- DUT I/O ----------------
    reg clk;
    reg rst;
    reg [7:0] current_char;
    reg data_valid;
    reg last;
    wire [7:0] char_out;
    wire [7:0] count_out;

    // ---------------- File handling ----------------
    integer infile, outfile;
    integer char_code;
    reg [7:0] mem [0:65535];   // input buffer (max 64K chars)
    integer num_chars;
    integer idx;

    // Must match the encoding used in controller.v
    localparam IDLE    = 2'b00;
    localparam PROCESS = 2'b01;
    localparam OUTPUT  = 2'b10;
    localparam FINISH  = 2'b11;

    reg sim_done;

    // ---------------- DUT instantiation ----------------
    rle_top dut (
        .clk         (clk),
        .rst         (rst),
        .current_char(current_char),
        .data_valid  (data_valid),
        .last        (last),
        .char_out    (char_out),
        .count_out   (count_out)
    );

    // ---------------- Clock: 10ns period ----------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ---------------------------------------------------------------
    // load_output is a combinational output of the controller. It is
    // stable for the whole cycle BEFORE the clock edge that uses it,
    // so sampling it on negedge clk gives us, for free, the value that
    // the very next posedge will use to update char_out/count_out.
    // ---------------------------------------------------------------
    reg load_output_d;
    always @(negedge clk) load_output_d <= dut.load_output;

    // Write every emitted run to output.txt as "char" immediately
    // followed by its count, e.g. input "aaabbccccd" -> "a3b2c4d1"
    always @(posedge clk) begin
        #1; // let char_out / count_out settle right after the edge
        if (load_output_d) begin
            $fwrite(outfile, "%c%0d", char_out, count_out);
            $display("Run emitted -> char='%c' count=%0d", char_out, count_out);
        end
    end

    // ---------------------------------------------------------------
    // Read the whole input file into memory (happens at time 0, before
    // any clock edges have occurred).
    // ---------------------------------------------------------------
    initial begin
        num_chars = 0;
        infile = $fopen("input.txt", "r");
        if (infile == 0) begin
            $display("ERROR: could not open input.txt");
            $finish;
        end
        char_code = $fgetc(infile);
        while (char_code != -1) begin
            // skip newline/carriage-return so a normal text file works
            if (char_code != 8'h0A && char_code != 8'h0D) begin
                mem[num_chars] = char_code[7:0];
                num_chars = num_chars + 1;
            end
            char_code = $fgetc(infile);
        end
        $fclose(infile);
        $display("Read %0d characters from input.txt", num_chars);

        outfile = $fopen("output.txt", "w");
        if (outfile == 0) begin
            $display("ERROR: could not open output.txt");
            $finish;
        end
    end

    // ---------------------------------------------------------------
    // Stimulus: rle_top expects one new character per clock cycle,
    // EXCEPT while the FSM sits in the OUTPUT state, where the
    // character that broke the current run must be held for one more
    // cycle (it gets reloaded as prev_char there). We track this by
    // peeking at the controller's current_state hierarchically -
    // this is a simulation-only trick, not synthesizable.
    // ---------------------------------------------------------------
    initial begin : STIM
        rst          = 1;
        data_valid   = 0;
        last         = 0;
        current_char = 8'd0;
        idx          = 0;
        sim_done     = 0;

        repeat (3) @(negedge clk);
        rst = 0;
        #1; // let the file-read block (time-0) finish first

        if (num_chars == 0) begin
            $display("Input file is empty - nothing to compress.");
            sim_done = 1;
            disable STIM;
        end

        // present the first character
        current_char = mem[0];
        data_valid   = 1;
        last         = (num_chars == 1);

        forever begin
            @(negedge clk);
            data_valid = 0; // only needs to pulse during the IDLE cycle

            if (dut.ctrl.current_state == FINISH) begin
                sim_done = 1;
                disable STIM;
            end
            else if (dut.ctrl.current_state == OUTPUT) begin
                // hold the breaking character - do NOT advance idx
                current_char = mem[idx];
                last         = (idx == num_chars - 1);
            end
            else begin
                // PROCESS: advance to the next character
                idx = idx + 1;
                if (idx < num_chars) begin
                    current_char = mem[idx];
                    last         = (idx == num_chars - 1);
                end
            end
        end
    end

    // ---------------------------------------------------------------
    // Cleanup: once STIM signals completion, give the DUT a few extra
    // cycles to flush the FINISH-state output, then close the file.
    // ---------------------------------------------------------------
    initial begin
        wait (sim_done == 1);
        repeat (5) @(posedge clk);
        $fwrite(outfile, "\n");
        $fclose(outfile);
        $display("Done. Compressed result written to output.txt");
        $finish;
    end

endmodule