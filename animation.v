

// Part 3

module animation
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);

    // Instansiate FSM control
    // control c0(...);
    
	 animation_logic a_0(.clk(CLOCK_50), .resetn(resetn), .go(KEY[1]), .colour_input(SW[9:7]), .X(x), .Y(y), .colour_out(colour), .writeEn(writeEn));
	 
endmodule


module animation_logic(clk, resetn, go, colour_input, X, Y, colour_out, writeEn);
		input clk;
		input resetn;
		input go; //input to start calculation
		input [2:0] colour_input;
	 
		output [7:0] X;
		output [6:0] Y;
		output [2:0] colour_out;
		output reg writeEn;
		
		wire control_out_en, control_load_x, control_load_y;
		wire move_en;
		wire [2:0]colour;
		wire [7:0]x_coord;
		wire [6:0]y_coord;

		animation_control a_c_0(.clk(clk), .resetn(resetn), .go(go), .input_colour(colour_input), 
								.en(control_out_en), .load_x(control_load_x), .load_y(control_load_y), .move_logic_en(move_en), .control_colour(colour));
		
		move_logic m_l_0(.clk(clk), .en(move_en), .resetn(resetn), .x(x_coord), .y(y_coord));
		
		animation_datapath a_d_0(.x_input(x_coord), .y_input(y_coord), .en(control_out_en), .colour(colour), .clk(clk), .resetn(resetn), .ld_x(control_load_x), .ld_y(control_load_y), 
								 .X(X), .Y(Y), .colour_out(colour_out));
							
		always @ (posedge clk)
			begin
				if (!resetn)
					begin
						writeEn <= 0;
					end
				else
					begin
						writeEn <= control_out_en;
					end	
			end

endmodule




//CONTROL
module animation_control(clk, resetn, go, input_colour, en, load_x, load_y, move_logic_en, control_colour);

    input clk;
    input resetn;
    input go; //input to start calculation
	 input [2:0]input_colour;
	 

    output reg en; //enables the vga adapter
	 output reg load_x;
	 output reg load_y;
	 output reg move_logic_en; 
	 output reg [2:0]control_colour;

	 
	 
	 wire [3:0]draw_counter_out;
	 reg frame_counter_reset, frame_counter_enable;
	 wire frame_counter_out;
    reg [2:0] current_state, next_state;
	 reg draw_counter_en;
	 
    
	 
	 //States encoded
	localparam  START					= 3'd0, //starts the animation
					LOAD_COORD			= 3'd1, //load coordinates of x and y
					DRAW					= 3'd2, //draws the box at current location - lasts for 16 clock cycles
					RESET_DELAY			= 3'd3, //reset the delay counters to count out the delay
					DELAY		    		= 3'd4, //counts 15 frames delay time
					ERASE					= 3'd5, //erases the box at current location - lasts for 16 clock cycles
					UPDATE				= 3'd6; //updates the coordinates of the box and direction of move - 1 clock cycle
    
	 
	 //5-bit counter to count enough steps for VGA to draw the box
	 counter_5_bit c_5(.clk(clk), .en(draw_counter_en), .resetn(resetn), .out(draw_counter_out));
	 
	 //15 frames counter
	 fps_15_signal fps_15(.clk(clk), .resetn(frame_counter_reset), .en(frame_counter_enable), .move_signal_out(frame_counter_out));
	 
	 
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
					START	   				: next_state = go ? LOAD_COORD : START; // Wait until go command is given to load coordinates
					LOAD_COORD				: next_state = DRAW; // draw the box after loading the coordinates
					DRAW						: next_state = (draw_counter_out == 4'b1111) ? RESET_DELAY : DRAW; //draw->reset delay counters
					RESET_DELAY				: next_state = DELAY; //reset delay counters-> delay
					DELAY						: next_state = (frame_counter_out == 1'b1) ? ERASE : DELAY; //delay->erase
					ERASE						: next_state = (draw_counter_out == 4'b1111) ? UPDATE : ERASE; //erase->update
					UPDATE					: next_state = LOAD_COORD; //update->draw
            default     				: next_state = START;
        endcase
    end // state_table
   
    // Output logic aka all of our datapath control signals
    always @(*)
		 begin: enable_signals
			  // By default make all our signals 0
				load_x = 1'b0;
				load_y = 1'b0;
				en = 1'b0; //starts the drawing
				move_logic_en = 1'b0; //enables the move logic circuit to calculate the next coordinates
				draw_counter_en = 1'b0; //enables the drawing counter_16 so that the box is drawn in full
				control_colour = 3'b000; //controls the colour that will be used to draw the box
				frame_counter_reset = 1'b1; //resets the frame coutner
				frame_counter_enable = 1'b0; //enables the frame counter
			  
				//state control signals
			  case (current_state)
						START:
							begin
								load_x = 1'b1;
								load_y = 1'b1;
							end
						LOAD_COORD:
							begin
								load_x = 1'b1;
								load_y = 1'b1;
							end
						DRAW:
							begin
								en = 1'b1;
								draw_counter_en = 1'b1;
								control_colour = input_colour;
							end
						RESET_DELAY: //reset the delay counters
							begin
								frame_counter_reset = 1'b0;
							end
						DELAY: //delay for 15 frames
							begin
								frame_counter_reset = 1'b1;
								frame_counter_enable = 1'b1;
							end
						ERASE:
							begin
								en = 1'b1;
								draw_counter_en = 1'b1;
								control_colour = 3'b000;
							end
						UPDATE:
							begin
								move_logic_en = 1'b1;
							end
			  // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
			  endcase
		 end // enable_signals
   
    // current_state registers
    always@(posedge clk)
		 begin: state_FFs
			  if(!resetn)
					current_state <= START; 
			  else
					current_state <= next_state;
		 end // state_FFS
endmodule

//5_bit counter for drawing of the box - counts to 16 so that the box is drawn compltely
module counter_5_bit(clk, en, resetn, out);
		input clk;
		input resetn;
		input en;
		output reg [3:0] out;
		
		always @(posedge clk)
			begin
				if (resetn == 1'b0)
					out <= 4'b0000;
				else
					if (en)
						begin
							if (out == 4'b1111)
								out <= 4'b0000;
							else 
								out <= out + 4'b0001;
						end
			end
endmodule



//15 FRAMES COUNTER - outputs 1 after counting 15 frames
module fps_15_signal(clk, resetn, en, move_signal_out);
		input clk, resetn, en;
		output move_signal_out;
		wire fps_out;
		rate_divider_60_fps f0(.clk(clk), .resetn(resetn), .en(en), .fps_60_out(fps_out));
		counter_15 c_0(.clk(clk), .resetn(resetn), .en(fps_out), .q(move_signal_out));
endmodule

//counte 60 frames per second
module rate_divider_60_fps(clk, resetn, en, fps_60_out);
		input clk, resetn, en;
		output fps_60_out;
		wire [19:0]out;
		counter_834k c0(.clk(clk), .resetn(resetn), .en(en), .q(out));
		assign fps_60_out = (out == 833334) ? (1) : (0);
endmodule

//counter for rate divider for 50 Mhz
module counter_834k(clk, resetn, en, q);
		input clk, resetn, en;
		output reg [19:0]q;
		always @ (posedge clk)
			begin
				if (resetn == 0)
					q <= 0;
				else	if (en == 1)
					begin
						if (q == 833334)
							q <= 0;
						else
							q <= q + 1;
					end
			end
endmodule

//counts to 15 
module counter_15(clk, resetn, en, q);
		input clk, resetn, en;
		output q;
		reg [3:0]count;
		always @ (posedge clk)
			begin
				if (resetn == 0)
					count <= 0;
				else	if (en == 1)
					begin
						if (count == 14)
							count <= 0;
						else
							count <= count + 1;
					end
			end
		assign q = (count == 14) ? (1) : (0);
endmodule






//MOVE LOGIC
module move_logic(clk, en, resetn, x, y);

		input clk;
		input en;
		input resetn;
		output [7:0]x;
		output [6:0]y;
		
		wire h_dir;
		wire v_dir;
		wire [7:0] x_coord;
		wire [6:0] y_coord;
		
		hor_dir_reg h_d_r0(.clk(clk), .resetn(resetn), .x_coord(x_coord), .left_right(h_dir));
		x_counter x_0(.clk(clk), .resetn(resetn), .en(en), .up_down(h_dir), .x_coord(x_coord));
		ver_dir_reg v_d_r0(.clk(clk), .resetn(resetn), .y_coord(y_coord), .up_down(v_dir));
		y_counter y_0(.clk(clk), .resetn(resetn), .en(en), .up_down(v_dir), .y_coord(y_coord));
		
		assign x = x_coord;
		assign y = y_coord;
endmodule

//counter for y-coordinate
module y_counter(clk, resetn, en, up_down, y_coord);
		input clk;
		input resetn;
		input en;
		input up_down;
		
		output reg [6:0] y_coord;


		always @(posedge clk)
			begin
				if (!resetn)
					y_coord <= 60;
				else
					if (en)
						begin
							if (up_down)
								y_coord <= y_coord + 1;
							else 
								y_coord <= y_coord - 1;
						end
			end
endmodule

//direction registers, which will give the coordinate counters their conting directions
module ver_dir_reg(clk, resetn, y_coord, up_down);
		input clk;
		input resetn;
		input [6:0] y_coord;
		
		output reg up_down;
		
		always @(posedge clk)
			begin
				if (!resetn)
					up_down <= 1;
				else
						begin
							if (y_coord == 116)			//if we reached the right border, start subtracting
								up_down <= 0;
							else if (y_coord == 1)
								up_down <= 1;			//if we reached the left border, start adding						
						end
			end
endmodule

//counter for x-coordinate
module x_counter(clk, resetn, en, up_down, x_coord);
		input clk;
		input resetn;
		input en;
		input up_down;
		
		output reg [7:0] x_coord; 


		always @(posedge clk)
			begin
				if (!resetn)
					x_coord <= 0;
				else
					if (en)
						begin
							if (up_down)
								x_coord <= x_coord + 1;
							else 
								x_coord <= x_coord - 1;
						end
			end
endmodule

//direction registers, which will give the coordinate counters their conting directions
module hor_dir_reg(clk, resetn, x_coord, left_right);
		input clk;
		input resetn;
		input [7:0]x_coord;
		
		output reg left_right; 
		
		always @(posedge clk)
			begin
				if (!resetn)
					left_right <= 1;
				else
						begin
							if (x_coord == 156)			//if we reached the right border, start subtracting
								left_right <= 0;
							else if (x_coord == 1)
								left_right <= 1;			//if we reached the left border, start adding						
						end
			end
endmodule





//DATAPATH
module animation_datapath(x_input, y_input, en, colour, clk, resetn, ld_x, ld_y, X, Y, colour_out);
		input [7:0] x_input;
		input [6:0] y_input;
		input [2:0] colour;
		input clk;
		input resetn;
		input en;
		input ld_x;
		input ld_y;
		
		output reg [7:0] X;
		output reg [6:0] Y;
		output reg [2:0] colour_out; 
		
		//extend x-coordinate
		wire [3:0] counter_out;
		reg [7:0] x_register;
		reg [6:0] y_register;
		
		//instantiate 4-bit counter
		counter_4_bit c_4(.clk(clk), .en(en), .resetn(resetn), .out(counter_out));
		
		//registers for X and y
		always @(posedge clk)
			begin
				if (resetn == 1'b0)
					begin
						x_register <= 8'b0000_0000;
						y_register <= 7'b0000_000;
					end
				else
					begin
						if (ld_x)
							x_register <= x_input;
						if (ld_y)
							y_register <= y_input;	
					end
			end
		
		
		//output registers
		always@ (posedge clk)
			begin
				if (!resetn)
					begin
						X <= 8'b0000_0000;
						Y <= 7'b000_0000;
					end
				else 
					if (en)
						begin
							X <= x_register + {6'b00_0000, counter_out[1:0]};
							Y <= y_register + {5'b0_0000, counter_out[3:2]};
						end
			end
		
		always @ (posedge clk)
			begin
				if (!resetn)
					colour_out <= 3'b000;
				else 
					colour_out <= colour;	
			end
			
endmodule

// 4_bit counter for datapath (to draw out the box)
module counter_4_bit(clk, en, resetn, out);
		input clk;
		input resetn;
		input en;
		output reg [3:0] out;
		
		always @(posedge clk)
			begin
				if (resetn == 1'b0)
					out <= 4'b0000;
				else
					if (en)
						out <= out + 4'b0001;
			end
endmodule



















