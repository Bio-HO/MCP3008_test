module seg7(clk_50M,rst,seg7_x,seg7_y,out_data,channel);

output reg[7:0] seg7_x;
output reg[7:0] seg7_y;

input[2:0] channel;
input[9:0] out_data;

input clk_50M;
input rst;

//register or wire for each 7-seg(left(x0)-->right(x_7))
wire[7:0] x_0;
wire[7:0] x_1;
reg[7:0] x_2;
wire[7:0] x_3;
reg[7:0] x_4;
reg[7:0] x_5;
reg[7:0] x_6;
reg[7:0] x_7;

reg[2:0] count;

assign x_0=8'b10011100;	//C
assign x_1=8'b01101110;	//H

always@(channel)
begin
	case(channel)	//x_2
		3'b000:x_2=8'b01100000;	//1
		3'b001:x_2=8'b11011010;	//2
		3'b010:x_2=8'b11110010;	//3
		3'b011:x_2=8'b01100110;	//4
		3'b100:x_2=8'b10110110;	//5
		3'b101:x_2=8'b10111110;	//6
		3'b110:x_2=8'b11100100;	//7
		3'b111:x_2=8'b11111110;	//8
		default;
	endcase
end

assign x_3=8'b00000000;	//x_3 no use

//binary to bcd, use double dabble
reg[12:0] bcd;
integer i,j;

always@(out_data) 
begin
  bcd[12:0] =13'b0000000000000;     // initialize with zeros
  bcd[9:0] = out_data;                                   // initialize with input vector
  for(i = 0; i <= 6; i = i+1)                       // iterate on structure depth
    for(j = 0; j <= i/3; j = j+1)                     // iterate on structure width
      if (bcd[10-i+4*j -: 4] > 4)                      // if > 4
        bcd[10-i+4*j -: 4] = bcd[10-i+4*j -: 4] + 4'd3; // add 3
end

//x_4 to x_7 for print out_data in 7-seg

always@(bcd[12])
begin
	case(bcd[12])
	 	4'b0000:x_4<=8'b11111100;//0
	 	4'b0001:x_4<=8'b01100000;//1
	 	default:x_4<=8'b11111100;//default
	endcase
end

always@(bcd[11:8])
begin	
	case(bcd[11:8])
	 	4'b0000:x_5<=8'b11111100;//0
	 	4'b0001:x_5<=8'b01100000;//1
	 	4'b0010:x_5<=8'b11011010;//2
	 	4'b0011:x_5<=8'b11110010;//3
	 	4'b0100:x_5<=8'b01100110;//4
	 	4'b0101:x_5<=8'b10110110;//5
	 	4'b0110:x_5<=8'b10111110;//6
	 	4'b0111:x_5<=8'b11100100;//7
		4'b1000:x_5<=8'b11111110;//8
		4'b1001:x_5<=8'b11110110;//9
		default:x_5<=8'b11111100;//default
	endcase
end
	
always@(bcd[7:4])
begin
	case(bcd[7:4])
	 	4'b0000:x_6<=8'b11111100;//0
	 	4'b0001:x_6<=8'b01100000;//1
	 	4'b0010:x_6<=8'b11011010;//2
	 	4'b0011:x_6<=8'b11110010;//3
	 	4'b0100:x_6<=8'b01100110;//4
	 	4'b0101:x_6<=8'b10110110;//5
	 	4'b0110:x_6<=8'b10111110;//6
	 	4'b0111:x_6<=8'b11100100;//7
		4'b1000:x_6<=8'b11111110;//8
		4'b1001:x_6<=8'b11110110;//9
		default:x_6<=8'b11111100;//default
	endcase
end

always@(bcd[3:0])
begin	
	case(bcd[3:0])
	 	4'b0000:x_7<=8'b11111100;//0
	 	4'b0001:x_7<=8'b01100000;//1
	 	4'b0010:x_7<=8'b11011010;//2
	 	4'b0011:x_7<=8'b11110010;//3
	 	4'b0100:x_7<=8'b01100110;//4
	 	4'b0101:x_7<=8'b10110110;//5
	 	4'b0110:x_7<=8'b10111110;//6
	 	4'b0111:x_7<=8'b11100100;//7
		4'b1000:x_7<=8'b11111110;//8
		4'b1001:x_7<=8'b11110110;//9
		default:x_7<=8'b11111100;//default
	endcase
end


//low clk generator

wire low_clk=clk_count[12];
reg[12:0] clk_count;

always@(posedge clk_50M or negedge rst)
begin
	if(!rst)
	begin
		clk_count<=13'b0000000000000;
	end
	else
	begin
		clk_count<=clk_count+1'b1;
	end
end

//7-seg control circuit, need low clk so LED can switch property

always@(posedge low_clk or negedge rst)
begin
	if(!rst)
	begin
		count<=3'b000;
		seg7_x<=8'b11111111;
		seg7_y<=8'b11111111;
	end
	else
	begin
		count<=count+1'b1;
		case(count)	
				3'b000: 
				begin
					seg7_x<=8'b01111111;
					seg7_y<=~x_0;
				end
				
				3'b001: 
				begin
					seg7_x<=8'b10111111;
					seg7_y<=~x_1;
				end
				
				3'b010: 
				begin
					seg7_x<=8'b11011111;
					seg7_y<=~x_2;
				end
				
				3'b011: 
				begin
					seg7_x<=8'b11101111;
					seg7_y<=~x_3;
				end
				
				3'b100: 
				begin
					seg7_x<=8'b11110111;
					seg7_y<=~x_4;
				end
				
				3'b101: 
				begin
					seg7_x<=8'b11111011;
					seg7_y<=~x_5;
				end
				
				3'b110: 
				begin
					seg7_x<=8'b11111101;
					seg7_y<=~x_6;
				end
				
				3'b111: 
				begin
					seg7_x<=8'b11111110;
					seg7_y<=~x_7;
				end
				
				default
				begin
					seg7_x<=8'b11111111;
					seg7_y<=8'b11111111;
				end
				
		endcase
	end
end

endmodule
