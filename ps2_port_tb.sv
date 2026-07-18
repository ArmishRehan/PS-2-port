`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2026 02:45:52 PM
// Design Name: 
// Module Name: ps2_port_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ps2_port_tb;


    // Testbench Signals

    logic       ps2_clk;
    logic       rst;
    logic       ps2_data;

    logic [7:0] scan_code;
    logic       data_valid;
    logic       parity_error;
    logic       frame_error;

    ps2_port dut (
        .ps2_clk(ps2_clk),
        .rst(rst),
        .ps2_data(ps2_data),
        .scan_code(scan_code),
        .data_valid(data_valid),
        .parity_error(parity_error),
        .frame_error(frame_error)
    );


    // Task : Generate one PS/2 clock pulse
    // Data is sampled on the falling edge.

    task clock_pulse;
    begin
        #10 ps2_clk = 1;
        #10 ps2_clk = 0;      // Falling edge 
    end
    endtask


    //====================================================
    // Task : Send a complete PS/2 frame
    //
    // Frame Format:
    // Start(0)
    // 8 Data bits (LSB First)
    // Odd Parity
    // Stop(1)
    //====================================================
    task send_frame(input [7:0] data);
        integer i;
        logic parity;
    begin

        //------------------------------------------------
        // Calculate Odd Parity
        //------------------------------------------------
        parity = ~(^data);

        //------------------------------------------------
        // Start Bit
        //------------------------------------------------
        ps2_data = 0;
        clock_pulse();

        //------------------------------------------------
        // Send 8 Data Bits (LSB First)
        //------------------------------------------------
        for(i=0; i<8; i=i+1)
        begin
            ps2_data = data[i];
            clock_pulse();
        end

        //------------------------------------------------
        // Send Parity Bit
        //------------------------------------------------
        ps2_data = parity;
        clock_pulse();

        //------------------------------------------------
        // Send Stop Bit
        //------------------------------------------------
        ps2_data = 1;
        clock_pulse();

    end
    endtask


    //====================================================
    // Task : Send Wrong Parity Frame
    //====================================================
    task send_bad_parity(input [7:0] data);
        integer i;
        logic parity;
    begin

        parity = ~(^data);

        // Intentionally invert parity
        parity = ~parity;

        ps2_data = 0;
        clock_pulse();

        for(i=0;i<8;i=i+1)
        begin
            ps2_data = data[i];
            clock_pulse();
        end

        ps2_data = parity;
        clock_pulse();

        ps2_data = 1;
        clock_pulse();

    end
    endtask


    //====================================================
    // Task : Send Wrong Stop Bit
    //====================================================
    task send_bad_stop(input [7:0] data);
        integer i;
        logic parity;
    begin

        parity = ~(^data);

        ps2_data = 0;
        clock_pulse();

        for(i=0;i<8;i=i+1)
        begin
            ps2_data = data[i];
            clock_pulse();
        end

        ps2_data = parity;
        clock_pulse();

        // Wrong stop bit
        ps2_data = 0;
        clock_pulse();

    end
    endtask


    //====================================================
    // Test Sequence
    //====================================================
    initial
    begin

        //------------------------------------------------
        // Initialize Signals
        //------------------------------------------------
        ps2_clk  = 1;
        ps2_data = 1;
        rst      = 1;

        #30;
        rst = 0;

        //------------------------------------------------
        // Test Case 1
        // Send scan code for key 'A'
        // 8'h1C
        //------------------------------------------------
        $display("======================================");
        $display("TEST 1 : Valid Frame");
        $display("======================================");

        send_frame(8'h1C);

        #50;

        //------------------------------------------------
        // Test Case 2
        // Another Valid Frame
        //------------------------------------------------
        $display("======================================");
        $display("TEST 2 : Valid Frame");
        $display("======================================");

        send_frame(8'hF0);

        #50;

        //------------------------------------------------
        // Test Case 3
        // Wrong Parity
        //------------------------------------------------
        $display("======================================");
        $display("TEST 3 : Bad Parity");
        $display("======================================");

        send_bad_parity(8'h55);

        #50;

        //------------------------------------------------
        // Test Case 4
        // Wrong Stop Bit
        //------------------------------------------------
        $display("======================================");
        $display("TEST 4 : Bad Stop Bit");
        $display("======================================");

        send_bad_stop(8'hAA);

        #50;

        //------------------------------------------------
        // Finish Simulation
        //------------------------------------------------
        $display("Simulation Finished.");
        $stop;

    end


    //====================================================
    // Monitor Outputs
    //====================================================
    initial
    begin
        $monitor(
        "Time=%0t | Data=%h | Valid=%b | Parity_Error=%b | Frame_Error=%b",
        $time,
        scan_code,
        data_valid,
        parity_error,
        frame_error
        );
    end

endmodule
