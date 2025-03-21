//+------------------------------------------------------------------+
//|                                   Copyright 2025, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 1
//--- plot BBBandwidth
#property indicator_label1 "BBandwidth"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Purple
#property indicator_style1 STYLE_SOLID
#property indicator_width1 3
// --- Inputs
input int InpBandsPeriod = 20;          // Period
input int InpBandsShift = 0;            // Shift
input double InpBandsDeviations = 2.0;  // Deviation
// --- BollingerBand handle
int BBHandle;
//--- indicator buffers
double BBandwidthBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    //--- indicator buffers mapping
    SetIndexBuffer(0, BBandwidthBuffer, INDICATOR_DATA);
    /*
       saving processing time by making calls to the iBands indicator to get the
       upper and lower band values, then we just perform a simple calculation to
       output the result to a single indicator on a seperate chart window.
    */
    BBHandle = iBands(_Symbol, PERIOD_CURRENT, InpBandsPeriod, InpBandsShift,
                      InpBandsDeviations, PRICE_CLOSE);

    //---
    return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
    //--- variables
    int pos = 0;
    double upper_band[];
    double lower_band[];

    // --- Turn the arrays into dynamic series arrays
    ArraySetAsSeries(lower_band, true);
    ArraySetAsSeries(upper_band, true);
    ArraySetAsSeries(BBandwidthBuffer, true);

    //--- check if all data calculated
    if (BarsCalculated(BBHandle) < rates_total) return (0);
    //--- we can copy all data
    if (CopyBuffer(BBHandle, 1, 0, rates_total, upper_band) <= 0) return (0);
    if (CopyBuffer(BBHandle, 2, 0, rates_total, lower_band) <= 0) return (0);

    /*
       Now loop through the rates_total to populate the  the buffer with the
       calculation needed to get the bandwidth of the bollinger bands.  Using a
       switch on the digits value to determine the decimal calculation offset so
       that result is consistent.
    */
    for (int i = pos; i < rates_total - 1; i++) {
        switch (_Digits) {
            case 2: {
                BBandwidthBuffer[i] =
                    floor(((upper_band[i] - lower_band[i]) / _Point) * 0.1);
                break;
            }
            case 3: {
                BBandwidthBuffer[i] =
                    floor(((upper_band[i] - lower_band[i]) / _Point) * 0.01);
                break;
            }
            case 4: {
                BBandwidthBuffer[i] =
                    floor((upper_band[i] - lower_band[i]) / _Point);
                break;
            }
            case 5: {
                BBandwidthBuffer[i] =
                    floor(((upper_band[i] - lower_band[i]) / _Point) * 0.1);
                break;
            }
            default: {
                BBandwidthBuffer[i] =
                    floor((upper_band[i] - lower_band[i]) / _Point);
                break;
            }
        }
    }

    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+