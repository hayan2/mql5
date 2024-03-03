//--- 259P

#import "user32.dll"

int MessageBoxW(ulong hWnd, string lpText, string lpCaption, uint uType);
#import

int MessageBox_32_64_bit() {
	int res = -1;

	// 64bit windows
	if (_IsX64) {
		ulong hwnd = 0;
		res = MessageBoxW(hwnd, "64-bit call MessageBoxW example", "MessageBoxW 64 bit", MB_OK | MB_ICONINFORMATION);
	}
	else {
		uint hwnd = 0;
		res = MessageBoxW(hwnd, "32-bit call MessageBoxW example", "MessageBoxW 32 bit", MB_OK | MB_ICONINFORMATION);
	}
	return res;
}

void OnStart() {
	int ans = MessageBox_32_64_bit();
	PrintFormat("MessageBox_32_64_bit returned %d", ans);
}