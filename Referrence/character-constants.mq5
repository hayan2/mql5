//+------------------------------------------------------------------+
//|                                          character-constants.mq5 |
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
    int a = 0xAE; // the code of ® corresponds to the '\xAE' literal
    int b = 0x24; // the code of $ corresponds to the '\x24' literal
    int c = 0xA9; // the code of © corresponds to the '\xA9' literal
    int d = 0x263A; // the code of ☺ corresponds to the '\x263A' literal
//--- show values
    Print(a, b, c, d);
//--- add a character to the string
    string test = "";
    StringSetCharacter(test, 0, a);
    Print(test);
//--- replace a character in a string
    StringSetCharacter(test, 0, b);
    Print(test);
//--- replace a character in a string
    StringSetCharacter(test, 0, c);
    Print(test);
//--- replace a character in a string
    StringSetCharacter(test, 0, d);
    Print(test);
//--- codes of suits
    int a1 = 0x2660;
    int b1 = 0x2661;
    int c1 = 0x2662;
    int d1 = 0x2663;
//--- add a character of spades
    StringSetCharacter(test, 1, a1);
    Print(test);
//--- add a character of hearts
    StringSetCharacter(test, 2, b1);
    Print(test);
//--- add a character of diamonds
    StringSetCharacter(test, 3, c1);
    Print(test);
//--- add a character of clubs
    StringSetCharacter(test, 4, d1);
    Print(test);
//--- Example of character literals in a string
    test = "Queen\x2660Ace\x2662";
    printf("%s", test);
}
//+------------------------------------------------------------------+
