//+------------------------------------------------------------------+
//|                                               Display prices.mq5 |
//|                         Copyright © 2018-2020, Vladimir Karputov |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018-2020, Vladimir Karputov"
#property version "1.001"
//---
#include <Trade\SymbolInfo.mqh>
//---
CSymbolInfo m_symbol;  // object of CSymbolInfo class
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    //---
    ResetLastError();
    if (!m_symbol.Name(Symbol()))  // sets symbol name
    {
        Print(__FILE__, " ", __FUNCTION__, ", ERROR: CSymbolInfo.Name");
        return (INIT_FAILED);
    }
    RefreshRates();
    //---
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    //---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    //---
    if (!RefreshRates()) return;
    Comment("Ask: ", DoubleToString(m_symbol.Ask(), m_symbol.Digits()), "\n",
            "Bid: ", DoubleToString(m_symbol.Bid(), m_symbol.Digits()));
}
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates() {
    //--- refresh rates
    if (!m_symbol.RefreshRates()) {
        Print(__FILE__, " ", __FUNCTION__, ", ERROR: ", "RefreshRates error");
        return (false);
    }
    //--- protection against the return value of "zero"
    if (m_symbol.Ask() == 0 || m_symbol.Bid() == 0) {
        Print(__FILE__, " ", __FUNCTION__,
              ", ERROR: ", "Ask == 0.0 OR Bid == 0.0");
        return (false);
    }
    //---
    return (true);
}
//+------------------------------------------------------------------+