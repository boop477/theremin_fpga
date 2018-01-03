module Top (CLK100MHZ, sw, echo, trig, an, seg, dp, LED, pmod_1, pmod_2, pmod_4);
        
    input CLK100MHZ;
    input[16-1:0] sw;
    input echo;
    output[16-1:0] LED;
    output trig;
    output [4-1:0] an;
    output [7-1:0] seg;
    output dp;
    output pmod_1;
    output pmod_2;
    output pmod_4;
    
    wire[32-1:0] dist;
    wire out_get_echo;
    reg[4-1:0] digit;
    reg [15-1:0] disp_counter;
    reg[3-1:0] digit_counter;
    reg [4-1:0] an;
    reg [7-1:0] seg;
    reg dp;
    reg[16-1:0] LED;
    
    Sensor sensor(CLK100MHZ, sw[0], echo, trig, dist, out_get_echo);
    
    wire [31:0] freq;
    assign pmod_2 = 1'd1;    //no gain(6dB)
    assign pmod_4 = 1'd1;    //turn-on
    
    always@ (*) begin
        if(out_get_echo == 1'b0) begin
            LED[15] = 1'b0;
        end
        else begin
            LED[15] = 1'b1;
        end
        
        if(trig == 1'b1) begin
            LED[14] = 1'b1;
        end
        else begin
            LED[14] = 1'b0;
        end
    end
        
    Decoder decoder00 (
        .tone(dist),
        .freq(freq)
    );
    
    PWM_gen pwm_0 ( 
        .clk(CLK100MHZ), 
        .reset(sw[0]), 
        .freq(freq),
        .duty(10'd512), 
        .PWM(pmod_1)
    );
    
    // 7-segment clock divider
    always @(posedge CLK100MHZ) begin
        if(sw[0] == 1'b0) begin
            // Reset dclock divider for 7-segment
            disp_counter <= 15'b0;
        end
        else begin
            if(disp_counter == 15'd5000) begin
                disp_counter <= 15'd1;
            end
            else begin
                disp_counter <= disp_counter + 1;
            end
        end
    end
    
    // Digit divider(?
    always@(posedge CLK100MHZ) begin
        if(disp_counter == 15'd5000) begin
            if(sw[0] == 1'b0) begin
                digit_counter <= 3'b0;
            end
            else begin
                if(digit_counter == 3'd4) begin
                    digit_counter <= 3'd1;
                end
                else begin
                    digit_counter <= digit_counter + 1'b1;
                end
            end
        end
        else begin
            digit_counter <= digit_counter;
        end
    end
    
    // Comb: An Selector
    always @(digit_counter) begin
        case(digit_counter)
        3'd1: begin
            an = 4'b1110;
            dp = 1'b1;
            digit = dist % 10; 
        end
        3'd2: begin
            an = 4'b1101;
            dp = 1'b0;
            digit = (dist % 100) / 10;
            //digit = (dist % 10) % 10;
        end
        3'd3: begin
            an = 4'b1011;
            dp = 1'b1;
            digit = (dist % 1000) / 100;
        end
        3'd4: begin
            an = 4'b0111;
            dp = 1'b1;
            digit = dist / 1000;
        end
        default: begin
            an = 4'b1110;
            dp = 1'b1;
        end
        endcase
    end
    
    // Comb: Convert digit to segment
    always@(*) begin
        case(digit)
            4'b0000: seg = 7'b1000000; // 0
            4'b0001: seg = 7'b1111001; // 1
            4'b0010: seg = 7'b0100100; // 2
            4'b0011: seg = 7'b0110000; // 3
            4'b0100: seg = 7'b0011001; // 4
            4'b0101: seg = 7'b0010010; // 5
            4'b0110: seg = 7'b0000010; //6
            4'b0111: seg = 7'b1011000; // 7
            4'b1000: seg = 7'b0000000; // 8
            4'b1001: seg = 7'b0010000; // 9
            default: seg = 7'b1000000;
        endcase
    end
    
    // Connect distance to LED
    always@(*) begin
        if(dist < 13'd100) begin
            // 10cm
            LED[1] = 1'b1;
            LED[2] = 1'b0;
            LED[3] = 1'b0;
        end
        else if (dist < 13'd300) begin
            // 30cm
            LED[1] = 1'b0;
            LED[2] = 1'b1;
            LED[3] = 1'b0;
        end
        else begin
            // >30cm
            LED[1] = 1'b0;
            LED[2] = 1'b0;
            LED[3] = 1'b1;
        end
    end
    
endmodule