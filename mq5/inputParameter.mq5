//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
//--- 237P
#property copyright "Copyright 2024, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "1.00"

input group "signal";
input int extBBPeriod = 20;
input double extBBDeviation = 2.0;
input ENUM_TIMEFRAMES extSignalTF = PERIOD_H1;

input group "trends";
input int extMAPeriod = 13;
input ENUM_TIMEFRAMES extTrendTF = PERIOD_H1;

input group "exit rules";
input bool extUseSL = true;
input int extSLPoints = 50;
input bool extUseTP = false;
input int extTPPoints = 100;
input bool extUseTS = true;
input int extTSPoints = 30;

input group "money management";
sinput double extInitialLot = 0.1;
input bool extUseAutoLot = true;

input group "support";
sinput int extMagicNumber = 123456;
sinput bool extDebugMessage = true;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() { return (INIT_SUCCEEDED); }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {}
