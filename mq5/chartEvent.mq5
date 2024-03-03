//--- 303P
#define KEY_NUMPAD_5 12
#define KEY_LEFT 37
#define KEY_UP 38
#define KEY_RIGHT 39
#define KEY_DOWN 40
#define KEY_NUMLOCK_DOWN 98
#define KEY_NUMLOCK_5 101
#define KEY_NUMLOCK_RIGHT 102
#define KEY_NUMLOCK_UP 104

int OnInit() {
    Print("이름이 ", MQL5InfoString(MQL5_PROGRAM_NAME), " 인 expert가 실행 중");
    ChartSetInteger(ChartID(), CHART_EVENT_OBJECT_CREATE, true);
    ChartSetInteger(ChartID(), CHART_EVENT_OBJECT_DELETE, true);
    ChartRedraw();

    return INIT_SUCCEEDED;
}

void OnChartEvent(const int id, const long& lparam, const double& dparam,
                  const string& sparam) {
    if (id == CHARTEVENT_CLICK) {
        Print("차트에서 마우스 클릭 좌표는 다음과 같음: x = ", lparam,
              " y = ", dparam);
    }
    if (id == CHARTEVENT_OBJECT_CLICK) {
        Print("다음 이름의 객체를 마우스로 클릭함 '" + sparam + "'");
    }
    if (id == CHARTEVENT_KEYDOWN) {
        switch (lparam) {
            case KEY_LEFT:
                Print("KEY_LEFT 이(가) 눌렸습니다");
                break;
            case KEY_NUMLOCK_UP:
                Print("KEY_NUMLOCK_UP 이(가) 눌렸습니다");
                break;
            case KEY_UP:
                Print("KEY_UP 이(가) 눌렸습니다");
                break;
            case KEY_NUMLOCK_RIGHT:
                Print("KEY_NUMLOCK_RIGHT 이(가) 눌렸습니다");
                break;
            case KEY_RIGHT:
                Print("KEY_RIGHT 이(가) 눌렸습니다");
                break;
            case KEY_NUMLOCK_DOWN:
                Print("KEY_NUMLOCK_DOWN 이(가) 눌렸습니다");
                break;
            case KEY_DOWN:
                Print("KEY_DOWN 이(가) 눌렸습니다");
                break;
            case KEY_NUMPAD_5:
                Print("KEY_NUMPAD_5 이(가) 눌렸습니다");
                break;
			case KEY_NUMLOCK_5:
                Print("KEY_NUMLOCK_5 이(가) 눌렸습니다");
                break;
			default:
				Print("목록에 없는 일부 키가 눌렸습니다.");
        }
		ChartRedraw();
    }

	if (id == CHARTEVENT_OBJECT_DELETE) {
		Print(" ", sparam, " 의 이름의 객체가 삭제되었습니다");
	}
	if (id == CHARTEVENT_OBJECT_CREATE) {
		Print(" ", sparam, " 의 이름의 객체가 생성되었습니다");
	}
	if (id == CHARTEVENT_OBJECT_DRAG) {
		Print("이름이 ", sparam, " 인 객체의 고정점 좌표가 변경되었습니다");
	}
	if (id == CHARTEVENT_OBJECT_ENDEDIT) {
		Print("이름이 ", sparam, " 인 객체의 편집 필드에 있는 텍스트가 변경되었습니다");
	}
}