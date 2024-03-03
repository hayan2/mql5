//+------------------------------------------------------------------+
//|                                   Copyright 2024, Anonymous Ltd. |
//|                                        https://github.com/hayan2 |
//+------------------------------------------------------------------+
//--- 242P

#property copyright "Copyright 2024, Anonymous Ltd."
#property link "https://github.com/hayan2"
#property version "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

struct str3 {
    int lowPart;
    int highPart;
};

struct str10 {
    str3 a3;
    double d1[10];
    int i3;
};

void OnStart() {
    str10 s10_1 = {
        {1, 0}, {1.0, 2.1, 3.2, 4.4, 5.3, 6.1, 7.8, 8.7, 9.2, 10.0}, 100};
    str10 s10_2 = {{1, 0}, {0}, 100};
    str10 s10_3 = {{1, 0}, {1.0}};

    Print("1. s10_1.d1[5] = ", s10_1.d1[5]);
    Print("2. s10_2.d1[5] = ", s10_2.d1[5]);
    Print("3. s10_3.d1[5] = ", s10_3.d1[5]);
    Print("4. s10_3.d1[0] = ", s10_3.d1[0]);
    Print("5. s10_3.a3 = ", s10_1.i3);
}