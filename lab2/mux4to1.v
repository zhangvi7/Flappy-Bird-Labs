module mux4to1(SW, LEDR);
	input [9:0] SW;
	output [9:0] LEDR;
	
	wire c1;
	wire c2;
	
	mux2to1 m1(		
		.x(SW[0]),
		.y(SW[1]),
		.s(SW[9]),
		.m(c1)
		);
	
	mux2to1 m2(
		.x(SW[2]),
		.y(SW[3]),
		.s(SW[9]),
		.m(c2)
		);
		
	mux2to1 m3(
		.x(c1),
		.y(c2),
		.s(SW[8]),
		.m(LEDR[0])
		);
endmodule 
	
module mux2to1(x, y, s, m);
	input x;	//when s is 0
	input y;	//when s is 1
	input s;	//select signal
	output m;	//output
	
	assign m = s & y | ~s & x;
	
endmodule 