module EE445_HW1_2030393(RST,CLK,PASSWD,PADOUT,DAV,OK,LOCKED,G,R,Y);
	
	input RST;
	input CLK;
	input PASSWD;
	input [3:0]PADOUT; //Output of the keypad
	input DAV;
	input OK;
	reg[15:0]INPUT;	  //Register to store the input 
	reg[15:0]CURRENT; //Current password
	reg[2:0]SHIFTC;	  //Counter to keep track of shifts   
	reg[2:0]INNUM;	  //Number of inputs after last OK
	output reg LOCKED; 
	reg[15:0]PREV1;
	reg[15:0]PREV2;
	reg[15:0]PREV3;
	reg[31:0]LEDC;    //Counter to keep track of LED toggle times
	output reg G;
	output reg R;
	output reg Y;
	reg [2:0]STATE; 
	reg B_DAV; //Buffer for DAV
	parameter S_PassEnter= 3'd0;
	parameter S_Unlocked = 3'd1; 
	parameter S_Wrong     = 3'd2; 
	parameter S_Shift     = 3'd3;
	parameter S_NewPass   = 3'd4;
	parameter S_Shift2    = 3'd5;

	
always @(negedge RST or posedge CLK) begin
	
	if (!RST) begin	 //Asynchronous reset
		STATE   <= S_PassEnter; 
		INPUT   <= 0;
		INNUM	<= 0; 		
		SHIFTC  <= 0;		
		CURRENT <= 16'h1234;
		G 		<= 0; 		
		R	    <= 0;
		Y		<= 1;
		LEDC	<= 0; 		
		LOCKED  <= 0; 	    
		PREV1	<= 16'h1234; 
		PREV2	<= 16'h1234;
		PREV3	<= 16'h1234;
		STATE   <= S_PassEnter;
		B_DAV   <= 0;
		
	end else begin
	B_DAV <= DAV; //Buffer DAV to be able to check for changes
	case (STATE) 
	S_PassEnter: begin
		if(OK) begin
			if(INNUM == 3'd4) begin
				if(!PASSWD) begin             //Pasword is assumed to be active low
					if(INPUT==CURRENT) begin 
						Y 	  <= 0;
						INNUM <= 0;
						INPUT <= 0;
						STATE <= S_NewPass;    //If OK is pressed while PASSWD is on and the password is correct go to new password state
					end else begin
						LEDC  <= 0;
						INNUM <= 0;
						INPUT <= 0;
						STATE <= S_PassEnter;  //If the password is incorrect go back to pass enter to try again
					end
				end else begin
					if(INPUT==CURRENT) begin  //If PASSWD is off and password is correct go to unlocked state and light green LED
						LOCKED <= 1;
						G      <= 1;
						Y      <= 0;
						STATE  <= S_Unlocked;
					end else begin 			//If the pasword is incorrect go to wrong state and light red LED
						R 	   <= 1;
						Y      <= 0;
						STATE  <= S_Wrong;
					end
				end
			end else begin                 //If  less than 4 inputs are taken ignore them and clear.
				INNUM <= 0;
				INPUT <= 0;
				STATE <= S_PassEnter;
			end
		end else begin
			if ((B_DAV != DAV) && (DAV == 1)) begin //If OK is not pressed wait until DAV goes from 0 to 1 
				if(INNUM == 3'd4) begin			    //Ignore inputs after 4th
				STATE <= S_PassEnter;
				end else begin						//Store the input if less than 4 inputs are taken then increment INNUM
				INPUT[3:0] <= PADOUT;
				STATE <= S_Shift;
				INNUM <= INNUM + 1'b1;
				end 
			end else begin
			STATE <= S_PassEnter;	
			end
		end
	end

	S_Unlocked: begin
		if (LEDC >= 32'd5000000) begin				//Light the green led 5s and then turn it off when returning back to PassEnter. 
			LOCKED<= 0;								//Lock the door again after 5 seconds 
			STATE <= S_PassEnter;
			INNUM <= 0;
			INPUT <= 0;
			G 	  <= 0;
			Y     <= 1;
			
		end else begin
			LEDC <= LEDC + 1 ;
			STATE  <= S_Unlocked;
		end 
	end

	S_Wrong: begin
		if (LEDC >= 32'd3000000) begin			//Light the green led 5s and then turn it off when returning back to PassEnter. 
			STATE <= S_PassEnter;	
			INNUM <= 0;
			INPUT <= 0;
			R 	  <= 0;
			Y     <= 1;
		end else begin
			LEDC  <= LEDC + 1 ;
			STATE <= S_Wrong;
		end 
	end

	S_Shift: begin
		if ((SHIFTC==4) || (INNUM == 4)) begin//Shift the INPUT 4 times to make space for the next input. If 4th input came don't shift since it is in place
			SHIFTC<= 0;
			STATE <= S_PassEnter;
		end else begin
			INPUT = INPUT << 1;
			SHIFTC<= SHIFTC + 1'b1;
			STATE <= S_Shift;
		end 
	end 

	S_NewPass: begin
		if (LEDC >= 32'd500000) begin  //Turn the lod on and of every 0.5 seconds
			Y 	 <= ~Y;
			LEDC <= 0;
		end else begin
			LEDC <= LEDC + 1 ;
			if (OK) begin				//If OK is pressed and there are 4 inputs store the new passwords and shift the old ones.
				if(INNUM == 3'd4) begin
					if ((INPUT==PREV1)||(INPUT==PREV2)||(INPUT==PREV3)) begin
						STATE <= S_NewPass;
						INNUM <= 0;
					end else begin
						CURRENT <= INPUT;
						PREV1   <= CURRENT;
						PREV2   <= PREV1;
						PREV3   <= PREV2;
						INNUM   <= 0;
						INPUT   <= 0;
						STATE   <= S_PassEnter;
						LEDC    <= 0;
						Y       <= 1;
					end 
				end else begin
					INNUM <= 0;
					STATE <= S_NewPass;
				end 
			end else begin
				if ((B_DAV != DAV) && (DAV == 1)) begin  //This part is the same as PassEnter state. It recieves the new password input
					if(INNUM == 3'd4) begin
						STATE <= S_NewPass;
					end else begin 
						INPUT[3:0] <= PADOUT;
						STATE <= S_Shift2;
						INNUM <= INNUM + 1'b1;
					end
				end else begin
					STATE <= S_NewPass;
				end 
			end 	
		end	 	
	end 
		
	S_Shift2: begin
		if ((SHIFTC==4) || (INNUM == 4)) begin  //Works the same as Shift but goes to different states. 
			SHIFTC<= 0;
			STATE <= S_NewPass;
		end else begin
			INPUT = INPUT << 1;
			SHIFTC<= SHIFTC + 1'b1;
			STATE <= S_Shift2;
		end 
	end 

	default : begin 
		STATE <= S_PassEnter;
	end 
	endcase
	end 
end  
endmodule 	
