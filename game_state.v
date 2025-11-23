module game_state(
input clk,
input rst,
input start,
input [9:0]y_axis,
input [1:0]lives

);


reg [1:0] S, NS;

parameter	HOME = 3'd0,
				GAME = 3'd1,
				TAKE_LIFE = 3'd2,
				GAME_OVER = 3'd3;
				
				
				
always@(posedge clk or negedge rst)
    if (!rst) S <= HOME;
    else       S <= NS;
	 
	 
always@(*)
case(S)

	HOME:
	if(start == 1'b1)
	NS = GAME;
	
	GAME:
	if(y_axis >= 400)
	NS = TAKE_LIFE;
	
	TAKE_LIFE:
	if(lives == 0)
	NS = GAME_OVER;
	else
	NS = GAME;
	
	GAME_OVER:
	if(start == 1'b1)
	NS = HOME;

endcase


/*always@(posedge clk or negedge rst)
	case(S)
	HOME:
	
	
	GAME:

	
	TAKE_LIFE:

	
	GAME_OVER:
	


endcase*/
	
	
	 
endmodule