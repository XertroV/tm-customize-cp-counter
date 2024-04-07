funcdef string EnumToStringF(int);

int DrawArbitraryEnum(const string &in label, int val, int nbVals, EnumToStringF@ eToStr) {
    if (UI::BeginCombo(label, eToStr(val))) {
        for (int i = 0; i < nbVals; i++) {
            if (UI::Selectable(eToStr(i), val == i)) {
                val = i;
            }
        }
        UI::EndCombo();
    }
    return val;
}


CGameManialinkControl::EAlignHorizontal DrawComboEAlignHorizontal(const string &in label, CGameManialinkControl::EAlignHorizontal val) {
    return CGameManialinkControl::EAlignHorizontal(
        DrawArbitraryEnum(label, int(val), 4, function(int v) {
            return tostring(CGameManialinkControl::EAlignHorizontal(v));
        })
    );
}

CGameManialinkControl::EAlignVertical DrawComboEAlignVertical(const string &in label, CGameManialinkControl::EAlignVertical val) {
    return CGameManialinkControl::EAlignVertical(
        DrawArbitraryEnum(label, int(val), 5, function(int v) {
            return tostring(CGameManialinkControl::EAlignVertical(v));
        })
    );
}
