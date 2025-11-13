module enemy_movement(
	input clk,
   input rst,  
   input [9:0] xPixel,  
   input [9:0] yPixel,  
   output reg enemy_color
);

	reg [9:0] enemy_x;
   reg [9:0] enemy_y;
	reg right;
	reg [2:0]S,NS;
	
	reg [26:0]move_delay;
	parameter	ENEMY_HEIGHT = 40;
	parameter	ENEMY_WIDTH = 40;
	parameter 	SCREEN_WIDTH  = 640;
	parameter VIRTUAL_SCREEN_WIDTH = 160;
   parameter 	SCREEN_HEIGHT = 480;
	parameter VIRTUAL_SCREEN_HEIGHT = 120;
	
	parameter	M_RIGHT = 3'b000,
					SHIFT_R = 3'b001,
					SHIFT_D = 3'b010,
					M_LEFT  = 3'b011,
					SHIFT_L = 3'b100;
					
	always@(posedge clk or negedge rst)
		if(!rst)
			S = M_RIGHT;
		else
			S = NS;
			
	always@(*)
	if(xPixel >= enemy_x && xPixel <= enemy_x + ENEMY_WIDTH && yPixel >= enemy_y && yPixel <= enemy_y + ENEMY_HEIGHT)
		enemy_color = 24'h00FF19;
	else
		enemy_color = 24'h000000;
	
	
	always@(*)
		case(S)
		M_RIGHT:
			if(move_delay == 26'd25000000)
				NS = SHIFT_R;
			else
				NS = M_RIGHT;
		SHIFT_R:
			if (SCREEN_WIDTH - ENEMY_WIDTH == enemy_x)
				NS = SHIFT_D;
			else
				NS = M_RIGHT;
		SHIFT_D:
			if(right == 1'b1)
				NS = M_LEFT;
			else
				NS = M_RIGHT;
		M_LEFT:
			if(move_delay == 26'd25000000)
				NS = SHIFT_L;
			else
				NS = M_LEFT;
		SHIFT_L:
			if (enemy_x == 0)
				NS = SHIFT_D;
			else
				NS = M_LEFT;
		endcase
		
	
	always@(posedge clk or negedge rst)
		if (!rst)
		begin
			right <= 1'b1;
			move_delay <= 26'd0;
			enemy_x <= 10'd10;
			enemy_y <= 10'd10;
		end
		else
			case(S)
				M_RIGHT:
					if(move_delay >= 26'd25000000)
						move_delay <= 26'd0;
					else
						move_delay <= move_delay + 1;
				SHIFT_R:
				begin
					enemy_x <= enemy_x + 2'd2;
					move_delay <= 26'd0;
				end
				SHIFT_D:
					enemy_y <= enemy_y + 6'd60;
				M_LEFT:
				begin
					right <= 1'b0;
					if(move_delay >= 26'd25000000)
						move_delay <= 26'd0;
					else
						move_delay <= move_delay + 1;
				end
				SHIFT_L:
					begin
					enemy_x <= enemy_x - 3'd4;
					move_delay <= 26'd0;
					end
				endcase
		
		
endmodule
		