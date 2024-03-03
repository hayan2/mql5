//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
//--- 249P
#property copyright "Copyright 2024, Anonymous Ltd."
#property link      "https://github.com/hayan2"
#property version   "1.00"

// #define identifier expression				 - format without parameter
// #define identifier(par1, ... par8) expression - format with parameters
// --- EXAMPLE
// #define ABC 100
// #define PI 3.14
// #define COMPANY_NAME "MetaQuotes Software Corp."
/*
void ShowCopyright() {
	Print("Copyright 2001-2009, ", COMPANY_NAME);
	Print("https://www.metaquotes.net");
}
*/

#define TWO 2
#define THREE 3
#define INCOMPLETE TWO + THREE
#define COMPLETE (TWO + THREE)

void OnStart() {
	Print("2 + 3 * 2 = ", INCOMPLETE * 2);
	Print("(2 + 3) * 2 = ", COMPLETE * 2);
}