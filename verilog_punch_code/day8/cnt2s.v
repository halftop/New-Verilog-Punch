module cnt2s(
    input clk, rst_n,
    output [3:0] o_cnt
    );
    reg [3:0] cnt;
//异步复位
/* always @ (posedge clk or negedge rst_n) begin
    if ( !rst_n )
        cnt <= 4'b0000;
    else if ( cnt == 4'b1111 )
        cnt <= 4'b0000;
    else
        cnt <= cnt + 1'b1;
end */
//同步复位
always @ (posedge clk) begin
    if ( !rst_n )
        cnt <= 4'b0000;
    else if ( cnt == 4'b1111 )
        cnt <= 4'b0000;
    else
        cnt <= cnt + 1'b1;
end

assign o_cnt = cnt;

endmodule