string getSignal() {
    MqlRates PriceInfo[];
	
    ArraySetAsSeries(PriceInfo, true);

    int data = CopyRates(_Symbol, _Period, 0, 3, PriceInfo);

    string signal = "";

    double MiddleBandArray[];
    double UpperBandArray[];
    double LowerBandArray[];

    ArraySetAsSeries(MiddleBandArray, true);
    ArraySetAsSeries(UpperBandArray, true);
    ArraySetAsSeries(LowerBandArray, true);

    int handleBollingerBand = iBands(_Symbol, _Period, 20, 0, 2, PRICE_CLOSE);

    CopyBuffer(handleBollingerBand, 0, 0, 3, MiddleBandArray);
    CopyBuffer(handleBollingerBand, 1, 0, 3, UpperBandArray);
    CopyBuffer(handleBollingerBand, 2, 0, 3, LowerBandArray);

    if (PriceInfo[1].close < LowerBandArray[1] &&
        PriceInfo[0].close > LowerBandArray[0]) {
        signal = "buy";
    }

    if (PriceInfo[1].close > UpperBandArray[1] &&
        PriceInfo[0].close < UpperBandArray[0]) {
        signal = "sell";
    }

    return signal;
}