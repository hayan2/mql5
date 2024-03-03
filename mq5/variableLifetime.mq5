//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
//--- 243P
#property copyright "Copyright 2024, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

void CalculateLWMA(int ratesTotal, int prev_calculated, int begin,
                   const double &price[]) {
    int i, limit;
    static int weightSum = 0;
    double sum = 0;

    if (prev_calculated == 0) {
        limit = MA_Peiod + begin;

        for (i = 0; i < limit; i++) {
            LineBuffer[i] = 0.0;
        }

		double firstValue = 0;
		for (int i = begin; i < limit; i++) {
			int k = i - begin + 1;
			weightSum += k;
			firstValue += k * price[i];
		}
		firstValue /= (double)weightSum;
		LineBuffer[limit - 1] = firstValue;
    }
	else {
		limit = prev_calculated - 1;
	}

	for (i = limit; i < ratesTotal; i++) {
		sum = 0;
		for (int j = 0; j < MA_Period; j++) {
			sum += (MA_Period - j) * price[i - j];
			LineBuffer[i] = sum / weightSum;
		}
	}
}