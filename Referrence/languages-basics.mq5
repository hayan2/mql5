//+------------------------------------------------------------------+
//|                                                print-example.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#define BUTTON_LENGTH 13
#define X_SIZE 140      // width of an edit object 
#define Y_SIZE 33       // height of an edit object 
#define SCRIPT_LENGTH 140

input string inputName = "Button";
input ENUM_BASE_CORNER inputCornor = CORNER_LEFT_UPPER;
input string inputFont = "Consolas";
input int inputFontSize = 10;
input color inputColor = clrBlack;
input color inputBackColor = C'236,233,216';
input color inputBorderColor = clrNONE;
input bool inputState = false;
input bool inputBack = false;
input bool inputSelection = false;
input bool inputHidden = true;
input long inputZOrder = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Web color array                                                  |
//+------------------------------------------------------------------+
color colorClassList[140] = {
    clrAliceBlue, clrAntiqueWhite, clrAqua, clrAquamarine, clrAzure, clrBeige, clrBisque, clrBlack, clrBlanchedAlmond,
    clrBlue, clrBlueViolet, clrBrown, clrBurlyWood, clrCadetBlue, clrChartreuse, clrChocolate, clrCoral, clrCornflowerBlue,
    clrCornsilk, clrCrimson, clrCyan, clrDarkBlue, clrDarkCyan, clrDarkGoldenrod, clrDarkGray, clrDarkGreen, clrDarkKhaki,
    clrDarkMagenta, clrDarkOliveGreen, clrDarkOrange, clrDarkOrchid, clrDarkRed, clrDarkSalmon, clrDarkSeaGreen,
    clrDarkSlateBlue, clrDarkSlateGray, clrDarkTurquoise, clrDarkViolet, clrDeepPink, clrDeepSkyBlue, clrDimGray,
    clrDodgerBlue, clrFireBrick, clrFloralWhite, clrForestGreen, clrFuchsia, clrGainsboro, clrGhostWhite, clrGold,
    clrGoldenrod, clrGray, clrGreen, clrGreenYellow, clrHoneydew, clrHotPink, clrIndianRed, clrIndigo, clrIvory, clrKhaki,
    clrLavender, clrLavenderBlush, clrLawnGreen, clrLemonChiffon, clrLightBlue, clrLightCoral, clrLightCyan,
    clrLightGoldenrod, clrLightGreen, clrLightGray, clrLightPink, clrLightSalmon, clrLightSeaGreen, clrLightSkyBlue,
    clrLightSlateGray, clrLightSteelBlue, clrLightYellow, clrLime, clrLimeGreen, clrLinen, clrMagenta, clrMaroon,
    clrMediumAquamarine, clrMediumBlue, clrMediumOrchid, clrMediumPurple, clrMediumSeaGreen, clrMediumSlateBlue,
    clrMediumSpringGreen, clrMediumTurquoise, clrMediumVioletRed, clrMidnightBlue, clrMintCream, clrMistyRose, clrMoccasin,
    clrNavajoWhite, clrNavy, clrOldLace, clrOlive, clrOliveDrab, clrOrange, clrOrangeRed, clrOrchid, clrPaleGoldenrod,
    clrPaleGreen, clrPaleTurquoise, clrPaleVioletRed, clrPapayaWhip, clrPeachPuff, clrPeru, clrPink, clrPlum, clrPowderBlue,
    clrPurple, clrRed, clrRosyBrown, clrRoyalBlue, clrSaddleBrown, clrSalmon, clrSandyBrown, clrSeaGreen, clrSeashell,
    clrSienna, clrSilver, clrSkyBlue, clrSlateBlue, clrSlateGray, clrSnow, clrSpringGreen, clrSteelBlue, clrTan, clrTeal,
    clrThistle, clrTomato, clrTurquoise, clrViolet, clrWheat, clrWhite, clrWhiteSmoke, clrYellow, clrYellowGreen
};
//+------------------------------------------------------------------+
//| Button create                                                    |
//+------------------------------------------------------------------+
bool button_create(
    const long chartID = 0,
    const string name = "Example Button",
    const int subWindow = 0,
    const int x = 0,
    const int y = 0,
    const int width = 50,
    const int height = 13,
    const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER,
    const string text = "Example Button",
    const string font = "Consolas",
    const int fontSize = 10,
    const color clr = clrBlack,
    const color backClr = C'236,233,216',
    const color borderClr = clrNONE,
    const bool state = false,
    const bool back = false,
    const bool selection = false,
    const bool hidden = true,
    const long zOrder = 0) {
    ResetLastError();
    if (!ObjectCreate(chartID, name, OBJ_BUTTON, subWindow, 0, 0)) {
        Print(__FUNCTION__, ": failed to craete the button! Error code = ", GetLastError());
        return false;
    }
    ObjectSetInteger(chartID, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(chartID, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(chartID, name, OBJPROP_XSIZE, width);
    ObjectSetInteger(chartID, name, OBJPROP_YSIZE, height);
    ObjectSetInteger(chartID, name, OBJPROP_CORNER, corner);
    ObjectSetString(chartID, name, OBJPROP_TEXT, text);
    ObjectSetString(chartID, name, OBJPROP_FONT, font);
    ObjectSetInteger(chartID, name, OBJPROP_FONTSIZE, fontSize);
    ObjectSetInteger(chartID, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(chartID, name, OBJPROP_BGCOLOR, backClr);
    ObjectSetInteger(chartID, name, OBJPROP_BORDER_COLOR, borderClr);
    ObjectSetInteger(chartID, name, OBJPROP_STATE, state);
    ObjectSetInteger(chartID, name, OBJPROP_BACK, back);
    ObjectSetInteger(chartID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chartID, name, OBJPROP_SELECTED, selection);
    ObjectSetInteger(chartID, name, OBJPROP_HIDDEN, hidden);
    ObjectSetInteger(chartID, name, OBJPROP_ZORDER, zOrder);
    return true;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Button move                                                      |
//+------------------------------------------------------------------+
bool button_move(
    const long chartID = 0,
    const string name = "Button",
    const int x = 0,
    const int y = 0) {
    ResetLastError();
    if (!ObjectSetInteger(chartID, name, OBJPROP_XDISTANCE, x)) {
        Print(__FUNCTION__, ": failed to move X coordinate of the button! Error code = ", GetLastError());
        return false;
    }
    if (!ObjectSetInteger(chartID, name, OBJPROP_YDISTANCE, y)) {
        Print(__FUNCTION__, ": failed to move Y coordinate of the button! Error code = ", GetLastError());
        return false;
    }
    return true;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Button change size                                               |
//+------------------------------------------------------------------+
bool button_change_size(
    const long chartID = 0,
    const string name = "Button",
    const int width = 50,
    const int height = 18) {
    ResetLastError();
    if (!ObjectSetInteger(chartID, name, OBJPROP_XSIZE, width)) {
        Print(__FUNCTION__, ": failed to change the button width! Error code = ", GetLastError());
        return false;
    }
    if (!ObjectSetInteger(chartID, name, OBJPROP_YSIZE, height)) {
        Print(__FUNCTION__, ": failed to change the button height! Error code = ", GetLastError());
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Button change corner                                             |
//+------------------------------------------------------------------+
bool button_change_cornor(
    const long chartID = 0,
    const string name = "Button",
    const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER) {
    ResetLastError();
    if (!ObjectSetInteger(chartID, name, OBJPROP_CORNER, corner)) {
        Print(__FUNCTION__, ": failed to change the anchor cornor! Error code = ", GetLastError());
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Button text change                                               |
//+------------------------------------------------------------------+
bool button_text_change(
    const long chartID = 0,
    const string name = "Button",
    const string text = "Text") {
    ResetLastError();
    if (!ObjectSetString(chartID, name, OBJPROP_TEXT, text)) {
        Print(__FUNCTION__, ": failed to change the anchor cornor! Error code = ", GetLastError());
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Button delete                                                    |
//+------------------------------------------------------------------+
bool button_delete(
    const long chartID = 0,
    const string name = "Button") {
    ResetLastError();
    if (!ObjectDelete(chartID, name)) {
        Print(__FUNCTION__, ": failed to delete the button! Error code = ", GetLastError());
        return false;
    }
    return true;
}

//+------------------------------------------------------------------+
//| Create color box                                                 |
//+------------------------------------------------------------------+
void create_color_box(int x, int y, color c) {
    string name = "colorBox " + (string)x + "_" + (string)y;
    if (!ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0)) {
        Print("You can't create : '", name, "'");
        return;
    }
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x * X_SIZE);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y * Y_SIZE);
    ObjectSetInteger(0, name, OBJPROP_XSIZE, X_SIZE);
    ObjectSetInteger(0, name, OBJPROP_YSIZE, Y_SIZE);
    if (clrBlack == c) {
        ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
    } else {
        ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
    }
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, c);
    ObjectSetString(0, name, OBJPROP_TEXT, (string)c);
}

//+------------------------------------------------------------------+
//| Start script                                                     |
//+------------------------------------------------------------------+
void start_script() {
    for (uint i = 0; i < 140; i++) {
        create_color_box(i % 7, i / 7, colorClassList[i]);
    }
}

//+------------------------------------------------------------------+
//| Main function                                                    |
//+------------------------------------------------------------------+
void OnStart() {
    for (uint i = 0; i < 140; i++) {
        create_color_box(i % 7, i / 7, colorClassList[i]);
    }    
    /*
     long xDistance;
     long yDistance;
     if (!ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0, xDistance)) {
         Print("Failed to get the chart width! Error code = ", GetLastError());
         return;
     }
     if (!ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0, yDistance)) {
         Print("Failed to get the chart height! Error code = ", GetLastError());
         return;
     }
     int xStep = (int)xDistance / 32;
     int yStep = (int)yDistance / 32;
     int x = (int)xDistance / 32;
     int y = (int)yDistance / 32;
     int xSize = (int)xDistance * 15 / 16;
     int ySize = (int)yDistance * 15 / 16;
     if (!button_create(0, inputName, 0, x, y, xSize, ySize, inputCornor, "Press", inputFont, inputFontSize,
                        inputColor, inputBackColor, inputBorderColor, inputState, inputBack, inputSelection, inputHidden, inputZOrder)) {
         return;
     }
     ChartRedraw();
     int i = 0;
     while (i < 13) {
         Sleep(500);
         ObjectSetInteger(0, inputName, OBJPROP_STATE, true);
         ChartRedraw();
         Sleep(200);
         x += xStep;
         y += yStep;
         xSize -= xStep * 2;
         ySize -= yStep * 2;
         button_move(0, inputName, x, y);
         button_change_size(0, inputName, xSize, ySize);
         ObjectSetInteger(0, inputName, OBJPROP_STATE, false);
         ChartRedraw();
         if (IsStopped()) {
             return;
         }
         i++;
     }
     Sleep(500);
     button_delete(0, inputName);
     ChartRedraw();
     Sleep(1000);
    */
}
//+------------------------------------------------------------------+
