//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
//---- plot Line
#property indicator_label1 "Line"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrDarkBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

double LineBuffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{

	SetIndexBuffer(0, LineBuffer, INDICATOR_DATA);
	//---
	return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
				const int prev_calculated,
				const datetime &time[],
				const double &open[],
				const double &high[],
				const double &low[],
				const double &close[],
				const long &tick_volume[],
				const long &volume[],
				const int &spread[])
{
	int bars = Bars(Symbol(), 0);
	Print("Bars = ", bars, ", rates_total = ", rates_total, ", prev_calculated = ", prev_calculated);
	Print("time[0] = ", time[0], " time[rates_total-1] = ", time[rates_total - 1]);
	return (rates_total);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
