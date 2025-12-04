module enemy_grid(
   input clk,
   input rst,
   input [9:0] xPixel,
   input [9:0] yPixel,
   input [9:0] bullet_x,
   input [9:0] bullet_y,
	input in_game,
	input reset_level,
   output reg [23:0] enemy_color,
   output reg bullet_hit,
	output reg enemy_reached_bottom,
	output reg [13:0]score
);

parameter ENEMY_W     = 30;
parameter ENEMY_H     = 30;
parameter SPACING_X   = 20;
parameter SPACING_Y   = 20;
parameter BULLET_WIDTH  = 4;
parameter BULLET_HEIGHT = 12;
parameter TOP_LAYER = 30;
parameter MIDDLE_LAYERS = 20;
parameter BOTTOM_LAYERS = 10;

parameter COLUMNS     = 10;
parameter ROWS        = 5;
parameter ENEMIES     = 50;
parameter SCREEN_W    = 640;

parameter M_RIGHT  = 3'd0,
          SHIFT_R  = 3'd1,
          SHIFT_D  = 3'd2,
          M_LEFT   = 3'd3,
          SHIFT_L  = 3'd4;

reg [2:0] S, NS;

reg [26:0] move_delay;
reg [4:0] speed_inc;
reg right;
reg [9:0] grid_x, grid_y;




integer k;
integer c;
integer row;
integer col;
integer actual_x;
integer actual_y;
integer left_col;
integer right_col;
integer r;
integer alive_in_col;
integer alive_in_row;



always @(posedge clk or negedge rst)
    if (!rst) S <= M_RIGHT;
	 else if(reset_level) S<= M_RIGHT;
    else       S <= NS;


		
	 
always @(*) 

begin
	col = 0;
	row = 0;
	actual_x = 0;
	actual_y = 0;
	left_col  = COLUMNS;   
	right_col = -1'b1;       

    for (col = 0; col < COLUMNS; col = col + 1) begin
        alive_in_col = 0;

        for (row = 0; row < ROWS; row = row + 1) begin
            r = row*COLUMNS + col;
            if (!dead[r])
                alive_in_col = 1;
        end

        if (alive_in_col) begin
            if (col < left_col)  left_col  = col;
            if (col > right_col) right_col = col;
        end
    end
end

reg [9:0] lowest_enemy_y;

always @(*) 

begin
	col = 0;
	row = 0;
	actual_x = 0;
	actual_y = 0;
    lowest_enemy_y = 0;
    enemy_reached_bottom = 0;

    for (k = 0; k < ENEMIES; k = k + 1) begin
        if (!dead[k]) begin
            col = k % COLUMNS;
            row = k / COLUMNS;

            actual_x = grid_x + col * (ENEMY_W + SPACING_X);
            actual_y = grid_y + row * (ENEMY_H + SPACING_Y);

            if (actual_y + ENEMY_H > lowest_enemy_y)
                lowest_enemy_y = actual_y + ENEMY_H;
        end
    end

    if (lowest_enemy_y >= 10'd400)
        enemy_reached_bottom = 1'b1;
end


always@(*)

		case(S)
		M_RIGHT:
			if(move_delay >= 26'd10000000)
				NS = SHIFT_R;
			else
				NS = M_RIGHT;
		SHIFT_R:
			if (((grid_x + right_col*(ENEMY_W+SPACING_X) + ENEMY_W) >= SCREEN_W) && right == 1'b1)
				NS = SHIFT_D;
			else
				NS = M_RIGHT;
		SHIFT_D:
			if(right == 1'b1)
				NS = M_LEFT;
			else
				NS = M_RIGHT;
		M_LEFT:
			if(move_delay >= 26'd10000000)
				NS = SHIFT_L;
			else
				NS = M_LEFT;
		SHIFT_L:
			if ((grid_x <= 2'd2) && right == 1'b0)
				NS = SHIFT_D;
			else
				NS = M_LEFT;
		endcase


		
		
always @(posedge clk or negedge rst)
begin
    if (!rst)
    begin
        grid_x     <= 10'd20;
        grid_y     <= 10'd20;
        right      <= 1'b1;
        move_delay <= 27'd0;
		  speed_inc  <= 5'd1;
    end
	 else if(reset_level)
	 begin
        grid_x     <= 10'd20;
        grid_y     <= 10'd20;
        right      <= 1'b1;
        move_delay <= 27'd0;
		  speed_inc  <= 5'd1;
    end
	 
    else 
    begin
        case (S)
            M_RIGHT: begin
                right <= 1'b1;
                if(move_delay >= 27'd10_000_000) 
						move_delay <= 27'd0;
					 else
						move_delay <= move_delay + speed_inc;
            end

            SHIFT_R: 
				if(in_game)	
					grid_x <= grid_x + 3'd2;
				else
					grid_x <= grid_x;

            SHIFT_D: begin
               if(right == 1'd1)
						right <= 1'b0;
					else
						right <= 1'b1;
                if(in_game) 
						grid_y <= grid_y + 5'd20;
					else
						grid_y <= grid_y;
					
					if(right == 1'd1 && speed_inc < 5'd20 && in_game)
					 speed_inc <= speed_inc + 5'b1;
            end

            M_LEFT:
                if(move_delay >= 27'd10_000_000) 
						move_delay <= 27'd0;
					 else
						move_delay <= move_delay + speed_inc;
            SHIFT_L: 
				if(in_game) 
					grid_x <= grid_x - 3'd2;
				else
					grid_x <= grid_x;
        endcase
    end
end



reg [49:0] dead;



always @(posedge clk or negedge rst)
begin
	col = 0;
	row = 0;
	actual_x = 0;
	actual_y = 0;
    if (!rst)
    begin
        dead <= {ENEMIES{1'b0}};
        bullet_hit <= 1'b0;
    end
	 
	 else if(reset_level)
	 begin
        dead <= {ENEMIES{1'b0}};
        bullet_hit <= 1'b0;
    end
	 
    else 
    begin
        bullet_hit <= 1'b0; 

        
        for (k = 0; k < ENEMIES; k = k + 1'b1)
        begin
            if (!dead[k])
            begin
                col = k % COLUMNS;
                row = k / COLUMNS;
                actual_x = grid_x + col * (ENEMY_W + SPACING_X);
                actual_y = grid_y + row * (ENEMY_H + SPACING_Y);
                if (((bullet_x > actual_x) || (bullet_x + BULLET_WIDTH > actual_x)) && (bullet_x < actual_x + ENEMY_W) &&
                    ((bullet_y > actual_y) || (bullet_y + BULLET_HEIGHT > actual_y)) && (bullet_y < actual_y + ENEMY_H))
                begin
                    dead[k] <= 1'b1;
                    bullet_hit <= 1'b1;
                end
            end
        end
    end
end



always @(*) 

begin
	col = 0;
	row = 0;
	actual_x = 0;
	actual_y = 0;
    enemy_color = 24'h000000;

    
    for (c = 0; c < ENEMIES; c = c + 1)
    begin
        if (!dead[c])
        begin
            col = c % COLUMNS;
            row = c / COLUMNS;

            actual_x = grid_x + col * (ENEMY_W + SPACING_X);
            actual_y = grid_y + row * (ENEMY_H + SPACING_Y);

            if ((xPixel >= actual_x) && (xPixel < actual_x + ENEMY_W) &&
                (yPixel >= actual_y) && (yPixel < actual_y + ENEMY_H) && c < 10)
            begin
                enemy_color = 24'hF2C516;
					 end
				else 
				if ((xPixel >= actual_x) && (xPixel < actual_x + ENEMY_W) &&
                (yPixel >= actual_y) && (yPixel < actual_y + ENEMY_H) && (c >= 10 && c < 30))
            begin
                enemy_color = 24'h07A3F0;
					 end
					 
				else 
				if ((xPixel >= actual_x) && (xPixel < actual_x + ENEMY_W) &&
                (yPixel >= actual_y) && (yPixel < actual_y + ENEMY_H) && c >= 30)
            begin
                enemy_color = 24'hF007B6;
            end
        end
    end
end


always@(*)
begin
	score = score_amount0 + score_amount1 + score_amount2 + score_amount3 + score_amount4 + score_amount5 + score_amount6 + score_amount7 + score_amount8 + score_amount9 + score_amount10
	 + score_amount11 + score_amount12 + score_amount13 + score_amount14 + score_amount15 + score_amount16 + score_amount17 + score_amount18 + score_amount19 + score_amount20  + score_amount21
	 + score_amount22 + score_amount23 + score_amount24 + score_amount25 + score_amount26 + score_amount27 + score_amount28 + score_amount29 + score_amount30 + score_amount31 + score_amount32
	 + score_amount33 + score_amount34 + score_amount35 + score_amount36 + score_amount37 + score_amount38 + score_amount39 + score_amount40 + score_amount41 + score_amount42 + score_amount43
	 + score_amount44 + score_amount45 + score_amount46 + score_amount47 + score_amount48 + score_amount49;
	if(dead[0])
		score_amount0 = TOP_LAYER;
		else
		score_amount0 = 0;
	if(dead[1])
		score_amount1 = TOP_LAYER;
		else
		score_amount1 = 0;
	if(dead[2])
		score_amount2 = TOP_LAYER;
		else
		score_amount2 = 0;
	if(dead[3])
		score_amount3 = TOP_LAYER;
		else
		score_amount3 = 0;
	if(dead[4])
		score_amount4 = TOP_LAYER;
		else
		score_amount4 = 0;
	if(dead[5])
		score_amount5 = TOP_LAYER;
		else
		score_amount5 = 0;
	if(dead[6])
		score_amount6 = TOP_LAYER;
		else
		score_amount6 = 0;
	if(dead[7])
		score_amount7 = TOP_LAYER;
		else
		score_amount7 = 0;
	if(dead[8])
		score_amount8 = TOP_LAYER;
		else
		score_amount8 = 0;
	if(dead[9])
		score_amount9 = TOP_LAYER;
		else
		score_amount9 = 0;
	if(dead[10])
		score_amount10 = MIDDLE_LAYERS;
		else
		score_amount10 = 0;
	if(dead[11])
		score_amount11 = MIDDLE_LAYERS;
		else
		score_amount11 = 0;
	if(dead[12])
		score_amount12 = MIDDLE_LAYERS;
		else
		score_amount12 = 0;
	if(dead[13])
		score_amount13 = MIDDLE_LAYERS;
		else
		score_amount13 = 0;
	if(dead[14])
		score_amount14 = MIDDLE_LAYERS;
		else
		score_amount14 = 0;
	if(dead[15])
		score_amount15 = MIDDLE_LAYERS;
		else
		score_amount15 = 0;
	if(dead[16])
		score_amount16 = MIDDLE_LAYERS;
		else
		score_amount16 = 0;
	if(dead[17])
		score_amount17 = MIDDLE_LAYERS;
		else
		score_amount17 = 0;
	if(dead[18])
		score_amount18 = MIDDLE_LAYERS;
		else
		score_amount18 = 0;
	if(dead[19])
		score_amount19 = MIDDLE_LAYERS;
		else
		score_amount19 = 0;
	if(dead[20])
		score_amount20 = MIDDLE_LAYERS;
		else
		score_amount20 = 0;
	if(dead[21])
		score_amount21 = MIDDLE_LAYERS;
		else
		score_amount21 = 0;
	if(dead[22])
		score_amount22 = MIDDLE_LAYERS;
		else
		score_amount22 = 0;
	if(dead[23])
		score_amount23 = MIDDLE_LAYERS;
		else
		score_amount23 = 0;
	if(dead[24])
		score_amount24 = MIDDLE_LAYERS;
		else
		score_amount24 = 0;
	if(dead[25])
		score_amount25 = MIDDLE_LAYERS;
		else
		score_amount25 = 0;
	if(dead[26])
		score_amount26 = MIDDLE_LAYERS;
		else
		score_amount26 = 0;
	if(dead[27])
		score_amount27 = MIDDLE_LAYERS;
		else
		score_amount27 = 0;
	if(dead[28])
		score_amount28 = MIDDLE_LAYERS;
		else
		score_amount28 = 0;
	if(dead[29])
		score_amount29 = MIDDLE_LAYERS;
		else
		score_amount29 = 0;
	if(dead[30])
		score_amount30 = BOTTOM_LAYERS;
		else
		score_amount30 = 0;
	if(dead[31])
		score_amount31 = BOTTOM_LAYERS;
		else
		score_amount31 = 0;
	if(dead[32])
		score_amount32 = BOTTOM_LAYERS;
		else
		score_amount32 = 0;
	if(dead[33])
		score_amount33 = BOTTOM_LAYERS;
		else
		score_amount33 = 0;
	if(dead[34])
		score_amount34 = BOTTOM_LAYERS;
		else
		score_amount34 = 0;
	if(dead[35])
		score_amount35 = BOTTOM_LAYERS;
		else
		score_amount35 = 0;
	if(dead[36])
		score_amount36 = BOTTOM_LAYERS;
		else
		score_amount36 = 0;
	if(dead[37])
		score_amount37 = BOTTOM_LAYERS;
		else
		score_amount37 = 0;
	if(dead[38])
		score_amount38 = BOTTOM_LAYERS;
		else
		score_amount38 = 0;
	if(dead[39])
		score_amount39 = BOTTOM_LAYERS;
		else
		score_amount39 = 0;
	if(dead[40])
		score_amount40 = BOTTOM_LAYERS;
		else
		score_amount40 = 0;
	if(dead[41])
		score_amount41 = BOTTOM_LAYERS;
		else
		score_amount41 = 0;
	if(dead[42])
		score_amount42 = BOTTOM_LAYERS;
		else
		score_amount42 = 0;
	if(dead[43])
		score_amount43 = BOTTOM_LAYERS;
		else
		score_amount43 = 0;
	if(dead[44])
		score_amount44 = BOTTOM_LAYERS;
		else
		score_amount44 = 0;
	if(dead[45])
		score_amount45 = BOTTOM_LAYERS;
		else
		score_amount45 = 0;
	if(dead[46])
		score_amount46 = BOTTOM_LAYERS;
		else
		score_amount46 = 0;
	if(dead[47])
		score_amount47 = BOTTOM_LAYERS;
		else
		score_amount47 = 0;
	if(dead[48])
		score_amount48 = BOTTOM_LAYERS;
		else
		score_amount48 = 0;
	if(dead[49])
		score_amount49 = BOTTOM_LAYERS;
		else
		score_amount49 = 0;
end

reg [13:0] score_amount0;
reg [13:0] score_amount1;
reg [13:0] score_amount2;
reg [13:0] score_amount3;
reg [13:0] score_amount4;
reg [13:0] score_amount5;
reg [13:0] score_amount6;
reg [13:0] score_amount7;
reg [13:0] score_amount8;
reg [13:0] score_amount9;
reg [13:0] score_amount10;
reg [13:0] score_amount11;
reg [13:0] score_amount12;
reg [13:0] score_amount13;
reg [13:0] score_amount14;
reg [13:0] score_amount15;
reg [13:0] score_amount16;
reg [13:0] score_amount17;
reg [13:0] score_amount18;
reg [13:0] score_amount19;
reg [13:0] score_amount20;
reg [13:0] score_amount21;
reg [13:0] score_amount22;
reg [13:0] score_amount23;
reg [13:0] score_amount24;
reg [13:0] score_amount25;
reg [13:0] score_amount26;
reg [13:0] score_amount27;
reg [13:0] score_amount28;
reg [13:0] score_amount29;
reg [13:0] score_amount30;
reg [13:0] score_amount31;
reg [13:0] score_amount32;
reg [13:0] score_amount33;
reg [13:0] score_amount34;
reg [13:0] score_amount35;
reg [13:0] score_amount36;
reg [13:0] score_amount37;
reg [13:0] score_amount38;
reg [13:0] score_amount39;
reg [13:0] score_amount40;
reg [13:0] score_amount41;
reg [13:0] score_amount42;
reg [13:0] score_amount43;
reg [13:0] score_amount44;
reg [13:0] score_amount45;
reg [13:0] score_amount46;
reg [13:0] score_amount47;
reg [13:0] score_amount48;
reg [13:0] score_amount49;


endmodule
