//+------------------------------------------------------------------+
//|                                               EA_MTSupporter.mq4 |
//|                                         Manual Trading Supporter |
//|                                                  공부할때 참고해보게 |
//+------------------------------------------------------------------+
#property copyright "목포나무아래"
#property strict

#define  MAX_ORDER 50

//속성창
input string str_PropertyTitle1 = "== 진입(청산) 조건 ==";//== 진입(청산) 조건 ==
input double db_Lots = 0.1;//계약수
input int n_StopLoss = 100;//손절폭
input int n_TakeProfit = 100;//익절폭
input ulong n_Slippage = 5;//슬리피지
input ulong n_MagicNumber = 0;//매직넘버
input bool b_MagicNumberCheck = true;//매직넘버 체크

input string str_PropertyTitle2 = "== 알람 ==";//== 알람 ==
input bool b_Sound = true;//소리
input string str_OK = "ok.wav";
input string str_Error = "timeout.wav";
input string str_PropertyTitle5 = "== 기    타 ==";//== 기     타 ==
input bool b_SpreadLineShow = true; //스프레드(라인) 표시

input string str_PropertyTitle3 = "== 버튼 색상 ==";//== 버튼 색상 ==
input color clr_Buy = clrTomato;//매수
input color clr_Sell = clrRoyalBlue;//매도
input color clr_CloseCancel = clrGray;//청산(취소)
input color clr_Warning = clrIndianRed;//주의
input color clr_Other = clrForestGreen;//기타

input color clr_BasicText = clrWhite;//글자
input color clr_EditText = clrBlack;//에디트 글자
input color clr_Edit = clrWhite;//에디트배경
input color clr_EditLock = clrDarkGray;//에디트배경Lock


//주문Total
int n_OrdersTotal_Symbol = 0; //특정상품의 모든 주문 갯수
int n_PreOrdersTotal_Symbol = 0;

string str_Font = "Arial";
int n_FontSize = 11;

//시장가
string str_Button_MarketBuy = "str_Button_MarketBuy" ;
bool     b_Button_MarketBuy = false;
string str_Button_MarketSell = "str_Button_MarketSell" ;
bool     b_Button_MarketSell = false;
string str_Button_CloseAll = "str_Button_CloseAll" ;
bool     b_Button_CloseAll = false;

//지정가
string str_Button_PendingBuy = "str_Button_PendingBuy" ;
bool     b_Button_PendingBuy = false;
string str_Button_PendingSell = "str_Button_PendingSell" ;
bool     b_Button_PendingSell = false;
string str_Button_CancelAll = "str_Button_CancelAll" ;
bool     b_Button_CancelAll = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ask() {
    return(SymbolInfoDouble(Symbol(), SYMBOL_ASK));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Bid() {
    return(SymbolInfoDouble(Symbol(), SYMBOL_BID));
}

string strBuy = "buy";
string strSell = "sell";
string strBuyLimit = "buy limit";
string strSellLimit = "sell limit";
string strBuyStop = "buy stop";
string strSellStop = "sell stop";

int n_X = 100;
int n_Y = 100;
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    //시장가매수 버튼생성
    ButtonCreate(0, str_Button_MarketBuy,  0, n_X + 100, n_Y + 100, 90, 20, CORNER_LEFT_UPPER, "시장가 매수", str_Font, n_FontSize, clr_BasicText, clr_Buy,  clrNONE, b_Button_MarketBuy, false, false, true);
    //시장가매도 버튼생성
    ButtonCreate(0, str_Button_MarketSell, 0, n_X + 200, n_Y + 100, 90, 20, CORNER_LEFT_UPPER, "시장가 매도", str_Font, n_FontSize, clr_BasicText, clr_Sell, clrNONE, b_Button_MarketSell, false, false, true);
    //모두청산
    ButtonCreate(0, str_Button_CloseAll,   0, n_X + 100, n_Y + 130, 190, 20, CORNER_LEFT_UPPER, "모두 청산", str_Font, n_FontSize, clr_BasicText, clr_CloseCancel, clrNONE, b_Button_CloseAll, false, false, true);
    //시장가매수 버튼생성
    ButtonCreate(0, str_Button_PendingBuy,  0, n_X + 300, n_Y + 100, 90, 20, CORNER_LEFT_UPPER, "지정가 매수", str_Font, n_FontSize, clr_BasicText, clr_Buy,  clrNONE, b_Button_PendingBuy, false, false, true);
    //시장가매도 버튼생성
    ButtonCreate(0, str_Button_PendingSell, 0, n_X + 400, n_Y + 100, 90, 20, CORNER_LEFT_UPPER, "지정가 매도", str_Font, n_FontSize, clr_BasicText, clr_Sell, clrNONE, b_Button_PendingSell, false, false, true);
    //모두취소
    ButtonCreate(0, str_Button_CancelAll,   0, n_X + 300, n_Y + 130, 190, 20, CORNER_LEFT_UPPER, "모두 취소", str_Font, n_FontSize, clr_BasicText, clr_CloseCancel, clrNONE, b_Button_CancelAll, false, false, true);
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
ulong n_PositionTicket = 0;
ulong n_Ticket = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
    //시장가매수
    if(IsButtonDown(str_Button_MarketBuy)) {
        MarketBuy(db_Lots, n_StopLoss, n_TakeProfit);
        //사용자에 의해서 눌려진 버튼을 UP 시킨다.
        SetButtonUp(str_Button_MarketBuy, b_Button_MarketBuy);
    }
    //시장가매도
    if(IsButtonDown(str_Button_MarketSell)) {
        MarketSell(db_Lots, n_StopLoss, n_TakeProfit);
        //사용자에 의해서 눌려진 버튼을 UP 시킨다.
        SetButtonUp(str_Button_MarketSell, b_Button_MarketSell);
    }
    //포지션모두 청산
    if(IsButtonDown(str_Button_CloseAll)) {
        CloseAll();
        //사용자에 의해서 눌려진 버튼을 UP 시킨다.
        SetButtonUp(str_Button_CloseAll, b_Button_CloseAll);
    }
    //지정가매수
    if(IsButtonDown(str_Button_PendingBuy)) {
        PendingBuy(Ask() + 1000 * Point(), db_Lots, n_StopLoss, n_TakeProfit);
        //사용자에 의해서 눌려진 버튼을 UP 시킨다.
        SetButtonUp(str_Button_PendingBuy, b_Button_PendingBuy);
    }
    //지정가매도
    if(IsButtonDown(str_Button_PendingSell)) {
        PendingSell(Bid() - 1000 * Point(), db_Lots, n_StopLoss, n_TakeProfit);
        //사용자에 의해서 눌려진 버튼을 UP 시킨다.
        SetButtonUp(str_Button_PendingSell, b_Button_PendingSell);
    }
    //지정가 모두 취소
    if(IsButtonDown(str_Button_CancelAll)) {
        CancelAll();
        //사용자에 의해서 눌려진 버튼을 UP 시킨다.
        SetButtonUp(str_Button_CancelAll, b_Button_CancelAll);
    }
    Comment("시장가 ", TotalOpensAll(), " 지정가 ", TotalPendingAll(), " 시장가+지정가 ", OrdersTotal_Symbol());
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong GetMagicNumber(bool bMagicNumberCheck, ulong nOrderMagicNumber) {
    if(bMagicNumberCheck == true)
        return(n_MagicNumber);
    else
        return(nOrderMagicNumber); //인자값으로 넘겨 받은 magic 값을 되돌려줘서 항상 true가 되도록 한다.
}

//+------------------------------------------------------------------+
//| 주문 함수
//+------------------------------------------------------------------+
int TotalOpensAll() {
    int nTotalOpens = 0;
    int nOrdersTotal = PositionsTotal();
    for(int nCnt = 0 ; nCnt < nOrdersTotal ; nCnt++) {
        ulong  order_ticket = PositionGetTicket(nCnt);
        if(PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == GetMagicNumber(b_MagicNumberCheck, PositionGetInteger(POSITION_MAGIC)))nTotalOpens++ ;
    }
    return(nTotalOpens);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalOpensBuy() {
    int nTotalOpens = 0;
    int nOrdersTotal = PositionsTotal();
    for(int nCnt = 0 ; nCnt < nOrdersTotal ; nCnt++) {
        ulong  order_ticket = PositionGetTicket(nCnt);
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == GetMagicNumber(b_MagicNumberCheck, PositionGetInteger(POSITION_MAGIC)))nTotalOpens++ ;
    }
    return(nTotalOpens);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalOpensSell() {
    int nTotalOpens = 0;
    int nOrdersTotal = PositionsTotal();
    for(int nCnt = 0 ; nCnt < nOrdersTotal ; nCnt++) {
        ulong  order_ticket = PositionGetTicket(nCnt);
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetString(POSITION_SYMBOL) == Symbol() && PositionGetInteger(POSITION_MAGIC) == GetMagicNumber(b_MagicNumberCheck, PositionGetInteger(POSITION_MAGIC)))nTotalOpens++ ;
    }
    return(nTotalOpens);
}

//특정상품의 주문갯수(매직넘버 포함)
int TotalPendingAll() {
    int nOrdersTotal_Symbol = 0;
    int nOrdersTotal = OrdersTotal();
    for(int nCnt = nOrdersTotal - 1; nCnt >= 0; nCnt--) {
        ulong  order_ticket = OrderGetTicket(nCnt); //OrderGetTicket()함수는 자동선택 기능이 있다.
        if(OrderGetString(ORDER_SYMBOL) == Symbol() && OrderGetInteger(ORDER_MAGIC) == GetMagicNumber(b_MagicNumberCheck, OrderGetInteger(ORDER_MAGIC)))nOrdersTotal_Symbol++ ;
    }
    return(nOrdersTotal_Symbol);
}

//특정상품의 주문갯수(매직넘버 포함)
int OrdersTotal_Symbol() {
    return(TotalOpensAll() + TotalPendingAll());
}

//시장가 매수
bool MarketBuy(double dbLots, int nStopLoss, int nTakeProfit) {
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
//--- parameters of request
    request.action   = TRADE_ACTION_DEAL;                    // type of trade operation
    request.symbol   = Symbol();                             // symbol
    request.volume   = dbLots;                               // volume of 0.1 lot
    request.type     = ORDER_TYPE_BUY;                       // order type
    request.price    = Ask(); // price for opening
    request.deviation = n_Slippage;                                   // allowed deviation from the price
    request.magic    = n_MagicNumber;                         // MagicNumber of the order
    if(nStopLoss   > 0) request.sl = request.price - nStopLoss * Point();
    if(nTakeProfit > 0) request.tp = request.price + nTakeProfit * Point();
//--- send the request
    if(!OrderSend(request, result)) {
        Print("OrderSend(buy) error ", GetLastError());
        if(b_Sound)PlaySound(str_Error);
        return(false);
    }
    if(b_Sound)PlaySound(str_OK);
    return(true);
}

//시장가 매도
bool MarketSell(double dbLots, int nStopLoss, int nTakeProfit) {
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
//--- parameters of request
    request.action   = TRADE_ACTION_DEAL;                    // type of trade operation
    request.symbol   = Symbol();                             // symbol
    request.volume   = dbLots;                               // volume of 0.1 lot
    request.type     = ORDER_TYPE_SELL;                       // order type
    request.price    = Bid(); // price for opening
    request.deviation = n_Slippage;                                   // allowed deviation from the price
    request.magic    = n_MagicNumber;                         // MagicNumber of the order
    if(nStopLoss   > 0) request.sl = request.price + nStopLoss * Point();
    if(nTakeProfit > 0) request.tp = request.price - nTakeProfit * Point();
//--- send the request
    if(!OrderSend(request, result)) {
        Print("OrderSend(sell) error ", GetLastError());
        if(b_Sound)PlaySound(str_Error);
        return(false);
    }
    if(b_Sound)PlaySound(str_OK);
    return(true);
}
//Modify_Ticket
//주문 수정
bool ModifyPosition_Ticket(ulong nTicket, int nStopLoss, int nTakeProfit) {
    string strError = "OrderModify";
    double dbStopLoss = 0, dbTakeProfit = 0 ;
    bool bOrderSelect = false; //이변수는 Warning을 없애기 위해서만 사용된다.
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
    if(!PositionSelectByTicket(nTicket))return(false);
    double dbPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); // type of the position
    if(PositionGetString(POSITION_SYMBOL) != Symbol() || PositionGetInteger(POSITION_MAGIC) != GetMagicNumber(b_MagicNumberCheck, PositionGetInteger(POSITION_MAGIC))) {
        Print("수정 조건 아님 ==> order_symbol!=Symbol() || magic!=GetMagicNumber(b_MagicNumberCheck,magic)");
        if(b_Sound)PlaySound(str_Error);
        return(false);
    }
    strError += "(" + OrdertypeToString(type) + ") error ";
    request.action = TRADE_ACTION_SLTP;                         // type of trade operation
    request.position = nTicket; // ticket of the position
    request.symbol = PositionGetString(POSITION_SYMBOL); // symbol
    if(type == POSITION_TYPE_BUY) {
        if(nStopLoss   > 0) request.sl = dbPrice - nStopLoss * Point();
        if(nTakeProfit > 0) request.tp = dbPrice + nTakeProfit * Point();
    } else {
        if(nStopLoss   > 0) request.sl = dbPrice + nStopLoss * Point();
        if(nTakeProfit > 0) request.tp = dbPrice - nTakeProfit * Point();
    }
    request.magic = PositionGetInteger(POSITION_MAGIC);
    if(!OrderSend(request, result)) {
        Print(strError, GetLastError(), " #", nTicket);
        if(b_Sound)PlaySound(str_Error);
        return(false);
    }
    if(b_Sound)PlaySound(str_OK);
    return(true);
}

//시장가 청산
bool Close_Ticket(ulong nTicket, double dbLots) {
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
    int nOrderType = 0;
    double dbClosePrice = 0;
    double dbCloseLots = 0;
    bool bClose = false;
    bool bOrderSelect = false; //이변수는 Warning을 없애기 위해서만 사용된다.
    if(!PositionSelectByTicket(nTicket))return(false);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position
    if(PositionGetString(POSITION_SYMBOL) != Symbol() || PositionGetInteger(POSITION_MAGIC) != GetMagicNumber(b_MagicNumberCheck, PositionGetInteger(POSITION_MAGIC))) {
        Print("청산 조건이 아니다 order_symbol!=Symbol() || magic!=GetMagicNumber(b_MagicNumberCheck,magic) || nOrderType > ORDER_TYPE_SELL");
        if(b_Sound) PlaySound(str_Error);
        return(false);
    }
    //--- setting the operation parameters
    request.action   = TRADE_ACTION_DEAL;       // type of trade operation
    request.position = nTicket;         // ticket of the position
    request.symbol   = PositionGetString(POSITION_SYMBOL);         // symbol
    request.volume   = dbLots;                  // volume of the position
    request.deviation = n_Slippage;                      // allowed deviation from the price
    request.magic    = n_MagicNumber;            // MagicNumber of the position
    if(type == POSITION_TYPE_BUY) {
        request.price = Bid();
        request.type = ORDER_TYPE_SELL;
    } else {
        request.price = Ask();
        request.type = ORDER_TYPE_BUY;
    }
    if( dbLots < PositionGetDouble(POSITION_VOLUME)) request.volume = dbLots;
    else request.volume = PositionGetDouble(POSITION_VOLUME);
    if(!OrderSend(request, result)) {
        if( type == POSITION_TYPE_BUY)
            Print("OrderClose(buy) error ", GetLastError(), " #", nTicket);
        else
            Print("OrderClose(sell) error ", GetLastError(), " #", nTicket);
        if(b_Sound) PlaySound(str_Error);
        return(false);
    }
    if(b_Sound) PlaySound(str_OK);
    return(true);
}

// 청산(매수포지션만)
bool CloseBuy(double dbLots) {
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
    bool bCloseAll = false;
    bool bClose = false;
    double closeLot; // 매회 청산 수량
    double sumLot; // 청산해야할 수량, 0이 될때까지 청산 for문을 돌린다.
    sumLot = dbLots;
    int total = PositionsTotal();
    if(sumLot == 0) return(false);
    for(int cnt = total - 1; cnt >= 0; cnt--) {
        //--- parameters of the order
        ulong  order_ticket = PositionGetTicket(cnt);
        string order_symbol = PositionGetString(POSITION_SYMBOL);                         // symbol
        ulong  magic = PositionGetInteger(POSITION_MAGIC);                                // MagicNumber of the position
        double OrderLots = PositionGetDouble(POSITION_VOLUME);                               // volume of the position
        ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position
        if(order_symbol == Symbol() && magic == GetMagicNumber(b_MagicNumberCheck, magic)) {
            if(type == POSITION_TYPE_BUY) {
                if( OrderLots >= sumLot ) {
                    closeLot = sumLot;
                    sumLot = 0;
                } else {
                    closeLot = OrderLots ;
                    sumLot = sumLot - closeLot;
                }
                //--- zeroing the request and result values
                ZeroMemory(request);
                ZeroMemory(result);
                //--- setting the operation parameters
                request.action   = TRADE_ACTION_DEAL;       // type of trade operation
                request.position = order_ticket;         // ticket of the position
                request.symbol   = order_symbol;         // symbol
                request.volume   = closeLot;                  // volume of the position
                request.deviation = n_Slippage;                      // allowed deviation from the price
                request.magic    = magic;            // MagicNumber of the position
                //--- set the price and order type depending on the position type
                request.price = Bid();
                request.type = ORDER_TYPE_SELL;
                if(!OrderSend(request, result)) {
                    Print("OrderClose(Buy) error ", GetLastError(), " #", order_ticket);
                    bCloseAll = false;
                }
            }
            if(sumLot == 0) {
                if(b_Sound)PlaySound(str_OK);
                return(true);
            }
        }
    }
    if(b_Sound && !bCloseAll)PlaySound(str_Error);
    return(bCloseAll);
}

// 청산(매도포지션만)
bool CloseSell(double dbLots) {
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
    bool bCloseAll = false;
    bool bClose = false;
    double closeLot; // 매회 청산 수량
    double sumLot; // 청산해야할 수량, 0이 될때까지 청산 for문을 돌린다.
    sumLot = dbLots;
    int total = PositionsTotal();
    if(sumLot == 0) return(false);
    for(int cnt = total - 1; cnt >= 0; cnt--) {
        //--- parameters of the order
        ulong  order_ticket = PositionGetTicket(cnt);
        string order_symbol = PositionGetString(POSITION_SYMBOL);                         // symbol
        ulong  magic = PositionGetInteger(POSITION_MAGIC);                                // MagicNumber of the position
        double OrderLots = PositionGetDouble(POSITION_VOLUME);                               // volume of the position
        ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position
        if(order_symbol == Symbol() && magic == GetMagicNumber(b_MagicNumberCheck, magic)) {
            if(type == POSITION_TYPE_SELL) {
                if( OrderLots >= sumLot ) {
                    closeLot = sumLot;
                    sumLot = 0;
                } else {
                    closeLot = OrderLots ;
                    sumLot = sumLot - closeLot;
                }
                //--- zeroing the request and result values
                ZeroMemory(request);
                ZeroMemory(result);
                //--- setting the operation parameters
                request.action   = TRADE_ACTION_DEAL;       // type of trade operation
                request.position = order_ticket;         // ticket of the position
                request.symbol   = order_symbol;         // symbol
                request.volume   = closeLot;                  // volume of the position
                request.deviation = n_Slippage;                      // allowed deviation from the price
                request.magic    = magic;            // MagicNumber of the position
                //--- set the price and order type depending on the position type
                request.price = Ask();
                request.type = ORDER_TYPE_BUY;
                if(!OrderSend(request, result)) {
                    Print("OrderClose(Sell) error ", GetLastError(), " #", order_ticket);
                    bCloseAll = false;
                }
            }
            if(sumLot == 0) {
                if(b_Sound)PlaySound(str_OK);
                return(true);
            }
        }
    }
    if(b_Sound && !bCloseAll)PlaySound(str_Error);
    return(bCloseAll);
}


// 청산
void CloseAll() {
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
    int total = PositionsTotal();
    for(int cnt = total - 1; cnt >= 0; cnt--) {
        //--- parameters of the order
        ulong  order_ticket = PositionGetTicket(cnt);
        string order_symbol = PositionGetString(POSITION_SYMBOL);                         // symbol
        ulong  magic = PositionGetInteger(POSITION_MAGIC);                                // MagicNumber of the position
        double OrderLots = PositionGetDouble(POSITION_VOLUME);                               // volume of the position
        ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position
        if(order_symbol == Symbol() && magic == GetMagicNumber(b_MagicNumberCheck, magic)) {
            //--- zeroing the request and result values
            ZeroMemory(request);
            ZeroMemory(result);
            //--- setting the operation parameters
            request.action   = TRADE_ACTION_DEAL;       // type of trade operation
            request.position = order_ticket;         // ticket of the position
            request.symbol   = order_symbol;         // symbol
            request.volume   = OrderLots;                  // volume of the position
            request.deviation = n_Slippage;                      // allowed deviation from the price
            request.magic    = magic;            // MagicNumber of the position
            //--- set the price and order type depending on the position type
            if(type == POSITION_TYPE_BUY) {
                request.price = Bid();
                request.type = ORDER_TYPE_SELL;
            } else {
                request.price = Ask();
                request.type = ORDER_TYPE_BUY;
            }
            if(!OrderSend(request, result)) {
                if(type == POSITION_TYPE_BUY)
                    Print("OrderClose(Buy) error ", GetLastError(), " #", order_ticket);
                else
                    Print("OrderClose(Sell) error ", GetLastError(), " #", order_ticket);
            }
        }
    }
    if(b_Sound)PlaySound(str_Error);
    return;
}

//지정가 매수
bool PendingBuy(double dbPrice, double dbLots, int nStopLoss, int nTakeProfit) {
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
//--- parameters to place a pending order
    request.action   = TRADE_ACTION_PENDING;                            // type of trade operation
    request.symbol   = Symbol();                             // symbol
    request.volume   = dbLots;                  // volume of 0.1 lot
    request.deviation = n_Slippage;                                   // allowed deviation from the price
    request.magic    = n_MagicNumber;                         // MagicNumber of the order
    if(dbPrice > Ask() )request.type = ORDER_TYPE_BUY_STOP;
    else request.type = ORDER_TYPE_BUY_LIMIT;
    request.price    = dbPrice;
    if(nStopLoss   > 0) request.sl = dbPrice - nStopLoss * Point();
    if(nTakeProfit > 0) request.tp = dbPrice + nTakeProfit * Point();
//--- send the request
    if(!OrderSend(request, result)) {
        if(request.type == ORDER_TYPE_BUY_STOP)
            Print("OrderSend(buy stop) error ", GetLastError());
        else
            Print("OrderSend(buy limit) error ", GetLastError());
        if(b_Sound)PlaySound(str_Error);
        return(false);
    }
    if(b_Sound)PlaySound(str_OK);
    return(true);
}

//지정가 매도
bool PendingSell(double dbPrice, double dbLots, int nStopLoss, int nTakeProfit) {
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
//--- parameters to place a pending order
    request.action   = TRADE_ACTION_PENDING;                            // type of trade operation
    request.symbol   = Symbol();                             // symbol
    request.volume   = dbLots;                               // volume of 0.1 lot
    request.deviation = n_Slippage;                                   // allowed deviation from the price
    request.magic    = n_MagicNumber;                         // MagicNumber of the order
    if(dbPrice > Bid() )request.type = ORDER_TYPE_SELL_LIMIT;
    else request.type = ORDER_TYPE_SELL_STOP;
    request.price    = dbPrice;
    if(nStopLoss   > 0) request.sl = dbPrice + nStopLoss * Point();
    if(nTakeProfit > 0) request.tp = dbPrice - nTakeProfit * Point();
//--- send the request
    if(!OrderSend(request, result)) {
        if(request.type == ORDER_TYPE_SELL_LIMIT)
            Print("OrderSend(sell limit) error ", GetLastError());
        else
            Print("OrderSend(sell stop) error ", GetLastError());
        if(b_Sound)PlaySound(str_Error);
        return(false);
    }
    if(b_Sound)PlaySound(str_OK);
    return(true);
}

//Modify_Ticket
//주문 수정
bool ModifyPending_Ticket(ulong nTicket, double dbPrice, int nStopLoss, int nTakeProfit) {
    string strError = "OrderModify";
    double dbStopLoss = 0, dbTakeProfit = 0 ;
    bool bOrderSelect = false; //이변수는 Warning을 없애기 위해서만 사용된다.
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
    if(!OrderSelect(nTicket))return(false);
    ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE); // type of the position
    if(OrderGetString(ORDER_SYMBOL) != Symbol() || OrderGetInteger(ORDER_MAGIC) != GetMagicNumber(b_MagicNumberCheck, OrderGetInteger(ORDER_MAGIC))) {
        Print("수정 조건 아님 ==> order_symbol!=Symbol() || magic!=GetMagicNumber(b_MagicNumberCheck,magic)");
        if(b_Sound)PlaySound(str_Error);
        return(false);
    }
    strError += "(" + OrdertypeToString(type) + ") error ";
    request.action = TRADE_ACTION_MODIFY;                         // type of trade operation
    request.order = nTicket;                            // order ticket
    request.symbol = OrderGetString(ORDER_SYMBOL);                                  // symbol
    request.deviation = n_Slippage;
    request.price = dbPrice;
    if(type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP) {
        if(nStopLoss   > 0) request.sl = dbPrice - nStopLoss * Point();
        if(nTakeProfit > 0) request.tp = dbPrice + nTakeProfit * Point();
    }
    if(type == ORDER_TYPE_SELL_LIMIT || type == ORDER_TYPE_SELL_STOP) {
        if(nStopLoss   > 0) request.sl = dbPrice + nStopLoss * Point();
        if(nTakeProfit > 0) request.tp = dbPrice - nTakeProfit * Point();
    }
    if(!OrderSend(request, result)) {
        Print(strError, GetLastError(), " #", nTicket);
        if(b_Sound)PlaySound(str_Error);
        return(false);
    }
    if(b_Sound)PlaySound(str_OK);
    return(true);
}

//지정가 취소
bool Cancel_Ticket(ulong nTicket) {
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
    if(!OrderSelect(nTicket))return(false);
    if(OrderGetString(ORDER_SYMBOL) != Symbol() || OrderGetInteger(ORDER_MAGIC) != GetMagicNumber(b_MagicNumberCheck, OrderGetInteger(ORDER_MAGIC))) {
        Print("취소 조건 아님 ==> order_symbol!=Symbol() || magic!=GetMagicNumber(b_MagicNumberCheck,magic) || type < ORDER_TYPE_BUY_LIMIT");
        if(b_Sound)PlaySound(str_Error);
        return(false);
    }
    request.action = TRADE_ACTION_REMOVE;            // type of trade operation
    request.order = nTicket;                         // order ticket
    if(OrderSend(request, result)) {
        if(b_Sound)PlaySound(str_OK);
        return(true);
    }
    return(false);
}

//예약 주문 모두 취소
void CancelAll() {
    MqlTradeRequest request = {0};
    MqlTradeResult  result = {0};
    int total = OrdersTotal();
    for(int cnt = total - 1; cnt >= 0; cnt--) {
        ulong  order_ticket = OrderGetTicket(cnt); //OrderGetTicket()함수는 자동선택 기능이 있다.
        if(OrderGetString(ORDER_SYMBOL) == Symbol() && OrderGetInteger(ORDER_MAGIC) == GetMagicNumber(b_MagicNumberCheck, OrderGetInteger(ORDER_MAGIC))) {
            ZeroMemory(request);
            ZeroMemory(result);
            request.action = TRADE_ACTION_REMOVE;            // type of trade operation
            request.order = order_ticket;                         // order ticket
            if(OrderSend(request, result))
                if(b_Sound)PlaySound(str_OK);
        }
    }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrdertypeToString(int nOrderType ) {
    switch(nOrderType) {
    case ORDER_TYPE_BUY :
        return(strBuy);//POSITION_TYPE_BUY과 같은 상수값임
    case ORDER_TYPE_SELL :
        return(strSell);//POSITION_TYPE_SELL과 같은 상수값임
    case ORDER_TYPE_BUY_LIMIT :
        return(strBuyLimit);
    case ORDER_TYPE_SELL_LIMIT :
        return(strSellLimit);
    case ORDER_TYPE_BUY_STOP :
        return(strBuyStop);
    case ORDER_TYPE_SELL_STOP :
        return(strSellStop);
    }
    return("");
}

//+------------------------------------------------------------------+
//|  Edit 함수                                                       |
//+------------------------------------------------------------------+
bool OnEndEdit(string strObject, string& strPreText ) {
    string strCurrentText;
    if( ObjectFind(0, strObject) < 0)return(false);
    strCurrentText = ObjectGetString(0, strObject, OBJPROP_TEXT );
    if(strCurrentText == strPreText )return(false);// 상대 변화가 없으므로 OnEndEdit는 false이다
    strPreText = strCurrentText;
    return(true);
}

//+------------------------------------------------------------------+
//|  button 함수                                                     |
//+------------------------------------------------------------------+
bool OnButtonClick(string strObject, bool& bPreState) {
    if( ObjectFind(0, strObject) < 0)return(false);
    if(OnButtonDown(strObject, bPreState)) {
        ObjectSetInteger(0, strObject, OBJPROP_STATE, false); //ButtonDown된 상태를 ButtonUp 상태로 변경해 준다.
        bPreState = false;
        return(true);//ButtonDown일때 OnButtonClick은 true이다
    }
    return(false);//그외의 모든 상황일때 OnButtonClick은 false이다
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OnButtonDown(string strObject, bool& bPreState) {
    bool bCurrentState;
    if( ObjectFind(0, strObject) < 0)return(false);
    bCurrentState = ObjectGetInteger(0, strObject, OBJPROP_STATE);
    if(bCurrentState == bPreState )return(false);// 상대 변화가 없으므로 OnButtonDown은 false이다
    if(bCurrentState) { //ButtonDown은 bCurrentState가 true일때만 OnButtonDown이 true이다
        bPreState = bCurrentState;
        return(true);
    }
    //bCurrentState가 false이면 ButtonUp이므로 OnButtonDown은 false이다.
    return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OnButtonUp(string strObject, bool& bPreState) {
    bool  bCurrentState;
    if( ObjectFind(0, strObject) < 0)return(false);
    bCurrentState = ObjectGetInteger(0, strObject, OBJPROP_STATE);
    if(bCurrentState == bPreState )return(false); // 상대 변화가 없으므로 OnButtonUp은 false이다
    if(!bCurrentState) { //OnButtonUp은 bCurrentState가 false일때만 OnButtonUp이 true이다
        bPreState = bCurrentState;
        return(true);
    }
    //bCurrentState가 true이면 OnButtonDown이므로 OnButtonUp은 false이다.
    return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetButtonDown(string strObject, bool& bState) {
    ObjectSetInteger(0, strObject, OBJPROP_STATE, true);
    bState = true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetButtonUp(string strObject, bool& bState) {
    ObjectSetInteger(0, strObject, OBJPROP_STATE, false);
    bState = false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsButtonDown(string strObject) {
    if( ObjectGetInteger(0, strObject, OBJPROP_STATE) == true )
        return(true);
    else
        return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsButtonUp(string strObject) {
    if( ObjectGetInteger(0, strObject, OBJPROP_STATE) == false )
        return(true);
    else
        return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetButtonState(string strObject) {
    return((bool)ObjectGetInteger(0, strObject, OBJPROP_STATE));
}

//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID = 0,             // chart's ID
                  const string            name = "Button",          // button name
                  const int               sub_window = 0,           // subwindow index
                  const int               x = 0,                    // X coordinate
                  const int               y = 0,                    // Y coordinate
                  const int               width = 50,               // button width
                  const int               height = 18,              // button height
                  const ENUM_BASE_CORNER  corner = CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text = "Button",          // text
                  const string            font = "Arial",           // font
                  const int               font_size = 10,           // font size
                  const color             clr = clrBlack,           // text color
                  const color             back_clr = C'236,233,216', // background color
                  const color             border_clr = clrNONE,     // border color
                  const bool              state = false,            // pressed/released
                  const bool              back = false,             // in the background
                  const bool              selection = false,        // highlight to move
                  const bool              hidden = true,            // hidden in the object list
                  const long              z_order = 0) {            // priority for mouse click
//--- reset the error value
    ResetLastError();
//--- create the button
    if(!ObjectCreate(chart_ID, name, OBJ_BUTTON, sub_window, 0, 0)) {
        Print(__FUNCTION__,
              ": failed to create the button! Error code = ", GetLastError());
        return(false);
    }
//--- set button coordinates
    ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set button size
    ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
    ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set the chart's corner, relative to which point coordinates are defined
    ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set the text
    ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
//--- set text font
    ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
    ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set text color
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set background color
    ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
//--- set border color
    ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
//--- display in the foreground (false) or background (true)
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- set button state
    ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
    return(true);
}


//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID = 0,             // chart's ID
                 const string            name = "Label",           // label name
                 const int               sub_window = 0,           // subwindow index
                 const int               x = 0,                    // X coordinate
                 const int               y = 0,                    // Y coordinate
                 const ENUM_BASE_CORNER  corner = CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text = "Label",           // text
                 const string            font = "Arial",           // font
                 const int               font_size = 10,           // font size
                 const color             clr = clrRed,             // color
                 const double            angle = 0.0,              // text slope
                 const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back = false,             // in the background
                 const bool              selection = false,        // highlight to move
                 const bool              hidden = true,            // hidden in the object list
                 const long              z_order = 0) {            // priority for mouse click
//--- reset the error value
    ResetLastError();
//--- create a text label
    if(!ObjectCreate(chart_ID, name, OBJ_LABEL, sub_window, 0, 0)) {
        Print(__FUNCTION__,
              ": failed to create text label! Error code = ", GetLastError());
        return(false);
    }
//--- set label coordinates
    ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set the chart's corner, relative to which point coordinates are defined
    ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set the text
    ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
//--- set text font
    ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
    ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set the slope angle of the text
    ObjectSetDouble(chart_ID, name, OBJPROP_ANGLE, angle);
//--- set anchor type
    ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
//--- set color
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- display in the foreground (false) or background (true)
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
    return(true);
}

//+------------------------------------------------------------------+
//| Create rectangle label                                           |
//+------------------------------------------------------------------+
bool RectLabelCreate(const long             chart_ID = 0,             // chart's ID
                     const string           name = "RectLabel",       // label name
                     const int              sub_window = 0,           // subwindow index
                     const int              x = 0,                    // X coordinate
                     const int              y = 0,                    // Y coordinate
                     const int              width = 50,               // width
                     const int              height = 18,              // height
                     const color            back_clr = C'236,233,216', // background color
                     const ENUM_BORDER_TYPE border = BORDER_SUNKEN,   // border type
                     const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER, // chart corner for anchoring
                     const color            clr = clrRed,             // flat border color (Flat)
                     const ENUM_LINE_STYLE  style = STYLE_SOLID,      // flat border style
                     const int              line_width = 1,           // flat border width
                     const bool             back = false,             // in the background
                     const bool             selection = false,        // highlight to move
                     const bool             hidden = true,            // hidden in the object list
                     const long             z_order = 0) {            // priority for mouse click
//--- reset the error value
    ResetLastError();
//--- create a rectangle label
    if(!ObjectCreate(chart_ID, name, OBJ_RECTANGLE_LABEL, sub_window, 0, 0)) {
        Print(__FUNCTION__,
              ": failed to create a rectangle label! Error code = ", GetLastError());
        return(false);
    }
//--- set label coordinates
    ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set label size
    ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
    ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set background color
    ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
//--- set border type
    ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_TYPE, border);
//--- set the chart's corner, relative to which point coordinates are defined
    ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set flat border color (in Flat mode)
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set flat border line style
    ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set flat border width
    ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, line_width);
//--- display in the foreground (false) or background (true)
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
    return(true);
}

//+------------------------------------------------------------------+
//| Create Edit object                                               |
//+------------------------------------------------------------------+
bool EditCreate(const long             chart_ID = 0,             // chart's ID
                const string           name = "Edit",            // object name
                const int              sub_window = 0,           // subwindow index
                const int              x = 0,                    // X coordinate
                const int              y = 0,                    // Y coordinate
                const int              width = 50,               // width
                const int              height = 18,              // height
                const string           text = "Text",            // text
                const string           font = "Arial",           // font
                const int              font_size = 10,           // font size
                const ENUM_ALIGN_MODE  align = ALIGN_CENTER,     // alignment type
                const bool             read_only = false,        // ability to edit
                const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER, // chart corner for anchoring
                const color            clr = clrBlack,           // text color
                const color            back_clr = clrWhite,      // background color
                const color            border_clr = clrNONE,     // border color
                const bool             back = false,             // in the background
                const bool             selection = false,        // highlight to move
                const bool             hidden = true,            // hidden in the object list
                const long             z_order = 0) {            // priority for mouse click
//--- reset the error value
    ResetLastError();
//--- create edit field
    if(!ObjectCreate(chart_ID, name, OBJ_EDIT, sub_window, 0, 0)) {
        Print(__FUNCTION__,
              ": failed to create \"Edit\" object! Error code = ", GetLastError());
        return(false);
    }
//--- set object coordinates
    ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set object size
    ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
    ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set the text
    ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
//--- set text font
    ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
    ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set the type of text alignment in the object
    ObjectSetInteger(chart_ID, name, OBJPROP_ALIGN, align);
//--- enable (true) or cancel (false) read-only mode
    ObjectSetInteger(chart_ID, name, OBJPROP_READONLY, read_only);
//--- set the chart's corner, relative to which object coordinates are defined
    ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set text color
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set background color
    ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
//--- set border color
    ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
//--- display in the foreground (false) or background (true)
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
    return(true);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID = 0,             // chart's ID
                const string            name = "Text",            // object name
                const int               sub_window = 0,           // subwindow index
                datetime                time = 0,                 // anchor point time
                double                  price = 0,                // anchor point price
                const string            text = "Text",            // the text itself
                const string            font = "Arial",           // font
                const int               font_size = 10,           // font size
                const color             clr = clrRed,             // color
                const double            angle = 0.0,              // text slope
                const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER, // anchor type
                const bool              back = false,             // in the background
                const bool              selection = false,        // highlight to move
                const bool              hidden = true,            // hidden in the object list
                const long              z_order = 0) {            // priority for mouse click
//--- set anchor point coordinates if they are not set
    // ChangeTextEmptyPoint(time,price);
//--- reset the error value
    ResetLastError();
//--- create Text object
    if(!ObjectCreate(chart_ID, name, OBJ_TEXT, sub_window, time, price)) {
        Print(__FUNCTION__,
              ": failed to create \"Text\" object! Error code = ", GetLastError());
        return(false);
    }
//--- set the text
    ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
//--- set text font
    ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
//--- set font size
    ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
//--- set the slope angle of the text
    ObjectSetDouble(chart_ID, name, OBJPROP_ANGLE, angle);
//--- set anchor type
    ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
//--- set color
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- display in the foreground (false) or background (true)
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the object by mouse
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
    return(true);
}

//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID = 0,      // chart's ID
                 const string          name = "TrendLine", // line name
                 const int             sub_window = 0,    // subwindow index
                 datetime              time1 = 0,         // first point time
                 double                price1 = 0,        // first point price
                 datetime              time2 = 0,         // second point time
                 double                price2 = 0,        // second point price
                 const color           clr = clrRed,      // line color
                 const ENUM_LINE_STYLE style = STYLE_SOLID, // line style
                 const int             width = 1,         // line width
                 const bool            back = false,      // in the background
                 const bool            selection = true,  // highlight to move
                 const bool            ray_right = false, // line's continuation to the right
                 const bool            hidden = true,     // hidden in the object list
                 const long            z_order = 0) {     // priority for mouse click
//--- set anchor points' coordinates if they are not set
    //ChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
    ResetLastError();
//--- create a trend line by the given coordinates
    if(!ObjectCreate(chart_ID, name, OBJ_TREND, sub_window, time1, price1, time2, price2)) {
        Print(__FUNCTION__,
              ": failed to create a trend line! Error code = ", GetLastError());
        return(false);
    }
//--- set line color
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set line display style
    ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set line width
    ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
//--- display in the foreground (false) or background (true)
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right
    ObjectSetInteger(chart_ID, name, OBJPROP_RAY_RIGHT, ray_right);
//--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
    return(true);
}
//+------------------------------------------------------------------+
