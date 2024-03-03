bool ChartIsObject(bool& result, const long chart_ID = 0) {
	long value

	ResetLastError();

	if (!ChartGetInteger(chart_ID, CHART_IS_OBJECT, 0, value)) {
		Print(__FUNCTION__ + ", 에러 코드 = ", GetLastError());

		return false;
	}

	result = value;

	return true;
}

bool ChartBringToTop(const long chart_ID = 0) {
	ResetLastError();

	if (!ChartSetInteger(chart_ID, CHART_BRING_TO_TOP, 0, true)) {
		Print(__FUNCTION__ + ", 에러 코드 = ", GetLastError());
		return false;		
	}
	return true;
}