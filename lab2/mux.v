//SW[2:0] data inputs
//SW[9] select signal
//LEDR[0] Output display

module mux(SW, LEDR);
	input[9:0] SW;
	output[9:0] LEDR;
	
	mux2to1 u0(
		.x(SW[0]),
		.y(SW[1]),
		.s(SW[9]),
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
