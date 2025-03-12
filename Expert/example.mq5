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

// 증거금을 기준으로 로트 크기 계산
double CalculateLotSize() {
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double lotSize = (equity * (Lot_Size_Percentage / 100.0)) / 100000;
    return NormalizeDouble(lotSize, 2);
}

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
    double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
    double lotSize = CalculateLotSize();

    // 볼린저 밴드 값 가져오기
    if (CopyBuffer(bb_handle, 0, 0, 1, upperBand) <= 0 ||
        CopyBuffer(bb_handle, 1, 0, 1, middleBand) <= 0 ||
        CopyBuffer(bb_handle, 2, 0, 1, lowerBand) <= 0) {
        Print("❌ 볼린저 밴드 값 복사 실패!");
        return;
    }

    double upper = upperBand[0];
    double middle = middleBand[0];
    double lower = lowerBand[0];

    // 1. 하단 밴드 돌파 시 매수
    if (price < lower) {
        trade.Buy(lotSize);
    }

    // 2. 하단 밴드 위로 돌파 시 추가 매수
    if (PositionSelect(Symbol()) && price > lower) {
        trade.Buy(lotSize);
    }

    // 3. 중심선에서 50% 익절
    if (PositionSelect(Symbol()) && price >= middle) {
        trade.PositionClosePartial(PositionGetInteger(POSITION_TICKET), PositionGetDouble(POSITION_VOLUME) * 0.5);
    }

    // 4. 중심선 돌파 시 추가 매수
    if (price > middle) {
        trade.Buy(lotSize);
    }

    // 5. 상단 밴드에서 50% 익절
    if (PositionSelect(Symbol()) && price >= upper) {
        trade.PositionClosePartial(PositionGetInteger(POSITION_TICKET), PositionGetDouble(POSITION_VOLUME) * 0.5);
    }

    // 6. 상단 밴드 하향 돌파 시 매수
    if (price < upper) {
        trade.Buy(lotSize);
    }
}