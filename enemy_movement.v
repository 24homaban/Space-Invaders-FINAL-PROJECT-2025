module enemy_movement(
	input clk,
   input rst,  
   input [9:0] xPixel,  
   input [9:0] yPixel,
	input [9:0] bullet_x,
	input [9:0] bullet_y,
   output reg [23:0]enemy_color,
	output reg bullet_hit
);

	reg [9:0] enemy_x;
   reg [9:0] enemy_y;
	reg right;
	reg dead;
	reg [2:0]S,NS;
	
	reg [26:0]move_delay;
	parameter	ENEMY_HEIGHT = 30;
	parameter	ENEMY_WIDTH = 30;
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
			
	always@(*) begin
	if(xPixel >= enemy_x && xPixel <= enemy_x + ENEMY_WIDTH && yPixel >= enemy_y && yPixel <= enemy_y + ENEMY_HEIGHT && dead == 1'b0)
		enemy_color = 24'hFFFFFF;
	else
		enemy_color = 24'h000000;
		end
			
	
	
	always@(*)
		case(S)
		M_RIGHT:
			if(move_delay == 26'd10000000)
				NS = SHIFT_R;
			else
				NS = M_RIGHT;
		SHIFT_R:
			if (SCREEN_WIDTH - ENEMY_WIDTH <= enemy_x && right == 1'b1)
				NS = SHIFT_D;
			else
				NS = M_RIGHT;
		SHIFT_D:
			if(right == 1'b1)
				NS = M_LEFT;
			else
				NS = M_RIGHT;
		M_LEFT:
			if(move_delay == 26'd10000000)
				NS = SHIFT_L;
			else
				NS = M_LEFT;
		SHIFT_L:
			if (enemy_x <= 2'd2 && right == 1'd0)
				NS = SHIFT_D;
			else
				NS = M_LEFT;
		endcase
		
	
	always@(posedge clk or negedge rst)
	begin
		if (!rst)
		begin
			right <= 1'b1;
			move_delay <= 26'd0;
			enemy_x <= 10'd10;
			enemy_y <= 10'd10;
			dead <= 1'b0;
			bullet_hit <= 1'b0;
		end
		else
		begin
			if ((bullet_x >= enemy_x && bullet_x < enemy_x + ENEMY_WIDTH) && (bullet_y >= enemy_y && bullet_y < enemy_y + ENEMY_HEIGHT)) 
				begin
					dead <= 1'b1;
					bullet_hit <= 1'b1;
				end	
			else 
					bullet_hit <= 1'b0;
			case(S)
				M_RIGHT:
				begin
				right <= 1;
					if(move_delay >= 26'd10000000)
						move_delay <= 26'd0;
					else
						move_delay <= move_delay + 1'b1;
				end
				SHIFT_R:
				begin
					enemy_x <= enemy_x + 2'd2;
					move_delay <= 26'd0;
				end
				SHIFT_D:
				begin
					if(right == 1)
						right <= 1'b0;
					else
						right <= 1'b1;
					enemy_y <= enemy_y + 6'd50;
				end
				M_LEFT:
				begin
					if(move_delay >= 26'd10000000)
						move_delay <= 26'd0;
					else
						move_delay <= move_delay + 1'b1;
				end
				SHIFT_L:
					begin
					enemy_x <= enemy_x - 2'd2;
					move_delay <= 26'd0;
					end
				endcase
			end
		end
		
endmodule
		