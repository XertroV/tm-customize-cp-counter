const string CheckpointPageName = "UIModule_Race_LapsCounter";
bool CanAccessMLElements = false;

void CMapLoop() {
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto net = app.Network;
    while (true) {
        yield();
        CanAccessMLElements = false;
        while (net.ClientManiaAppPlayground is null) yield();
        AwaitGetMLObjs();
        CanAccessMLElements = true;
        while (net.ClientManiaAppPlayground !is null && CPCountFrame !is null) yield();
        NullifyMLObjs();
    }
}

void NullifyMLObjs() {
    @CPCountFrame = null;
    @CPCountFrameInner = null;
    @CPCountLabel = null;
}

CGameManialinkFrame@ CPCountFrame = null;
CGameManialinkFrame@ CPCountFrameInner = null;
CGameManialinkLabel@ CPCountLabel = null;
vec2 OrigCpFramePos;
CGameManialinkControl::EAlignHorizontal origHorizAlign;
CGameManialinkControl::EAlignVertical origVertAlign;

void AwaitGetMLObjs() {
    auto app = GetApp();
    auto net = cast<CTrackManiaNetwork>(app.Network);
    if (net.ClientManiaAppPlayground is null) throw('null cmap');
    auto cmap = net.ClientManiaAppPlayground;
    while (net.ClientManiaAppPlayground !is null && cmap.UILayers.Length < 7) yield();
    if (net.ClientManiaAppPlayground is null) return;
    uint count = 0;
    while (CPCountFrame is null && net.ClientManiaAppPlayground !is null && app.CurrentPlayground !is null && count < 50) {
        yield();
        for (uint i = 0; i < cmap.UILayers.Length; i++) {
            auto layer = cmap.UILayers[i];
            if (!layer.IsLocalPageScriptRunning || !layer.IsVisible || layer.LocalPage is null) continue;

            auto frame = cast<CGameManialinkFrame>(layer.LocalPage.GetFirstChild("Race_LapsCounter"));
            if (frame is null) continue;

            @CPCountFrame = frame;
            @CPCountFrameInner = cast<CGameManialinkFrame>(frame.GetFirstChild("frame-checkpoints-counter"));
            @CPCountLabel = cast<CGameManialinkLabel>(frame.GetFirstChild("label-checkpoints-counter"));

            if (CPCountFrameInner !is null) {
                OrigCpFramePos = CPCountFrameInner.RelativePosition_V3;
            }

            if (CPCountLabel !is null) {
                origHorizAlign = CPCountLabel.HorizontalAlign;
                origVertAlign = CPCountLabel.VerticalAlign;
            }

            break;
        }
        count++;
    }
    if (net.ClientManiaAppPlayground is null) return;
    if (CPCountFrame is null) {
        trace('Failed to find CPCountFrame');
        return;
    }
    startnew(SetCPCounterProperties).WithRunContext(Meta::RunContext::AfterScripts);
}

vec3 g_CamDir = vec3(1, 1, 1);
vec3 g_CamVelDir = vec3(1, 1, 1);

void SetCPCounterProperties() {
    auto app = cast<CTrackMania>(GetApp());
    auto net = cast<CTrackManiaNetwork>(app.Network);

    while (net.ClientManiaAppPlayground !is null && CPCountFrame !is null) {
        yield();
        if (!PluginActive) continue;

        // can occasionally be null due to yield, but we need the yield before the continues;
        if (CPCountFrame !is null && CPCountFrameInner !is null && CPCountLabel !is null) {
            if (S_EnableCustomPos) {
                CPCountFrameInner.RelativePosition_V3 = S_CustomPos - CPCountFrame.RelativePosition_V3;
                CPCountFrameInner.RelativeScale = S_RelativeScale;
                CPCountLabel.HorizontalAlign = S_HorizAlign;
                CPCountLabel.VerticalAlign = S_VerticalAlign;
            } else {
                CPCountFrameInner.RelativePosition_V3 = OrigCpFramePos;
                CPCountFrameInner.RelativeScale = 1.0;
                CPCountLabel.HorizontalAlign = origHorizAlign;
                CPCountLabel.VerticalAlign = origVertAlign;
            }
            if (S_ForceOnCpCounter) {
                CPCountFrameInner.Visible = true;
            }
        }
    }
}
