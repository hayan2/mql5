//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "1.00"

input int BandsPeriod = 20;
input int BandsShift = 0;
input double Deviation = 2.0;
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;

int handleBB;
double upperBand[], middleBand[], lowerBand[];

int OnInit() {
    handleBB = iBands(Symbol(), PERIOD_CURRENT, BandsPeriod, BandsShift,
                      Deviation, AppliedPrice);

    if (handleBB == INVALID_HANDLE) {
        Print("FAILED");
        return INIT_FAILED;
    }

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
    if (BarsCalculated(handleBB) < BandsPeriod) {
        Print("Not enough datas");
        return;
    }

    ArraySetAsSeries(upperBand, true);
    ArraySetAsSeries(middleBand, true);
    ArraySetAsSeries(lowerBand, true);

    if (CopyBuffer(handleBB, 0, 0, 1, upperBand) <= 0 ||
        CopyBuffer(handleBB, 1, 0, 1, middleBand) <= 0 ||
        CopyBuffer(handleBB, 2, 0, 1, lowerBand) <= 0) {
        Print("FAILED");
        return;
    }
}