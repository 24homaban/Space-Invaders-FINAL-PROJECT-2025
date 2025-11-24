module alien_grid(
    input  clk,
    input  rst,
    input  [9:0] xPixel,
    input  [9:0] yPixel,
    input  [9:0] bullet_x,
    input  [9:0] bullet_y,
    output reg [23:0] enemy_color,
    output reg bullet_hit
);


parameter ENEMY_W  = 30;
parameter ENEMY_H  = 30;
parameter SPACING_X = 10;
parameter SPACING_Y = 10;

parameter COLUMNS = 10;
parameter ROWS = 5;
parameter ENEMIES = 50;

parameter SCREEN_W = 640;
parameter VIRTUAL_SCREEN_WIDTH = 160;
parameter SCREEN_HEIGHT = 480;
parameter VIRTUAL_SCREEN_HEIGHT = 120;

reg [9:0] grid_x;
reg [9:0] grid_y;

reg right; 

reg [26:0] move_delay;


reg dead [0:49];



parameter M_RIGHT  = 3'd0,
          SHIFT_R  = 3'd1,
          SHIFT_D = 3'd2,
          M_LEFT   = 3'd3,
          SHIFT_L  = 3'd4;

reg [2:0] S, NS;

always @(posedge clk or negedge rst)
    if(!rst)
        S <= M_RIGHT;
    else
        S <= NS;



always @(*) begin
    case(S)
        M_RIGHT:
            if(move_delay == 27'd10000000)
                NS = SHIFT_R;
            else
                NS = M_RIGHT;

        SHIFT_R:
            if(grid_x + (COLUMNS*ENEMY_W + (COLUMNS-1'b1)*SPACING_X) > SCREEN_W && right == 1'b1)
                NS = SHIFT_D;
            else
                NS = M_RIGHT;

        SHIFT_D:
				if(right == 1'b1)
					NS = M_LEFT;
				else
					NS = M_RIGHT;

        M_LEFT:
            if(move_delay == 27'd10000000)
                NS = SHIFT_L;
            else
                NS = M_LEFT;

        SHIFT_L:
            if(grid_x <= 2'd2 && right == 1'b0)
                NS = SHIFT_D;
            else
                NS = M_LEFT;

        default: NS = M_RIGHT;
    endcase
end


always @(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        grid_x <= 10'd20;
        grid_y <= 10'd20;
        right <= 1'b1;
        move_delay <= 27'd0;
		  
		  
    end
    else
    begin

        case(S)
            M_RIGHT: begin
               right <= 1'b1;
					if(move_delay >= 27'd10000000)
						move_delay <= 27'd0;
					else
						move_delay <= move_delay + 1'b1;
            end
            SHIFT_R: begin
                grid_x <= grid_x + 2'd2;
            end
            SHIFT_D: begin
					if(right == 1)
						right <= 1'b0;
					else
						right <= 1'b1;
               grid_y <= grid_y + (ENEMY_H + SPACING_Y);
            end
				
            M_LEFT:
				if(move_delay >= 27'd10000000)
					move_delay <= 27'd0;
				else
					move_delay <= move_delay + 1'b1;
            SHIFT_L: begin
                grid_x <= grid_x - 2'd2;
            end

  
        endcase
    end
end


reg [5:0] enemy_index;  
reg [9:0] enemy_x;   
reg [9:0] enemy_y;   

always @(posedge clk or negedge rst)
begin
    if(!rst)
        enemy_index <= 6'd0;
    else
        if(enemy_index == 6'd49)
            enemy_index <= 6'd0;
        else
            enemy_index <= enemy_index + 1'b1;
end



reg [9:0] offx, offy;

always @(*) begin
    case(enemy_index)
	6'd0:  
	begin 
		offx=0*(ENEMY_W+SPACING_X);
		offy=0*(ENEMY_H+SPACING_Y); 
	end
	6'd1:
	begin 
		offx=1*(ENEMY_W+SPACING_X);
		offy=0*(ENEMY_H+SPACING_Y);
	end
	6'd2:
	begin
		offx=2*(ENEMY_W+SPACING_X);
		offy=0*(ENEMY_H+SPACING_Y);
	end
	6'd3:
	begin
		offx=3*(ENEMY_W+SPACING_X);
		offy=0*(ENEMY_H+SPACING_Y);
	end
	6'd4:
	begin
		offx=4*(ENEMY_W+SPACING_X);
		offy=0*(ENEMY_H+SPACING_Y);
	end
	6'd5:
	begin
		offx=5*(ENEMY_W+SPACING_X);
		offy=0*(ENEMY_H+SPACING_Y);
	end
	6'd6:
	begin 
		offx=6*(ENEMY_W+SPACING_X);
		offy=0*(ENEMY_H+SPACING_Y);
	end
	6'd7:
	begin
		offx=7*(ENEMY_W+SPACING_X);
		offy=0*(ENEMY_H+SPACING_Y);
	end
	6'd8:
	begin
		offx=8*(ENEMY_W+SPACING_X);
		offy=0*(ENEMY_H+SPACING_Y);
	end
	6'd9:
	begin
		offx=9*(ENEMY_W+SPACING_X);
		offy=0*(ENEMY_H+SPACING_Y);
	end

       
	6'd10: begin offx=0*(ENEMY_W+SPACING_X); offy=1*(ENEMY_H+SPACING_Y); end
	6'd11: begin offx=1*(ENEMY_W+SPACING_X); offy=1*(ENEMY_H+SPACING_Y); end
	6'd12: begin offx=2*(ENEMY_W+SPACING_X); offy=1*(ENEMY_H+SPACING_Y); end
	6'd13: begin offx=3*(ENEMY_W+SPACING_X); offy=1*(ENEMY_H+SPACING_Y); end
	6'd14: begin offx=4*(ENEMY_W+SPACING_X); offy=1*(ENEMY_H+SPACING_Y); end
	6'd15: begin offx=5*(ENEMY_W+SPACING_X); offy=1*(ENEMY_H+SPACING_Y); end
	6'd16: begin offx=6*(ENEMY_W+SPACING_X); offy=1*(ENEMY_H+SPACING_Y); end
	6'd17: begin offx=7*(ENEMY_W+SPACING_X); offy=1*(ENEMY_H+SPACING_Y); end
	6'd18: begin offx=8*(ENEMY_W+SPACING_X); offy=1*(ENEMY_H+SPACING_Y); end
	6'd19: begin offx=9*(ENEMY_W+SPACING_X); offy=1*(ENEMY_H+SPACING_Y); end

     
	6'd20: begin offx=0*(ENEMY_W+SPACING_X); offy=2*(ENEMY_H+SPACING_Y); end
	6'd21: begin offx=1*(ENEMY_W+SPACING_X); offy=2*(ENEMY_H+SPACING_Y); end
	6'd22: begin offx=2*(ENEMY_W+SPACING_X); offy=2*(ENEMY_H+SPACING_Y); end
	6'd23: begin offx=3*(ENEMY_W+SPACING_X); offy=2*(ENEMY_H+SPACING_Y); end
	6'd24: begin offx=4*(ENEMY_W+SPACING_X); offy=2*(ENEMY_H+SPACING_Y); end
	6'd25: begin offx=5*(ENEMY_W+SPACING_X); offy=2*(ENEMY_H+SPACING_Y); end
	6'd26: begin offx=6*(ENEMY_W+SPACING_X); offy=2*(ENEMY_H+SPACING_Y); end
	6'd27: begin offx=7*(ENEMY_W+SPACING_X); offy=2*(ENEMY_H+SPACING_Y); end
	6'd28: begin offx=8*(ENEMY_W+SPACING_X); offy=2*(ENEMY_H+SPACING_Y); end
	6'd29: begin offx=9*(ENEMY_W+SPACING_X); offy=2*(ENEMY_H+SPACING_Y); end

      
	6'd30: begin offx=0*(ENEMY_W+SPACING_X); offy=3*(ENEMY_H+SPACING_Y); end
	6'd31: begin offx=1*(ENEMY_W+SPACING_X); offy=3*(ENEMY_H+SPACING_Y); end
	6'd32: begin offx=2*(ENEMY_W+SPACING_X); offy=3*(ENEMY_H+SPACING_Y); end
	6'd33: begin offx=3*(ENEMY_W+SPACING_X); offy=3*(ENEMY_H+SPACING_Y); end
	6'd34: begin offx=4*(ENEMY_W+SPACING_X); offy=3*(ENEMY_H+SPACING_Y); end
	6'd35: begin offx=5*(ENEMY_W+SPACING_X); offy=3*(ENEMY_H+SPACING_Y); end
	6'd36: begin offx=6*(ENEMY_W+SPACING_X); offy=3*(ENEMY_H+SPACING_Y); end
	6'd37: begin offx=7*(ENEMY_W+SPACING_X); offy=3*(ENEMY_H+SPACING_Y); end
	6'd38: begin offx=8*(ENEMY_W+SPACING_X); offy=3*(ENEMY_H+SPACING_Y); end
	6'd39: begin offx=9*(ENEMY_W+SPACING_X); offy=3*(ENEMY_H+SPACING_Y); end


	6'd40: begin offx=0*(ENEMY_W+SPACING_X); offy=4*(ENEMY_H+SPACING_Y); end
	6'd41: begin offx=1*(ENEMY_W+SPACING_X); offy=4*(ENEMY_H+SPACING_Y); end
	6'd42: begin offx=2*(ENEMY_W+SPACING_X); offy=4*(ENEMY_H+SPACING_Y); end
	6'd43: begin offx=3*(ENEMY_W+SPACING_X); offy=4*(ENEMY_H+SPACING_Y); end
	6'd44: begin offx=4*(ENEMY_W+SPACING_X); offy=4*(ENEMY_H+SPACING_Y); end
	6'd45: begin offx=5*(ENEMY_W+SPACING_X); offy=4*(ENEMY_H+SPACING_Y); end
	6'd46: begin offx=6*(ENEMY_W+SPACING_X); offy=4*(ENEMY_H+SPACING_Y); end
	6'd47: begin offx=7*(ENEMY_W+SPACING_X); offy=4*(ENEMY_H+SPACING_Y); end
	6'd48: begin offx=8*(ENEMY_W+SPACING_X); offy=4*(ENEMY_H+SPACING_Y); end
	6'd49: begin offx=9*(ENEMY_W+SPACING_X); offy=4*(ENEMY_H+SPACING_Y); end

        default: begin offx = 0; offy = 0; end
    endcase
end



always @(*) begin
    enemy_x = grid_x + offx;
    enemy_y = grid_y + offy;
end



always @(posedge clk or negedge rst)
begin
    if(!rst)
	 begin
        enemy_color <= 24'd0;
		  dead[0] <= 1'b0;
		  dead[1] <= 1'b0;
		  dead[2] <= 1'b0;
		  dead[3] <= 1'b0;
		  dead[4] <= 1'b0;
		  dead[5] <= 1'b0;
		  dead[6] <= 1'b0;
		  dead[7] <= 1'b0;
		  dead[8] <= 1'b0;
		  dead[9] <= 1'b0;
		  dead[10] <= 1'b0;
		  dead[11] <= 1'b0;
		  dead[12] <= 1'b0;
		  dead[13] <= 1'b0;
		  dead[14] <= 1'b0;
		  dead[15] <= 1'b0;
		  dead[16] <= 1'b0;
		  dead[17] <= 1'b0;
		  dead[18] <= 1'b0;
		  dead[19] <= 1'b0;
		  dead[20] <= 1'b0;
		  dead[21] <= 1'b0;
		  dead[22] <= 1'b0;
		  dead[23] <= 1'b0;
		  dead[24] <= 1'b0;
		  dead[25] <= 1'b0;
		  dead[26] <= 1'b0;
		  dead[27] <= 1'b0;
		  dead[28] <= 1'b0;
		  dead[29] <= 1'b0;
		  dead[30] <= 1'b0;
		  dead[31] <= 1'b0;
		  dead[32] <= 1'b0;
		  dead[33] <= 1'b0;
		  dead[34] <= 1'b0;
		  dead[35] <= 1'b0;
		  dead[36] <= 1'b0;
		  dead[37] <= 1'b0;
		  dead[38] <= 1'b0;
		  dead[39] <= 1'b0;
		  dead[40] <= 1'b0;
		  dead[41] <= 1'b0;
		  dead[42] <= 1'b0;
		  dead[43] <= 1'b0;
		  dead[44] <= 1'b0;
		  dead[45] <= 1'b0;
		  dead[46] <= 1'b0;
		  dead[47] <= 1'b0;
		  dead[48] <= 1'b0;
		  dead[49] <= 1'b0;
		  bullet_hit <= 1'b0;
		  end
    else
    begin
 
        if(!dead[enemy_index]) begin
            if(bullet_x >= enemy_x && bullet_x < enemy_x+ENEMY_W &&
               bullet_y >= enemy_y && bullet_y < enemy_y+ENEMY_H) begin
                dead[enemy_index] <= 1'b1;
                bullet_hit <= 1'b1;
            end
			else
			bullet_hit <= 1'b0;
        end

        if(!dead[enemy_index] &&
           xPixel >= enemy_x && xPixel < enemy_x+ENEMY_W &&
           yPixel >= enemy_y && yPixel < enemy_y+ENEMY_H)
            enemy_color <= 24'hFFFFFF;
        else
            enemy_color <= 24'h000000;
    end
end

endmodule
