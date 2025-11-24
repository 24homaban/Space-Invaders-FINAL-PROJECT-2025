module game_state(
input clk,
input rst,
input start,
input [9:0] xPixel,
input [9:0] yPixel,
input enemy_reached_bottom,
output reg in_game,
output reg [1:0] lives

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
	if(enemy_reached_bottom)
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


always@(posedge clk or negedge rst)
if(!rst)
begin
	lives <= 2'd3;
	in_game <= 1'b0;
end

else

	case(S)
	HOME:;
	
	
	GAME:
		in_game <= 1'b1;

	
	TAKE_LIFE:
		if (enemy_reached_bottom)
        if (lives > 2'd0)
            lives <= lives - 2'd1;

	
	GAME_OVER:;
	


endcase
	
	
	 
endmodule