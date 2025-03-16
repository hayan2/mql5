//+------------------------------------------------------------------+
//|                                                      BB_EA.mq5   |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                       https://www.mql5.com      |
//+------------------------------------------------------------------+
input int period = 20;        // 이동 평균 기간
input double deviation = 2.0; // 표준 편차 배수

double upperBand[];
double lowerBand[];
double middleBand[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // 지표 데이터 버퍼 초기화
    SetIndexBuffer(0, upperBand);   // 상한선 버퍼
    SetIndexBuffer(1, middleBand);   // 중단선 버퍼
    SetIndexBuffer(2, lowerBand);    // 하한선 버퍼

    // 지표 속성 설정
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrBlue);   // 상한선 색상
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);    // 중단선 색상
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, clrGreen);  // 하한선 색상

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Bollinger Bands 계산
    int bbHandle = iBands(NULL, 0, period, deviation, 0, PRICE_CLOSE);
    
    if (bbHandle != INVALID_HANDLE)
    {
        // 데이터 버퍼에 값 저장
        CopyBuffer(bbHandle, 0, 0, 5, upperBand);   // 상한선
        CopyBuffer(bbHandle, 1, 0, 5, middleBand);  // 중단선
        CopyBuffer(bbHandle, 2, 0, 5, lowerBand);   // 하한선
    }
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // EA 종료 시 추가 작업이 필요하면 여기에 작성
}

//+------------------------------------------------------------------+