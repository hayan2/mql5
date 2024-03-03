//+------------------------------------------------------------------+
//|                                                      swapday.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   
  }
//+------------------------------------------------------------------+


//--- days

enum dayOfWeek {
	S = 0,
	M = 1,
	T = 2,
	W = 3,
	Th = 4,
	Fr = 5,
	St = 6,
};

input dayOfWeek swapday = W;