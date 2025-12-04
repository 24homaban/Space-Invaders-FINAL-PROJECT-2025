module player (
   input clk,
   input rst,
	input bullet_hit,	 
   input left,
   input right,
   input shoot,
   input [9:0] xPixel,  
   input [9:0] yPixel, 
	input in_game,
	input reset_level,
	input increase_bullet_speed,
	output reg [9:0] bullet_x,
	output reg [9:0] bullet_y,
   output reg [23:0] player_color
	
);


    parameter PLAYER_WIDTH  = 60;
    parameter PLAYER_HEIGHT = 30;
    parameter SCREEN_WIDTH  = 640;
	 parameter VIRTUAL_SCREEN_WIDTH = 160;
    parameter SCREEN_HEIGHT = 480;
	 parameter VIRTUAL_SCREEN_HEIGHT = 120;
    parameter BULLET_WIDTH  = 4;
    parameter BULLET_HEIGHT = 12;


    parameter IDLE      = 2'b00;
    parameter SHOOT     = 2'b01;
    parameter SHOOTING  = 2'b10;

    reg [1:0] S, NS;

    reg [9:0] player_x;
    reg [9:0] player_y;
    reg [22:0] move_delay;
	 reg [19:0] bullet_move_delay;
	 reg [19:0] bullet_move_delay_inc;



	 always @(posedge clk or negedge rst)
	 if(!rst)
		S <= IDLE;
		else if(reset_level)
		S <= IDLE;
	else
		S <= NS;

    always @(*) 
	
	 begin
        case (S)
            IDLE: begin
                if (shoot && in_game)
                    NS = SHOOT;
                else
                    NS = IDLE;
            end
            SHOOT: begin
                NS = SHOOTING;
            end
            SHOOTING: begin
                if (bullet_hit || bullet_y == 0)
                    NS = IDLE;
                else
                    NS = SHOOTING;
            end
            default: NS = IDLE;
        endcase
    end

	 


    always @(posedge clk or negedge rst) 
	 begin
        if (!rst) begin
            player_x <= 10'd280;
            player_y <= 10'd400;
            bullet_x <= 10'd0;
            bullet_y <= 10'd0;
            move_delay <= 23'd0;
				bullet_move_delay <= 20'd0;
        end else if(reset_level) begin
				player_x <= 10'd280;
            player_y <= 10'd400;
            bullet_x <= 10'd0;
            bullet_y <= 10'd0;
            move_delay <= 23'd0;
				bullet_move_delay <= 20'd0; end
				else
		  
		  begin
			if(increase_bullet_speed)
			bullet_move_delay_inc <= 19'd500;
			else
			bullet_move_delay_inc <= 19'd1;
				
		
            if (move_delay == 23'd0)
                move_delay <= 23'd500000;
            else
                move_delay <= move_delay - 1'b1;
					 
				if (bullet_move_delay == 20'd0)
                bullet_move_delay <= 20'd1000000;
            else
                bullet_move_delay <= bullet_move_delay - bullet_move_delay_inc;

            
            if (in_game && move_delay == 23'd0) begin
                if (left && !right && player_x > 10'd0)
                    player_x <= player_x - 1'd1;
                else if (right && !left && player_x < (SCREEN_WIDTH - PLAYER_WIDTH))
                    player_x <= player_x + 1'd1;
            end

            // Bullet updates
            case (S)
                IDLE: begin
                    bullet_x <= 10'd0;
                    bullet_y <= 10'd800;
                end
                SHOOT: begin
                    bullet_x <= player_x + (PLAYER_WIDTH / 3'd2) - (BULLET_WIDTH / 3'd2);
                    bullet_y <= player_y - BULLET_HEIGHT;
                end
                SHOOTING: begin
					 if(bullet_move_delay == 20'd0)
                    bullet_y <= bullet_y - 3'd4; 
                end
            endcase
        end
    end

	 
	always@(*)
	
	
	if(xPixel >= player_x && xPixel <= player_x + PLAYER_WIDTH && yPixel >= player_y && yPixel <= player_y + PLAYER_HEIGHT)
		player_color = 24'h00FF19;
	else
		if(xPixel >= bullet_x && xPixel <= bullet_x + BULLET_WIDTH && yPixel >= bullet_y && yPixel <= bullet_y + BULLET_HEIGHT)
			player_color = 24'hFF0000;
		else
			player_color = 24'h000000;
 
endmodule