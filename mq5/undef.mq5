// cancel macro
//--- 251P
#define MACRO

void func1() {
#ifdef MACRO
    Print(" MACRO는 다음에 정의되어 있습니다: ", __FUNCTION__);
#else
    Print(" MACRO가 다음에 정의되어 있지 않습니다: ", __FUNCTION__);
#endif
}

#undef MACRO

void func2() {
#ifdef MACRO
    Print(" MACRO가 다음에 정의되어 있습니다: ", __FUNCTION__);
#else
    Print(" MACRO가 다음에 정의되어 있지 않습니다: ", __FUNCTION__);
#endif
}
void OnStart() {
    func1();
    func2();
}
