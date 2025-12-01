module enemy_grid(
    input clk,
    input rst,
    input [9:0] xPixel,
    input [9:0] yPixel,
    input [9:0] bullet_x,
    input [9:0] bullet_y,
    output reg [23:0] enemy_color,
    output reg bullet_hit
);

parameter ENEMY_W     = 30;
parameter ENEMY_H     = 30;
parameter SPACING_X   = 10;
parameter SPACING_Y   = 10;

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
                if ((bullet_x >= ax) && (bullet_x < ax + ENEMY_W) &&
                    (bullet_y >= ay) && (bullet_y < ay + ENEMY_H))
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
                (yPixel >= ay) && (yPixel < ay + ENEMY_H))
            begin
                enemy_color = 24'hFFFFFF;
            end
        end
    end
end

endmodule


