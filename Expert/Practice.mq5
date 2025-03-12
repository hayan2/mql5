//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "1.00"

input const string Symbol = "EURUSD";
input ENUM_TIMEFRAMES Period;

int OnInit() { return (INIT_SUCCEEDED); }

void OnDeinit(const int reason) {}

void OnTick() {
    Alert("OnTick() : ");
    MqlRates priceInfo[];

    ArraySetAsSeries(priceInfo, true);

    int data = CopyRates(Symbol, Period, 0, 3, priceInfo);

    for (int i = 0; i < data; i++) {
        Alert("---------------------------");
        if (i == 0) {
            Alert(i + 1, "st");
        } else if (i == 1) {
            Alert(i + 1, "nd");
        } else if (i == 2) {
            Alert(i + 1, "rd");
        } else {
            Alert(i + 1, "th");
        }
		Alert("time : ", priceInfo[i].time);
        Alert("high : ", priceInfo[i].high);
        Alert("low : ", priceInfo[i].low);
    }

    Alert("data : ", data);
}