//+------------------------------------------------------------------+
//|                                                datetime-type.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//---
//---
    return(INIT_SUCCEEDED);
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
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() {
    datetime NY = D'2015.01.01 00:00';
    datetime d1 = D'1980.07.19 12:30:27';
    datetime d2 = D'19.07.1980 12:30:27';
    datetime d3 = D'19.07.1980 12';
    datetime d4 = D'01.01.2004';
    datetime compilation_date = __DATE__;
    datetime compilation_date_time = __DATETIME__;
    datetime compilation_time = __DATETIME__-__DATE__;
    datetime warning1 = D'12:30:27';
    datetime warning2 = D'';
    
    Print("NY = D\'2015.01.01 00:00\' ", NY);
    
    Print("d1 = D\'1980.07.19 12:30:27\' ", d1);
    Print("d2 = D\'19.07.1980 12:30:27\' ", d2);
    Print("d3 = D\'19.07.1980 12\' ", d3);
    Print("d4 = D\'01.01.2004\' ", d4);
    Print("compilation_date = __DATE__ ", compilation_date);
    Print("compilation_date_time = __DATETIME__ ", compilation_date_time);
    Print("compilation_time = __DATETIME__-__DATE__ ", compilation_time);
    Print("warning1 = D\'12:30:27\' ", warning1);    
    Print("warning2 = D\'\' ", warning2);
}
//+------------------------------------------------------------------+
