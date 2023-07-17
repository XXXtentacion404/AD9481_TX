//--------------------------------------------------------------
// 程序描述:
//     高速AD（AD9481）数据采集程序,上位机显示程序
// 作    者: 凌智电子
// 开始日期: 2021-06-25
// 完成日期: 2021-06-25
// 修改日期:
// 版    本: V1.0 
// 调试工具: 
// 说    明:
//     (1) 分别输入正弦波、方波和三角波，通过串口调试助手观察采集的数据波形。
//--------------------------------------------------------------
module ADC_AD9481(
	input        EXT_RST_N,         // 复位
	input        EXT_CLK,           // 系统时钟
	
	input        KEY,               // 开始采集按键	
	input        RX,                // 串口读
	output       TX,                // 串口写
	
	input        ADC_DCO_P,         // 输入数据时钟
	input        ADC_DCO_N,         // 输入数据时钟
	input  [7:0] ADC_DIN_A,         // 输入数据
	input  [7:0] ADC_DIN_B,         // 输入数据
	
	output       ADC_CLK,           // ADC时钟
	output       ADC_PDWN           // ADC掉电控制，高电平有效
);

wire adc_clk_in;                  // 250MHz时钟
wire sys_clk;                     // adc_clk_in / 2

wire [15:0] adc_out;              // ADC 连续数据
wire [15:0] FIFO_IN;			       // FIFO输入数据
wire FIFO_RD_CLK;						 // FIFO读时钟
wire FIFO_WR;					       // FIFO写使能
wire WREMPTY;					       // FIFO写空信号
wire [12:0] WRUSEDW;			       // FIFO存储的个数
wire [15:0] FIFO_OUT;		       // FIFO输出数据

// PLL
// 50MHz to 250MHz
pll_m	pll_m_inst (
	.areset 		( ~EXT_RST_N 	),   // 复位
	.inclk0 		( EXT_CLK 		),   // PLL输入时钟：50MHz
	.c0 			( sys_clk 		),   // adc_clk_in / 2
	.c1 			( adc_clk_in   ),	  // 250MHz 时钟
	.locked 		(  				)
);


// ADC数据处理模块；
// 将A、B端口的数据合并后输出；
// 将ADC合并后数据同步到sys_clk。
HS_AD9481_IN HS_AD9481_IN_u1(
	.adc_clk_in	( adc_clk_in   ),    // ADC时钟 MAX 250MHz
	.sys_clk		( sys_clk		),    // 系统时钟 adc_clk_in / 2
	.sys_rst_n	( EXT_RST_N		),    // 复位
	.dco_p		( ADC_DCO_P		),    // 数据时钟 +
	.dco_n		( ADC_DCO_N		),    // 数据时钟 -
	
	.din_a		( ADC_DIN_A		),    // ADC端口A数据
	.din_b		( ADC_DIN_B		),    // ADC端口B数据
	
	.adc_clk		( ADC_CLK		),    // ADC时钟
	.dout			( adc_out		),    // ADC合并后数据
	.pdwn			( ADC_PDWN		)     // ADC掉电控制，高电平有效
);

// ADC数据处理模块
Data_Processing U_Data_Processing(
	.clk        ( sys_clk      ),    // 时钟
	.rst_n      ( EXT_RST_N    ),    // 复位
	.adc_in     ( adc_out      ),    // ADC输入数据
	.WRUSEDW    ( WRUSEDW      ),    // FIFO存储的个数
	.WREMPTY    ( WREMPTY      ),    // FIFO写空信号
	.FIFO_WR    ( FIFO_WR      ),    // FIFO写使能
	.FIFO_IN    ( FIFO_IN      )     // FIFO数据输入
);

// FIFO
FIFO_ADC_DATA U_FIFO_ADC_DATA(
	.data       ( FIFO_IN      ),    // FIFO数据输入
	.rdclk      ( FIFO_RD_CLK  ),    // FIFO读时钟
	.rdreq      ( 1'b1         ),    // FIFO读使能
	.wrclk      ( sys_clk      ),    // FIFO写时钟
	.wrreq      ( FIFO_WR      ),    // FIFO写使能
	.q          ( FIFO_OUT     ),    // FIFO数据输出
	.wrusedw    ( WRUSEDW      ),    // FIFO存储个数
	.wrempty    ( WREMPTY      )     // FIFO写空信号
);

// 串口传输模块
UART U_UART(
	.clk        ( sys_clk      ),    // 时钟
	.clk_50m    ( EXT_CLK      ),    // 50MHz时钟
	.rst_n      ( EXT_RST_N    ),    // 复位
	.key        ( KEY          ),    // 按键
	.WREMPTY    ( WREMPTY      ),    // FIFO写空信号
	.FIFO_OUT   ( FIFO_OUT     ),    // FIFO数据输出
	.RX         ( RX           ),    // 串口读
	.TX         ( TX           ),    // 串口写
	.FIFO_RD_CLK( FIFO_RD_CLK  )     // FIFO读时钟
);

endmodule 