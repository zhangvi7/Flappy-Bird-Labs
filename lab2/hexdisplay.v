module hexdisplay(SW, HEX);
	input [3:0] SW;
	output [6:0] HEX;
	
	seg0 s0(
		.x0(SW[0]),
		.x1(SW[1]),
		.x2(SW[2]),
		.x3(SW[3]),
		.out(HEX[0])
		);
	
	seg1 s1(
		.x0(SW[0]),
		.x1(SW[1]),
		.x2(SW[2]),
		.x3(SW[3]),
		.out(HEX[1])
		);
	
	seg2 s2(
		.x0(SW[0]),
		.x1(SW[1]),
		.x2(SW[2]),
		.x3(SW[3]),
		.out(HEX[2])
		);
	
	seg3 s3(
		.x0(SW[0]),
		.x1(SW[1]),
		.x2(SW[2]),
		.x3(SW[3]),
		.out(HEX[3])
		);
	
	seg4 s4(
		.x0(SW[0]),
		.x1(SW[1]),
		.x2(SW[2]),
		.x3(SW[3]),
		.out(HEX[4])
		);
	
	seg5 s5(
		.x0(SW[0]),
		.x1(SW[1]),
		.x2(SW[2]),
		.x3(SW[3]),
		.out(HEX[5])
		);
	
	seg6 s6(
		.x0(SW[0]),
		.x1(SW[1]),
		.x2(SW[2]),
		.x3(SW[3]),
		.out(HEX[6])
		);
endmodule
		
module seg0(x0, x1, x2, x3, out);
	 input x0;
	 input x1;
	 input x2;
	 input x3;
	 output out;
	 
	 assign out = (~x0 & x1 & ~x2 & ~x3) | (~x0 & ~x1 & ~x2 & x3) | (x0 & x1 & ~x2 & x3) | (x0 & ~x1 & x2 & x3);
endmodule

module seg1(x0, x1, x2, x3, out);
	 input x0;
	 input x1;
	 input x2;
	 input x3;
	 output out;
	 
	 assign out = (~x0 & x1 & ~x2 & x3) | (x0 & x1 & ~x3) | (x0 & x2 & x3) | (x1 & x2 & ~x3);
endmodule

module seg2(x0, x1, x2, x3, out);
	 input x0;
	 input x1;
	 input x2;
	 input x3;
	 output out;
	 
	 assign out = (~x0 & ~x1 & x2 & ~x3) | (x0 & x1 & x2) | (x0 & x1 & ~x3);
endmodule

module seg3(x0, x1, x2, x3, out);
	 input x0;
	 input x1;
	 input x2;
	 input x3;
	 output out;
	 
	 assign out = (~x0 & x1 & ~x2 & ~x3) | (~x1 & ~x2 & x3) | (x1 & x2 & x3) | (x0 & ~x1 & x2 & ~x3);
endmodule

module seg4(x0, x1, x2, x3, out);
	 input x0;
	 input x1;
	 input x2;
	 input x3;
	 output out;
	 
	 assign out = (~x0 & x1 & ~x2) | (~x1 & ~x2 & x3) | (~x0 & x3);
endmodule

module seg5(x0, x1, x2, x3, out);
	 input x0;
	 input x1;
	 input x2;
	 input x3;
	 output out;
	 
	 assign out = (x0 & x1 & ~x2 & x3) | (~x1 & ~x0 & x3) | (~x0 & ~x1 & x2) | (~x0 & x3 & x2);
endmodule

module seg6(x0, x1, x2, x3, out);
	 input x0;
	 input x1;
	 input x2;
	 input x3;
	 output out;
	 
	 assign out = (x0 & x1 & ~x2 & ~x3) | (x1 & ~x0 & x2 & x3) | (~x0 & ~x1 & ~x2);
endmodule


