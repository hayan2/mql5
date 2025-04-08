//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "0.20"

input group "---------- Trade Validation ----------";
input int MinimumBars = 100;
input int TradeMarginPercent = 10;
input group "---------- Bollinger Bands variable ----------";
input int BandsPeriod = 30;
input int BandsShift = 0;
input double Deviation = 2.0;
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;
input group "---------- Relative Strength Index variable ----------";
input int RsiPeriod = 13;
input int SellConditionRsi = 70;
input int BuyConditionRsi = 30;

const int COUNT_BANDS = 3;
const int COUNT_RSI = 3;
const int CURRENT = 0;
const int PREVIOUS = 1;
const double MINIMUM_LOTS = 0.01;

enum ENUM_ORDER_FILLING {
    Fire_or_kill = 0,
    Immediate_or_cancel = 1,
    Order_filling_return = 2
};

#include <Trade/SymbolInfo.mqh>
#include <Trade/Trade.mqh>

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

    bool loadSymbolInfo();
    void logValidationInfo();

   public:
    TradeValidator();
    ~TradeValidator() {};

	bool loadSymbolInfo();
    bool loadAccountInfo();
    void notEnoughEquity() { Print("Not enough equity."); }
	void notEnoughBalance() { Print("Not enough balance."); }

    bool checkHistory();
    bool isInTester() { return MQLInfoInteger(MQL_TESTER) != 0; }
	
	bool calculateLots();

    bool hasOpenPositions() { return PositionsTotal() > 0; }

    bool executeTrade(ENUM_ORDER_TYPE type, double currentPrice, double volume,
                      ulong magic);
    double validateStopLoss();
    double validateTakeProfit();

    double getBalance() { return balance; }
    double getEquity() { return equity; }
    string getSymbol() { return symbol; }
    double getLots() { return lots; }

    double getBid() { return SymbolInfoDouble(symbol, SYMBOL_BID); }
    double getAsk() { return SymbolInfoDouble(symbol, SYMBOL_ASK); }
};

TradeValidator::TradeValidator() {
	symbol = _Symbol;
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

bool TradeValidator::loadAccountInfo() {
	balance = AccountInfoDouble(ACCOUNT_BALANCE);
	equity = AccountInfoDouble(ACCOUNT_EQUITY);
}

bool TradeValidator::checkHistory() {
	// check if enough bars are available for the current symbol/timeframe
    if (Bars(symbol, PERIOD_CURRENT) < MinimumBars) {
        LogValidationInfo("WARNING: Not enough historical data. Required: " +
                          IntegerToString(MinimumBars) + ", Available: " +
                          IntegerToString(Bars(symbol, PERIOD_CURRENT)));
        return false;
    }

    return true;
}

bool TradeValidator::calculateLots() {
	double contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
	lots = MathCeil(balance / contractSize * (TradeMarginPercent / 100));

	if (lots < minLots) return false;
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
    // load indicators
    handleBand = iBands(_Symbol, PERIOD_CURRENT, BandsPeriod, BandsShift,
                        Deviation, AppliedPrice);
    handleRsi = iRSI(_Symbol, PERIOD_CURRENT, RsiPeriod, AppliedPrice);

    if (handleBand == INVALID_HANDLE || handleRsi == INVALID_HANDLE) {
        Print("Error loading indicators : ", GetLastError());
        return INIT_FAILED;
    }

    // check if enough historical data is available
    if (!validator.checkHistory(handleBand + handleRsi)) {
        Print("Not enough historical data for indicator calculation.");
        // continue in validation mode, otherwise fail
        // if (!validator.isInTester()) return INIT_FAILED;
    }

    Print("Mean Reversion Trend EA initialized. Symbol: ", _Symbol,
          ", Timeframe: ", EnumToString(Period()));

    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {}

void OnTick() {
    double upperBand[], middleBand[], lowerBand[];
    double rsi[];

    ArraySetAsSeries(upperBand, true);
    ArraySetAsSeries(middleBand, true);
    ArraySetAsSeries(lowerBand, true);
    ArraySetAsSeries(rsi, true);

    if (CopyBuffer(handleBand, BASE_LINE, 0, COUNT_BANDS, middleBand) <
            COUNT_BANDS ||
        CopyBuffer(handleBand, LOWER_BAND, 0, COUNT_BANDS, lowerBand) <
            COUNT_BANDS ||
        CopyBuffer(handleBand, UPPER_BAND, 0, COUNT_BANDS, upperBand) <
            COUNT_BANDS ||
        CopyBuffer(handleRsi, 0, 0, COUNT_RSI, rsi) < COUNT_RSI) {
        Print("Error copying indicators values : ", GetLastError());
        return;
    }

    if (!validator.loadAccountInfo()) validator.notEnoughEquity();
	if (!validator.calculateLots()) validator.notEnoughBalance();

    double currentMiddleBand = middleBand[CURRENT];
    double currentUpperBand = upperBand[CURRENT];
    double currentLowerBand = lowerBand[CURRENT];
    double currentRSI = rsi[CURRENT];

    double prevMiddleBand = middleBand[PREVIOUS];
    double prevUpperBand = upperBand[PREVIOUS];
    double prevLowerBand = lowerBand[PREVIOUS];
    double prevRsi = rsi[PREVIOUS];

    double currentPrice = (validator.getAsk() + validator.getBid()) / 2;

    double prevClosePrice =
        iClose(validator.getSymbol(), PERIOD_CURRENT, PREVIOUS);
    double prevOpenPrice =
        iOpen(validator.getSymbol(), PERIOD_CURRENT, PREVIOUS);
    double prevHighPrice =
        iHigh(validator.getSymbol(), PERIOD_CURRENT, PREVIOUS);
    double prevLowPrice = iLow(validator.getSymbol(), PERIOD_CURRENT, PREVIOUS);

    bool buySignal =
        prevLowerBand > prevClosePrice && prevRsi < BuyConditionRsi;
    bool sellSignal =
        prevUpperBand < prevClosePrice && prevRsi > SellConditionRsi;
}