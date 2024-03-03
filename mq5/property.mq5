//-- 256P

#property version "3.70"
#property description "HELLO WORLD"
#property description "HOW ARE YOU?"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 1
#property indicator_type1 DRAW_CANDLES
#property indicator_width1 3
#property indicator_label1 "C open;C high;C low;C close"

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
        int bars = Bars(Symbol(), 0);
    Print("Bars = ", bars, ", rates_total = ", rates_total,
          ", prev_calculated = ", prev_calculated);
    Print("time[0] = ", time[0],
          " time[rates_total-1] = ", time[rates_total - 1]);
    return (rates_total);
}