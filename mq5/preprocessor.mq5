//+------------------------------------------------------------------+
//| foreach pseudo-operator |
//+------------------------------------------------------------------+
//--- 247P
#define ForEach(index, array)
    for (int index = 0, max_##index = ArraySize((array)); index < max_##index;
         index++)
void OnStart() {
    string array[] = {"12", "23", "34", "45"};
    ForEach(i, array) { PrintFormat("%d: array[%d]=%s", i, i, array[i]); }
}