`timescale 1us/1ps 
module EE445_HW1__2030393tb();

	reg RST;
	reg CLK;
	reg PASSWD;
	reg [3:0]PADOUT;
	reg DAV;
	reg OK;
	wire LOCKED;
	wire G;
	wire R;
	wire Y;
	
	EE445_HW1_2030393 testModule(
						  .RST(RST),
						  .CLK(CLK),
						  .PASSWD(PASSWD),
						  .PADOUT(PADOUT),
						  .DAV(DAV),
						  .OK(OK),
						  .LOCKED(LOCKED),
						  .G(G),
						  .R(R),
						  .Y(Y)
						  );

	initial begin
		CLK    = 0;
		RST    = 1; 
		PASSWD = 1;
		DAV    = 0;
		OK     = 0;
		#2;
		RST    = 0; //Send reset to initialize the system
		#2;
		RST    = 1; 
		#2;
		PASSWD = 0; //Use the PASSWD switch to set the new password. PASSWD assumed to be active low
		PADOUT = 4'h1;  
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20;
		PADOUT = 4'h2;  
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20;
		PADOUT = 4'h3;  
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20;
		PADOUT = 4'h4;  
		DAV    = 1;
		#2; 
		DAV    = 0;
		#2;
		OK     = 1; //After entering 4 digits press OK
		#4; 
		OK     = 0; 
		PASSWD = 0; 
		PADOUT = 4'h2;  
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20;
		PADOUT = 4'h9;  
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20;
		PADOUT = 4'h8;  
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20;
		PADOUT = 4'h7;  
		DAV    = 1;
		#2; 
		DAV    = 0;
		#2;
		OK     = 1; //Set the new password
		#4; 
		OK     = 0; 
		#20; 
		PADOUT = 4'h2; //  Lets change the password again to observe the change on previous value. PASSWD is still low
		DAV    = 1;	
		#2; 
		DAV    = 0;
		#20; 
		PADOUT = 4'h9;
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20; 
		PADOUT = 4'h8; 
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20; 
		PADOUT = 4'h7;
		DAV    = 1;
		#2; 
		DAV    = 0;
		#2; 
		OK     = 1;  
		#4; 
		OK     = 0;
		#20; 
		PADOUT = 4'hA; // Enter the new password
		DAV    = 1;	
		#2; 
		DAV    = 0;
		#20; 
		PADOUT = 4'hB;
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20; 
		PADOUT = 4'h2; 
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20; 
		PADOUT = 4'h3;
		DAV    = 1;
		#2; 
		DAV    = 0;
		#2; 
		OK     = 1; //After entering the new password (AB23) press OK. The previous value should have (2987)
		#4; 
		OK     = 0;
		#6; 
		PASSWD = 1; //PASSWD switch back to off 
		#10;
		PADOUT = 4'hA;
		DAV    = 1;	
		#2; 
		DAV    = 0;
		#20; 
		PADOUT = 4'hB;
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20; 
		PADOUT = 4'h2; 
		DAV    = 1;
		#2; 
		DAV    = 0;
		#20; 
		PADOUT = 4'h3;
		DAV    = 1;
		#2; 
		DAV    = 0;
		#2; 
		OK     = 1; //Enter the correct password and press OK. See the locked G and Y change.
		#4; 
		OK     = 0;
		#30; 
		RST    = 0; //When reset input comes the system initializes to back to password of 1234. Reset also erases previous passwords in this implementation
		#2;
		RST    = 1;
		$finish;
	end 	

	always @* begin
	forever #0.5 CLK = ~CLK; 
	end  
	
endmodule 
