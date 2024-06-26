void Main() {
    startnew(CMapLoop).WithRunContext(Meta::RunContext::AfterScripts);
    // startnew(WatchForCpFrameChangeOfVis).WithRunContext(Meta::RunContext::AfterScripts);
}

/** Called when the plugin is unloaded and completely removed from memory.
*/
void OnDestroyed() { Unload(); }
void OnDisabled() { Unload(); }
void Unload() {
    if (CPCountFrameInner !is null) {
        ResetCpCounterStuff();
    }
}

void ResetCpCounterStuff() {
    CPCountFrameInner.RelativePosition_V3 = OrigCpFramePos;
    CPCountFrameInner.RelativeScale = 1.0;
    CPCountLabel.VerticalAlign = CGameManialinkControl::EAlignVertical::VCenter;
    CPCountLabel.HorizontalAlign = CGameManialinkControl::EAlignHorizontal::Right;
    // NullifyMLObjs();
}

void OnEnabled() {
    Main();
}

void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg);
    trace("Notified: " + msg);
}

void NotifyError(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Error", msg, vec4(.9, .3, .1, .3), 15000);
}

void NotifyWarning(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Warning", msg, vec4(.9, .6, .2, .3), 15000);
}



const string PluginIcon = Icons::ArrowUp;
const string MenuTitle = "\\$c8f" + PluginIcon + "\\$z " + Meta::ExecutingPlugin().Name;


[Setting hidden]
bool PluginActive = true;

/** Render function called every frame intended only for menu items in `UI`. */
void RenderMenu() {
    if (UI::MenuItem(MenuTitle, "", PluginActive)) {
        PluginActive = !PluginActive;
        if (!PluginActive) Unload();
    }
}


void Render() {
    DrawLocator();
}




void AddSimpleTooltip(const string &in msg) {
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text(msg);
        UI::EndTooltip();
    }
}
