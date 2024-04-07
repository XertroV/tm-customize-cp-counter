[Setting hidden category="Custom Pos" name="Enable Custom Position"]
bool S_EnableCustomPos = false;

[Setting hidden category="Custom Pos" name="Show Custom Position Locator" description=" (Will stay visible till next CP if you disable locator from here.)"]
bool g_DrawLocator = false;

[Setting hidden category="Custom Pos" name="Position (ML Coords)" description=""]
vec2 S_CustomPos = vec2(-10, 66.5);

[Setting hidden category="Custom Pos" name="Relative Scale" description="Default: 1.0" min=0.1 max=2]
float S_RelativeScale = .5;

[Setting hidden category="Custom Pos" name="H Align"]
CGameManialinkControl::EAlignHorizontal S_HorizAlign = CGameManialinkControl::EAlignHorizontal::Right;

[Setting hidden category="Custom Pos" name="V Align"]
CGameManialinkControl::EAlignVertical S_VerticalAlign = CGameManialinkControl::EAlignVertical::VCenter;

[SettingsTab name="Customize CP Indicator" order=1]
void RenderCustomPosSettingsTab() {
    S_EnableCustomPos = UI::Checkbox("Enable Custom Position", S_EnableCustomPos);
    g_DrawLocator = UI::Checkbox("Show Custom Position Locator", g_DrawLocator);
    AddSimpleTooltip("You can drag it around while in a map. To hide the CP indicator when locator is off, use the X in the window corner.");
    S_CustomPos = UI::InputFloat2("Position (ML Coords)", S_CustomPos);
    S_RelativeScale = UI::SliderFloat("Relative Scale", S_RelativeScale, 0.1, 2);
    S_HorizAlign = DrawComboEAlignHorizontal("H Align", S_HorizAlign);
    S_VerticalAlign = DrawComboEAlignVertical("V Align", S_VerticalAlign);
    UI::Separator();
    if (UI::Button("Set to center just above chrono (timer)")) {
        S_CustomPos = vec2(0, -76.0);
        S_RelativeScale = 0.4;
        S_HorizAlign = CGameManialinkControl::EAlignHorizontal::HCenter;
        S_VerticalAlign = CGameManialinkControl::EAlignVertical::Bottom;
    }
}

#if DEV
[SettingsTab name="DEV" order=999]
void RenderDevSetingsTab() {
    auto net = cast<CTrackManiaNetwork>(GetApp().Network);
    if (net.ClientManiaAppPlayground !is null && CPCountFrame !is null) {
        if (UI::Button("Explore CP Frame")) { ExploreNod("CP Frame", CPCountFrame); }
        if (UI::Button("Explore CP Frame Parent 1")) { ExploreNod("CP Frame Parent 1", CPCountFrame.Parent); }
        if (UI::Button("Explore CP Frame Parent 2")) { ExploreNod("CP Frame Parent 2", CPCountFrame.Parent.Parent); }
    }
    UI::Text("xExtra: " + xExtra);
    UI::Text("screen: " + screen.ToString());
    UI::Text("idealScreen: " + idealScreen.ToString());
    auto midpoint = GetScreen() / 2.;
    UI::Text("screen midpoint: " + (midpoint).ToString());
    UI::Text("ML midpoint: " + ScreenToML(midpoint).ToString());
    UI::Text("s1 * midpoint: " + (s1 * midpoint).xy.ToString());
    UI::Text("s2 * midpoint: " + (s2 * midpoint).xy.ToString());
    UI::Text("s3 * midpoint: " + (s3 * midpoint).xy.ToString());
    UI::Text("s4 * midpoint: " + (s4 * midpoint).xy.ToString());
    UI::Text("pos: " + S_CustomPos.ToString());
    UI::Text("locatorWinPos: " + locatorWinPos.ToString());
    UI::Text("locatorNewWinPos: " + locatorNewWinPos.ToString());
    UI::Text("OrigCpFramePos: " + OrigCpFramePos.ToString());
}
#endif

bool wasActive = false;

vec2 locatorWinPos;
vec2 locatorNewWinPos;

void DrawLocator() {
    if (!g_DrawLocator) return;
    vec2 mlPosOffset = vec2(0, 0);
    auto winSize = vec2(250, 150) * Draw::GetHeight() / 1440.;
    locatorWinPos = (MLToScreen(S_CustomPos - mlPosOffset) - winSize / 2.0) / UI::GetScale();
    locatorWinPos.x = Math::Ceil(locatorWinPos.x);
    locatorWinPos.y = Math::Ceil(locatorWinPos.y);
    UI::PushStyleColor(UI::Col::WindowBg, vec4(0, 0, 0, .4));
    UI::SetNextWindowPos(int(locatorWinPos.x), int(locatorWinPos.y), wasActive ? UI::Cond::Appearing : UI::Cond::Always);
    UI::SetNextWindowSize(int(winSize.x), int(winSize.y), UI::Cond::Always);
    if (UI::Begin("cp locator", g_DrawLocator, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoResize)) {
        wasActive = UI::IsWindowFocused();
        if (wasActive) {
            locatorNewWinPos = UI::GetWindowPos();// * UI::GetScale();
            S_CustomPos = ScreenToML(locatorNewWinPos + winSize / 2.0) + mlPosOffset;
        }
    }
    UI::End();
    UI::PopStyleColor();

    if (GetApp().Network.ClientManiaAppPlayground !is null && CPCountFrame !is null) {
        CPCountFrame.Visible = true;
        CPCountFrame.Controls[0].Visible = g_DrawLocator;
    }
}

mat3 screenToML;
mat3 mlToScreen;
float xExtra;
mat3 s1, s2, s3, s4;
vec2 screen, idealScreen;
const vec2 MLBounds = vec2(160, 90);

void RenderEarly() {
    screen = GetScreen();
    xExtra = Math::Max(0.0, screen.x - (screen.y * 16. / 9.)) / 2.;
    auto xOff = vec2(-1.0 * xExtra, 0);
    idealScreen = screen + xOff * 2.;
    s1 = mat3::Translate(xOff);
    s2 = mat3::Inverse(mat3::Scale(idealScreen)) * s1;
    s3 = mat3::Translate(vec2(-.5)) * s2;
    s4 = mat3::Scale(MLBounds * vec2(2., -2.)) * s3;
    screenToML = s4; // mat3::Translate(xOff) * mat3::Scale(vec2(1.0) / screen) * mat3::Translate(vec2(-.5)) * mat3::Scale(MLBounds * vec2(2., -2.));
    mlToScreen = mat3::Inverse(screenToML);
}

vec2 GetScreen() {
    return vec2(Draw::GetWidth(), Draw::GetHeight());
}

vec2 ScreenToML(vec2 screenPos) {
    return (screenToML * screenPos).xy;
}

vec2 MLToScreen(vec2 MLPos) {
    return (mlToScreen * MLPos).xy;
}
