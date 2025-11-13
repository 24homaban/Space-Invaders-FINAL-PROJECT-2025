module five_decimal_vals (
input [16:0]val,
output [6:0]seg7_dig0,
output [6:0]seg7_dig1,
output [6:0]seg7_dig2,
output [6:0]seg7_dig3,
output [6:0]seg7_dig4,
output [6:0]seg7_dig5
);

reg [3:0] result_one_digit;
reg [3:0] result_ten_digit;
reg [3:0] result_hundred_digit;
reg [3:0] result_thousand_digit;
reg [3:0] result_ten_thousand_digit;
reg [3:0] result_hundred_thousand_digit;



/* convert the binary value into 6 signals */
always @(*)
begin


	  result_hundred_thousand_digit = val / 100000;
	  result_ten_thousand_digit = (val % 100000) / 10000;
	  result_thousand_digit = (val % 10000) / 1000;
	  result_hundred_digit = (val % 1000) / 100;
	  result_ten_digit = (val % 100) / 10;
	  result_one_digit = val % 10;
	  
	  
	  
end

/* instantiate the modules for each of the seven seg decoders including the negative one */


seven_segment hundred_thousand_digit(result_ten_thousand_digit, seg7_dig5);
seven_segment ten_thousand_digit(result_ten_thousand_digit, seg7_dig4);
seven_segment thousand_digit(result_thousand_digit, seg7_dig3);
seven_segment hundred_digit(result_hundred_digit, seg7_dig2);
seven_segment ten_digit(result_ten_digit, seg7_dig1);
seven_segment one_digit(result_one_digit, seg7_dig0);



endmodule