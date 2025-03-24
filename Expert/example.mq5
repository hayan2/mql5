//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Anonymous Ltd."
#property link      "https://github.com/hayan2"
#property version   "1.00"

// Bollinger Bands Trading Strategy EA for MQL5
#include <Trade/Trade.mqh>

CTrade trade;

// 인디케이터 핸들
int bb_handle;

// 볼린저 밴드 값 저장 배열
double upperBand[], middleBand[], lowerBand[];

// 입력 변수
input int BB_Period = 20;
input double BB_Deviation = 2.0;
input double Lot_Size_Percentage = 10.0;

// OnInit: 인디케이터 핸들 생성
int OnInit() {
    bb_handle = iBands(Symbol(), PERIOD_CURRENT, BB_Period, 0, BB_Deviation, PRICE_CLOSE);
    if (bb_handle == INVALID_HANDLE) {
        Print("❌ Bollinger Bands 핸들 생성 실패!");
        return INIT_FAILED;
    }
    return INIT_SUCCEEDED;
}

// OnTick: 트레이딩 로직 실행
void OnTick() {
    double price = SymbolInfoDouble(Symbol(), SYMBOL_BID) + SymbolInfoDouble(_Symbol, SYMBOL_ASK) / 2.0;

    // 볼린저 밴드 값 가져오기
    if (CopyBuffer(bb_handle, 0, 0, 6, upperBand) <= 0 ||
        CopyBuffer(bb_handle, 1, 0, 6, middleBand) <= 0 ||
        CopyBuffer(bb_handle, 2, 0, 6, lowerBand) <= 0) {
        Print("❌ 볼린저 밴드 값 복사 실패!");
        return;
    }

    double upper = upperBand[0];
    double middle = middleBand[0];
    double lower = lowerBand[0];

	double bbw = ((upper - lower) / middle) * 100;

	Print("bbw : ", bbw);

	double upperSlope = calculateSlope(upperBand, 5);
	double middleSlope = calculateSlope(middleBand, 5);
	double lowerSlope = calculateSlope(lowerBand, 5);

	Print("upper slope : ", upperSlope);
	Print("middle slope : ", middleSlope);
	Print("lower slope : ", lowerSlope);

}

double calculateSlope(double& band[], int period) {
	if (period < 2) return 0;

	double slope = (band[period - 1] - band[0]) / (period - 1);

	return slope;
}