module ADC_TOP(clk_50M,sclk,MISO,MOSI,CE_N,rst,seg7_x,seg7_y,key1);

input clk_50M;
input rst;

//SPI port
output sclk;
input MISO;
output MOSI;
output CE_N;

//7 segement port
output[7:0] seg7_x;
output[7:0] seg7_y;

reg[2:0] channel;
wire[9:0] out_data;

//ADC controller
ADC_test ADC_block(clk_50M,sclk,MISO,MOSI,CE_N,rst,channel,out_data);

//binary to 7-seg's controller
seg7 seg_conventer(clk_50M,rst,seg7_x,seg7_y,out_data,channel);

//low clk for buttom read
wire low_clk=clk_count[13];
reg[13:0] clk_count;

always@(posedge clk_50M or negedge rst)
begin
	if(!rst)
	begin
		clk_count<=14'b00000000000000;
	end
	else
	begin
		clk_count<=clk_count+1'b1;
	end
end

//buttom read, key1_old for debounce 
//use buttom to change ADC's channel(1 to 8)
input key1;
reg[9:0] key1_old;

always@(posedge low_clk or negedge rst)
begin
	if(!rst)
	begin
		channel<=3'b000;
		key1_old<=10'b0000000000;
	end
	else
	begin
		key1_old<={key1_old[8:0],key1};
		if((!key1)&&(&(key1_old)))
		begin
			channel<=channel+1'b1;
		end
		else
		begin
			channel<=channel;
		end
	end
end

endmodule
