//+------------------------------------------------------------------+
//|                                   Copyright 2025, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "1.00"

#define CURRENT 0
#define PREVIOUS 1
#define ONE_HALF 0.5
#define ONE_TENTH 0.1

input group "---------- General ----------";
input ulong MagicNumber = 2147483647;
input ENUM_TIMEFRAMES ChartPeriod = PERIOD_H1;
input group "---------- Bollinger bands variable ----------";
input int BandsPeriod = 20;
input int BandsShift = 0;
input double Deviation = 2.0;
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;
input group "---------- Risk and money management ----------";
input double Lots = 0.01;
input bool HedgeMode = false;
input double TakeProfitPercent = 0.05;
input double MarginPercent = 0.1;
input double trueIsBalanceFalseIsEquity = false;

#include <Trade/SymbolInfo.mqh>
#include <Trade/Trade.mqh>

CTrade trade;
CSymbolInfo symbolInfo;
CPositionInfo positionInfo;
CHistoryOrderInfo historyOrderInfo;
CDealInfo dealInfo;

class TradeValidator {
   private:
    // buy position variable
    bool isLowerBroken;
    bool isCrossedAboveLower;
	bool isBuyTouchedMiddle;
    bool isTouchedUpper;
    // sell position variable
    bool isUpperBroken;
    bool isCrossedBelowUpper;
	bool isSellTouchedMiddle;
    bool isTouchedLower;
	double balance;
	double equity;
	// 10%
	double lotsOneTenth;
	// 50%
	double lotsOneHalf;

   public:
    TradeValidator();
    ~TradeValidator() {};

    void refresh();
	bool loadAccountInfo();
	void calculateLots(string symbol);

	bool checkActiveBuyPosition();
	bool checkActiveSellPosition();

	// buy position method
    void buyLowerBroken();
    void buyCrossedAboveLower();
    void buyTouchedMiddle();
    void buyTouchedUpper();

	// sell position method
    void sellUpperBroken();
    void sellCrossedBelowUpper();
    void sellTouchedMiddle();
    void sellTouchedLower();

	// close all position
    void closeAllBuyPosition();
    void closeAllSellPosition();

	double getAccountBalance() { return balance; }
	double getAccountEquity() { return equity; }
};

TradeValidator::TradeValidator() {
    isLowerBroken = false;
    isCrossedAboveLower = false;
	isBuyTouchedMiddle = false;
    isTouchedUpper = false;
    isUpperBroken = false;
    isCrossedBelowUpper = false;
	isSellTouchedMiddle = false;
    isTouchedLower = false;
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

void TradeValidator::calculateLots(string symbol) {
	double contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
	double equityPerContract = equity / contractSize;
	double balancePerContract = balance / contractSize;

	if (trueIsBalanceFalseIsEquity) {
		lotsOneHalf = balancePerContract / 0.5;
		lotsOneTenth = balancePerContract / 0.1;
	}
	else {
		lotsOneHalf = equityPerContract / 0.5;
		lotsOneTenth = equityPerContract / 0.1;
	}
}

// buy
void TradeValidator::buyLowerBroken() {
	isLowerBroken = true;
}

void TradeValidator::buyCrossedAboveLower() {
	isCrossedAboveLower = true;
}

void TradeValidator::buyTouchedMiddle() {
	isBuyTouchedMiddle = true;
}

void TradeValidator::buyTouchedUpper() {
	isTouchedUpper = true;
}

// sell
void TradeValidator::sellUpperBroken() {
	isUpperBroken = true;
}

void TradeValidator::sellCrossedBelowUpper() {
	isCrossedBelowUpper = true;
}

void TradeValidator::sellTouchedMiddle() {
	isSellTouchedMiddle = true;
}

void TradeValidator::sellTouchedLower() {
	isTouchedLower = true;
}

bool TradeValidator::checkActiveBuyPosition() {
	return (isLowerBroken || isCrossedAboveLower || isBuyTouchedMiddle || isTouchedUpper);
}

bool TradeValidator::checkActiveSellPosition() {
	return (isUpperBroken || isCrossedBelowUpper || isSellTouchedMiddle || isTouchedLower);
}

double upperBand[], middleBand[], lowerBand[];
int handleBand;

int OnInit() {
    handleBand = iBands(_Symbol, ChartPeriod, BandsPeriod, BandsShift,
                        Deviation, AppliedPrice);

    if (handleBand == INVALID_HANDLE) {
        Print("Failed to create Bollinger Bands");
        return INIT_FAILED;
    }

    //---
    if (HedgeMode) trade.SetMarginMode();
    trade.SetExpertMagicNumber(MagicNumber);

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
    // get bollinger bands middle, lower, upper line.
    CopyBuffer(handleBand, BASE_LINE, 0, 3, middleBand);
    CopyBuffer(handleBand, LOWER_BAND, 0, 3, lowerBand);
    CopyBuffer(handleBand, UPPER_BAND, 0, 3, upperBand);

    // bollinger bands values
    double currentUpperBand = upperBand[CURRENT];
    double currentMiddleBand = middleBand[CURRENT];
    double currentLowerBand = lowerBand[CURRENT];
    double prevUpperBand = upperBand[PREVIOUS];
    double prevMiddleBand = middleBand[PREVIOUS];
    double prevLowerBand = lowerBand[PREVIOUS];

    // current ask and bid price
    double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double bidPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    // previous candle info
    double prevClosePrice = iClose(_Symbol, ChartPeriod, PREVIOUS);
    double prevOpenPrice = iOpen(_Symbol, ChartPeriod, PREVIOUS);
    double prevHighPrice = iHigh(_Symbol, ChartPeriod, PREVIOUS);
    double prevLowPrice = iLow(_Symbol, ChartPeriod, PREVIOUS);
}

void sellOrder() { return; }

void buyOrder() { return; }