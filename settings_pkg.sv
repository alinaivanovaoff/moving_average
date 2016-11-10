//-----------------------------------------------------------------------------
// Original Author: Alina Ivanova
// email: alina.al.ivanova@gmail.com
// web: alinaivanovaoff.com
// settings_pkg.sv
// Created: 11.10.2016
//
// Settings package.
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
//-----------------------------------------------------------------------------
//`include "functions_pkg.sv"
//-----------------------------------------------------------------------------
package settings_pkg;
	import functions_pkg::*; 
//-----------------------------------------------------------------------------
// Parameter Declaration(s)
//-----------------------------------------------------------------------------
    parameter MAX_WINDOW                      = 64;
    parameter WINDOW_SIZE                     = clog2(MAX_WINDOW);
    parameter DATA_SIZE                       = 16;
    parameter FULL_SIZE                       = DATA_SIZE + WINDOW_SIZE;
//-----------------------------------------------------------------------------
endpackage: settings_pkg
