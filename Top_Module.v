module Top_Module (
	//////////// ADC //////////
	//output		          		ADC_CONVST,
	//output		          		ADC_DIN,
	//input 		          		ADC_DOUT,
	//output		          		ADC_SCLK,

	//////////// Audio //////////
	//input 		          		AUD_ADCDAT,
	//inout 		          		AUD_ADCLRCK,
	//inout 		          		AUD_BCLK,
	//output		          		AUD_DACDAT,
	//inout 		          		AUD_DACLRCK,
	//output		          		AUD_XCK,

	//////////// CLOCK //////////
	//input 		          		CLOCK2_50,
	//input 		          		CLOCK3_50,
	//input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SDRAM //////////
	//output		    [12:0]		DRAM_ADDR,
	//output		     [1:0]		DRAM_BA,
	//output		          		DRAM_CAS_N,
	//output		          		DRAM_CKE,
	//output		          		DRAM_CLK,
	//output		          		DRAM_CS_N,
	//inout 		    [15:0]		DRAM_DQ,
	//output		          		DRAM_LDQM,
	//output		          		DRAM_RAS_N,
	//output		          		DRAM_UDQM,
	//output		          		DRAM_WE_N,

	//////////// I2C for Audio and Video-In //////////
	//output		          		FPGA_I2C_SCLK,
	//inout 		          		FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// IR //////////
	//input 		          		IRDA_RXD,
	//output		          		IRDA_TXD,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// PS2 //////////
	//inout 		          		PS2_CLK,
	//inout 		          		PS2_CLK2,
	//inout 		          		PS2_DAT,
	//inout 		          		PS2_DAT2,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// Video-In //////////
	//input 		          		TD_CLK27,
	//input 		     [7:0]		TD_DATA,
	//input 		          		TD_HS,
	//output		          		TD_RESET_N,
	//input 		          		TD_VS,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output reg		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output reg		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output reg	 	     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_1
);
wire [19:0] score;
wire clk;
assign clk = CLOCK_50;
wire rst;
assign rst = KEY[0];
reg [23:0]vga_color;
wire [23:0] player_color;
wire [23:0] enemy_color;
wire [9:0] bullet_y;
wire [9:0] bullet_x;
wire bullet_hit;
wire [9:0] x;
wire [9:0] y;
reg [19:0] total_score;
reg in_game;
reg reset_level;
wire enemy_reached_bottom;
reg [4:0] increase_enemy_speed;

reg [1:0] lives;
reg [19:0] display_score;

assign  LEDR[9:8] = S;
assign  LEDR[6:5] = lives;


parameter MEMORY_SIZE = 16'd19200; // 160*120 // Number of memory spots ... highly reduced since memory is slow
parameter PIXEL_VIRTUAL_SIZE = 16'd4; // Pixels per spot - therefore 4x4 pixels are drawn per memory location

/* ACTUAL VGA RESOLUTION */
parameter VGA_WIDTH = 16'd640;
parameter VGA_HEIGHT = 16'd480;

/* Our reduced RESOLUTION 160 by 120 needs a memory of 19,200 words each 24 bits wide */
parameter VIRTUAL_PIXEL_WIDTH = VGA_WIDTH/PIXEL_VIRTUAL_SIZE; // 160
parameter VIRTUAL_PIXEL_HEIGHT = VGA_HEIGHT/PIXEL_VIRTUAL_SIZE; // 120





parameter  START       = 3'd0,
           LEVEL       = 3'd1,
           WAVE_CLEAR  = 3'd2,
           GAME_OVER   = 3'd3,
			  ADD_SUM	  = 3'd4;

    reg [2:0] S, NS;

    
    always @(posedge clk or negedge rst)
        if (!rst) 
            S <= START;
            
       else 
            S <= NS;
       

    
    always @(*) begin
	 NS = S;
			{VGA_R, VGA_G, VGA_B} = vga_color;
			if (S == LEVEL)
				display_score = total_score + score;
			else
				display_score = total_score;
			
			case (S)
 
            START: begin
				in_game = 1'b0;
				vga_color = 24'h0000FF;
				
                if (SW[5]) begin
                    NS = LEVEL;
                end
					 else 
						NS = START;
            end

           
            LEVEL: begin
				
				if (player_color != 24'h000000)
					vga_color = player_color;
				else if (enemy_color != 24'h000000)
					vga_color = enemy_color;
				else
					vga_color = 24'h000000;
				in_game = 1'b1;
           
                if (enemy_reached_bottom) begin
                    if (lives > 1) begin
                        NS = LEVEL;
                    end else begin
                        NS = GAME_OVER;
                    end
                end

                
                else if (score == 14'd900) begin 
                        NS = ADD_SUM;
                    end
						
						  else
								NS = LEVEL;
            end
				ADD_SUM: begin
					in_game = 1'b0;
					vga_color = 24'h00FF00;
					NS = WAVE_CLEAR;
           end
			  
            WAVE_CLEAR: begin
				
				in_game = 1'b0;
				vga_color = 24'h00FF00;
				
               if (SW[6]) begin
						NS = LEVEL;
                end
					else
						NS = WAVE_CLEAR;
            end

            
				
            GAME_OVER: begin
				in_game = 1'b0;
				vga_color = 24'hFF0000;
				
                if (SW[7]) begin
                  NS = START;
                end
					 else
						NS = GAME_OVER;
            end

        endcase
    end

    
    always @(posedge clk or negedge rst) begin
        if (!rst)
		  begin
            total_score <= 20'd0;
            lives <= 2'd3;
            reset_level <= 1'd0;
				increase_enemy_speed <= 5'd0;
			end
        else begin
				//reset_level <= 1'd0;
               
				
				case (S)
				START: begin
				total_score <= 20'd0;
                if (SW[5])
                    reset_level <= 1'b1;
                
            end

           
            LEVEL: begin
						reset_level <= 1'b0;
                
               if (enemy_reached_bottom) begin
                    if (lives >= 2'd1) begin
                        lives <= lives - 1'b1;
                        reset_level <= 1'b1;
								total_score <= total_score + (score / 2);
                    end
                end
					end
               

           
            ADD_SUM: begin
                    reset_level <= 1'b1;
						  total_score <= total_score + 20'd900;
						  increase_enemy_speed <= increase_enemy_speed + 5'd1;
            end
				WAVE_CLEAR: begin
				reset_level <= 1'b1;
				
				end

 
            GAME_OVER: begin
       
                if (SW[7]) begin
                    lives <= 2'd3;
                    reset_level <= 1'b1;
						  increase_enemy_speed <= 5'd0;
                end
            end
        endcase
    end
	end





player the_player (.clk(clk), .rst(rst), .bullet_hit(bullet_hit), .left(~KEY[3]), .right(~KEY[1]), .shoot(~KEY[2]), .xPixel(x), .yPixel(y), .in_game(in_game), .bullet_x(bullet_x),
.bullet_y(bullet_y), .player_color(player_color), .reset_level(reset_level), .increase_bullet_speed(SW[9]));

enemy_grid aliens(.clk(clk), .rst(rst), .xPixel(x), .yPixel(y), .bullet_x(bullet_x), .bullet_y(bullet_y), .bullet_hit(bullet_hit), .in_game(in_game), .enemy_color(enemy_color), 
.score(score), .enemy_reached_bottom(enemy_reached_bottom), .reset_level(reset_level), .increase_enemy_speed(increase_enemy_speed));

five_decimal_vals score1(display_score, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5); 

vga_driver the_vga(
.clk(clk),
.rst(rst),

.vga_clk(VGA_CLK),

.hsync(VGA_HS),
.vsync(VGA_VS),

.active_pixels(active_pixels),
//.frame_done(frame_done),

.xPixel(x),
.yPixel(y),

.VGA_BLANK_N(VGA_BLANK_N),
.VGA_SYNC_N(VGA_SYNC_N)
);
endmodule