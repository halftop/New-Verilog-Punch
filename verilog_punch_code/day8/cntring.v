module cnt_ring(
	input clk, rst_n,
    output [3:0] o_cnt
);
reg [3:0] cnt;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		cnt <= 4'b0001;
	end else begin
		cnt <= {cnt[0],cnt[3:1]};
	end
end

assign o_cnt = cnt;
endmodule