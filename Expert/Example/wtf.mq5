//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Anonymous Ltd."
#property link      "https://github.com/hayan2"
#property version   "1.00"


int OnInit() {
	 

	 return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
	 
}

void OnTick() {
	int bars = iBars(_Symbol, PERIOD_H1);
	static int totalBars = bars;
	if (totalBars != bars) {
		totalBars = bars;

		string time = TimeToString(iTime(_Symbol, PERIOD_H1, 0));
		StringReplace(time, " ", ", ");

		int start = 
	}
}