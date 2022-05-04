module ADC_test(clk_50M,sclk,MISO,MOSI,CE_N,rst,channel,out_data);

input clk_50M;
input rst;
input[2:0] channel;
output reg[9:0] out_data; //raw 10bits data

//SPI port
output sclk=(rst)?clk_12k:1'b1;
input MISO;
output MOSI=MOSI_reg;
output CE_N=CE_N_reg;

//clk for SPI
wire clk_12k=count[11];	//12.5kHz
reg[13:0] count;

//other registers
reg MOSI_reg;
reg MISO_reg;
reg CE_N_reg;
reg[4:0] state;
reg[4:0] next_state;
reg process;
reg[9:0] out_data_reg;

//state change and count use for get low-speed clk for SPI 
always@(posedge clk_50M or negedge rst)
begin
	if(!rst)
	begin
		state<=5'b00000;
		count<=14'b00000000000000;
	end
	else
	begin
		state<=next_state;
		count<=count+1'b1;
	end
end

//for SPI read data(input)
always@(posedge clk_12k or negedge rst)
begin
	if(!rst)
	begin
		MISO_reg<=1'b0;
	end
	else
	begin
		MISO_reg<=MISO;			
	end
end

//for SPI write data(output)
always@(negedge clk_12k or negedge rst)
begin
	if(!rst)
	begin
		next_state<=5'b00000;
		MOSI_reg<=1'b1;
		CE_N_reg<=1'b1;
		out_data_reg<=9'b000000000;
	end
	else
	begin		

		case(state)
		
			5'b00000: //wait state
			begin
				out_data_reg<=out_data_reg;
				CE_N_reg<=1'b1;
				MOSI_reg<=1'b1;
				out_data<=out_data;
				next_state<=5'b00001;
			end
			
			5'b00001: //start state(MOSI start bit)
			begin
				out_data_reg<=out_data_reg;
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;
				next_state<=5'b00010;
				out_data<=out_data;
			end
			
			5'b00010: //MOSI control bit 1 
			begin
				out_data_reg<=out_data_reg;
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	//(1=single;0=different)
				next_state<=5'b00011;
				out_data<=out_data;
			end
			
			5'b00011: //MOSI control bit 2(channel bit[2]) 
			begin
				out_data_reg<=out_data_reg;
				CE_N_reg<=1'b0;
				MOSI_reg<=channel[2];
				next_state<=5'b00100;
				out_data<=out_data;
			end
			
			5'b00100: //MOSI control bit 3(channel bit[1]) 
			begin
				out_data_reg<=out_data_reg;
				CE_N_reg<=1'b0;
				MOSI_reg<=channel[1];	
				next_state<=5'b00101;
				out_data<=out_data;
			end
			
			5'b00101: //MOSI control bit 4(channel bit[0]) 
			begin
				out_data_reg<=out_data_reg;
				CE_N_reg<=1'b0;
				MOSI_reg<=channel[0];	
				next_state<=5'b00110;
				out_data<=out_data;
			end
			
			5'b00110: //nop
			begin
				out_data_reg<=out_data_reg;
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b00111;
				out_data<=out_data;
			end			
			5'b00111: //nop
			begin
				out_data_reg<=out_data_reg;
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b01000;
				out_data<=out_data;
			end			
			5'b01000: //nop
			begin
				out_data_reg<=out_data_reg;
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b01001;
				out_data<=out_data;
			end
			
			5'b01001: //MOSI input(D9)
			begin
				out_data_reg<={MISO_reg,out_data_reg[8:0]};
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b01010;
				out_data<=out_data;
			end

			5'b01010: //MOSI input(D8)
			begin
				out_data_reg<={out_data_reg[9],MISO_reg,out_data_reg[7:0]};
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b01011;
				out_data<=out_data;
			end

			5'b01011: //MOSI input(D7)
			begin
				out_data_reg<={out_data_reg[9:8],MISO_reg,out_data_reg[6:0]};
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b01100;
				out_data<=out_data;
			end	
			
			5'b01100: //MOSI input(D6)
			begin
				out_data_reg<={out_data_reg[9:7],MISO_reg,out_data_reg[5:0]};
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b01101;
				out_data<=out_data;
			end

			5'b01101: //MOSI input(D5)
			begin
				out_data_reg<={out_data_reg[9:6],MISO_reg,out_data_reg[4:0]};
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b01110;
				out_data<=out_data;
			end
	
			5'b01110: //MOSI input(D4)
			begin
				out_data_reg<={out_data_reg[9:5],MISO_reg,out_data_reg[3:0]};
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b01111;
				out_data<=out_data;
			end
		
			5'b01111: //MOSI input(D3)
			begin
				out_data_reg<={out_data_reg[9:4],MISO_reg,out_data_reg[2:0]};
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b10000;
				out_data<=out_data;
			end
		
			5'b10000: //MOSI input(D2)
			begin
				out_data_reg<={out_data_reg[9:3],MISO_reg,out_data_reg[1:0]};
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b10001;
				out_data<=out_data;
			end

			5'b10001: //MOSI input(D1)
			begin
				out_data_reg<={out_data_reg[9:2],MISO_reg,out_data_reg[0]};
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b10010;
				out_data<=out_data;
			end
			
			5'b10010: //MOSI input(D0)
			begin
				out_data_reg<={out_data_reg[9:1],MISO_reg};
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b10011;
				out_data<=out_data;
			end
			
			5'b10011: //end
			begin
				out_data_reg<=out_data_reg;
				CE_N_reg<=1'b0;
				MOSI_reg<=1'b1;	
				next_state<=5'b00000;
				out_data<=out_data_reg;
			end
				
			default
			begin
				out_data_reg<=out_data_reg;
				next_state<=5'b00000;
				MOSI_reg<=1'b1;
				CE_N_reg<=1'b1;
			end
			
		endcase
	end
end


endmodule
