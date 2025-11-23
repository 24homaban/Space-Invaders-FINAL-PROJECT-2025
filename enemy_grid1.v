module enemy_grid1(
    input clk,
    input rst,
    input [9:0] xPixel,
    input [9:0] yPixel,
    input [9:0] bullet_x,
    input [9:0] bullet_y,
    output reg [23:0] enemy_color,
    output reg bullet_hit,
	 output reg [10:0]score
);

parameter ENEMY_W     = 30;
parameter ENEMY_H     = 30;
parameter SPACING_X   = 10;
parameter SPACING_Y   = 10;
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
reg right;
reg [9:0] grid_x, grid_y;
reg [1:0] lives;



integer k;
integer c;
integer row;
integer col;
integer ax;
integer ay;
integer left_col;
integer right_col;
integer r;
integer alive_in_col;
integer alive_in_row;



always @(posedge clk or negedge rst)
    if (!rst) S <= M_RIGHT;
    else       S <= NS;


		
	 
always @(*) begin
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




always@(*)
		case(S)
		M_RIGHT:
			if(move_delay == 26'd10000000)
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
			if(move_delay == 26'd10000000)
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
		  lives		 <= 2'd3;
    end
    else
    begin
        case (S)
            M_RIGHT: begin
                right <= 1'b1;
                if(move_delay >= 27'd10_000_000) 
						move_delay <= 27'd0;
					 else
						move_delay <= move_delay + 4'd1;
            end

            SHIFT_R: grid_x <= grid_x + 2;

            SHIFT_D: begin
               if(right == 1)
						right <= 1'b0;
					else
						right <= 1'b1;
                grid_y <= grid_y + ENEMY_H + SPACING_Y;
            end

            M_LEFT:
                if(move_delay >= 27'd10_000_000) 
						move_delay <= 27'd0;
					 else
						move_delay <= move_delay + 4'd1;
            SHIFT_L: grid_x <= grid_x - 2;
        endcase
    end
end



reg [49:0] dead;



always @(posedge clk or negedge rst)
begin
    if (!rst)
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
                ax = grid_x + col * (ENEMY_W + SPACING_X);
                ay = grid_y + row * (ENEMY_H + SPACING_Y);
                if (((bullet_x > ax) || (bullet_x + BULLET_WIDTH > ax)) && (bullet_x < ax + ENEMY_W) &&
                    ((bullet_y > ay) || (bullet_y + BULLET_HEIGHT > ay)) && (bullet_y < ay + ENEMY_H))
                begin
                    dead[k] <= 1'b1;
                    bullet_hit <= 1'b1;
                end
            end
        end
    end
end



always @(*) begin
    enemy_color = 24'h808080;

    
    for (c = 0; c < ENEMIES; c = c + 1)
    begin
        if (!dead[c])
        begin
            col = c % COLUMNS;
            row = c / COLUMNS;

            ax = grid_x + col * (ENEMY_W + SPACING_X);
            ay = grid_y + row * (ENEMY_H + SPACING_Y);

            if ((xPixel >= ax) && (xPixel < ax + ENEMY_W) &&
                (yPixel >= ay) && (yPixel < ay + ENEMY_H) && c < 10)
            begin
                enemy_color = 24'hF2C516;
					 end
				else 
				if ((xPixel >= ax) && (xPixel < ax + ENEMY_W) &&
                (yPixel >= ay) && (yPixel < ay + ENEMY_H) && (c >= 10 && c < 30))
            begin
                enemy_color = 24'h07A3F0;
					 end
					 
				else 
				if ((xPixel >= ax) && (xPixel < ax + ENEMY_W) &&
                (yPixel >= ay) && (yPixel < ay + ENEMY_H) && c >= 30)
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
	if(dead[1])
		score_amount1 = TOP_LAYER;
	if(dead[2])
		score_amount2 = TOP_LAYER;
	if(dead[3])
		score_amount3 = TOP_LAYER;
	if(dead[4])
		score_amount4 = TOP_LAYER;
	if(dead[5])
		score_amount5 = TOP_LAYER;
	if(dead[6])
		score_amount6 = TOP_LAYER;
	if(dead[7])
		score_amount7 = TOP_LAYER;
	if(dead[8])
		score_amount8 = TOP_LAYER;
	if(dead[9])
		score_amount9 = TOP_LAYER;
	if(dead[10])
		score_amount10 = MIDDLE_LAYERS;
	if(dead[11])
		score_amount11 = MIDDLE_LAYERS;
	if(dead[12])
		score_amount12 = MIDDLE_LAYERS;
	if(dead[13])
		score_amount13 = MIDDLE_LAYERS;
	if(dead[14])
		score_amount14 = MIDDLE_LAYERS;
	if(dead[15])
		score_amount15 = MIDDLE_LAYERS;
	if(dead[16])
		score_amount16 = MIDDLE_LAYERS;
	if(dead[17])
		score_amount17 = MIDDLE_LAYERS;
	if(dead[18])
		score_amount18 = MIDDLE_LAYERS;
	if(dead[19])
		score_amount19 = MIDDLE_LAYERS;
	if(dead[20])
		score_amount20 = MIDDLE_LAYERS;
	if(dead[21])
		score_amount21 = MIDDLE_LAYERS;
	if(dead[22])
		score_amount22 = MIDDLE_LAYERS;
	if(dead[23])
		score_amount23 = MIDDLE_LAYERS;
	if(dead[24])
		score_amount24 = MIDDLE_LAYERS;
	if(dead[25])
		score_amount25 = MIDDLE_LAYERS;
	if(dead[26])
		score_amount26 = MIDDLE_LAYERS;
	if(dead[27])
		score_amount27 = MIDDLE_LAYERS;
	if(dead[28])
		score_amount28 = MIDDLE_LAYERS;
	if(dead[29])
		score_amount29 = MIDDLE_LAYERS;
	if(dead[30])
		score_amount30 = BOTTOM_LAYERS;
	if(dead[31])
		score_amount31 = BOTTOM_LAYERS;
	if(dead[32])
		score_amount32 = BOTTOM_LAYERS;
	if(dead[33])
		score_amount33 = BOTTOM_LAYERS;
	if(dead[34])
		score_amount34 = BOTTOM_LAYERS;
	if(dead[35])
		score_amount35 = BOTTOM_LAYERS;
	if(dead[36])
		score_amount36 = BOTTOM_LAYERS;
	if(dead[37])
		score_amount37 = BOTTOM_LAYERS;
	if(dead[38])
		score_amount38 = BOTTOM_LAYERS;
	if(dead[39])
		score_amount39 = BOTTOM_LAYERS;
	if(dead[40])
		score_amount40 = BOTTOM_LAYERS;
	if(dead[41])
		score_amount41 = BOTTOM_LAYERS;
	if(dead[42])
		score_amount42 = BOTTOM_LAYERS;
	if(dead[43])
		score_amount43 = BOTTOM_LAYERS;
	if(dead[44])
		score_amount44 = BOTTOM_LAYERS;
	if(dead[45])
		score_amount45 = BOTTOM_LAYERS;
	if(dead[46])
		score_amount46 = BOTTOM_LAYERS;
	if(dead[47])
		score_amount47 = BOTTOM_LAYERS;
	if(dead[48])
		score_amount48 = BOTTOM_LAYERS;
	if(dead[49])
		score_amount49 = BOTTOM_LAYERS;
end

reg [10:0] score_amount0;
reg [10:0] score_amount1;
reg [10:0] score_amount2;
reg [10:0] score_amount3;
reg [10:0] score_amount4;
reg [10:0] score_amount5;
reg [10:0] score_amount6;
reg [10:0] score_amount7;
reg [10:0] score_amount8;
reg [10:0] score_amount9;
reg [10:0] score_amount10;
reg [10:0] score_amount11;
reg [10:0] score_amount12;
reg [10:0] score_amount13;
reg [10:0] score_amount14;
reg [10:0] score_amount15;
reg [10:0] score_amount16;
reg [10:0] score_amount17;
reg [10:0] score_amount18;
reg [10:0] score_amount19;
reg [10:0] score_amount20;
reg [10:0] score_amount21;
reg [10:0] score_amount22;
reg [10:0] score_amount23;
reg [10:0] score_amount24;
reg [10:0] score_amount25;
reg [10:0] score_amount26;
reg [10:0] score_amount27;
reg [10:0] score_amount28;
reg [10:0] score_amount29;
reg [10:0] score_amount30;
reg [10:0] score_amount31;
reg [10:0] score_amount32;
reg [10:0] score_amount33;
reg [10:0] score_amount34;
reg [10:0] score_amount35;
reg [10:0] score_amount36;
reg [10:0] score_amount37;
reg [10:0] score_amount38;
reg [10:0] score_amount39;
reg [10:0] score_amount40;
reg [10:0] score_amount41;
reg [10:0] score_amount42;
reg [10:0] score_amount43;
reg [10:0] score_amount44;
reg [10:0] score_amount45;
reg [10:0] score_amount46;
reg [10:0] score_amount47;
reg [10:0] score_amount48;
reg [10:0] score_amount49;


endmodule
