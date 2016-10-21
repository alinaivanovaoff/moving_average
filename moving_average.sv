//(c) Alina Ivanova, alina.al.ivanova@gmail.com
//-----------------------------------------------------------------------------
// Moving average SIZE_DATA arithmetics
//----------------------------------------------------------------------------
`timescale 1ns/1ps
//-----------------------------------------------------------------------------
import package_settings::*;
//-----------------------------------------------------------------------------
module moving_average (
//-----------------------------------------------------------------------------
// Input Ports
//-----------------------------------------------------------------------------
	input  wire                                                clk,
	input  wire                                                reset,
//-----------------------------------------------------------------------------
	input  wire [SIZE_DATA-1:0]                                input_data,
	input  wire                                                enable,
	input  wire [SIZE_WINDOW-1:0]                              window_set,
//-----------------------------------------------------------------------------
// Output Ports
//-----------------------------------------------------------------------------
	output reg  [SIZE_DATA-1:0]                                output_data);
//-----------------------------------------------------------------------------
// Signal declarations
//-----------------------------------------------------------------------------
	reg         [SIZE_DATA-1:0]                                shift_reg        [SIZE_MAX_WINDOW];
	reg signed  [SIZE_DATA-1:0]                                pre_data
	reg signed  [SIZE_DATA-1:0]                                pre_pre_data;
	reg signed  [SIZE_DATA-1:0]                                sum_shift;
	reg signed  [SIZE_MAX_WINDOW-1:0]                          sum;
	reg         [SIZE_WINDOW-1:0]                              ena_plus_one;
	reg         [SIZE_WINDOW-1:0]                              window_set_internal;
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
	always_ff @(negedge reset or posedge clk) begin: MOVING_AVERAGE_SHIFT_REG
		if (!reset) begin
			for (int i = 0; i < SIZE_MAX_WINDOW; i++) begin
				shift_reg[i]                                  <= '0;
			end
		end else begin
			shift_reg[0]                                      <= input_data;
			for (int i = 1; i < SIZE_MAX_WINDOW; i++) begin
				shift_reg[i]                                  <= shift_reg[i-1];
			end
		end
	end: MOVING_AVERAGE_SHIFT_REG
//-----------------------------------------------------------------------------
	always_ff @(negedge reset or posedge clk) begin: MOVING_AVERAGE_PRE_DATA
		if (!reset) begin
			{window_set_internal, pre_pre_data, pre_data}     <= '0;
		end else begin
			window_set_internal                               <= window_set - 1;
			pre_pre_data                                      <= shift_reg[window_set_internal];
			pre_data                                          <= shift_reg[0] - pre_pre_data;
		end
	end: MOVING_AVERAGE_PRE_DATA
//-----------------------------------------------------------------------------
	always_ff @(negedge reset or posedge clk) begin: MOVING_AVERAGE_SUM
		if (!reset) begin
			sum                                               <= '0;
		end else begin
			sum                                               <= sum + pre_data;
		end
	end: MOVING_AVERAGE_SUM
//-----------------------------------------------------------------------------
	always_ff @(negedge reset or posedge clk) begin: MOVING_AVERAGE_SUM_SHIFT
		if (!reset) begin
			{sum_shift, ena_plus_one}                         <= '0;
		end else begin
			case (window_set)
				1: begin
					sum_shift                                 <= sum;
					ena_plus_one                              <= '0;
				end
				2: begin
					sum_shift                                 <= sum >>> 1;
					ena_plus_one                              <= sum[0];
				end
				4: begin
					sum_shift                                 <= sum >>> 2;
					ena_plus_one                              <= sum[1];
				end
				8: begin
					sum_shift                                 <= sum >>> 3;
					ena_plus_one                              <= sum[2];
				end
				16: begin
					sum_shift                                 <= sum >>> 4;
					ena_plus_one                              <= sum[3];
				end
				32: begin
					sum_shift                                 <= sum >>> 5;
					ena_plus_one                              <= sum[4];
				end
				64: begin
					sum_shift                                 <= sum >>> 6;
					ena_plus_one                              <= sum[5];
				end default: begin
					sum_shift                                 <= '0;
					ena_plus_one                              <= '0;
				end
			endcase
		end
	end: MOVING_AVERAGE_SUM_SHIFT
//-----------------------------------------------------------------------------
	always_ff @(negedge reset or posedge clk) begin: MOVING_AVERAGE_OUTPUT_DATA
		if (!reset) begin
			output_data                                       <= '0;
		end else begin
			if (enable) begin
				output_data                                   <= ena_plus_one ? sum_shift + {{SIZE_DATA-1{0}},1'b1} : sum_shift;
			end else
				;
		end
	end: MOVING_AVERAGE_OUTPUT_DATA
//-----------------------------------------------------------------------------
endmodule: moving_average
