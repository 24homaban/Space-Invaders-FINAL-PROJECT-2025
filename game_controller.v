module game_controller(
    input  clk,
    input  rst,
    input  start_button,
    input  enemy_reached_bottom,
    input  enemy_hit_player,
    input  [10:0] score_in,      
    output reg in_game,
    output reg [1:0] lives,
    output reg [1:0] level,
    output reg reset_level,      
    output reg [10:0] total_score
);

parameter  START       = 3'd0,
           LEVEL       = 3'd1,
           WAVE_CLEAR  = 3'd2,
           GAME_OVER   = 3'd3;

    reg [2:0] S, NS;

    
    always @(posedge clk or negedge rst)
        if (!rst) 
            S <= START;
            
       else 
            S <= NS;
       

    
    always @(*) begin

        case (S)

        
            START: begin
                if (start_button) begin
                    NS = LEVEL;
                end
            end

           
            LEVEL: begin

           
                if (enemy_hit_player) begin
                    if (lives > 1) begin
                        NS = LEVEL;
                    end else begin
                        NS = GAME_OVER;
                    end
                end

               
                else if (enemy_reached_bottom) begin
                    if (lives > 1) begin
                        NS = LEVEL;
                    end else begin
                        NS = GAME_OVER;
                    end
                end

                
                else if (score_in == 900) begin 
                    if (level < 3) begin
                        NS = WAVE_CLEAR;
                    end else begin
                        NS = GAME_OVER;
                    end
                end
            end

           
            WAVE_CLEAR: begin
                if (start_button) begin
                    NS = LEVEL;
                end
            end

            
				
            GAME_OVER: begin
                if (start_button) begin
                    NS = START;
                end
            end

        endcase
    end

    
    always @(posedge clk or negedge rst) begin
        if (!rst)
		  begin
            total_score <= 0;
				level <= 1;
            lives <= 3;
            reset_level <= 0;
			end
        else begin
				reset_level <= 0;
            total_score <= score_in;   
				
				case (S)
				START: begin
                if (start_button)
                    reset_level <= 1;
                
            end

           
            LEVEL: begin
                in_game <= 1;
					 reset_level <= 0;

                
                if (enemy_hit_player) begin
                    if (lives > 1) begin
                        lives <= lives - 1;
                        reset_level <= 1;
                        
                    end
                end

           
                else if (enemy_reached_bottom) begin
                    if (lives > 1) begin
                        lives <= lives - 1;
                        reset_level <= 1;
                    end
                end

               

           
            WAVE_CLEAR: begin
                if (start_button) begin
                    level <= level + 1;
                    reset_level <= 1;
                end
            end

       
            GAME_OVER: begin
                in_game <= 0;
                if (start_button) begin
                    total_score <= 0;
                    lives <= 3;
                    level <= 1;
                    reset_level <= 1;
                end
            end
			end
        endcase
    end
	end
endmodule