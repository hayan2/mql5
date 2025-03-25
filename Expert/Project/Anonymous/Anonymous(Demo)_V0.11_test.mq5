//+------------------------------------------------------------------+
//|                                   Copyright 2025, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "0.11"

#define CURRENT 0
#define PREVIOUS 1
#define ONE_HALF 0.5
#define ONE_TENTH 0.1
#define MINIMUM_LOTS 0.01

enum ENUM_ORDER_FILLING {
    Fire_or_kill = 0,
    Immediate_or_cancel = 1,
    Order_filling_return = 2
};

input group "---------- General ----------";
input ulong BoxMagicNumber = 2147483647;
input ulong TrendMagicNumber = 2147483648;
input ENUM_TIMEFRAMES ChartPeriod = PERIOD_H1;
input ENUM_ORDER_FILLING OrderFilling = 1;
input group "---------- Bollinger Bands variable ----------";
input int BandsPeriod = 20;
input int BandsShift = 0;
input double Deviation = 2.0;
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;
input int SlopePeriod = 3;
input group "---------- Relative Strength Index variable ----------";
input int RsiPeriod = 14;
input group "---------- Pattern variable ----------";
input double BoxPatternSlope = 3.7;
input double BoxPatternBBW = 50;
input group "---------- Risk and money management ----------";
input double Lots = 0.01;
input bool HedgeMode = false;
input double TakeProfitPercent = 0.05;
input double MarginPercent = 0.1;
input double trueIsBalanceFalseIsEquity = false;
input double StopLoss = 200;
input bool EnableTP = false;
input double TakeProfit = 500;
input int Slippage = 10;
input group "---------- Order management ----------";
input int PointsGap = 0;
input int FirstSellPointsGap = 40;
input int SecondSellPointsGap = 0;
input int ThirdSellPointsGap = 0;
input int FirstBuyPointsGap = 40;
input int SecondBuyPointsGap = 0;
input int ThirdBuyPointsGap = 0;
input int TakeProfitGap = 20;
input int StopLossGap = 20;
input bool EnableSL = false;

#include <Trade/SymbolInfo.mqh>
#include <Trade/Trade.mqh>

struct Slope {
    double upper, middle, lower, absUpper, absMiddle, absLower;
};

class TradeValidator {
   public:
    Slope slope;
    double bbw;
    string symbol;
    //---
    // buy position variable
    bool isLowerBroken, isCrossedAboveLower, isBuyTouchedMiddle, isTouchedUpper;
    bool isBuyCloseMiddle;
    // sell position variable
    bool isUpperBroken, isCrossedBelowUpper, isSellTouchedMiddle,
        isTouchedLower;
    bool isSellCloseMiddle;
    //---
    double balance, equity;
    // 10%
    double lotsOneTenth;
    // 50%
    double lotsOneHalf;

    TradeValidator();
    ~TradeValidator() {};

    void refresh();
    bool loadAccountInfo();
    double calculateLots();
    double calculatePip(double point) { return point * _Point; }

    bool checkActiveBuyPosition();
    bool checkActiveSellPosition();

    bool executeTrade(ENUM_ORDER_TYPE type, double currentPrice, double volume, ulong magic);
    bool closePositionHalf(ENUM_ORDER_TYPE type,
                           ENUM_POSITION_TYPE positionType);

    // close all position
    void closeAllBuyPosition();
    void closeAllSellPosition();

    void notEnoughEquity() { Print("Not enough equity."); }

    double getAccountBalance() { return balance; }
    double getAccountEquity() { return equity; }
    double getSpread() {
        return SymbolInfoDouble(symbol, SYMBOL_ASK) -
               SymbolInfoDouble(symbol, SYMBOL_BID);
    }
    void getCurrentBollingerBandsSlope(double& lowerBand[],
                                       double& middleBand[],
                                       double& upperBand[], int period);
    void getCurrentBollingerBandwidth(double currentLowerBand,
                                      double currentMiddleBand,
                                      double currentUpperBand);
	bool getBoxTradingBuySignal();
	bool getBoxTradingSellSignal();
	bool getTrendTradingBuySignal();
	bool getTrendTradingSellSignal();

    void displayBBW() { Print("BBW : ", bbw); }
    void displaySlope() {
        Print("upper slope : ", slope.upper);
        Print("middle slope : ", slope.middle);
        Print("lower slope : ", slope.lower);
    }

    double getBid() { return SymbolInfoDouble(symbol, SYMBOL_BID); }
    double getAsk() { return SymbolInfoDouble(symbol, SYMBOL_ASK); }
};

TradeValidator::TradeValidator() {
    symbol = _Symbol;
    isLowerBroken = false;
    isCrossedAboveLower = false;
    isBuyTouchedMiddle = false;
    isTouchedUpper = false;
    isUpperBroken = false;
    isCrossedBelowUpper = false;
    isSellTouchedMiddle = false;
    isTouchedLower = false;
    isBuyCloseMiddle = false;
    isSellCloseMiddle = false;
    balance = 0.0;
    equity = 0.0;
    lotsOneTenth = 0.01;
    lotsOneHalf = 0.05;
}

bool TradeValidator::loadAccountInfo() {
    balance = AccountInfoDouble(ACCOUNT_BALANCE);
    equity = AccountInfoDouble(ACCOUNT_EQUITY);

    return true;
}

double TradeValidator::calculateLots() {
    double contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    double equityPerContract = equity / contractSize;
    double balancePerContract = balance / contractSize;

    if (trueIsBalanceFalseIsEquity) {
        lotsOneHalf = balancePerContract * ONE_HALF;
        lotsOneTenth = balancePerContract * ONE_TENTH;
    } else {
        lotsOneHalf = equityPerContract * ONE_HALF;
        lotsOneTenth = equityPerContract * ONE_TENTH;
    }

    lotsOneHalf = MathCeil(lotsOneHalf * 100) / 10;
    lotsOneTenth = MathCeil(lotsOneTenth * 100) / 10;

    return lotsOneTenth;
}

// returns true if there are no open buy position
bool TradeValidator::checkActiveBuyPosition() {
    return !(isLowerBroken || isCrossedAboveLower || isBuyTouchedMiddle ||
             isTouchedUpper);
}

// returns true if there are no open sell position
bool TradeValidator::checkActiveSellPosition() {
    return !(isUpperBroken || isCrossedBelowUpper || isSellTouchedMiddle ||
             isTouchedLower);
}

bool TradeValidator::executeTrade(ENUM_ORDER_TYPE type, double currentPrice,
                                  double volume, ulong magic) {
    MqlTradeRequest request = {};
    MqlTradeResult result = {};

    request.action = TRADE_ACTION_DEAL;
    request.symbol = symbol;
    request.volume = volume;
    request.type = type;

    if (OrderFilling == 0)
        request.type_filling = ORDER_FILLING_FOK;
    else if (OrderFilling == 1)
        request.type_filling = ORDER_FILLING_IOC;
    else if (OrderFilling == 2)
        request.type_filling = ORDER_FILLING_RETURN;

    if (type == ORDER_TYPE_BUY)
        request.price = validator.getAsk();
    else if (type == ORDER_TYPE_SELL)
        request.price = validator.getBid();

    if (EnableSL && EnableTP) {
        request.sl = StopLoss;
        request.tp = TakeProfit;
    }
    request.deviation = Slippage;
    request.magic = BoxMagicNumber;
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

bool TradeValidator::closePositionHalf(ENUM_ORDER_TYPE type,
                                       ENUM_POSITION_TYPE positionType) {
    // POSITION_TYPE_BUY  == 0
    // POSITION_TYPE_SELL == 1
    for (int i = PositionsTotal(); i >= 0; i--) {
        if (positionInfo.SelectByIndex(i)) {
            ENUM_POSITION_TYPE ptype = positionInfo.PositionType();
            if (ptype == positionType) {
                double volume =
                    MathCeil(positionInfo.Volume() / 2.0 * 100) / 100;
                Print("info volume : ", positionInfo.Volume());
                Print("volume : ", volume);
                if (positionInfo.Symbol() == symbol &&
                    positionInfo.Magic() == BoxMagicNumber) {
                    trade.PositionClosePartial(positionInfo.Ticket(), volume,
                                               0);
                }
            }
        }
    }

    return true;
}

void TradeValidator::closeAllBuyPosition() {
    for (int i = PositionsTotal(); i >= 0; i--) {
        if (positionInfo.SelectByIndex(i)) {
            ENUM_POSITION_TYPE ptype = positionInfo.PositionType();
            if (ptype == POSITION_TYPE_BUY) {
                double volume = positionInfo.Volume();
                Print("info volume : ", positionInfo.Volume());
                Print("volume : ", volume);
                if (positionInfo.Symbol() == symbol &&
                    positionInfo.Magic() == BoxMagicNumber) {
                    trade.PositionClose(positionInfo.Ticket(), 0);
                }
            }
        }
    }

    isLowerBroken = isCrossedAboveLower = isBuyTouchedMiddle = isTouchedUpper =
        isBuyCloseMiddle = false;
}

void TradeValidator::closeAllSellPosition() {
    for (int i = PositionsTotal(); i >= 0; i--) {
        if (positionInfo.SelectByIndex(i)) {
            ENUM_POSITION_TYPE ptype = positionInfo.PositionType();
            if (ptype == POSITION_TYPE_SELL) {
                double volume = positionInfo.Volume();
                Print("info volume : ", positionInfo.Volume());
                Print("volume : ", volume);
                if (positionInfo.Symbol() == symbol &&
                    positionInfo.Magic() == BoxMagicNumber) {
                    trade.PositionClose(positionInfo.Ticket(), 0);
                }
            }
        }
    }
    isUpperBroken = isCrossedBelowUpper = isSellTouchedMiddle = isTouchedLower =
        isSellCloseMiddle = false;
}

void TradeValidator::getCurrentBollingerBandsSlope(double& lowerBand[],
                                                   double& middleBand[],
                                                   double& upperBand[],
                                                   int period) {
    slope.lower = ((lowerBand[0] - lowerBand[period - 1]) / (period - 1)) * 10000;
    slope.middle = ((middleBand[0] - middleBand[period - 1]) / (period - 1)) * 10000;
    slope.upper = ((upperBand[0] - upperBand[period - 1]) / (period - 1)) * 10000;

	slope.absLower = MathAbs(slope.lower);
	slope.absMiddle = MathAbs(slope.middle);
	slope.absUpper = MathAbs(slope.upper);
}

void TradeValidator::getCurrentBollingerBandwidth(double currentLowerBand,
                                                  double currentMiddleBand,
                                                  double currentUpperBand) {
    bbw = ((currentUpperBand - currentLowerBand) / currentMiddleBand) * 10000;
}

bool TradeValidator::getBoxTradingBuySignal() {
	return 
}

bool TradeValidator::getBoxTradingSellSignal() {
	return true;
}

bool TradeValidator::getTrendTradingBuySignal() {
	return true;
}

bool TradeValidator::getTrendTradingSellSignal() {
	return true;
}

CTrade trade;
CSymbolInfo symbolInfo;
CPositionInfo positionInfo;
CHistoryOrderInfo historyOrderInfo;
CDealInfo dealInfo;

TradeValidator validator;
int handleBand, handleRsi;

int OnInit() {
    handleBand = iBands(_Symbol, ChartPeriod, BandsPeriod, BandsShift,
                        Deviation, AppliedPrice);
	handleRsi = iRSI(_Symbol, ChartPeriod, RsiPeriod, AppliedPrice);

    if (handleBand == INVALID_HANDLE) {
        Print("Failed to create Bollinger Bands");
        return INIT_FAILED;
    }

	if (handleRsi == INVALID_HANDLE) {
		Print("Failed to create RSI");
		return INIT_FAILED;
	}

    //---
    if (HedgeMode) trade.SetMarginMode();
    trade.SetExpertMagicNumber(BoxMagicNumber);

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
    // get bollinger bands middle, lower, upper line.
	double upperBand[], middleBand[], lowerBand[];
	double rsi[];

    ArraySetAsSeries(middleBand, true);
    ArraySetAsSeries(lowerBand, true);
    ArraySetAsSeries(upperBand, true);
	ArraySetAsSeries(rsi, true);

    if (CopyBuffer(handleBand, BASE_LINE, 0, 4, middleBand) < 4 ||
        CopyBuffer(handleBand, LOWER_BAND, 0, 4, lowerBand) < 4 ||
        CopyBuffer(handleBand, UPPER_BAND, 0, 4, upperBand) < 4 ||
		CopyBuffer(handleRsi, 0, 0, 5, rsi) < 0) {
        Print("Error copying indicator values : ", GetLastError());
        return;
    }

    validator.loadAccountInfo();
    if (validator.calculateLots() < MINIMUM_LOTS) {
        validator.notEnoughEquity();
        return;
    }

    // bollinger bands values
    double currentUpperBand = upperBand[CURRENT];
    double currentMiddleBand = middleBand[CURRENT];
    double currentLowerBand = lowerBand[CURRENT];
    double prevUpperBand = upperBand[PREVIOUS];
    double prevMiddleBand = middleBand[PREVIOUS];
    double prevLowerBand = lowerBand[PREVIOUS];

	// rsi values
	double currentRsi = rsi[CURRENT];
	double prevRsi = rsi[PREVIOUS];

    // previous candle info
    double prevClosePrice = iClose(_Symbol, ChartPeriod, PREVIOUS);
    double prevOpenPrice = iOpen(_Symbol, ChartPeriod, PREVIOUS);
    double prevHighPrice = iHigh(_Symbol, ChartPeriod, PREVIOUS);
    double prevLowPrice = iLow(_Symbol, ChartPeriod, PREVIOUS);

    // current ask and bid price and mean price values
    double bidPrice = validator.getBid();
    double askPrice = validator.getAsk();
    double currentPrice = (validator.getAsk() + validator.getBid()) / 2.0;

    validator.getCurrentBollingerBandsSlope(lowerBand, middleBand, upperBand,
                                            SlopePeriod);
    validator.getCurrentBollingerBandwidth(currentLowerBand, currentMiddleBand,
                                           currentUpperBand);

    bool boxTradingBuySignal = validator.getBoxTradingBuySignal();
	bool boxTradingSellSignal = validator.getBoxTradingSellSignal();
    bool trendTradingBuySignal = validator.getTrendTradingBuySignal();
    bool trendTradingSellSignal = validator.getTrendTradingSellSignal();

    //--- order buy and sell
    //--- buy order section
    // first buy
    if (!validator.isBuyCloseMiddle && prevClosePrice < prevLowerBand &&
        currentPrice <
            currentLowerBand - validator.calculatePip(FirstBuyPointsGap) &&
        validator.checkActiveBuyPosition()) {
        validator.executeTrade(ORDER_TYPE_BUY, currentPrice,
                               validator.lotsOneTenth, BoxMagicNumber);
        validator.isLowerBroken = true;
    }
    // second buy
    if (!validator.isBuyCloseMiddle && validator.isLowerBroken &&
        !validator.isCrossedAboveLower && !validator.isBuyTouchedMiddle &&
        !validator.isTouchedUpper && currentPrice > currentLowerBand) {
        validator.executeTrade(ORDER_TYPE_BUY, currentPrice,
                               validator.lotsOneHalf, BoxMagicNumber);
        validator.isCrossedAboveLower = true;
    }
    // thrid buy
    if (validator.isBuyCloseMiddle && !validator.isBuyTouchedMiddle &&
        !validator.isTouchedUpper && currentPrice >= currentMiddleBand) {
        validator.executeTrade(ORDER_TYPE_BUY, currentPrice,
                               validator.lotsOneHalf, BoxMagicNumber);
        validator.isBuyTouchedMiddle = true;
    }
    //--- sell order section
    // first sell
    if (!validator.isSellCloseMiddle && prevClosePrice > prevUpperBand &&
        currentPrice >
            currentUpperBand + validator.calculatePip(FirstSellPointsGap) &&
        validator.checkActiveSellPosition()) {
        validator.executeTrade(ORDER_TYPE_SELL, currentPrice,
                               validator.lotsOneTenth, BoxMagicNumber);
        validator.isUpperBroken = true;
    }
    // second sell
    if (!validator.isSellCloseMiddle && validator.isUpperBroken &&
        !validator.isCrossedBelowUpper && !validator.isSellTouchedMiddle &&
        !validator.isTouchedLower && currentPrice < currentUpperBand) {
        validator.executeTrade(ORDER_TYPE_SELL, currentPrice,
                               validator.lotsOneHalf, BoxMagicNumber);
        validator.isCrossedBelowUpper = true;
    }
    // thrid sell
    if (validator.isSellCloseMiddle && !validator.isSellTouchedMiddle &&
        !validator.isTouchedLower && currentPrice <= currentMiddleBand) {
        validator.executeTrade(ORDER_TYPE_SELL, currentPrice,
                               validator.lotsOneHalf, BoxMagicNumber);
        validator.isSellTouchedMiddle = true;
    }
    //---

    //--- take profit and stop loss
    // close buy 50%
    if (validator.isLowerBroken && validator.isCrossedAboveLower &&
        currentPrice + validator.calculatePip(TakeProfitGap) >=
            currentMiddleBand) {
        validator.closePositionHalf(ORDER_TYPE_CLOSE_BY, POSITION_TYPE_BUY);
        validator.isLowerBroken = false;
        validator.isCrossedAboveLower = false;
        validator.isBuyCloseMiddle = true;
    }
    // close all buy positions
    if (validator.isBuyTouchedMiddle && validator.isBuyCloseMiddle &&
        prevClosePrice > prevUpperBand && currentPrice < currentUpperBand) {
        validator.closeAllBuyPosition();
    }
    // buy positions all close -> touched middle and cross below middle line ?
    if (validator.isBuyCloseMiddle && prevClosePrice > prevMiddleBand &&
        currentPrice <
            currentMiddleBand - validator.calculatePip(StopLossGap)) {
        validator.closeAllBuyPosition();
    }
    // close sell 50%
    if (validator.isUpperBroken && validator.isCrossedBelowUpper &&
        currentPrice <=
            currentMiddleBand + validator.calculatePip(TakeProfitGap)) {
        validator.closePositionHalf(ORDER_TYPE_CLOSE_BY, POSITION_TYPE_SELL);
        validator.isUpperBroken = false;
        validator.isCrossedBelowUpper = false;
        validator.isSellCloseMiddle = true;
    }
    // close all sell positions
    if (validator.isSellTouchedMiddle && validator.isSellCloseMiddle &&
        prevClosePrice < prevLowerBand && currentPrice > currentLowerBand) {
        validator.closeAllSellPosition();
    }
    // sell positions all close -> touched middle and cross above middle line ?
    if (validator.isSellCloseMiddle && prevClosePrice < prevMiddleBand &&
        currentPrice >
            currentMiddleBand + validator.calculatePip(StopLossGap)) {
        validator.closeAllSellPosition();
    }
}

/*

What's added in 0.11v

sell positions all close -> touched middle and cross above middle line ?
buy positions all close -> touched middle and cross below middle line ?

*/