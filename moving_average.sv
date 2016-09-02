//-----------------------------------------------------------------------------
// Title       : moving_average
//-----------------------------------------------------------------------------
// File        : moving_average.sv
// Company     : INP SB RAS
// Created     : 04/12/2014
// Created by  : Alina Ivanova
//-----------------------------------------------------------------------------
// Description : moving_average
//-----------------------------------------------------------------------------
// Revision    : 1.1
//-----------------------------------------------------------------------------
// Copyright (c) 2014 INP SB RAS
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from INP SB RAS.
//-----------------------------------------------------------------------------
// SystemVerilog name_module
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
	input  wire [SIZE_SHAPER_DATA-1:0]                         input_data,
//-----------------------------------------------------------------------------
	input  wire                                                enable,
//-----------------------------------------------------------------------------
	input  wire [SIZE_MOVING_AVERAGE_WINDOW-1:0]               window_set,
//-----------------------------------------------------------------------------
// Output Ports
//-----------------------------------------------------------------------------
	output reg  [SIZE_SHAPER_DATA-1:0]                         output_data,
	output wire signed  [SIZE_SHAPER_DATA-1:0]                 pre_data);
//-----------------------------------------------------------------------------
// Signal declarations
//-----------------------------------------------------------------------------
	reg         [SIZE_SHAPER_DATA-1:0]                         shift_reg        [SIZE_MOVING_AVERAGE_MAX_WINDOW-1:0];
	reg signed  [SIZE_SHAPER_DATA-1:0]                         pre_pre_data;
	reg signed  [SIZE_SHAPER_DATA-1:0]                         sum_shift;
	reg signed  [SIZE_MOVING_AVERAGE_MAX_WINDOW-1:0]           sum;
	reg         [SIZE_MOVING_AVERAGE_WINDOW-1:0]               window;
	reg         [SIZE_MOVING_AVERAGE_WINDOW-1:0]               ena_plus_one;
	reg         [SIZE_MOVING_AVERAGE_WINDOW-1:0]               window_set_internal;
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
	always @ (negedge reset or posedge clk)
	begin: MOVING_AVERAGE_SHIFT_REG
		if (!reset)
		begin
			for (integer i = 0; i < SIZE_MOVING_AVERAGE_MAX_WINDOW; i++)
			begin
				shift_reg[i]                                     <= 0;
			end
		end
		else
		begin
//			if (enable)
//			begin
				shift_reg[0]                                     <= input_data;
				for (integer i = 1; i < SIZE_MOVING_AVERAGE_MAX_WINDOW; i++)
				begin
					shift_reg[i]                                  <= shift_reg[i-1];
				end
//			end
//			else
//			begin
//				for (integer i = 0; i < SIZE_MOVING_AVERAGE_MAX_WINDOW; i++)
//				begin
//					shift_reg[i]                                  <= shift_reg[i];
//				end
//			end
		end
	end
//-----------------------------------------------------------------------------
	always @ (negedge reset or posedge clk)
	begin: MOVING_AVERAGE_PRE_DATA
		if (!reset)
		begin
			window_set_internal                                 <= 0;
			pre_pre_data                                        <= 0;
			pre_data                                            <= 0;
		end
		else
		begin
			window_set_internal                                 <= window_set - 8'b1;
//			if (enable)
//			begin
				pre_pre_data                                     <= shift_reg[window_set_internal];
				pre_data                                         <= shift_reg[0] - pre_pre_data;
//			end
//			else
//				;
		end
	end
//-----------------------------------------------------------------------------
	always @ (negedge reset or posedge clk)
	begin: MOVING_AVERAGE_SUM
		if (!reset)
		begin
			sum                                                 <= 0;
		end
		else
		begin
//			if (enable)
//			begin
				sum                                              <= sum + pre_data;
//			end
//			else
//			begin
//				sum                                              <= sum;
//			end
		end
	end
//-----------------------------------------------------------------------------
	always @ (negedge reset or posedge clk)
	begin: MOVING_AVERAGE_SUM_SHIFT
		if (!reset)
		begin
			sum_shift                                           <= 0;
			ena_plus_one                                        <= 0;
		end
		else
		begin
//			if (enable)
//			begin
				case (window_set)
					1:
					begin
						sum_shift                                  <=  sum;
						ena_plus_one                               <=  0;
					end
					2:
					begin
						sum_shift                                  <= (sum >>> 1);
						ena_plus_one                               <=  sum[0];
					end
					4:
					begin
						sum_shift                                  <= (sum >>> 2);
						ena_plus_one                               <=  sum[1];
					end
					8:
					begin
						sum_shift                                  <= (sum >>> 3);
						ena_plus_one                               <=  sum[2];
					end
					16:
					begin
						sum_shift                                  <= (sum >>> 4);
						ena_plus_one                               <=  sum[3];
					end
					32:
					begin
						sum_shift                                  <= (sum >>> 5);
						ena_plus_one                               <=  sum[4];
					end
					64:
					begin
						sum_shift                                  <= (sum >>> 6);
						ena_plus_one                               <=  sum[5];
					end
					default:
					begin
						sum_shift                                  <= 0;
						ena_plus_one                               <= 0;
					end
				endcase
//			end
//			else
//			begin
//				sum_shift                                        <= sum_shift;//0;
//				ena_plus_one                                     <= ena_plus_one;//0;
//			end
		end
	end
//-----------------------------------------------------------------------------
	always @ (negedge reset or posedge clk)
	begin: MOVING_AVERAGE_OUTPUT_DATA
		if (!reset)
		begin
			output_data                                         <= 0;
		end
		else
		begin
			if (enable)
			begin
				case (ena_plus_one)
					1: output_data                                <= sum_shift + 1;
					default: output_data                          <= sum_shift;
				endcase
//				output_data                                      <= pre_pre_data;
			end
			else
				;
		end
	end
//-----------------------------------------------------------------------------
endmodule
