//
//
//
//

module Decoder (
	input [32:0] tone,
	output reg [32-1:0] freq 
);

    reg[32-1:0] q;
    reg[32-1:0] s;

always @(*) begin
    //q = tone % 232 + 1'b1;
    if(tone > 43'd4700) begin
        freq = 32'd20000;
    end
    else begin
        q = tone / 10;
        q = q - 50;
        s = q / 232;
        if(s == 23'b0) begin
            freq = (q % 232) + 32'd262;
        end
        else begin
            freq = (q % 232) + 32'd262;
            freq = freq << 1;
        end
    end
    /*    
	case (tone)
		16'b0000_0000_0000_0010: freq = 32'd294;	//Re-m
		16'b0000_0000_0000_0100: freq = 32'd330;	//Mi-m
		16'b0000_0000_0000_1000: freq = 32'd349;	//Fa-m
		16'b0000_0000_0001_0000: freq = 32'd392;	//Sol-m
		16'b0000_0000_0010_0000: freq = 32'd440;	//La-m
		16'b0000_0000_0100_0000: freq = 32'd494;	//Si-m
		16'b0000_0000_1000_0000: freq = 32'd262 << 1;	//Do-h
		16'b0000_0001_0000_0000: freq = 32'd294 << 1;
		16'b0000_0010_0000_0000: freq = 32'd330 << 1;
		16'b0000_0100_0000_0000: freq = 32'd349 << 1;
		16'b0000_1000_0000_0000: freq = 32'd392 << 1;
		16'b0001_0000_0000_0000: freq = 32'd440 << 1;
		16'b0010_0000_0000_0000: freq = 32'd494 << 1;
		16'b0100_0000_0000_0000: freq = 32'd262 << 2;
		16'b1000_0000_0000_0000: freq = 32'd294 << 2;
		default : freq = 32'd20000;	//Do-dummy
	endcase
	*/
end

endmodule