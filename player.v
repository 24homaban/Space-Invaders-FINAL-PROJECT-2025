module player (
   input clk,
   input rst,
	input bullet_hit,	 
   input left,
   input right,
   input shoot,
   input [9:0] xPixel,  
   input [9:0] yPixel,  
   output reg [23:0] player_color
	//output reg [23:0] bullet_color,
);


    parameter PLAYER_WIDTH  = 80;
    parameter PLAYER_HEIGHT = 40;
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
	 reg [9:0] bullet_x;
    reg [9:0] bullet_y;
    reg [22:0] move_delay;
	 reg [19:0] bullet_move_delay;



	 always @(posedge clk or negedge rst)
	 if(rst == 1'b0)
		S <= IDLE;
	else
		S <= NS;

    always @(*) 
	 begin
        case (S)
            IDLE: begin
                if (shoot)
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
            player_x <= 280;
            player_y <= 400;
            bullet_x <= 0;
            bullet_y <= 0;
            move_delay <= 0;
        end else 
		  begin
            if (move_delay == 0)
                move_delay <= 23'd5000000;
            else
                move_delay <= move_delay - 1'b1;
					 
				if (bullet_move_delay == 0)
                bullet_move_delay <= 20'd1000000;
            else
                bullet_move_delay <= bullet_move_delay - 1'b1;

            
            if (move_delay == 0) begin
                if (left && !right && player_x > 0)
                    player_x <= player_x - 8;
                else if (right && !left && player_x < (SCREEN_WIDTH - PLAYER_WIDTH))
                    player_x <= player_x + 8;
            end

            // Bullet updates
            case (S)
                IDLE: begin
                    bullet_x <= 0;
                    bullet_y <= 0;
                end
                SHOOT: begin
                    bullet_x <= player_x + (PLAYER_WIDTH / 2) - (BULLET_WIDTH / 2);
                    bullet_y <= player_y - BULLET_HEIGHT;
                end
                SHOOTING: begin
					 if(bullet_move_delay == 0)
                    bullet_y <= bullet_y - 4; 
                end
            endcase
        end
    end

	 
	always@(*)
	if(xPixel >= player_x && xPixel <= player_x + PLAYER_WIDTH && yPixel >= player_y && yPixel <= player_y + PLAYER_HEIGHT)
		player_color = 24'h00FF19;
	else
		if(xPixel >= bullet_x && xPixel <= bullet_x + BULLET_WIDTH && yPixel >= bullet_y && yPixel <= bullet_y+BULLET_HEIGHT)
			player_color = 24'hFF0000;
		else
			player_color = 24'h000000;
 
endmodule