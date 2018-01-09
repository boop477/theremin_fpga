module Sensor(CLK, RESET_n, echo, trig, dist, out_get_echo);
    input CLK, echo, RESET_n;
    output trig;
    output[32-1:0] dist;
    output out_get_echo;
    
    reg[32-1:0] r_dist;
    reg[15-1:0] dummy_dist; // Period of trig signal
    reg r_trig;
    reg[32-1:0] counter, dist_counter;
    reg get_echo;
    reg echo_a, echo_b, echo_c;
    
    assign trig = r_trig;
    assign dist = r_dist;
    assign out_get_echo = get_echo;
    
    // Counter
    always@(posedge CLK) begin
        if(RESET_n == 1'b0) begin
            // Turn the switch on to reset sensor
            counter <= 32'd0;
            dist_counter <= 32'd0;
            dummy_dist <= 15'd0;
            get_echo <= 1'b0;
        end
        else begin
            // Counter
            $display("%d", counter);
            if(counter == 32'd0) begin
                // turn trig on
                r_trig <= 1'b1;
                counter <= counter + 1;
                //dist_counter <= dist_counter + 1;
                dummy_dist <= dummy_dist + 1;
                get_echo <= 1'b0;
            end
            else if(counter == 32'd110) begin
                // turn trig on for 10e5 seccond
                r_trig <= 1'b0;
                counter <= counter + 1;
                get_echo <= get_echo;
            end
            else if(counter == 32'd1000000) begin
                // 1 echo/sec
                counter <= 32'd0;	
                //dist_counter <= 32'd0;
                r_trig <= r_trig;
                get_echo <= get_echo;
            end
            else begin
                counter <= counter + 1'b1;
                r_trig <= r_trig;
                get_echo <= get_echo;
            end
            
            echo_a <= echo_b;
            echo_b <= echo_c;
            echo_c <= echo;
            // Echo
            if(echo_b == 1'b1 && echo_c == 1'b0 && trig == 1'b0) begin  // negedge
                // Get echo!
                dist_counter <= dist_counter;
                if(get_echo == 1'b0) begin
                    r_dist <= dist_counter / 100;//50000
                    get_echo <= 1'b1;
                end
                else begin
                    r_dist <= r_dist;
                    get_echo <= 1'b1;
                end
            end
            else begin
                if(trig == 1'b0) begin
                    // Wait echo!
                    dist_counter <= dist_counter + 1;
                    r_dist <= r_dist;
                    get_echo <= get_echo;
                end
                else begin
                    // Stop counting
                    dist_counter <= 23'd0;
                    r_dist <= r_dist;
                    get_echo <= 1'b0;
                end
            end
        end
    end
endmodule
