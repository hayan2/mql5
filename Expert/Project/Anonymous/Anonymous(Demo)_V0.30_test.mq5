//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "1.00"

input double Lots = 0.01;
input int MartingalePointGap = 1000;
input int TpPoints = 0;
input int TslPoints = 100;
input int IndicatorStopTime = 3;

input int FastMAPeriod = 50;
input int SlowMAPeriod = 200;
input ENUM_MA_METHOD MAMode = MODE_SMA;
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;

#include <Trade/SymbolInfo.mqh>
#include <Trade/Trade.mqh>

const int CURRENT = 0;
const int PREVIOUS = 1;

class TradeValidator {
   private:
    double balance;
    double equity;
    string symbol;
    double lots;
    double minLots;
    double maxLots;
    double point;
    double digits;

    void logValidationInfo(string message);

   public:
    TradeValidator();
    ~TradeValidator() {};

    bool loadSymbolInfo();
    void loadAccountInfo();
    void notEnoughEquity() { Print("Not enough equity."); }
    void notEnoughBalance() { Print("Not enough balance."); }

    bool checkHistory(int minimumBars);
    bool isInTester() { return MQLInfoInteger(MQL_TESTER) != 0; }

    bool hasOpenPositions() { return PositionsTotal() > 0; }
    bool hasOpenBuyPositions();
    bool hasOpenSellPositions();

    bool executeTrade(ENUM_ORDER_TYPE type, double currentPrice, double volume,
                      ulong magic);
    void closePositions(ENUM_ORDER_TYPE type, ENUM_POSITION_TYPE positionType);
    double validateStopLoss(ENUM_ORDER_TYPE type, double currentPrice);
    double validateTakeProfit(ENUM_ORDER_TYPE type, double currentPrice);

    double getBalance() { return balance; }
    double getEquity() { return equity; }
    string getSymbol() { return symbol; }
    double getLots() { return lots; }

    double getBid() { return SymbolInfoDouble(symbol, SYMBOL_BID); }
    double getAsk() { return SymbolInfoDouble(symbol, SYMBOL_ASK); }
};

TradeValidator::TradeValidator() { symbol = _Symbol; }

void TradeValidator::logValidationInfo(string message) {
    Print("[Validator] ", message);
}

bool TradeValidator::loadSymbolInfo() {
    // basic properties
    digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    point = SymbolInfoDouble(symbol, SYMBOL_POINT);

    // trading properties
    minLots = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    maxLots = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);

    // Protection against invalid data
    if (minLots <= 0) minLots = 0.01;
    if (maxLots <= 0) maxLots = 100.0;

    return true;
}

void TradeValidator::loadAccountInfo() {
    balance = AccountInfoDouble(ACCOUNT_BALANCE);
    equity = AccountInfoDouble(ACCOUNT_EQUITY);
}

bool TradeValidator::checkHistory(int minimumBars) {
    // check if enough bars are available for the current symbol/timeframe
    if (Bars(symbol, PERIOD_CURRENT) < MinimumBars) {
        logValidationInfo("WARNING: Not enough historical data. Required: " +
                          IntegerToString(MinimumBars) + ", Available: " +
                          IntegerToString(Bars(symbol, PERIOD_CURRENT)));
        return false;
    }

    return true;
}


bool TradeValidator::hasOpenBuyPositions() {
    for (int i = 0; i < PositionsTotal(); i++) {
        if (positionInfo.SelectByIndex(i)) {
            ENUM_POSITION_TYPE ptype = positionInfo.PositionType();
            if (ptype == POSITION_TYPE_BUY) return true;
        }
    }
    return false;
}

bool TradeValidator::hasOpenSellPositions() {
    for (int i = 0; i < PositionsTotal(); i++) {
        if (positionInfo.SelectByIndex(i)) {
            ENUM_POSITION_TYPE ptype = positionInfo.PositionType();
            if (ptype == POSITION_TYPE_SELL) return true;
        }
    }
    return false;
}

double TradeValidator::validateStopLoss(ENUM_ORDER_TYPE type,
                                        double currentPrice) {
    if (currentPrice <= 0.0) return 0.0;
    if (StopLoss <= 0.0) return 0.0;

    bool isBuy =
        (type == ORDER_TYPE_BUY || type == ORDER_TYPE_BUY_LIMIT ||
         type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_STOP_LIMIT);
    bool isSell =
        (type == ORDER_TYPE_SELL || type == ORDER_TYPE_SELL_LIMIT ||
         type == ORDER_TYPE_SELL_STOP || type == ORDER_TYPE_SELL_STOP_LIMIT);

    if (isBuy)
        return NormalizeDouble(currentPrice - (double)StopLoss * _Point,
                               _Digits);
    if (isSell)
        return NormalizeDouble(currentPrice + (double)StopLoss * _Point,
                               _Digits);

    return 0.0;
}

double TradeValidator::validateTakeProfit(ENUM_ORDER_TYPE type,
                                          double currentPrice) {
    if (currentPrice <= 0.0) return 0.0;
    if (TakeProfit <= 0.0) return 0.0;

    bool isBuy =
        (type == ORDER_TYPE_BUY || type == ORDER_TYPE_BUY_LIMIT ||
         type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_STOP_LIMIT);
    bool isSell =
        (type == ORDER_TYPE_SELL || type == ORDER_TYPE_SELL_LIMIT ||
         type == ORDER_TYPE_SELL_STOP || type == ORDER_TYPE_SELL_STOP_LIMIT);

    if (isBuy)
        return NormalizeDouble(currentPrice + TakeProfit * _Point, _Digits);
    if (isSell)
        return NormalizeDouble(currentPrice - TakeProfit * _Point, _Digits);

    return 0.0;
}

bool TradeValidator::executeTrade(ENUM_ORDER_TYPE type, double currentPrice,
                                  double volume, ulong magic) {
    MqlTradeRequest request = {};
    MqlTradeResult result = {};

    request.action = TRADE_ACTION_DEAL;
    request.type = type;
    request.volume = volume;
    request.symbol = symbol;
    request.price = currentPrice;
    request.sl = validateStopLoss(type, currentPrice);
    request.tp = validateTakeProfit(type, currentPrice);

    if (OrderFilling == 0)
        request.type_filling = ORDER_FILLING_FOK;
    else if (OrderFilling == 1)
        request.type_filling = ORDER_FILLING_IOC;
    else if (OrderFilling == 2)
        request.type_filling = ORDER_FILLING_RETURN;

    request.deviation = Slippage;
    request.magic = magic;
    request.comment = "";

    bool success = OrderSend(request, result);

    if (success && result.retcode == TRADE_RETCODE_DONE) {
        Print("Trade successfully executed. Ticket : ", result.order);
        return true;
    } else {
        Print("Trade error : ", result.retcode);
        Print("Description : ", result.comment);
        return false;
    }
}

void TradeValidator::closePositions(ENUM_ORDER_TYPE type,
                                    ENUM_POSITION_TYPE positionType) {
    for (int i = 0; i < PositionsTotal(); i++) {
        ENUM_POSITION_TYPE ptype = positionInfo.PositionType();
        if (ptype == positionType && positionInfo.Symbol() == symbol &&
            positionInfo.Magic() == MagicNumber) {
            trade.PositionClose(positionInfo.Ticket(), 0);
        }
    }
}

CTrade trade;
CSymbolInfo symbolInfo;
CPositionInfo positionInfo;
CHistoryOrderInfo historyOrderInfo;
CDealInfo dealInfo;

int totalBars;
double lastBuyPrice, lastSellPrice, buyLots, sellLots;
int handleFastMA, handleSlowMA;
double fastMA[], slowMA[];

int OnInit() {
    totalBars = iBars(_Symbol, PERIOD_CURRENT);

    handleFastMA =
        iMA(_Symbol, PERIOD_CURRENT, FastMAPeriod, 0, MAMode, AppliedPrice);
    handleSlowMA =
        iMA(_Symbol, PERIOD_CURRENT, SlowMAPeriod, 0, MAMode, AppliedPrice);

    if (handleFastMA == INVALID_HANDLE || handleSlowMA == INVALID_HANDLE) {
        Print("Failed to create MA.", GetLastError());
        return INIT_FAILED;
    }

    ArraySetAsSeries(fastMA, true);
    ArraySetAsSeries(slowMA, true);

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
    int currentBars = iBars(_Symbol, PERIOD_CURRENT);
    double bid =
        NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    double ask =
        NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    bool hasOpenBuyPositions = false, hasOpenSellPositions = false;
    int totalBuyPositions = 0, totalSellPositions = 0;

    if (currentBars != totalBars) {
        totalBars = currentBars;

        if (CopyBuffer(handleFastMA, 0, 1, IndicatorStopTime, fastMA) <
                IndicatorStopTime ||
            CopyBuffer(handleSlowMA, 0, 1, IndicatorStopTime, slowMA) <
                IndicatorStopTime) {
            Print("Failed copying indicator values. ", GetLastError());
            return;
        }

        for (int i = 0; i < PositionsTotal(); i++) {
            if (positionInfo.SelectByIndex(i)) {
                ENUM_POSITION_TYPE posType = positionInfo.PositionType();
                if (posType == POSITION_TYPE_BUY) {
                    hasOpenBuyPositions = true;
                    totalBuyPositions++;
                }
                if (posType == POSITION_TYPE_SELL) {
                    hasOpenSellPositions = true;
                    totalSellPositions++;
                }
            }
        }

        bool buySignal = fastMA[PREVIOUS] < slowMA[PREVIOUS] &&
                         fastMA[CURRENT] > slowMA[CURRENT];
        bool sellSignal = fastMA[PREVIOUS] > slowMA[PREVIOUS] &&
                          fastMA[CURRENT] < slowMA[CURRENT];

        if (sellSignal) {
            // sell signal
            Print("sell signal");

            if (hasOpenSellPositions &&
                lastSellPrice < ask - MartingalePointGap * _Point) {
                sellLots *= 2;
                trade.Sell(sellLots, _Symbol, ask, 0.0, 0.0, "");
                lastSellPrice = ask;
            } else if (!hasOpenSellPositions) {
                trade.Sell(Lots, _Symbol, ask, 0.0, TpPoints, "");
                lastSellPrice = ask;
                sellLots = Lots;
            }
        }
        if (buySignal) {
            // buy signal
            Print("buy signal");

            if (hasOpenBuyPositions &&
                lastBuyPrice > bid + MartingalePointGap * _Point) {
                buyLots *= 2;
                trade.Buy(buyLots, _Symbol, bid, 0.0, 0.0, "");
                lastBuyPrice = bid;
            } else if (!hasOpenBuyPositions) {
                trade.Buy(Lots, _Symbol, bid, 0.0, TpPoints, "");
                lastBuyPrice = bid;
                buyLots = Lots;
            }
        }
    }
}

/*

        Simple Fast MA(50) + Simple Slow MA(200), Martingale trading strategy.
        Use Trailing stop.

*/