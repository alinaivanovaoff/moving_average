//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// Contact Point: Alina Ivanova (alina.al.ivanova@gmail.com)
// moving_average.sv
// Created: 11.10.2016
//
// Moving average SIZE_DATA arithmetics, Window: 1, 2, 4, 8, 16, 32, 64
//
//-----------------------------------------------------------------------------
// Copyright (c) 2016 by Alina Ivanova
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//----------------------------------------------------------------------------
`timescale 1ns / 1ps
//-----------------------------------------------------------------------------
`include "functions_pkg.sv"
`include "settings_pkg.sv"
//-----------------------------------------------------------------------------
module moving_average import settings_pkg::*; (
//-----------------------------------------------------------------------------
// Input Ports
//-----------------------------------------------------------------------------
    input  wire                                           clk,
    input  wire                                           reset,
//-----------------------------------------------------------------------------
    input  wire signed [DATA_SIZE-1:0]                    input_data,
    input  wire                                           enable,
    input  wire        [WINDOW_SIZE:0]                    window,//1,2,4,8,16,32,64
//-----------------------------------------------------------------------------
// Output Ports
//-----------------------------------------------------------------------------
    output reg signed  [FULL_SIZE-1:0]                    output_data,
    output reg                                            output_data_valid);
//-----------------------------------------------------------------------------
// Signal declarations
//-----------------------------------------------------------------------------
    reg                                                   reset_synch;
    reg                [2:0]                              reset_z;
//-----------------------------------------------------------------------------
    reg signed         [FULL_SIZE-1:0]                    shift_reg        [MAX_WINDOW];
    reg                                                   enable_z         [4];
    reg signed         [FULL_SIZE-1:0]                    data;
    reg signed         [FULL_SIZE-1:0]                    data_diff;
    reg signed         [FULL_SIZE-1:0]                    sum_shift;
    reg signed         [MAX_WINDOW-1:0]                   sum;
    reg                [WINDOW_SIZE:0]                    window_internal;
//-----------------------------------------------------------------------------
// Function Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Sub Module Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Signal Section
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Process Section
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: MOVING_AVERAGE_RESET_SYNCH
        reset_z                                          <= {reset_z[1:0], reset};
        reset_synch                                      <= (reset_z[1] & (~reset_z[2])) ? '1 : '0 ;
    end: MOVING_AVERAGE_RESET_SYNCH
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: MOVING_AVERAGE_SHIFT_REG
        if (reset_synch) begin
            for (int i = 0; i < MAX_WINDOW; i++) begin
                shift_reg[i]                             <= '0;
            end
            enable_z[0]                                  <= '0;
        end else begin
            shift_reg[0]                                 <= (input_data[DATA_SIZE-1]) ? {{WINDOW_SIZE{1'b1}}, input_data} : {{WINDOW_SIZE{1'b0}}, input_data};
            for (int i = 1; i < MAX_WINDOW; i++) begin
                shift_reg[i]                             <= shift_reg[i-1];
            end
            enable_z[0]                                  <= enable;
        end
    end: MOVING_AVERAGE_SHIFT_REG
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: MOVING_AVERAGE_PRE_DATA
        if (reset_synch) begin
            {window_internal, data, data_diff, enable_z[1]}           <= '0;
        end else begin
            window_internal                              <= window - {{WINDOW_SIZE{0}}, 1'b1};
            data                                         <= shift_reg[window_internal];
            data_diff                                    <= shift_reg[0]- data;
            enable_z[1]                                  <= enable_z[0];
        end
    end: MOVING_AVERAGE_PRE_DATA
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: MOVING_AVERAGE_SUM
        if (reset_synch) begin
            {sum, enable_z[2]}                           <= '0;
        end else begin
            sum                                          <= sum + data_diff;
            enable_z[2]                                  <= enable_z[1];
        end
    end: MOVING_AVERAGE_SUM
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: MOVING_AVERAGE_SUM_SHIFT
        if (reset_synch) begin
            {sum_shift, enable_z[3]}                     <= '0;
        end else begin
            case (window)
                1: begin
                    sum_shift                            <= sum;
                end
                2: begin
                    sum_shift                            <= sum >>> 1;
                end
                4: begin
                    sum_shift                            <= sum >>> 2;
                end
                8: begin
                    sum_shift                            <= sum >>> 3;
                end
                16: begin
                    sum_shift                            <= sum >>> 4;
                end
                32: begin
                    sum_shift                            <= sum >>> 5;
                end
                64: begin
                    sum_shift                            <= sum >>> 6;
                end default: begin
                    sum_shift                            <= '0;
                end
            endcase
            enable_z[3]                                  <= enable_z[2];
        end
    end: MOVING_AVERAGE_SUM_SHIFT
//-----------------------------------------------------------------------------
    always_ff @(posedge clk) begin: MOVING_AVERAGE_OUTPUT_DATA
        if (reset_synch) begin
            output_data                                  <= '0;
            output_data_valid                            <= '0;
        end else begin
//            if (enable_z[0]) begin
                output_data                              <= sum_shift;
//            end
            output_data_valid                            <= enable_z[3];
        end
    end: MOVING_AVERAGE_OUTPUT_DATA
//-----------------------------------------------------------------------------
endmodule: moving_average
