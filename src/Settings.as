// [Setting category="General" name="Force show manialink CP counter" description="This is the in-game default CP counter, Still must be enabled in settings; shows CP 0/0 if no CPs. If you have this plugin, presumably you want this to be on."]
bool S_ForceOnCpCounter = true;

// #if DEV
// [SettingsTab name="Debug"]
// void RenderSettingsTab_Debug() {
//     UI::BeginDisabled(CPCountFrame is null);
//     if (UI::Button("Explore cp count frame")) {
//         ExploreNod("CPCountFrame", CPCountFrame);
//     }
//     UI::EndDisabled();
// }
// #endif
