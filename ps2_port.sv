`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2026 12:57:39 PM
// Design Name: 
// Module Name: ps2_port
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

module ps2_port(
    input  logic       ps2_clk,
    input  logic       rst,
    input  logic       ps2_data, // serial data coming from the keyboard

    output logic [7:0] scan_code, // stores the 8 bit output
    output logic       data_valid, // is high when complete 8 bit data has been recieved 
    output logic       parity_error, // high if parity is incorrect
    output logic       frame_error // high if there is an error in the frame
);


    // State Encoding

    parameter idle         = 3'b000;
    parameter start_bit    = 3'b001;
    parameter data_bit     = 3'b010;
    parameter parity_bit   = 3'b011;
    parameter stop_bit     = 3'b100;
    parameter done         = 3'b101;

    logic [2:0] state; // state register to store the current FSM state

    // Registers
    
    logic [7:0] data_reg; // stores incomming data bits
    logic       parity_reg; // stores parity bit  
    logic [2:0] bitCount_reg; // counts recieved bits

    // Receiver FSM

    always_ff @(negedge ps2_clk or posedge rst) // executes of falling edge
    begin
        if (rst)
        begin
            state         <= idle; // go back to idle and clear everything
            bitCount_reg  <= 3'd0;
            data_reg      <= 8'd0;
            parity_reg    <= 1'b0;
            scan_code     <= 8'd0;
            data_valid    <= 1'b0;
            parity_error  <= 1'b0;
            frame_error   <= 1'b0;
        end
        else
        begin
            case (state)
            
                // Idle State
                
                idle:
                begin
                    data_valid    <= 1'b0;
                    parity_error  <= 1'b0;
                    frame_error   <= 1'b0;

                    if (ps2_data == 1'b0) // ps2 frame always starts from 0, if 0 is detected,
                        state <= start_bit; // move to the next state
                end


                // Start Bit

                start_bit:
                begin
                    if (ps2_data == 1'b0)
                    begin
                        bitCount_reg <= 3'd0; //prepare the register to recieve 8 data bits
                        state <= data_bit; // start recieveing data
                    end
                    else
                    begin
                        frame_error <= 1'b1; // if fram error bit high then move to idle state
                        state <= idle;
                    end
                end


                // Receive 8 Data Bits

                data_bit:
                begin
                    data_reg[bitCount_reg] <= ps2_data; // stores one recieved bit

                    if (bitCount_reg == 3'd7) // all 8 bits recieved then,
                    begin
                        state <= parity_bit; // check parity bit
                    end
                    else
                    begin
                        bitCount_reg <= bitCount_reg + 1'b1; // recieve another bit if register not full yet
                    end
                end


                // Receive Parity Bit

                parity_bit:
                begin
                    parity_reg <= ps2_data; // save the parity bit
                    state <= stop_bit;
                end

                // Stop Bit

                stop_bit:
                begin
                    if (ps2_data != 1'b1) // stop bit must be one always
                        frame_error <= 1'b1;

                    state <= done;
                end


                // Done

                done:
                begin
                    // PS/2 uses odd parity
                    if (^{parity_reg, data_reg} != 1'b1) // using reduction xor across all bits in parity and data reg
                        parity_error <= 1'b1; // if reduction xor is 1 then there is no error and parity is correct

                    scan_code  <= data_reg; // stores the data into the output reg
                    data_valid <= 1'b1; // data_valid high means all the recieved scan_code data is valid

                    state <= idle;
                end

                // Default
                
                default:
                begin
                    state <= idle;
                end

            endcase
        end
    end

endmodule
   
