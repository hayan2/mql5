//--- 306P

int OnInit() {
    ChartSetInteger(0, CHART_EVENT_MOUSE_WHEEL, 1);
    ChartRedraw();

    return (INIT_SUCCEEDED);
}

void OnChartEvent(const int id, const long& mouseXPosition,
                  const double& mouseYPosition, const string& sparam) {
    if (id == CHARTEVENT_MOUSE_WHEEL) {
        int flagKeys = (int)(mouseXPosition >> 32);
        int xCursor = (int)(short)mouseXPosition;
        int yCursor = (int)(short)(mouseXPosition >> 16);
        int delta = (int)mouseYPosition;

        string strKeys = "";

        if ((flagKeys & 0x0001) != 0) strKeys += "LMOUSE";
        if ((flagKeys & 0x0002) != 0) strKeys += "RMOUSE";
        if ((flagKeys & 0x0004) != 0) strKeys += "SHIFT";
        if ((flagKeys & 0x0008) != 0) strKeys += "CTRL";
        if ((flagKeys & 0x0010) != 0) strKeys += "MMOUSE";
        if ((flagKeys & 0x0020) != 0) strKeys += "X1MOUSE";
        if ((flagKeys & 0x0040) != 0) strKeys += "X2MOUSE";

        if (strKeys != "") {
            strKeys = ", keys = '" +
                      StringSubstr(strKeys, 0, StringLen(strKeys) - 1) + "'";
        }
        PrintFormat("%s: X = %d, Y = %d, delta = %d%s",
                    EnumToString(CHARTEVENT_MOUSE_WHEEL), xCursor, yCursor, delta, strKeys);
    }
}