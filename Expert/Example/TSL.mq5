//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "1.00"

#include <Trade/Trade.mqh>

input int TslTriggerPoints = 5000;
input int TslPoints = 10000;

input ENUM_TIMEFRAMES TslMaTimeframe = PERIOD_CURRENT;
input int TslMaPeriod = 20;
input ENUM_MA_METHOD TslMaMethod = MODE_SMA;
input ENUM_APPLIED_PRICE TslMaAppliedPrice = PRICE_CLOSE;

int handleMa;

int OnInit() {
    handleMa = iMA(_Symbol, TslMaTimeframe, TslMaPeriod, 0, TslMaMethod,
                   TslMaAppliedPrice);

	if (handleMa == INVALID_HANDLE) {
		Print("Failed to craete indicator.", GetLastError());
		return INIT_FAILED;
	}

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

CTrade trade;

void OnTick() {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong posTicket = PositionGetTicket(i);

        if (PositionSelectByTicket(posTicket)) {
            if (PositionGetString(POSITION_SYMBOL) == _Symbol) {
                long posType = PositionGetInteger(POSITION_TYPE);
                double posOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                double posSl = PositionGetDouble(POSITION_SL);
                double posTp = PositionGetDouble(POSITION_TP);

                double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
                double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

				double ma[];
				CopyBuffer(handleMa, MAIN_LINE, 0, 1, ma);

                if (posType == POSITION_TYPE_BUY) {
                    if (bid > posOpenPrice + TslTriggerPoints * _Point) {
                        double sl = bid - TslPoints * _Point;

                        if (sl > posSl) {
                            
                            if (trade.PositionModify(posTicket, sl, posTp)) {
                                Print(__FUNCTION__, " > Pos # ", posTicket,
                                      " was modified by normal tsl.");
                            }
                        }
                    }

					if (ArraySize(ma) > 0) {
						double sl = ma[0];
						if (sl > posSl && sl < bid) {
							if (trade.PositionModify(posTicket, sl, posTp)) {
								Print(__FUNCTION__, " > Pos # ", posTicket,
									  " was modified by ma tsl.");
							}
						}
					}

                } else if (posType == POSITION_TYPE_SELL) {
                    double sl = ask + TslPoints * _Point;
					if (ask < posOpenPrice - TslTriggerPoints * _Point) {
						if (sl < posSl || posSl == 0.0) {
							if (trade.PositionModify(posTicket, sl, posTp)) {
								Print(__FUNCTION__, " > Pos # ", posTicket,
									  " was modified.");
							}
						}
					}
					if (ArraySize(ma) > 0) {
						double sl = ma[0];
						if ((sl < posSl || posSl == 0.0) && sl > ask) {
							if (trade.PositionModify(posTicket, sl, posTp)) {
								Print(__FUNCTION__, " > Pos # ", posTicket,
									  " was modified by ma tsl.");
							}
						}
					}
                }
            }
        }
    }
}