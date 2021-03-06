`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:37:42 01/02/2020 
// Design Name: 
// Module Name:    Obstacle_layer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Obstacle_layer(			 //障碍物图层
	 input wire [31:0]clk_div,	 //整体时钟信号  参数可调
										 //clk_div[1] 每隔多少时间从IP核中取出地址
										 //clk_div[23] 每隔多少时间生成一个障碍物
										 //clk_div[19] 障碍物每隔多少时间前进一列
	 input wire rdn,            // read pixel RAM (active_low)
	 input wire [9:0] col_addr, // pixel ram row address, 480 (512) lines
	 input wire [8:0] row_addr, // pixel ram col address, 640 (1024) pixels
	 output wire [11:0] dout	    //障碍物的数据输出bbbb_gggg_rrrr     
	 );

/*
	wire[11:0] dout;	//障碍物图像ip核输出，4*3 rgb   使用方法
	Obstacle_layer OLAYER(
		.clk_div(clk_div), 
		.col_addr(col_addr), 
		.row_addr(row_addr), 
		.dout(dout)
		);
*/	


	 parameter	
		min  	   = 0,			 //最小图层编号
		max      = 5;			 //最大图层编号

	 reg  [max:0]start;		 //开始信号，对不同障碍物移动的开始信号
	 wire [max:0]finish;	 	 //结束信号，障碍物移动结束
	 wire [11:0]dout_0,dout_1,dout_2,dout_3,dout_4,dout_5;
	//产生随机数模块
	integer seed;
	reg [2:0] i;
	reg [7:0] rand_num;	//[min,max]的值 此时是[0，5]
	
	initial begin 

		seed = 0;
		start <= 5'b0;
	end


	always @(posedge clk_div[27]) begin   //这个
		rand_num <= min + {$random(seed)}%(max-min+1);	//生成随机信号
		start <= 6'b0;
		
//		for(i=0;i<3 && finish[rand_num]==0;i=i+1)begin								//给for一个最大的循环次数 5次		
//			rand_num <= min+(rand_num+1)%(max-min+1); //若该障碍物已经在屏幕当中，则生成下一种障碍物
//		end

		if(finish[rand_num]==0)
			rand_num <= min+(rand_num+1)%(max-min+1); 
		
		case(rand_num)
			0:begin
				if(finish[0])	//上一个已经结束
					start[0] <= 1;   //生成障碍物0  小仙人掌
			end
			1:begin
				if(finish[1])
					start[1] <= 1;   //生成障碍物1  大仙人掌
			end
			2:begin
				if(finish[2])	//上一个已经结束
					start[2] <= 1;   //生成障碍物2  小仙人掌
			end
			3:begin
				if(finish[3])	//上一个已经结束
					start[3] <= 1;   //生成障碍物3  大仙人掌
			end
			4:begin
				if(finish[4])	//上一个已经结束
					start[4] <= 1;   //生成障碍物4  小仙人掌
			end
			5:begin
				if(finish[5])	//上一个已经结束
					start[5] <= 1;   //生成障碍物5  飞鸟		
			end
			default:;
		endcase
	end

	
   //仙人掌模块
   Cactus_s  layer0(.clk_ip(clk_div[1]),.clk(clk_div[17]),.start(start[0]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_0),.finish(finish[0]));
	Cactus_b  layer1(.clk_ip(clk_div[1]),.clk(clk_div[17]),.start(start[1]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_1),.finish(finish[1]));
   Cactus_s  layer2(.clk_ip(clk_div[1]),.clk(clk_div[17]),.start(start[2]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_2),.finish(finish[2]));	
	Cactus_b  layer3(.clk_ip(clk_div[1]),.clk(clk_div[17]),.start(start[3]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_3),.finish(finish[3]));
	Cactus_s  layer4(.clk_ip(clk_div[1]),.clk(clk_div[17]),.start(start[4]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_4),.finish(finish[4]));
	
	//飞鸟模块
	Birds     layer5(.clk_ip(clk_div[1]),.clk_birds(clk_div[24]),.clk(clk_div[18]),.start(start[5]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_5),.finish(finish[5]));
	
	//dout
		assign dout = dout_0 & dout_1 & dout_2 & dout_3 & dout_4 & dout_5;  //将不同的dout并起来



endmodule
