//--- 305P
void OnInit() {
	ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
	ChartSetInteger(0, CHART_CONTEXT_MENU, 0);
	ChartSetInteger(0, CHART_CROSSHAIR_TOOL, 0);
	ChartRedraw();
}

string mouseState(uint state) {
	string res;
	res += "\nML: " + (((state& 1) == 1) ? "DN" : "UP");
	res += "\nMR: " + (((state& 2) == 2) ? "DN" : "UP");
	res += "\nMM: " + (((state& 16) == 16) ? "DN" : "UP");
	res += "\nMX: " + (((state& 32) == 32) ? "DN" : "UP");
	res += "\nMY: " + (((state& 64) == 64) ? "DN" : "UP");
	res += "\nSHIFT: " + (((state& 4) == 4) ? "DN" : "UP");
	res += "\nCTRL: " + (((state& 8) == 8) ? "DN" : "UP");

	return res;
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
	if (id == CHARTEVENT_MOUSE_MOVE) {
		Comment("POINT: ", (int)lparam, ", ", (int)dparam, "\n", mouseState((uint)sparam));
	}
}
