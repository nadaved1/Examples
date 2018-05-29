`timescale 1ns/100ps
module ebuf (clk, clk_o, resetn, data_in, data_out, valid);
	parameter IN_WIDTH=8;
	parameter OUT_WIDTH=8;

	input  clk;
	input  clk_o;
	input  resetn;
	input  [IN_WIDTH-1:0] data_in;
	output logic [OUT_WIDTH-1:0] data_out;
	output logic valid;
	
	logic [IN_WIDTH-1:0] in_queue[$];
	int in_counter;

	always @(posedge clk or negedge resetn) begin
		if (!resetn) begin
			valid <= 0;
			data_out <= 0;
			in_counter = 0;
		end else begin
			in_queue.push_back(data_in);
			in_counter+=IN_WIDTH;
		end
		
		while (in_counter%OUT_WIDTH == 0 && in_counter > 0) begin
			logic [OUT_WIDTH-1:0] temp_out;
			logic [IN_WIDTH-1:0]  cur_q;
			temp_out = 0;
			if (OUT_WIDTH >= IN_WIDTH) begin
				for (int ii=0; ii<OUT_WIDTH/IN_WIDTH; ii++) begin
					cur_q = in_queue.pop_front();
					temp_out |= (cur_q) << IN_WIDTH*ii;
					in_counter-=IN_WIDTH;
				end
				data_out <= temp_out;
				valid <= 1;
			end else begin // OUT_WIDTH < IN_WIDTH
				cur_q = in_queue.pop_front();
				in_counter-=IN_WIDTH;
				for (int ii=0; ii<IN_WIDTH/OUT_WIDTH; ii++) begin
					temp_out = cur_q[ii*OUT_WIDTH +: OUT_WIDTH];
					data_out <= temp_out;
					valid <= 1;
					@(posedge clk_o);
				end
			end
		end
	end

	always @(posedge valid) begin
		valid <= #1 0;
	end

endmodule : ebuf
