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
wire [10:0] score;
wire [9:0] SW_db;
wire clk;
assign clk = CLOCK_50;
assign LEDR = SW_db;
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
wire [10:0] total_score;
wire in_game;
wire reset_level;
wire enemy_hit_player;
wire enemy_reached_bottom;
wire [1:0] level;
wire [1:0] lives;
wire combined_rst_n;
assign combined_rst_n = rst & ~reset_level;


parameter MEMORY_SIZE = 16'd19200; // 160*120 // Number of memory spots ... highly reduced since memory is slow
parameter PIXEL_VIRTUAL_SIZE = 16'd4; // Pixels per spot - therefore 4x4 pixels are drawn per memory location

/* ACTUAL VGA RESOLUTION */
parameter VGA_WIDTH = 16'd640;
parameter VGA_HEIGHT = 16'd480;

/* Our reduced RESOLUTION 160 by 120 needs a memory of 19,200 words each 24 bits wide */
parameter VIRTUAL_PIXEL_WIDTH = VGA_WIDTH/PIXEL_VIRTUAL_SIZE; // 160
parameter VIRTUAL_PIXEL_HEIGHT = VGA_HEIGHT/PIXEL_VIRTUAL_SIZE; // 120

always @(*) begin
    vga_color = player_color | enemy_color; //| laser_color;
    {VGA_R, VGA_G, VGA_B} = vga_color;
end



player the_player (.clk(clk), .rst(combined_rst_n), .bullet_hit(bullet_hit), .left(~KEY[3]), .right(~KEY[1]), .shoot(~KEY[2]), .xPixel(x), .yPixel(y), .in_game(in_game), .bullet_x(bullet_x),
.bullet_y(bullet_y), .player_color(player_color));

enemy_grid1 aliens(.clk(clk), .rst(combined_rst_n), .xPixel(x), .yPixel(y), .bullet_x(bullet_x), .bullet_y(bullet_y), .bullet_hit(bullet_hit), .in_game(in_game), .enemy_color(enemy_color), 
.score(score), .enemy_reached_bottom(enemy_reached_bottom), .dead_out(dead), .grid_x_out(grid_x_out), .grid_y_out(grid_y_out));

//alien_grid aliens(.clk(clk), .rst(rst), .xPixel(x), .yPixel(y), .bullet_x(bullet_x), .bullet_y(bullet_y), .bullet_hit(bullet_hit), .enemy_color(enemy_color));
//enemy_movement aliens(.clk(clk), .rst(rst), .xPixel(x), .yPixel(y), .bullet_x(bullet_x), .bullet_y(bullet_y), .bullet_hit(bullet_hit), .enemy_color(enemy_color));

//game_controller  g_c(.clk(clk), .rst(rst), .start_button(SW[0]), .enemy_reached_bottom(enemy_reached_bottom), .enemy_hit_player(enemy_hit_player), .score_in(score),
//.in_game(in_game), .lives(lives), .level(level), .reset_level(reset_level), .total_score(total_score));

//enemy_lasers lasers(.clk(clk), .rst(rst), .dead(dead), .grid_x(grid_x_out), .grid_y(grid_y_out), .xPixel(x), .yPixel(y), .laser_color(laser_color));

five_decimal_vals score1(total_score, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

debounce_switches db(clk, rst, SW, SW_db); 

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