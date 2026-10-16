do
    local getinfo = getinfo or debug.getinfo
    local DEBUG = false
    local Hooked = {}
    local Detected, Kill

    setthreadidentity(2)

    for i, v in getgc(true) do
        if typeof(v) == "table" then
            local DetectFunc = rawget(v, "Detected")
            local KillFunc = rawget(v, "Kill")
            if typeof(DetectFunc) == "function" and not Detected then
                Detected = DetectFunc
                hookfunction(Detected, function(Action, Info, NoCrash) return true end)
                table.insert(Hooked, Detected)
            end
            if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
                Kill = KillFunc
                hookfunction(Kill, function(Info) end)
                table.insert(Hooked, Kill)
            end
        end
    end

    local Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
        local LevelOrFunc = ...
        if Detected and LevelOrFunc == Detected then
            return coroutine.yield(coroutine.running())
        end
        return Old(...)
    end))
    setthreadidentity(7)
end

local Arvn = loadstring(game:HttpGet("https://raw.githubusercontent.com/zmpa/arvnlib/refs/heads/main/main.lua"))()

local H = {}

do
    H.Players           = game:GetService("Players")
    H.RunService        = game:GetService("RunService")
    H.UserInputService  = game:GetService("UserInputService")
    H.Lighting          = game:GetService("Lighting")
    H.TeleportService   = game:GetService("TeleportService")
    H.HttpService       = game:GetService("HttpService")
    H.ReplicatedStorage = game:GetService("ReplicatedStorage")
    H.CoreGui           = game:GetService("CoreGui")
    H.Workspace         = game:GetService("Workspace")
    H.LocalPlayer       = H.Players.LocalPlayer
    H.Camera            = workspace.CurrentCamera
    H.Mouse             = H.LocalPlayer:GetMouse()
    H.Flags             = Arvn.Flags

    H.Flags.NoSpread           = H.Flags.NoSpread or false
    H.Flags.OrbitEnabled       = H.Flags.OrbitEnabled or false
    H.Flags.SilentAimHitChance = H.Flags.SilentAimHitChance or 100

    H.RageMethod = "Method 2"

    H.Connections     = {}
    H.ESPObjects      = {}
    H.TracerObjects   = {}
    H.Target          = nil
    H.SilentCachedPart= nil
    H.SilentLastScan  = 0
    H.NoclipConn      = nil
    H.AntiAFKConn     = nil
    H.SpeedConn       = nil
    H.SpeedBV         = nil
    H.FOVCircle       = nil
    H.SilentFOVCircle = nil
    H.Watermark       = nil
    H.Spectating      = false
    H.AntiStompDebounce = 0
    H.ESPLastHealthCheck = 0
    H.ESPNeedsRebuild = false
    H.RapidFireLast   = 0
    H.RapidFireDone   = {}
    H.RapidFireConns  = {}
    H.AutoStompLast   = {}
    H.MainRemote      = nil
    H.FlyActive       = false
    H.HitboxConn      = nil
    H.TriggerBotLast  = 0
    H.Whitelist       = {}
    H.WL_GUI          = nil
    H.WL_CONN         = nil

    H.OrbitConn       = nil
    H.OrbitAngle      = 0
    H.OrbitRandXValue = 0
    H.OrbitRandZValue = 0
    H.OrbitWobble1    = 0
    H.OrbitWobble2    = 0
    H.OrbitWobble3    = 0
    H.OrbitWobble4    = 0
    H.OrbitLastRand   = 0
    H.OrbitSavedCF    = nil
    H.OrbitFirstTarget= nil
    H.OrbitVel        = Vector3.zero
    H.OrbitRNG        = Random.new(os.clock() * 1e6)
    H.OrbitViewIndex  = 0
    H.OrbitViewConn   = nil

    H.VoidLoopRunning     = false
    H.VoidLoopSavedPos    = nil
    H.VoidLoopCurrentPos  = Vector3.zero
    H.VoidLoopTargetPos   = Vector3.zero
    H.VoidLoopDiveLeft    = 0
    H.VoidLoopLastRefresh = 0
    H.VoidLoopAnchorPlayer= nil
    H.VoidLoopAnchorSince = 0
    H.VoidLoopOrbitDir    = 1
    H.VoidLoopOrbitPhase  = 0
    H.VoidLoopBurstLeft   = 0
    H.VoidLoopBurstVec    = Vector3.zero
    H.VoidLoopConn        = nil

    H.VoidLoopCFG = {
        active = false, speed = 42000, height = 8200, radius = 1800,
        diveChance = 0.42, diveDepth = 58000, targetPlayer = 0.90,
        refresh = 0.9, jitter = 40, spread = 0.55, orbitBias = 0.35,
        stickiness = 2.4, burstChance = 0.18, burstPower = 3.5,
    }

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(H.Workspace, "FallenPartsDestroyHeight", -999999999)
        else
            H.Workspace.FallenPartsDestroyHeight = -999999999
        end
    end)

    H.RageTargets          = {}
    H.RageTargetReady      = {}
    H.RageWaitingRespawn   = {}
    H.RageTargetOriginalCF = {}
    H.RageLastFire         = 0
    H.RageLastStomp        = {}
    H.RageLastStompAll     = 0
    H.RageSpectateConn     = nil
    H.RageTPLast           = {}
    H.RageTPQueue          = nil
    H.RageM1LastFire       = 0
    H.RageM2LastFire       = 0

    H.CFG = {
        RAGE_FIRE_RATE = 0.05,
        M1_FIRE_RATE = 0.08,
        M2_FIRE_RATE = 0.05,
        MAX_RAGE_TARGETS = 3,
        FF_CLEAR_DELAY = 0.12,
        SENTRY_Y = 900,
        SENTRY_RADIUS = 150,
        SENTRY_FIRE_RATE = 0.02,
        SENTRY_LOCK_TIME = 15,
        ARC_SEGS = 24,
        ARC_STRANDS = 4,
        ARC_DROP = 0.38,
        ARC_SPREAD = 4.5,
        GUN_ORDER = { "double", "db", "tactical", "revolver" },
        SENTRY_BLOCK = {
            wallet = true, money = true, cash = true, phone = true,
            knife = true, fist = true, bat = true, bottle = true,
            food = true, drink = true, mask = true, box = true,
        },
    }

    H.sentryTarget     = nil
    H.sentryLockUntil  = 0
    H.sentrySavedCF    = nil
    H.sentryLastFire   = 0
    H.sentryLastHp     = 100
    H.sentryVoided     = false
    H.sentryReturning  = false
    H.sentryGunIndex   = 1
    H.sentryAngle      = 0
    H.sentryCenter     = nil
    H.sentryNextChange = 0

    H.HAS_DRAWING = pcall(function()
        if not Drawing then error("no drawing") end
        local t = Drawing.new("Square")
        t.Visible = false
        t:Remove()
    end)

    H.HAS_QUAD = pcall(function()
        local q = Drawing.new("Quad")
        q.Visible = false
        q:Remove()
    end)

    H.oldLighting = {
        Brightness = H.Lighting.Brightness,
        ClockTime = H.Lighting.ClockTime,
        Ambient = H.Lighting.Ambient,
        OutdoorAmbient = H.Lighting.OutdoorAmbient,
        FogEnd = H.Lighting.FogEnd,
        FogStart = H.Lighting.FogStart,
    }
end

do
    local Players = H.Players
    local LocalPlayer = H.LocalPlayer
    local Camera = H.Camera
    local UserInputService = H.UserInputService

    function H.NormalizeColor(v, fallback)
        fallback = fallback or Color3.new(1, 1, 1)
        if typeof(v) == "Color3" then return v end
        if type(v) == "string" then
            local h = string.gsub(v, "#", "")
            local r, g, b = tonumber(string.sub(h, 1, 2), 16), tonumber(string.sub(h, 3, 4), 16), tonumber(string.sub(h, 5, 6), 16)
            if r and g and b then return Color3.fromRGB(r, g, b) end
            return fallback
        end
        if type(v) == "table" then
            if v.Color and typeof(v.Color) == "Color3" then return v.Color end
            if v[1] and typeof(v[1]) == "Color3" then return v[1] end
            if v.color and typeof(v.color) == "Color3" then return v.color end
        end
        return fallback
    end

    function H.AddConn(c)
        table.insert(H.Connections, c)
        return c
    end

    function H.SafeCall(fn, ...)
        local ok, err = pcall(fn, ...)
        if not ok then warn("[houhou] " .. tostring(err)) end
        return ok, err
    end

    function H.IsFinite(n)
        return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
    end

    function H.IsFiniteVec2(v)
        return typeof(v) == "Vector2" and H.IsFinite(v.X) and H.IsFinite(v.Y)
    end

    function H.GetHum()
        local c = LocalPlayer.Character
        return c and c:FindFirstChildOfClass("Humanoid") or nil
    end

    function H.GetHRP()
        local c = LocalPlayer.Character
        return c and c:FindFirstChild("HumanoidRootPart") or nil
    end

    function H.IsAlive(plr)
        local c = plr and plr.Character
        if not c then return false end
        local h = c:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end

    function H.IsKO(plr)
        local c = plr and plr.Character
        if not c then return false, false end
        local be = c:FindFirstChild("BodyEffects")
        local isKO = false
        if be then
            local ko = be:FindFirstChild("K.O") or be:FindFirstChild("Knocked")
                or be:FindFirstChild("k.o") or be:FindFirstChild("KO")
            if ko and ko.Value == true then isKO = true end
        end
        local hum = c:FindFirstChildOfClass("Humanoid")
        local isDowned = hum and hum:GetState() == Enum.HumanoidStateType.Physics
        local isGrabbed = c:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
        return (isKO or isDowned), isGrabbed
    end

    function H.IsKnocked(plr)
        return (H.IsKO(plr))
    end

    function H.HasTeam(plr)
        return plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team
    end

    function H.IsWhitelisted(plr)
        if not plr then return false end
        return H.Whitelist[plr.UserId] == true or H.Whitelist[plr.Name] == true
    end

    function H.HasForceField(plr)
        local c = plr and plr.Character
        if not c then return false end
        if c:FindFirstChildOfClass("ForceField") ~= nil then return true end
        local be = c:FindFirstChild("BodyEffects")
        if be then
            local ff = be:FindFirstChild("ForceField")
            if ff and (ff:IsA("BoolValue") and ff.Value or ff:IsA("ForceField")) then
                return true
            end
        end
        return false
    end

    function H.GetTargetPart(plr, partName)
        local c = plr and plr.Character
        if not c then return nil end
        if partName == "Closest" then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            local head = c:FindFirstChild("Head")
            if head and hrp then
                local dH = (Camera.CFrame.Position - head.Position).Magnitude
                local dR = (Camera.CFrame.Position - hrp.Position).Magnitude
                return dH < dR and head or hrp
            end
            return head or hrp
        end
        if partName == "Head" then return c:FindFirstChild("Head") end
        return c:FindFirstChild(partName)
    end

    function H.IsVisible(part)
        if not part then return false end
        local origin = Camera.CFrame.Position
        local dir = part.Position - origin
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
        local result = workspace:Raycast(origin, dir, params)
        if result then return result.Instance:IsDescendantOf(part.Parent) end
        return true
    end

    function H.WorldToScreen(pos)
        if not Camera then return Vector2.new(0, 0), false end
        local ok, v2, onScreen = pcall(function() return Camera:WorldToViewportPoint(pos) end)
        if not ok or not v2 then return Vector2.new(0, 0), false end
        if not H.IsFinite(v2.X) or not H.IsFinite(v2.Y) or not H.IsFinite(v2.Z) then
            return Vector2.new(0, 0), false
        end
        return Vector2.new(v2.X, v2.Y), (onScreen and v2.Z > 0)
    end

    function H.GetMousePos() return UserInputService:GetMouseLocation() end

    function H.resolvePlayer(flagVal)
        if typeof(flagVal) == "Instance" and flagVal:IsA("Player") then return flagVal end
        if type(flagVal) == "string" then
            local direct = Players:FindFirstChild(flagVal)
            if direct then return direct end
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == flagVal or p.DisplayName == flagVal then return p end
            end
        end
        return nil
    end
end

do
    local Players = H.Players
    local LocalPlayer = H.LocalPlayer
    local RunService = H.RunService
    local Camera = H.Camera

    H.OrbitStates = {
        Enum.HumanoidStateType.Landed,
        Enum.HumanoidStateType.Running,
        Enum.HumanoidStateType.RunningNoPhysics,
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.GettingUp,
        Enum.HumanoidStateType.Jumping,
        Enum.HumanoidStateType.Seated,
        Enum.HumanoidStateType.PlatformStanding,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.FallingDown,
    }

    function H.OrbitGetTargets()
        local list = {}
        for i = 1, 3 do
            local v = H.Flags["OrbitTarget" .. i]
            if v then
                local plr = H.resolvePlayer(v)
                if plr and plr ~= LocalPlayer then
                    table.insert(list, plr)
                end
            end
        end
        return list
    end

    function H.OrbitGetFirstValid()
        for _, t in ipairs(H.OrbitGetTargets()) do
            if H.IsAlive(t) and not H.HasForceField(t) then return t end
        end
        return nil
    end

    function H.OrbitDisableStates(hum)
        if not hum then return end
        for _, s in ipairs(H.OrbitStates) do
            pcall(function() hum:SetStateEnabled(s, false) end)
        end
    end

    function H.OrbitRestoreStates(hum)
        if not hum then return end
        for _, s in ipairs(H.OrbitStates) do
            pcall(function() hum:SetStateEnabled(s, true) end)
        end
        pcall(function()
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end

    function H.OrbitNewRandomValue(prev, range)
        local v
        local tries = 0
        repeat
            v = H.OrbitRNG:NextNumber(-range, range)
            tries = tries + 1
        until math.abs(v - prev) > (range * 0.15) or tries > 10
        return v
    end

    function H.OrbitRefreshRandom()
        H.OrbitRandZValue = math.rad(H.OrbitNewRandomValue(H.OrbitRandZValue, H.Flags.OrbitRandZ or 90))
        H.OrbitRandXValue = math.rad(H.OrbitNewRandomValue(H.OrbitRandXValue, H.Flags.OrbitRandX or 60))
        H.OrbitWobble1 = H.OrbitRNG:NextNumber(0.4, 1.6)
        H.OrbitWobble2 = H.OrbitRNG:NextNumber(0.4, 1.6)
        H.OrbitWobble3 = H.OrbitRNG:NextNumber(0.6, 2.2)
        H.OrbitWobble4 = H.OrbitRNG:NextNumber(0.6, 2.2)
        H.OrbitLastRand = tick()
    end

    function H.StopOrbitView()
        if H.OrbitViewConn then H.OrbitViewConn:Disconnect() H.OrbitViewConn = nil end
        H.OrbitViewIndex = 0
    end

    function H.StopOrbit()
        if H.OrbitConn then H.OrbitConn:Disconnect() H.OrbitConn = nil end
        H.StopOrbitView()
        local hum = H.GetHum()
        H.OrbitRestoreStates(hum)
        if H.OrbitSavedCF then
            local hrp = H.GetHRP()
            if hrp then
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = H.OrbitSavedCF
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end
        H.OrbitSavedCF = nil
        H.OrbitVel = Vector3.zero
        H.OrbitFirstTarget = nil
    end

    function H.StartOrbitViewForIndex()
        if H.OrbitViewConn then H.OrbitViewConn:Disconnect() H.OrbitViewConn = nil end
        if H.OrbitViewIndex == 0 then return end
        H.OrbitViewConn = RunService.RenderStepped:Connect(function()
            if H.OrbitViewIndex == 0 then return end
            local plr = H.resolvePlayer(H.Flags["OrbitTarget" .. H.OrbitViewIndex])
            if not plr or not plr.Character then return end
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() Camera.CameraSubject = hum end) end
        end)
    end

    function H.CycleOrbitView()
        local targets = H.OrbitGetTargets()
        if #targets == 0 then
            H.StopOrbitView()
            local hum = H.GetHum()
            if hum then pcall(function() Camera.CameraSubject = hum end) end
            return
        end
        H.OrbitViewIndex = H.OrbitViewIndex + 1
        if H.OrbitViewIndex > #targets then
            H.StopOrbitView()
            local hum = H.GetHum()
            if hum then pcall(function() Camera.CameraSubject = hum end) end
            return
        end
        H.StartOrbitViewForIndex()
    end

    function H.StartOrbit()
        H.StopOrbit()
        local hrp = H.GetHRP()
        if not hrp then return end

        H.OrbitSavedCF = hrp.CFrame
        H.OrbitAngle = H.OrbitRNG:NextNumber(0, math.pi * 2)
        H.OrbitRandZValue = 0
        H.OrbitRandXValue = 0
        H.OrbitVel = Vector3.zero
        H.OrbitFirstTarget = H.OrbitGetFirstValid()
        H.OrbitRefreshRandom()

        local hum = H.GetHum()
        if hum then
            H.OrbitDisableStates(hum)
            pcall(function()
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
            end)
        end

        H.OrbitConn = RunService.RenderStepped:Connect(function(dt)
            if not H.Flags.OrbitEnabled then return end
            dt = math.clamp(dt, 1/240, 0.1)

            local target = H.OrbitGetFirstValid() or H.OrbitFirstTarget
            if not target or not H.IsAlive(target) then return end

            local myHRP = H.GetHRP()
            local tHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP or not tHRP then return end

            local hum = H.GetHum()
            if hum then
                if hum.PlatformStand then pcall(function() hum.PlatformStand = false end) end
                if hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Freefall) end)
                end
            end

            local chaos = (H.Flags.OrbitChaos or 70) / 100
            local refreshTime = 0.35 - (chaos * 0.30)
            if refreshTime < 0.04 then refreshTime = 0.04 end
            if tick() - H.OrbitLastRand > refreshTime then H.OrbitRefreshRandom() end

            local radius = math.max(H.Flags.OrbitDistance or 14, 0.5)
            local angSpeed = (H.Flags.OrbitSpeed or 250) / radius
            H.OrbitAngle = H.OrbitAngle + angSpeed * dt

            local angleJitter = math.sin(tick() * 3.7) * 0.15 * (0.5 + chaos)
            local finalAngle = H.OrbitAngle + H.OrbitRandZValue + angleJitter

            local distBreath = math.sin(H.OrbitAngle * H.OrbitWobble1 * 0.7) * (chaos * 3)
            local dist = (H.Flags.OrbitDistance or 14) + distBreath

            local x = math.cos(finalAngle) * dist
            local z = math.sin(finalAngle) * dist

            local tiltAmp = math.sin(H.OrbitRandXValue) * (10 + chaos * 25)
            local wobbleY = math.sin(H.OrbitAngle * H.OrbitWobble1) * tiltAmp
                + math.sin(H.OrbitAngle * H.OrbitWobble3 * 1.7) * (chaos * 10)
                + math.cos(H.OrbitAngle * 0.9) * (chaos * 4)
            local y = (H.Flags.OrbitHeight or 2) + wobbleY

            local wobbleXZ = chaos * 8
            local xJit = math.sin(H.OrbitAngle * H.OrbitWobble2) * wobbleXZ
                + math.cos(H.OrbitAngle * H.OrbitWobble4 * 2.3) * (chaos * 3)
            local zJit = math.cos(H.OrbitAngle * H.OrbitWobble4) * wobbleXZ
                + math.sin(H.OrbitAngle * H.OrbitWobble2 * 2.1) * (chaos * 3)

            local desiredPos = tHRP.Position + Vector3.new(x + xJit, y, z + zJit)
            local currentPos = myHRP.Position
            local delta = desiredPos - currentPos

            local targetVel = tHRP.AssemblyLinearVelocity or Vector3.zero
            local lookAhead = tHRP.Position + targetVel * 0.15

            local maxSpeed = math.max((H.Flags.OrbitSpeed or 250) * 1.5, 80)
            local instantVel = delta * 13
            if instantVel.Magnitude > maxSpeed then instantVel = instantVel.Unit * maxSpeed end

            H.OrbitVel = H.OrbitVel:Lerp(instantVel, math.clamp(dt * 16, 0, 1))

            local lookCF = CFrame.new(currentPos, lookAhead)
            local rollSpeed = 1.5 + chaos * 1.2
            local addRoll = math.rad(math.sin(H.OrbitAngle * rollSpeed) * (20 + chaos * 35))
            local addPitch = math.rad(math.cos(H.OrbitAngle * 1.2) * (10 + chaos * 20))
            local addYaw = math.rad(math.sin(H.OrbitAngle * 0.8) * (5 + chaos * 10))
            local targetCF = lookCF * CFrame.Angles(addPitch, addYaw, addRoll)

            local rotAlpha = math.clamp(dt * 11, 0, 1)
            local finalCF = myHRP.CFrame:Lerp(targetCF, rotAlpha)
            finalCF = CFrame.new(currentPos + H.OrbitVel * dt) * (finalCF - finalCF.Position)

            pcall(function()
                myHRP.CFrame = finalCF
                myHRP.AssemblyLinearVelocity = H.OrbitVel
                myHRP.AssemblyAngularVelocity = Vector3.zero
            end)

            if H.Flags.OrbitNoclip then
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                    end
                end
            end
        end)
    end
end

do
    local Players = H.Players
    local LocalPlayer = H.LocalPlayer
    local Camera = H.Camera
    local RunService = H.RunService
    local UserInputService = H.UserInputService

    function H.ApplyAimbot()
        H.Camera = workspace.CurrentCamera or Camera
        if not H.Flags.AimbotEnabled then H.Target = nil return end

        local function PassesChecksForSticky(plr)
            if not plr or plr == LocalPlayer then return false end
            if not H.IsAlive(plr) then return false end
            if H.Flags.AimbotTeamCheck and H.HasTeam(plr) then return false end
            if H.Flags.AimbotKnockedCheck and H.IsKnocked(plr) then return false end
            if H.Flags.AimbotHealthCheck then
                local h = plr.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health < (H.Flags.AimbotMinHealth or 0) then return false end
            end
            return true
        end

        local function PassesChecks(plr)
            if not PassesChecksForSticky(plr) then return false end
            if H.Flags.AimbotWallCheck then
                local part = H.GetTargetPart(plr, H.Flags.AimbotHitPart or "Head")
                if not H.IsVisible(part) then return false end
            end
            return true
        end

        if H.Target and (H.Target == LocalPlayer or not PassesChecksForSticky(H.Target)) then H.Target = nil end

        if not (H.Flags.AimbotStickyAim and H.Target) then
            local method = H.Flags.AimbotMethod or "Closest to Mouse"
            local closest, best = nil, math.huge
            local mouse = H.GetMousePos()
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and PassesChecks(plr) then
                    local part = H.GetTargetPart(plr, H.Flags.AimbotHitPart or "Head")
                    if part then
                        local d
                        if method == "Closest Distance" then
                            d = (Camera.CFrame.Position - part.Position).Magnitude
                        elseif method == "FOV" then
                            local sp, onScreen = H.WorldToScreen(part.Position)
                            if onScreen then d = (sp - center).Magnitude end
                        else
                            local sp, onScreen = H.WorldToScreen(part.Position)
                            if onScreen then d = (sp - mouse).Magnitude end
                        end
                        if d and d < best then best = d; closest = plr end
                    end
                end
            end
            H.Target = closest
            if H.Target == LocalPlayer then H.Target = nil end
        end

        if not H.Target or not H.IsAlive(H.Target) then return end
        local part = H.GetTargetPart(H.Target, H.Flags.AimbotHitPart or "Head")
        if not part then return end

        local aimPos = part.Position
        if H.Flags.AimbotPrediction then
            local vel = part.AssemblyLinearVelocity or Vector3.zero
            local predTime = (H.Flags.AimbotPredictionValue or 16) / 100
            aimPos = aimPos + vel * predTime
        end

        if (H.Flags.AimbotType or "Camera") == "Camera" then
            local camPos = Camera.CFrame.Position
            local targetCF = CFrame.new(camPos, aimPos)
            if H.Flags.AimbotSmoothing and H.Flags.AimbotIndependentAxes then
                local cur = Camera.CFrame.LookVector
                local toTarget = (aimPos - camPos)
                if toTarget.Magnitude < 0.01 then return end
                local targetDir = toTarget.Unit
                local curYaw = math.atan2(cur.X, cur.Z)
                local curPitch = math.asin(math.clamp(cur.Y, -1, 1))
                local tgtYaw = math.atan2(targetDir.X, targetDir.Z)
                local tgtPitch = math.asin(math.clamp(targetDir.Y, -1, 1))
                local yawAlpha = math.clamp(1 / math.max(H.Flags.AimbotSmoothX or 15, 1), 0.05, 1)
                local pitchAlpha = math.clamp(1 / math.max(H.Flags.AimbotSmoothY or 15, 1), 0.05, 1)
                local yawDelta = tgtYaw - curYaw
                if yawDelta > math.pi then yawDelta = yawDelta - 2 * math.pi
                elseif yawDelta < -math.pi then yawDelta = yawDelta + 2 * math.pi end
                local newYaw = curYaw + yawDelta * yawAlpha
                local newPitch = curPitch + (tgtPitch - curPitch) * pitchAlpha
                local cosPitch = math.cos(newPitch)
                local look = Vector3.new(math.sin(newYaw) * cosPitch, math.sin(newPitch), math.cos(newYaw) * cosPitch)
                Camera.CFrame = CFrame.new(camPos, camPos + look)
            elseif H.Flags.AimbotSmoothing then
                local alpha = math.clamp(1 / math.max(H.Flags.AimbotSmoothness or 15, 1), 0.05, 1)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
            else
                Camera.CFrame = targetCF
            end
        else
            if mousemoverel then
                local sp = H.WorldToScreen(aimPos)
                local m = H.GetMousePos()
                local delta = sp - m
                local multX = H.Flags.AimbotSmoothing and (1 / math.max(H.Flags.AimbotIndependentAxes and (H.Flags.AimbotSmoothX or 15) or (H.Flags.AimbotSmoothness or 15), 1)) or 1
                local multY = H.Flags.AimbotSmoothing and (1 / math.max(H.Flags.AimbotIndependentAxes and (H.Flags.AimbotSmoothY or 15) or (H.Flags.AimbotSmoothness or 15), 1)) or 1
                H.SafeCall(mousemoverel, delta.X * multX, delta.Y * multY)
            else
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), 0.2)
            end
        end
    end

    function H.BuildFOVCircle()
        if not H.HAS_DRAWING then return end
        if H.FOVCircle then pcall(function() H.FOVCircle:Remove() end) end
        H.FOVCircle = Drawing.new("Circle")
        H.FOVCircle.Thickness = 2
        H.FOVCircle.NumSides = 64
        H.FOVCircle.Filled = false
        H.FOVCircle.Transparency = 1
        H.FOVCircle.Color = Color3.new(1, 1, 1)
        H.FOVCircle.Visible = false
    end

    function H.UpdateFOVCircle()
        if not H.FOVCircle then return end
        if H.Flags.AimbotShowFOV and H.Flags.AimbotEnabled then
            H.FOVCircle.Visible = true
            H.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            H.FOVCircle.Radius = H.Flags.AimbotFOV or 120
            H.FOVCircle.Color = H.NormalizeColor(H.Flags.AimbotFOVColor, Color3.new(1, 1, 1))
            H.FOVCircle.Transparency = 1
            H.FOVCircle.Thickness = 2
        else
            H.FOVCircle.Visible = false
        end
    end

    function H.BuildSilentFOVCircle()
        if not H.HAS_DRAWING then return end
        if H.SilentFOVCircle then pcall(function() H.SilentFOVCircle:Remove() end) end
        H.SilentFOVCircle = Drawing.new("Circle")
        H.SilentFOVCircle.Thickness = 2
        H.SilentFOVCircle.NumSides = 64
        H.SilentFOVCircle.Filled = false
        H.SilentFOVCircle.Transparency = 1
        H.SilentFOVCircle.Color = Color3.fromRGB(120, 180, 255)
        H.SilentFOVCircle.Visible = false
    end

    function H.UpdateSilentFOVCircle()
        if not H.SilentFOVCircle then return end
        if H.Flags.SilentAimShowFOV and H.Flags.SilentAimEnabled then
            H.SilentFOVCircle.Visible = true
            H.SilentFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            H.SilentFOVCircle.Radius = H.Flags.SilentAimFOV or 150
            H.SilentFOVCircle.Color = H.NormalizeColor(H.Flags.SilentAimFOVColor, Color3.fromRGB(120, 180, 255))
            H.SilentFOVCircle.Transparency = 1
            H.SilentFOVCircle.Thickness = 2
        else
            H.SilentFOVCircle.Visible = false
        end
    end

    function H.SilentScan()
        local now = tick()
        if now - H.SilentLastScan < 0.05 then return H.SilentCachedPart end
        H.SilentLastScan = now
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local camPos = Camera.CFrame.Position
        local bestPart, bestScreen = nil, (H.Flags.SilentAimFOV or 150)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local c = plr.Character
                if c then
                    local skip = false
                    if H.Flags.SilentAimTeamCheck and H.HasTeam(plr) then skip = true end
                    if not skip and H.Flags.SilentAimKnockedCheck and H.IsKnocked(plr) then skip = true end
                    if not skip then
                        local hum = c:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local hrp = c:FindFirstChild("HumanoidRootPart")
                            local head = c:FindFirstChild("Head")
                            local part
                            local mode = H.Flags.SilentAimHitPart or "Head"
                            if mode == "Head" then part = head
                            elseif mode == "HumanoidRootPart" then part = hrp
                            else
                                if head and hrp then
                                    part = (camPos - head.Position).Magnitude < (camPos - hrp.Position).Magnitude and head or hrp
                                else
                                    part = head or hrp
                                end
                            end
                            if part and hrp then
                                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                                if onScreen and sp.Z >= 0 then
                                    local wallOk = true
                                    if H.Flags.SilentAimWallCheck then
                                        if not H.IsVisible(part) then wallOk = false end
                                    end
                                    if wallOk then
                                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                        if d <= bestScreen then
                                            bestScreen = d
                                            bestPart = part
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        H.SilentCachedPart = bestPart
        return H.SilentCachedPart
    end

    function H.InstallSilentHooks()
        if not (hookmetamethod and newcclosure and getnamecallmethod) then return false end
        local check = checkcaller or function() return false end

        pcall(function()
            local oldIndex
            oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                if H.Flags.SilentAimEnabled and not check() and self == H.Mouse then
                    local part = H.SilentCachedPart
                    if part then
                        if key == "Hit" then return CFrame.new(part.Position) end
                        if key == "Target" then return part end
                    end
                end
                return oldIndex(self, key)
            end))
        end)

        pcall(function()
            local oldNC
            oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                if check() then return oldNC(self, ...) end

                local method = getnamecallmethod()
                if not (H.MainRemote and self == H.MainRemote and method == "FireServer") then
                    return oldNC(self, ...)
                end

                local silentOn = H.Flags.SilentAimEnabled == true
                local noSpread = H.Flags.NoSpread == true
                local sentryPart = H.sentryRedirectPart or H.followRedirectPart
                if sentryPart and not sentryPart.Parent then sentryPart = nil end
                if not (silentOn or noSpread or sentryPart) then return oldNC(self, ...) end

                local a = { ... }
                local part = (silentOn and H.SilentCachedPart and H.SilentCachedPart.Parent) and H.SilentCachedPart or nil

                if silentOn and part then
                    local chance = H.Flags.SilentAimHitChance or 100
                    if chance < 100 and math.random(1, 100) > chance then
                        part = nil
                    end
                end

                -- sentry redirect takes priority over normal silent aim
                if sentryPart then part = sentryPart end
                if a[1] == "UpdateMousePosI2" or a[1] == "UpdateMousePosI" or a[1] == "UpdateMousePos" then
                    if part then
                        a[2] = part.Position
                        return oldNC(self, table.unpack(a))
                    end
                    return oldNC(self, ...)
                end

                local function makeOffset2()
                    if noSpread then return Vector3.zero end
                    return Vector3.new(
                        (math.random() - 0.5) * 8.0,
                        (math.random() - 0.5) * 8.0,
                        (math.random() - 0.5) * 8.0
                    )
                end

                if a[1] == "ShootGun" then
                    if typeof(a[3]) == "Vector3" and typeof(a[4]) == "table" then
                        if part then
                            local hitPos = part.Position
                            for _, pellet in ipairs(a[4]) do
                                if type(pellet) == "table" then
                                    local finalPos = hitPos + makeOffset2()
                                    pellet.AimPosition    = finalPos
                                    pellet.RawAimPosition = finalPos
                                    pellet.Result1        = finalPos
                                    pellet.Result2        = part
                                    pellet.Result3        = Vector3.new(0, 1, 0)
                                    pellet.AimLockPart    = part
                                    pellet.HitPart        = part
                                    pellet.HitPosition    = finalPos
                                end
                            end
                            a[5] = hitPos
                            a[6] = part
                            a[7] = Vector3.new(0, 1, 0)
                        elseif noSpread then
                            local sx, sy, sz, n = 0, 0, 0, 0
                            for _, pellet in ipairs(a[4]) do
                                if type(pellet) == "table" and pellet.AimPosition then
                                    sx = sx + pellet.AimPosition.X
                                    sy = sy + pellet.AimPosition.Y
                                    sz = sz + pellet.AimPosition.Z
                                    n = n + 1
                                end
                            end
                            if n > 0 then
                                local avg = Vector3.new(sx/n, sy/n, sz/n)
                                for _, pellet in ipairs(a[4]) do
                                    if type(pellet) == "table" then
                                        pellet.AimPosition    = avg
                                        pellet.RawAimPosition = avg
                                        pellet.Result1        = avg
                                    end
                                end
                            end
                        end
                        return oldNC(self, table.unpack(a))
                    end

                    if typeof(a[3]) == "Vector3" and typeof(a[4]) == "Vector3" then
                        if part then
                            a[4] = part.Position
                            a[5] = part
                            a[6] = Vector3.new(0, 1, 0)
                        end
                        return oldNC(self, table.unpack(a))
                    end

                    -- single-bullet guns (revolver etc.): ShootGun, handle, origin, nil, aimPos, hitPart, normal, range, damage, result1
                    if typeof(a[3]) == "Vector3" and a[4] == nil and typeof(a[5]) == "Vector3" then
                        if part then
                            local hitPos = part.Position
                            a[5] = hitPos
                            a[6] = part
                            a[7] = Vector3.new(0, 1, 0)
                            if typeof(a[10]) == "Vector3" then a[10] = hitPos end
                        end
                        return oldNC(self, table.unpack(a, 1, select("#", ...)))
                    end
                end

                if a[1] == "ShootingGunLetsGo" then
                    if part then
                        local hitPos = part.Position
                        a[3] = hitPos
                        a[4] = { { Position = hitPos, Normal = Vector3.new(0, 1, 0), Instance = part } }
                    end
                    return oldNC(self, table.unpack(a))
                end

                return oldNC(self, ...)
            end))
        end)
        return true
    end
end

do
    local Players = H.Players
    local LocalPlayer = H.LocalPlayer
    local Camera = H.Camera
    local RunService = H.RunService
    local CFG = H.CFG

    function H.GetScaledTextSize(baseSize, minSize, boxHeight)
        if not boxHeight or boxHeight <= 0 then return baseSize end
        local scale = math.clamp(boxHeight / 60, 0.85, 1.7)
        local result = math.floor(baseSize * scale)
        if result < minSize then result = minSize end
        return result
    end

    function H.CreateESP(plr)
        if plr == LocalPlayer then return end
        if not plr.Character then return end
        if not H.IsAlive(plr) then return end
        if H.ESPObjects[plr] then H.RemoveESP(plr) end

        local char = plr.Character
        local obj = {}

        local hl = Instance.new("Highlight")
        hl.Name = "houhouHL"
        hl.FillTransparency = 1
        hl.OutlineTransparency = 1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = char
        hl.Parent = char
        obj.highlight = hl

        if H.HAS_DRAWING then
            obj.box = Drawing.new("Square")
            obj.box.Thickness = 2
            obj.box.Filled = false
            obj.box.Transparency = 1
            obj.box.Color = Color3.new(1, 1, 1)
            obj.box.Visible = false

            obj.boxGlow = {}
            for i = 1, 3 do
                local g = Drawing.new("Square")
                g.Thickness = 2 + i * 3
                g.Filled = false
                g.Transparency = 0.22 / i
                g.Visible = false
                obj.boxGlow[i] = g
            end

            obj.box3dGlow = {}
            for i = 1, 12 do
                local g = Drawing.new("Line")
                g.Thickness = 6
                g.Transparency = 0.25
                g.Visible = false
                obj.box3dGlow[i] = g
            end

            obj.box3d = {}
            for i = 1, 12 do
                local l = Drawing.new("Line")
                l.Thickness = 1.5
                l.Transparency = 1
                l.Visible = false
                obj.box3d[i] = l
            end

            obj.name = Drawing.new("Text")
            obj.name.Size = 16
            obj.name.Center = true
            obj.name.Outline = true
            obj.name.Color = Color3.new(1, 1, 1)
            obj.name.Visible = false

            if H.HAS_QUAD then
                obj.healthBar = Drawing.new("Quad")
                obj.healthBar.Filled = true
                obj.healthBar.Thickness = 0
                obj.healthBar.Transparency = 1
                obj.healthBar.Visible = false
            else
                obj.healthBar = Drawing.new("Square")
                obj.healthBar.Filled = true
                obj.healthBar.Thickness = 0
                obj.healthBar.Transparency = 1
                obj.healthBar.Visible = false
            end

            obj.distance = Drawing.new("Text")
            obj.distance.Size = 14
            obj.distance.Center = true
            obj.distance.Outline = true
            obj.distance.Color = Color3.new(1, 1, 1)
            obj.distance.Visible = false

            obj.toolTxt = Drawing.new("Text")
            obj.toolTxt.Size = 14
            obj.toolTxt.Center = true
            obj.toolTxt.Outline = true
            obj.toolTxt.Color = Color3.fromRGB(0, 255, 0)
            obj.toolTxt.Visible = false
        end

        local head = char:FindFirstChild("Head")
        if head then
            local bb = Instance.new("BillboardGui")
            bb.Name = "houhouBB"
            bb.Adornee = head
            bb.Size = UDim2.new(0, 220, 0, 64)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.LightInfluence = 0
            bb.Parent = char

            local nameLbl = Instance.new("TextLabel", bb)
            nameLbl.Name = "Name"
            nameLbl.Size = UDim2.new(1, 0, 0, 16)
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextColor3 = Color3.new(1, 1, 1)
            nameLbl.TextStrokeTransparency = 0
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 13
            nameLbl.Visible = false

            local distLbl = Instance.new("TextLabel", bb)
            distLbl.Name = "Dist"
            distLbl.Size = UDim2.new(1, 0, 0, 14)
            distLbl.Position = UDim2.new(0, 0, 0, 16)
            distLbl.BackgroundTransparency = 1
            distLbl.TextColor3 = Color3.fromRGB(255, 90, 90)
            distLbl.TextStrokeTransparency = 0
            distLbl.Font = Enum.Font.GothamBold
            distLbl.TextSize = 12
            distLbl.Visible = false

            local toolLbl = Instance.new("TextLabel", bb)
            toolLbl.Name = "Tool"
            toolLbl.Size = UDim2.new(1, 0, 0, 14)
            toolLbl.Position = UDim2.new(0, 0, 0, 30)
            toolLbl.BackgroundTransparency = 1
            toolLbl.TextColor3 = Color3.fromRGB(120, 255, 120)
            toolLbl.TextStrokeTransparency = 0
            toolLbl.Font = Enum.Font.Gotham
            toolLbl.TextSize = 12
            toolLbl.Visible = false

            local hpBg = Instance.new("Frame", bb)
            hpBg.Name = "HPBg"
            hpBg.Size = UDim2.new(0.7, 0, 0, 6)
            hpBg.Position = UDim2.new(0.15, 0, 0, 46)
            hpBg.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            hpBg.BorderSizePixel = 0
            hpBg.Visible = false

            local hpFill = Instance.new("Frame", hpBg)
            hpFill.Name = "HPFill"
            hpFill.Size = UDim2.new(1, 0, 1, 0)
            hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            hpFill.BorderSizePixel = 0

            obj.billboard = bb
            obj.nameLbl = nameLbl
            obj.distLbl = distLbl
            obj.toolLbl = toolLbl
            obj.hpBg = hpBg
            obj.hpFill = hpFill
        end

        H.ESPObjects[plr] = obj

        if H.HAS_DRAWING then
            local tracer = { lines = {} }
            local total = CFG.ARC_SEGS * CFG.ARC_STRANDS
            for i = 1, total do
                local l = Drawing.new("Line")
                l.Thickness = 1.4
                l.Transparency = 0.12
                l.Visible = false
                tracer.lines[i] = l
            end
            H.TracerObjects[plr] = tracer
        end
    end

    function H.RemoveESP(plr)
        local obj = H.ESPObjects[plr]
        if obj then
            if obj.box then pcall(function() obj.box:Remove() end) end
            if obj.box3d then for _, l in ipairs(obj.box3d) do pcall(function() l:Remove() end) end end
            if obj.boxGlow then for _, g in ipairs(obj.boxGlow) do pcall(function() g:Remove() end) end end
            if obj.box3dGlow then for _, g in ipairs(obj.box3dGlow) do pcall(function() g:Remove() end) end end
            if obj.name then pcall(function() obj.name:Remove() end) end
            if obj.healthBar then pcall(function() obj.healthBar:Remove() end) end
            if obj.distance then pcall(function() obj.distance:Remove() end) end
            if obj.toolTxt then pcall(function() obj.toolTxt:Remove() end) end
            if obj.highlight then pcall(function() obj.highlight:Destroy() end) end
            if obj.billboard then pcall(function() obj.billboard:Destroy() end) end
            H.ESPObjects[plr] = nil
        end
        local tr = H.TracerObjects[plr]
        if tr then
            if tr.lines then
                for _, l in ipairs(tr.lines) do pcall(function() l:Remove() end) end
            end
            H.TracerObjects[plr] = nil
        end
    end

    function H.HideESP(obj)
        if not obj then return end
        if obj.box then obj.box.Visible = false end
        if obj.box3d then for _, l in ipairs(obj.box3d) do l.Visible = false end end
        if obj.boxGlow then for _, g in ipairs(obj.boxGlow) do g.Visible = false end end
        if obj.box3dGlow then for _, g in ipairs(obj.box3dGlow) do g.Visible = false end end
        if obj.name then obj.name.Visible = false end
        if obj.healthBar then obj.healthBar.Visible = false end
        if obj.distance then obj.distance.Visible = false end
        if obj.toolTxt then obj.toolTxt.Visible = false end
        if obj.highlight then
            obj.highlight.FillTransparency = 1
            obj.highlight.OutlineTransparency = 1
        end
        if obj.nameLbl then obj.nameLbl.Visible = false end
        if obj.distLbl then obj.distLbl.Visible = false end
        if obj.toolLbl then obj.toolLbl.Visible = false end
        if obj.hpBg then obj.hpBg.Visible = false end
    end

    function H.HideAllTracerLines(plr)
        local tr = H.TracerObjects[plr]
        if tr and tr.lines then
            for _, l in ipairs(tr.lines) do l.Visible = false end
        end
    end

    function H.DrawArcBezier(tracer, origin, targetPos, color)
        local dir = targetPos - origin
        local dist = dir.Magnitude
        if dist < 2 then return end

        local ARC    = CFG.ARC_DROP
        local SPREAD = CFG.ARC_SPREAD
        local SEGS   = CFG.ARC_SEGS
        local STR    = CFG.ARC_STRANDS

        local function perp(d)
            local len = d.Magnitude
            if len < 0.001 then return Vector2.new(1, 0) end
            return Vector2.new(-d.Y / len, d.X / len)
        end
        local function bezier(p0, p1, p2, t)
            local u = 1 - t
            return u * u * p0 + 2 * u * t * p1 + t * t * p2
        end

        local n = perp(dir)
        local mid = origin:Lerp(targetPos, 0.45)
        local drop = dist * ARC
        local ctrl = mid
            + Vector2.new(0, drop)
            - dir.Unit * (dist * 0.08)

        local half = (STR - 1) * 0.5
        local idx = 1
        for s = 1, STR do
            local sideOffset = (s - 1 - half) * SPREAD
            local off = n * sideOffset
            local p0 = origin + off * 0.15
            local p1 = ctrl + off * 0.6
            local p2 = targetPos
            for i = 1, SEGS do
                local t0 = (i - 1) / SEGS
                local t1 = i / SEGS
                local a = bezier(p0, p1, p2, t0)
                local b = bezier(p0, p1, p2, t1)
                local line = tracer.lines[idx]
                if line then
                    line.From = a
                    line.To = b
                    line.Color = color
                    line.Thickness = 1.4
                    line.Visible = true
                end
                idx = idx + 1
                if idx > #tracer.lines then return end
            end
        end
    end

    function H.UpdateTracers(plr, screenPos)
        local tracer = H.TracerObjects[plr]
        if not tracer or not tracer.lines then return end
        for _, l in ipairs(tracer.lines) do l.Visible = false end
        local tType = H.Flags.ESPTracerType or "Off"
        if tType == "Off" then return end
        if not H.IsFiniteVec2(screenPos) then return end

        local origin
        local originType = H.Flags.ESPTracerOrigin or "Bottom"
        if originType == "Cursor" then origin = H.GetMousePos()
        elseif originType == "Center" then origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) end

        local color = H.NormalizeColor(H.Flags.ESPTracerColor, Color3.new(1, 1, 1))

        if tType == "Straight" then
            local l = tracer.lines[1]
            if l then
                l.From = origin
                l.To = screenPos
                l.Color = color
                l.Thickness = 1
                l.Visible = true
            end
        elseif tType == "Arc" then
            H.DrawArcBezier(tracer, origin, screenPos, color)
        end
    end

    function H.ResetESP()
        if not H.Flags.ESPEnabled then return end
        for plr in pairs(H.ESPObjects) do pcall(H.RemoveESP, plr) end
        H.ESPObjects = {}
        H.TracerObjects = {}
        task.wait()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and H.IsAlive(plr) then
                pcall(H.CreateESP, plr)
            end
        end
        H.ESPNeedsRebuild = false
    end

    function H.CheckESPHealth()
        if not H.Flags.ESPEnabled then return end
        local now = tick()
        if now - H.ESPLastHealthCheck < 8 then return end
        H.ESPLastHealthCheck = now
        for plr, obj in pairs(H.ESPObjects) do
            if not plr.Parent then H.ESPNeedsRebuild = true break end
            if not plr.Character or not H.IsAlive(plr) then H.ESPNeedsRebuild = true break end
            if obj.box then
                local ok = pcall(function()
                    local _ = obj.box.Visible
                    obj.box.Visible = obj.box.Visible
                end)
                if not ok then H.ESPNeedsRebuild = true break end
            end
        end
        if H.ESPNeedsRebuild then task.spawn(H.ResetESP) end
    end

    function H.UpdateESP()
        if not H.Flags.ESPEnabled then
            if next(H.ESPObjects) then
                for plr in pairs(H.ESPObjects) do H.RemoveESP(plr) end
            end
            return
        end
        local snapshot = {}
        local present = {}
        for _, plr in ipairs(Players:GetPlayers()) do table.insert(snapshot, plr) present[plr] = true end
        for plr in pairs(H.ESPObjects) do
            if not present[plr] then H.RemoveESP(plr) end
        end
        for plr in pairs(H.TracerObjects) do
            if not present[plr] then H.RemoveESP(plr) end
        end
        for _, plr in ipairs(snapshot) do
            if plr ~= LocalPlayer then
                if not plr.Parent then
                    H.RemoveESP(plr)
                elseif not plr.Character or not H.IsAlive(plr) then
                    H.RemoveESP(plr)
                elseif H.Flags.ESPTeamCheck and H.HasTeam(plr) then
                    if H.ESPObjects[plr] then H.HideESP(H.ESPObjects[plr]) end
                    H.HideAllTracerLines(plr)
                else
                    if not H.ESPObjects[plr] then pcall(H.CreateESP, plr) end
                    local obj = H.ESPObjects[plr]
                    if obj then
                        local char = plr.Character
                        if not char then
                            H.RemoveESP(plr)
                        else
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            local head = char:FindFirstChild("Head")
                            if not hrp or not hum or not head then
                                H.RemoveESP(plr)
                            else
                                if obj.highlight and obj.highlight.Adornee ~= char then
                                    obj.highlight.Adornee = char
                                    obj.highlight.Parent = char
                                end
                                if obj.billboard and obj.billboard.Adornee ~= head then
                                    obj.billboard.Adornee = head
                                    obj.billboard.Parent = char
                                end

                                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                                local maxDist = H.Flags.ESPMaxDistance or 500
                                local pos, onScreen = H.WorldToScreen(hrp.Position)
                                local tooFar = not H.Flags.ESPNoLimit and dist > maxDist
                                local offscreen = H.HAS_DRAWING and not onScreen

                                if tooFar or offscreen then
                                    H.HideESP(obj)
                                    H.HideAllTracerLines(plr)
                                else
                                    local topPos = H.WorldToScreen(head.Position + Vector3.new(0, 1, 0))
                                    local botPos = H.WorldToScreen(hrp.Position - Vector3.new(0, 3, 0))
                                    local boxH = math.abs(botPos.Y - topPos.Y)
                                    local boxW = boxH * 0.6
                                    local boxTopY = topPos.Y
                                    local hp = hum.Health
                                    local maxHp = math.max(hum.MaxHealth, 1)
                                    local pct = math.clamp(hp / maxHp, 0, 1)

                                    -- with 3D boxes, anchor the name/health/distance/tool labels to the 3D box's screen bounds
                                    if H.Flags.ESPBoxType == "3D" then
                                        local cf = hrp.CFrame
                                        local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
                                        for _, sx in ipairs({-1, 1}) do
                                            for _, sy in ipairs({-1, 1}) do
                                                for _, sz in ipairs({-1, 1}) do
                                                    local sp = H.WorldToScreen((cf * CFrame.new(sx * 2, sy * 2.75 - 0.25, sz * 1)).Position)
                                                    if sp.X < minX then minX = sp.X end
                                                    if sp.X > maxX then maxX = sp.X end
                                                    if sp.Y < minY then minY = sp.Y end
                                                    if sp.Y > maxY then maxY = sp.Y end
                                                end
                                            end
                                        end
                                        if H.IsFinite(minX) and H.IsFinite(maxX) and H.IsFinite(minY) and H.IsFinite(maxY) then
                                            local cx = (minX + maxX) / 2
                                            boxW = maxX - minX
                                            boxH = maxY - minY
                                            boxTopY = minY
                                            topPos = Vector2.new(cx, minY)
                                            pos = Vector2.new(cx, pos.Y)
                                        end
                                    end
                                    if H.HAS_DRAWING and obj.box then
                                        if H.Flags.ESPBoxType == "2D" and H.IsFinite(boxH) and boxH > 0 and boxH < 5000 then
                                            obj.box.Size = Vector2.new(boxW, boxH)
                                            obj.box.Position = Vector2.new(topPos.X - boxW / 2, boxTopY)
                                            obj.box.Color = H.NormalizeColor(H.Flags.ESPBoxColor, Color3.fromRGB(255, 255, 255))
                                            obj.box.Visible = true
                                            if obj.boxGlow then
                                                for _, g in ipairs(obj.boxGlow) do
                                                    if H.Flags.ESPGlowingBoxes then
                                                        g.Size = obj.box.Size
                                                        g.Position = obj.box.Position
                                                        g.Color = obj.box.Color
                                                        g.Visible = true
                                                    else
                                                        g.Visible = false
                                                    end
                                                end
                                            end
                                        else
                                            obj.box.Visible = false
                                            if obj.boxGlow then for _, g in ipairs(obj.boxGlow) do g.Visible = false end end
                                        end
                                    end

                                    if obj.box3d then
                                        local ok3 = false
                                        if H.Flags.ESPBoxType == "3D" then
                                            local cf = hrp.CFrame
                                            local hx, hy, hz = 2, 2.75, 1
                                            local pts, allOn = {}, true
                                            local idx = 1
                                            for _, sx in ipairs({-1, 1}) do
                                                for _, sy in ipairs({-1, 1}) do
                                                    for _, sz in ipairs({-1, 1}) do
                                                        local sp, on = H.WorldToScreen((cf * CFrame.new(sx * hx, sy * hy - 0.25, sz * hz)).Position)
                                                        pts[idx] = sp
                                                        if not on then allOn = false end
                                                        idx += 1
                                                    end
                                                end
                                            end
                                            if allOn then
                                                local col = H.NormalizeColor(H.Flags.ESPBoxColor, Color3.fromRGB(255, 255, 255))
                                                local edges = {{1,2},{3,4},{5,6},{7,8},{1,3},{2,4},{5,7},{6,8},{1,5},{2,6},{3,7},{4,8}}
                                                for i, e in ipairs(edges) do
                                                    local l = obj.box3d[i]
                                                    l.From = pts[e[1]]
                                                    l.To = pts[e[2]]
                                                    l.Color = col
                                                    l.Visible = true
                                                    local g = obj.box3dGlow and obj.box3dGlow[i]
                                                    if g then
                                                        if H.Flags.ESPGlowingBoxes then
                                                            g.From = l.From
                                                            g.To = l.To
                                                            g.Color = col
                                                            g.Visible = true
                                                        else
                                                            g.Visible = false
                                                        end
                                                    end
                                                end
                                                ok3 = true
                                            end
                                        end
                                        if not ok3 then
                                            for _, l in ipairs(obj.box3d) do l.Visible = false end
                                            if obj.box3dGlow then for _, g in ipairs(obj.box3dGlow) do g.Visible = false end end
                                        end
                                    end

                                    if obj.name then
                                        if H.Flags.ESPName and H.HAS_DRAWING then
                                            obj.name.Text = (H.Flags.ESPNameType == "Display") and plr.DisplayName or plr.Name
                                            obj.name.Color = H.NormalizeColor(H.Flags.ESPNameColor, Color3.new(1, 1, 1))
                                            obj.name.Size = H.GetScaledTextSize(16, 12, boxH)
                                            obj.name.Position = Vector2.new(pos.X, boxTopY - 18)
                                            obj.name.Visible = true
                                        else
                                            obj.name.Visible = false
                                        end
                                    end

                                    if obj.healthBar then
                                        if H.Flags.ESPHealth and H.HAS_DRAWING then
                                            local barW = math.max(2, math.floor(boxH * 0.08))
                                            local barOffset = math.max(3, math.floor(boxH * 0.08))
                                            local leftX = topPos.X - boxW / 2 - barOffset - barW
                                            local bottomY = boxTopY + boxH
                                            local topY = boxTopY + boxH * (1 - pct)
                                            if H.HAS_QUAD and obj.healthBar.PointA ~= nil then
                                                obj.healthBar.PointA = Vector2.new(leftX, topY)
                                                obj.healthBar.PointB = Vector2.new(leftX + barW, topY)
                                                obj.healthBar.PointC = Vector2.new(leftX + barW, bottomY)
                                                obj.healthBar.PointD = Vector2.new(leftX, bottomY)
                                            else
                                                obj.healthBar.Size = Vector2.new(barW, boxH * pct)
                                                obj.healthBar.Position = Vector2.new(leftX, topY)
                                            end
                                            local hc = H.NormalizeColor(H.Flags.ESPHealthColor, Color3.fromRGB(0, 255, 0))
                                            obj.healthBar.Color = Color3.fromRGB(255, 0, 0):Lerp(hc, pct)
                                            obj.healthBar.Visible = true
                                        else
                                            obj.healthBar.Visible = false
                                        end
                                    end

                                    if obj.distance then
                                        if H.Flags.ESPDistance and H.HAS_DRAWING then
                                            obj.distance.Text = string.format("[%d]", math.floor(dist))
                                            obj.distance.Color = H.NormalizeColor(H.Flags.ESPDistanceColor, Color3.new(1, 1, 1))
                                            obj.distance.Size = H.GetScaledTextSize(14, 12, boxH)
                                            obj.distance.Position = Vector2.new(pos.X, boxTopY + boxH + 2)
                                            obj.distance.Visible = true
                                        else
                                            obj.distance.Visible = false
                                        end
                                    end

                                    if obj.toolTxt then
                                        if H.Flags.ESPTool and H.HAS_DRAWING then
                                            local tool = char:FindFirstChildOfClass("Tool")
                                            if tool then
                                                obj.toolTxt.Text = tool.Name
                                                obj.toolTxt.Color = H.NormalizeColor(H.Flags.ESPToolColor, Color3.fromRGB(0, 255, 0))
                                                obj.toolTxt.Size = H.GetScaledTextSize(14, 12, boxH)
                                                obj.toolTxt.Position = Vector2.new(pos.X, boxTopY + boxH + (H.Flags.ESPDistance and 18 or 2))
                                                obj.toolTxt.Visible = true
                                            else
                                                obj.toolTxt.Visible = false
                                            end
                                        else
                                            obj.toolTxt.Visible = false
                                        end
                                    end

                                    if obj.highlight then
                                        if H.Flags.ESPGlow then
                                            local c = H.NormalizeColor(H.Flags.ESPGlowColor, Color3.fromRGB(255, 255, 255))
                                            obj.highlight.FillColor = c
                                            obj.highlight.FillTransparency = 0.5
                                            obj.highlight.OutlineColor = c
                                            obj.highlight.OutlineTransparency = 0
                                        else
                                            obj.highlight.FillTransparency = 1
                                            obj.highlight.OutlineTransparency = 1
                                        end
                                    end

                                    if obj.billboard then
                                        obj.billboard.Enabled = true
                                        if obj.nameLbl then
                                            if H.Flags.ESPName then
                                                obj.nameLbl.Text = (H.Flags.ESPNameType == "Display") and plr.DisplayName or plr.Name
                                                obj.nameLbl.TextColor3 = H.NormalizeColor(H.Flags.ESPNameColor, Color3.new(1, 1, 1))
                                                obj.nameLbl.Visible = true
                                            else
                                                obj.nameLbl.Visible = false
                                            end
                                        end
                                        if obj.distLbl then
                                            if H.Flags.ESPDistance then
                                                obj.distLbl.Text = string.format("[%d]", math.floor(dist))
                                                obj.distLbl.TextColor3 = H.NormalizeColor(H.Flags.ESPDistanceColor, Color3.new(1, 1, 1))
                                                obj.distLbl.Visible = true
                                            else
                                                obj.distLbl.Visible = false
                                            end
                                        end
                                        if obj.toolLbl then
                                            if H.Flags.ESPTool then
                                                local tool = char:FindFirstChildOfClass("Tool")
                                                if tool then
                                                    obj.toolLbl.Text = tool.Name
                                                    obj.toolLbl.TextColor3 = H.NormalizeColor(H.Flags.ESPToolColor, Color3.fromRGB(0, 255, 0))
                                                    obj.toolLbl.Visible = true
                                                else
                                                    obj.toolLbl.Visible = false
                                                end
                                            else
                                                obj.toolLbl.Visible = false
                                            end
                                        end
                                        if obj.hpBg then
                                            if H.Flags.ESPHealth and not H.HAS_DRAWING then
                                                obj.hpBg.Visible = true
                                                obj.hpFill.Size = UDim2.new(pct, 0, 1, 0)
                                                obj.hpFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0):Lerp(H.NormalizeColor(H.Flags.ESPHealthColor, Color3.fromRGB(0, 255, 0)), pct)
                                            else
                                                obj.hpBg.Visible = false
                                            end
                                        end
                                    end

                                    H.UpdateTracers(plr, pos)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

do
    local LocalPlayer = H.LocalPlayer
    local RunService = H.RunService
    local UserInputService = H.UserInputService
    local Camera = H.Camera

    function H.StopSpeedLoop()
        if H.SpeedConn then H.SpeedConn:Disconnect() H.SpeedConn = nil end
        if H.SpeedBV then H.SpeedBV:Destroy() H.SpeedBV = nil end
    end

    function H.applySpeed(on)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if on then
            local method = H.Flags.SpeedMethod or "Velocity"
            local val = H.Flags.SpeedValue or 16
            if method == "WalkSpeed" or method == "Hybrid" then
                hum.WalkSpeed = math.min(val, 500)
            end
            if method == "BodyVelocity" then
                local hrp = H.GetHRP()
                if hrp then
                    if H.SpeedBV then H.SpeedBV:Destroy() end
                    H.SpeedBV = Instance.new("BodyVelocity")
                    H.SpeedBV.Name = "houhouSpeed"
                    H.SpeedBV.MaxForce = Vector3.new(math.huge, 0, math.huge)
                    H.SpeedBV.P = 1250
                    H.SpeedBV.Velocity = Vector3.zero
                    H.SpeedBV.Parent = hrp
                end
            end
        else
            if hum then hum.WalkSpeed = 16 end
            if H.SpeedBV then H.SpeedBV:Destroy() H.SpeedBV = nil end
        end
    end

    function H.StartSpeedLoop()
        H.StopSpeedLoop()
        H.SpeedConn = RunService.RenderStepped:Connect(function(dt)
            if not H.Flags.SpeedEnabled then return end
            local hum = H.GetHum()
            local root = H.GetHRP()
            if not hum or not root then return end
            local speed = H.Flags.SpeedValue or 16
            local method = H.Flags.SpeedMethod or "Velocity"
            local dir = hum.MoveDirection
            if method == "Velocity" then
                if dir.Magnitude > 0 then
                    root.AssemblyLinearVelocity = Vector3.new(dir.X * speed, root.AssemblyLinearVelocity.Y, dir.Z * speed)
                end
            elseif method == "WalkSpeed" then
                hum.WalkSpeed = math.min(speed, 500)
            elseif method == "Hybrid" then
                hum.WalkSpeed = math.min(speed, 500)
                if dir.Magnitude > 0 then
                    root.AssemblyLinearVelocity = Vector3.new(dir.X * speed, root.AssemblyLinearVelocity.Y, dir.Z * speed)
                end
            elseif method == "CFrame" then
                if dir.Magnitude > 0 then
                    root.CFrame = root.CFrame + dir.Unit * speed * dt
                end
            elseif method == "BodyVelocity" then
                if not H.SpeedBV or not H.SpeedBV.Parent then
                    H.SpeedBV = Instance.new("BodyVelocity")
                    H.SpeedBV.Name = "houhouSpeed"
                    H.SpeedBV.MaxForce = Vector3.new(math.huge, 0, math.huge)
                    H.SpeedBV.P = 1250
                    H.SpeedBV.Parent = root
                end
                if dir.Magnitude > 0 then
                    H.SpeedBV.Velocity = Vector3.new(dir.X * speed, 0, dir.Z * speed)
                else
                    H.SpeedBV.Velocity = Vector3.zero
                end
            end
        end)
    end

    H.FlyConn = nil
    H.flyVelocityMock = Vector3.new(0, 0.03, 0)

    function H.StopFly()
        H.FlyActive = false
        if H.FlyConn then H.FlyConn:Disconnect() H.FlyConn = nil end
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            if hum then
                hum.PlatformStand = false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Freefall) end)
                -- re-assert next frame so the state sticks after PlatformStand clears
                task.defer(function()
                    if not H.FlyActive and hum.Parent then
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Freefall) end)
                    end
                end)
            end
        end
    end

    function H.StartFly()
        if H.FlyConn then H.FlyConn:Disconnect() H.FlyConn = nil end
        H.FlyActive = true
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.PlatformStand = true end) end
        end
        H.FlyConn = RunService.RenderStepped:Connect(function()
            if not H.Flags.FlyEnabled then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if not hum.PlatformStand then hum.PlatformStand = true end
            end
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            local speed = (H.Flags.FlySpeed or 5) * 2
            if moveDir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (moveDir.Unit * (speed / 5))
            end
            hrp.Velocity = H.flyVelocityMock
        end)
    end

    function H.safeNum(v, fallback)
        if type(v) ~= "number" then return fallback end
        if v ~= v then return fallback end
        if v == math.huge or v == -math.huge then return fallback end
        return v
    end

    function H.gauss(mean, dev)
        local u1 = math.random()
        local u2 = math.random()
        if u1 < 1e-9 then u1 = 1e-9 end
        return mean + math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2) * dev
    end

    function H.VoidLoopPickPlayers()
        local list = {}
        for _, p in ipairs(H.Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                if c then
                    local h = c:FindFirstChild("HumanoidRootPart")
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    if h and hum and hum.Health > 0 and h.Position.Magnitude < 1e7 then
                        table.insert(list, { plr = p, pos = h.Position })
                    end
                end
            end
        end
        return list
    end

    function H.VoidLoopWeightedPick(list)
        if #list == 0 then return nil end
        local weights = {}
        local total = 0
        local myHRP = H.GetHRP()
        local myPos = myHRP and myHRP.Position or Vector3.zero
        for i, entry in ipairs(list) do
            local d = (entry.pos - myPos).Magnitude
            local w = 1 / (1 + d * 0.0008)
            if H.VoidLoopAnchorPlayer == entry.plr then w = w * H.VoidLoopCFG.stickiness end
            weights[i] = w
            total = total + w
        end
        local r = math.random() * total
        local acc = 0
        for i, w in ipairs(weights) do
            acc = acc + w
            if r <= acc then return list[i] end
        end
        return list[#list]
    end

    function H.VoidLoopPickCenter()
        local list = H.VoidLoopPickPlayers()
        if #list == 0 then H.VoidLoopAnchorPlayer = nil return Vector3.zero end
        if math.random() < H.VoidLoopCFG.targetPlayer then
            local now = tick()
            if not H.VoidLoopAnchorPlayer or (now - H.VoidLoopAnchorSince) > H.VoidLoopCFG.stickiness then
                local pick = H.VoidLoopWeightedPick(list)
                H.VoidLoopAnchorPlayer = pick and pick.plr or nil
                H.VoidLoopAnchorSince = now
            else
                local stillThere = false
                for _, e in ipairs(list) do
                    if e.plr == H.VoidLoopAnchorPlayer then stillThere = true; break end
                end
                if not stillThere then
                    local pick = H.VoidLoopWeightedPick(list)
                    H.VoidLoopAnchorPlayer = pick and pick.plr or nil
                    H.VoidLoopAnchorSince = now
                end
            end
            if H.VoidLoopAnchorPlayer and H.VoidLoopAnchorPlayer.Character then
                local h = H.VoidLoopAnchorPlayer.Character:FindFirstChild("HumanoidRootPart")
                if h then return h.Position end
            end
        end
        return Vector3.zero
    end

    function H.VoidLoopNewTarget()
        local c = H.VoidLoopPickCenter()
        local spread = H.VoidLoopCFG.radius * H.VoidLoopCFG.spread
        H.VoidLoopOrbitPhase = H.VoidLoopOrbitPhase + (math.random() - 0.5) * 1.8
        if math.random() < 0.25 then H.VoidLoopOrbitDir = -H.VoidLoopOrbitDir end
        local ang = H.VoidLoopOrbitPhase * H.VoidLoopOrbitDir + math.random() * 0.4
        local rad = math.clamp(H.gauss(H.VoidLoopCFG.radius * 0.5, spread * 0.5), 150, H.VoidLoopCFG.radius)
        local dx = math.cos(ang) * rad + H.gauss(0, spread * 0.25)
        local dz = math.sin(ang) * rad + H.gauss(0, spread * 0.25)
        if H.VoidLoopAnchorPlayer and H.VoidLoopCFG.orbitBias > 0 then
            local bias = H.VoidLoopCFG.orbitBias
            dx = dx * (1 - bias) + math.cos(ang) * rad * bias
            dz = dz * (1 - bias) + math.sin(ang) * rad * bias
        end
        local y = H.VoidLoopCFG.height + math.random(-H.VoidLoopCFG.jitter, H.VoidLoopCFG.jitter)
        if H.VoidLoopDiveLeft <= 0 and math.random() < H.VoidLoopCFG.diveChance then
            H.VoidLoopDiveLeft = math.random(2, 5)
        end
        if H.VoidLoopDiveLeft > 0 then
            y = H.VoidLoopCFG.height - H.VoidLoopCFG.diveDepth + math.random(-300, 300)
            H.VoidLoopDiveLeft = H.VoidLoopDiveLeft - 1
        end
        if H.VoidLoopBurstLeft <= 0 and math.random() < H.VoidLoopCFG.burstChance then
            H.VoidLoopBurstLeft = math.random(2, 4)
            H.VoidLoopBurstVec = Vector3.new(
                H.gauss(0, H.VoidLoopCFG.radius * 1.5),
                math.random(-H.VoidLoopCFG.jitter * 4, H.VoidLoopCFG.jitter * 4),
                H.gauss(0, H.VoidLoopCFG.radius * 1.5)
            ) * H.VoidLoopCFG.burstPower
        end
        local px, py, pz = c.X + dx, y, c.Z + dz
        if H.VoidLoopBurstLeft > 0 then
            px = px + H.VoidLoopBurstVec.X
            py = py + H.VoidLoopBurstVec.Y
            pz = pz + H.VoidLoopBurstVec.Z
            H.VoidLoopBurstLeft = H.VoidLoopBurstLeft - 1
        end
        if px ~= px or py ~= py or pz ~= pz then
            return Vector3.new(0, H.VoidLoopCFG.height, 0)
        end
        return Vector3.new(px, py, pz)
    end

    function H.StopVoidLoop()
        H.VoidLoopRunning = false
        H.VoidLoopCFG.active = false
        if H.VoidLoopConn then H.VoidLoopConn:Disconnect() H.VoidLoopConn = nil end
        if H.VoidLoopSavedPos then
            local hrp = H.GetHRP()
            if hrp then
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame = H.VoidLoopSavedPos
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end
        local hum = H.GetHum()
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                hum.PlatformStand = false
            end)
        end
    end

    function H.StartVoidLoop()
        if H.VoidLoopConn then H.VoidLoopConn:Disconnect() H.VoidLoopConn = nil end
        local hrp = H.GetHRP()
        if not hrp then return end
        H.VoidLoopSavedPos = hrp.CFrame
        H.VoidLoopCurrentPos = hrp.Position
        H.VoidLoopDiveLeft = 0
        H.VoidLoopLastRefresh = tick()
        H.VoidLoopAnchorPlayer = nil
        H.VoidLoopAnchorSince = 0
        H.VoidLoopOrbitDir = math.random() < 0.5 and 1 or -1
        H.VoidLoopOrbitPhase = math.random() * math.pi * 2
        H.VoidLoopBurstLeft = 0
        H.VoidLoopBurstVec = Vector3.zero
        H.VoidLoopTargetPos = H.VoidLoopNewTarget()
        H.VoidLoopRunning = true
        H.VoidLoopCFG.active = true

        local hum = H.GetHum()
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum.PlatformStand = true
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
            end)
        end

        local MIN_Y = -8000
        H.VoidLoopConn = RunService.Heartbeat:Connect(function(dt)
            if not H.VoidLoopRunning or not H.VoidLoopCFG.active then return end
            local hrp = H.GetHRP()
            local character = LocalPlayer.Character
            if not hrp or not hrp.Parent or not character or not character.Parent then return end
            dt = H.safeNum(dt, 1 / 60)
            if dt <= 0 then dt = 1 / 60 end
            local hum = H.GetHum()
            if hum then
                pcall(function()
                    if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
                    if hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                        hum:ChangeState(Enum.HumanoidStateType.Freefall)
                    end
                    hum.PlatformStand = true
                end)
            end
            local pos = hrp.Position
            if pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z
                or math.abs(pos.X) > 1e7 or math.abs(pos.Z) > 1e7 then
                H.VoidLoopCurrentPos = Vector3.new(0, H.VoidLoopCFG.height, 0)
                H.VoidLoopTargetPos = H.VoidLoopCurrentPos
            end
            if H.VoidLoopTargetPos.Y < MIN_Y then
                H.VoidLoopTargetPos = Vector3.new(H.VoidLoopTargetPos.X, MIN_Y, H.VoidLoopTargetPos.Z)
            end
            if H.VoidLoopCurrentPos.Y < MIN_Y then
                H.VoidLoopCurrentPos = Vector3.new(H.VoidLoopCurrentPos.X, MIN_Y, H.VoidLoopCurrentPos.Z)
            end
            local dist = (H.VoidLoopCurrentPos - H.VoidLoopTargetPos).Magnitude
            if dist ~= dist then dist = 0 end
            if dist < 40 or (tick() - H.VoidLoopLastRefresh) > H.VoidLoopCFG.refresh then
                H.VoidLoopTargetPos = H.VoidLoopNewTarget()
                if H.VoidLoopTargetPos.Y < MIN_Y then
                    H.VoidLoopTargetPos = Vector3.new(H.VoidLoopTargetPos.X, MIN_Y, H.VoidLoopTargetPos.Z)
                end
                H.VoidLoopLastRefresh = tick()
            end
            local alpha = H.VoidLoopCFG.speed * dt / 100
            if alpha ~= alpha or alpha <= 0 then alpha = 0.1 end
            if alpha > 1 then alpha = 1 end
            H.VoidLoopCurrentPos = H.VoidLoopCurrentPos:Lerp(H.VoidLoopTargetPos, alpha)
            if H.VoidLoopCurrentPos.Y < MIN_Y then
                H.VoidLoopCurrentPos = Vector3.new(H.VoidLoopCurrentPos.X, MIN_Y, H.VoidLoopCurrentPos.Z)
            end
            local ok, cf = pcall(function()
                local look = hrp.CFrame - hrp.CFrame.Position
                return CFrame.new(H.VoidLoopCurrentPos) * look
            end)
            if ok and cf then pcall(function() hrp.CFrame = cf end) end
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end)
    end

    function H.ApplyNoclip()
        if H.NoclipConn then H.NoclipConn:Disconnect() H.NoclipConn = nil end
        if not H.Flags.Noclip then return end
        H.NoclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end
        end)
    end

    function H.ApplyAntiAFK()
        if H.AntiAFKConn then H.AntiAFKConn:Disconnect() H.AntiAFKConn = nil end
        if not H.Flags.AntiAFK then return end
        H.AntiAFKConn = LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end

    function H.ApplyAnchor()
        local hrp = H.GetHRP()
        if hrp then hrp.Anchored = H.Flags.Anchor end
    end

    function H.RestoreHitboxes()
        for _, plr in ipairs(H.Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        pcall(function()
                            hrp.Size = Vector3.new(2, 2, 1)
                            hrp.Transparency = 1
                            hrp.CanCollide = true
                        end)
                    end
                end
            end
        end
    end

    function H.ApplyHitbox()
        if H.HitboxConn then H.HitboxConn:Disconnect() H.HitboxConn = nil end
        if not H.Flags.HitboxEnabled then H.RestoreHitboxes() return end
        H.HitboxConn = RunService.Heartbeat:Connect(function()
            if not H.Flags.HitboxEnabled then return end
            local size = H.Flags.HitboxSize or 6
            local rawTrans = H.Flags.HitboxTransparency
            local trans
            if rawTrans == nil then trans = 0.5
            elseif rawTrans > 1 then trans = rawTrans / 100
            else trans = rawTrans end
            if trans < 0 then trans = 0 end
            if trans > 1 then trans = 1 end
            for _, plr in ipairs(H.Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local char = plr.Character
                    if char then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            pcall(function()
                                hrp.Size = Vector3.new(size, size, size)
                                hrp.Transparency = trans
                                hrp.CanCollide = false
                            end)
                        end
                    end
                end
            end
        end)
    end

    function H.ApplyFullbright()
        if H.Flags.Fullbright then
            H.Lighting.Brightness = 2
            H.Lighting.ClockTime = 12
            H.Lighting.Ambient = Color3.new(1, 1, 1)
            H.Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        else
            H.Lighting.Brightness = H.oldLighting.Brightness
            H.Lighting.ClockTime = H.oldLighting.ClockTime
            H.Lighting.Ambient = H.oldLighting.Ambient
            H.Lighting.OutdoorAmbient = H.oldLighting.OutdoorAmbient
        end
    end

    function H.ApplyNoFog()
        if H.Flags.NoFog then
            H.Lighting.FogEnd = 1e9
            H.Lighting.FogStart = 1e9
        else
            H.Lighting.FogEnd = H.oldLighting.FogEnd
            H.Lighting.FogStart = H.oldLighting.FogStart
        end
    end

    function H.ApplyClockTime()
        if H.Flags.ClockTimeEnabled then
            H.Lighting.ClockTime = H.Flags.ClockTime or 12
        else
            H.Lighting.ClockTime = H.oldLighting.ClockTime
        end
    end

    function H.ApplyAmbient()
        if H.Flags.AmbientEnabled then
            H.Lighting.Ambient = H.NormalizeColor(H.Flags.AmbientColor, Color3.new(0.5, 0.5, 0.5))
        else
            H.Lighting.Ambient = H.oldLighting.Ambient
        end
    end

    function H.GotoPlayer(plr)
        if not plr or not H.IsAlive(plr) then return end
        local my = H.GetHRP()
        local thrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if my and thrp then my.CFrame = thrp.CFrame + Vector3.new(0, 3, 0) end
    end

    function H.Spectate(plr)
        if not plr or not H.IsAlive(plr) then return end
        H.Spectating = true
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
    end

    function H.Unspectate()
        H.Spectating = false
        local hum = H.GetHum()
        if hum then Camera.CameraSubject = hum end
    end

    function H.BuildWatermark()
        if not H.HAS_DRAWING then return end
        if H.Watermark then pcall(function() H.Watermark:Remove() end) end
        H.Watermark = Drawing.new("Text")
        H.Watermark.Size = 20
        H.Watermark.Outline = true
        H.Watermark.Color = Color3.new(1, 1, 1)
        H.Watermark.Position = Vector2.new(15, 15)
        H.Watermark.Visible = false
    end

    function H.UpdateWatermark()
        if not H.Watermark then return end
        if not H.Flags.Watermark then H.Watermark.Visible = false return end
        H.Watermark.Visible = true
        local fps = 60
        pcall(function() fps = math.floor(1 / RunService.RenderStepped:Wait()) end)
        local ping = 0
        pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        H.Watermark.Text = string.format("houhou | %d fps | %d ms", fps, ping)
    end

    function H.findMainRemote()
        local rs = H.ReplicatedStorage
        local possible = {
            rs:FindFirstChild("GameRemotes") and rs.GameRemotes:FindFirstChild("MainGameEvent"),
            rs:FindFirstChild("MainRemotes") and rs.MainRemotes:FindFirstChild("MainRemoteEvent"),
            rs:FindFirstChild("GameRemotes") and rs.GameRemotes:FindFirstChild("MainRemoteEvent"),
            rs:FindFirstChild("MainRemotes") and rs.MainRemotes:FindFirstChild("MainGameEvent"),
            rs:FindFirstChild("MainGameEvent", true),
            rs:FindFirstChild("MainRemoteEvent", true),
        }
        for _, rem in pairs(possible) do
            if rem and rem:IsA("RemoteEvent") then return rem end
        end
        for _, v in pairs(rs:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local n = v.Name:lower()
                if n:find("main") or n:find("game") then return v end
            end
        end
        return nil
    end

    function H.DoAutoStomp()
        if not H.Flags.AutoStomp or not H.MainRemote then return end
        local now = tick()
        for _, plr in ipairs(H.Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                if not char then
                    H.AutoStompLast[plr] = nil
                else
                    local isKO, isGrabbed = H.IsKO(plr)
                    if isKO and not isGrabbed then
                        local last = H.AutoStompLast[plr]
                        if not last or now - last >= 0.4 then
                            H.AutoStompLast[plr] = now
                            pcall(function()
                                H.MainRemote:FireServer("Stomp")
                                H.MainRemote:FireServer("StompPlayer", char)
                                H.MainRemote:FireServer("Stomp", char)
                            end)
                        end
                    else
                        H.AutoStompLast[plr] = nil
                    end
                end
            end
        end
    end

    function H.IsWeapon(t)
        if not t or not t:IsA("Tool") then return false end
        if not t:FindFirstChild("Handle") then return false end
        return true
    end

    function H.ZeroCooldown(tool)
        if not tool then return end
        for _, v in ipairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                local n = string.lower(v.Name)
                if n:find("cool") or n:find("delay") or n:find("rate") or n:find("shoot") or n:find("debounce") then
                    pcall(function() v.Value = 0 end)
                end
            end
            if v:IsA("BoolValue") then
                local n = string.lower(v.Name)
                if n:find("cool") or n:find("debounce") then
                    pcall(function() v.Value = false end)
                end
            end
        end
        pcall(function()
            if tool:GetAttribute("Cooldown") ~= nil then tool:SetAttribute("Cooldown", nil) end
            if tool:GetAttribute("ShootingCooldown") ~= nil then tool:SetAttribute("ShootingCooldown", 0) end
        end)
    end

    function H.PatchConnections(tool)
        if typeof(getconnections) ~= "function" then return end
        pcall(function()
            for _, conn in ipairs(getconnections(tool.Activated)) do
                local fn = conn.Function
                if fn and debug and debug.getupvalue and debug.setupvalue then
                    local info = debug.getinfo(fn)
                    local nups = (info and info.nups) or 0
                    for i = 1, nups do
                        local val = debug.getupvalue(fn, i)
                        if type(val) == "number" and val > 0 and val < 1 then
                            debug.setupvalue(fn, i, 0)
                        end
                    end
                end
            end
        end)
    end

    function H.HardenTool(tool)
        if not tool or H.RapidFireDone[tool] then return end
        if not H.IsWeapon(tool) then return end
        H.ZeroCooldown(tool)
        H.PatchConnections(tool)
        H.RapidFireDone[tool] = true
        local conn = tool.DescendantAdded:Connect(function() H.ZeroCooldown(tool) end)
        table.insert(H.RapidFireConns, conn)
    end

    function H.ScanRapidFireTools()
        local char = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then H.HardenTool(t) end
            end
        end
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") then H.HardenTool(t) end
            end
        end
    end

    function H.GetEquippedWeapon()
        local char = LocalPlayer.Character
        if not char then return nil end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and H.IsWeapon(t) then return t end
        end
        return nil
    end

    function H.CleanupRapidFire()
        for _, c in ipairs(H.RapidFireConns) do pcall(function() c:Disconnect() end) end
        H.RapidFireConns = {}
        H.RapidFireDone = {}
    end

    function H.UpdateRapidFire()
        if not H.Flags.RapidFire then return end
        H.ScanRapidFireTools()
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return end
        if tick() - H.RapidFireLast < 0.015 then return end
        local tool = H.GetEquippedWeapon()
        if not tool then return end
        H.HardenTool(tool)
        H.ZeroCooldown(tool)
        H.RapidFireLast = tick()
        pcall(function() tool:Activate() end)
    end

    function H.GetTargetUnderMouse()
        local target = H.Mouse.Target
        if not target then return nil end
        local model = target:FindFirstAncestorOfClass("Model")
        if not model then return nil end
        local plr = H.Players:GetPlayerFromCharacter(model)
        if not plr then return nil end
        if plr == LocalPlayer then return nil end
        if H.IsWhitelisted(plr) then return nil end
        if H.HasForceField(plr) then return nil end
        if H.Flags.TriggerTeamCheck and H.HasTeam(plr) then return nil end
        if H.Flags.TriggerKnockedCheck and H.IsKnocked(plr) then return nil end
        if not H.IsAlive(plr) then return nil end
        return plr, target
    end

    function H.FireTriggerShot()
        if mouse1press and mouse1release then
            pcall(mouse1press)
            task.wait(0.01)
            pcall(mouse1release)
        elseif mouse1click then
            pcall(mouse1click)
        end
    end

    function H.UpdateTriggerBot()
        if not H.Flags.TriggerEnabled then return end
        if not H.IsAlive(LocalPlayer) then return end
        local weapon = H.GetEquippedWeapon()
        if not weapon then return end
        local shouldFire = false
        local mode = H.Flags.TriggerMode or "Hold"
        if mode == "Always" then shouldFire = true
        elseif mode == "Hold" then shouldFire = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        elseif mode == "OnKey" then
            local key = H.Flags.TriggerKey or "E"
            shouldFire = UserInputService:IsKeyDown(Enum.KeyCode[key:upper()] or Enum.KeyCode.E)
        end
        if not shouldFire then return end
        local plr = H.GetTargetUnderMouse()
        if not plr then return end
        local now = tick()
        local delay = (H.Flags.TriggerDelay or 100) / 1000
        if now - H.TriggerBotLast < delay then return end
        H.TriggerBotLast = now
        H.FireTriggerShot()
    end
end

do
    local Players = H.Players
    local LocalPlayer = H.LocalPlayer
    local CoreGui = H.CoreGui

    function H.DestroyWhitelistGUI()
        if H.WL_CONN then pcall(function() H.WL_CONN:Disconnect() end) H.WL_CONN = nil end
        if H.WL_GUI then pcall(function() H.WL_GUI:Destroy() end) H.WL_GUI = nil end
    end

    function H.BuildWhitelistGUI()
        H.DestroyWhitelistGUI()
        local parent
        pcall(function() parent = gethui() end)
        if not parent then parent = CoreGui end

        H.WL_GUI = Instance.new("ScreenGui")
        H.WL_GUI.Name = "houhou_whitelist"
        H.WL_GUI.ResetOnSpawn = false
        H.WL_GUI.IgnoreGuiInset = false
        H.WL_GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        H.WL_GUI.Parent = parent

        local main = Instance.new("Frame")
        main.Size = UDim2.new(0, 320, 0, 400)
        main.Position = UDim2.new(0.5, -160, 0.5, -200)
        main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        main.BorderSizePixel = 0
        main.Active = true
        main.Draggable = true
        main.Parent = H.WL_GUI
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke", main)
        stroke.Color = Color3.fromRGB(60, 60, 80)
        stroke.Thickness = 1

        local title = Instance.new("TextLabel", main)
        title.Size = UDim2.new(1, -80, 0, 30)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "Whitelist Manager"
        title.TextColor3 = Color3.fromRGB(220, 220, 240)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left

        local closeBtn = Instance.new("TextButton", main)
        closeBtn.Size = UDim2.new(0, 25, 0, 25)
        closeBtn.Position = UDim2.new(1, -30, 0, 3)
        closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(220, 100, 100)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 14
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = main
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
        closeBtn.MouseButton1Click:Connect(function() H.DestroyWhitelistGUI() end)

        local refreshBtn = Instance.new("TextButton", main)
        refreshBtn.Size = UDim2.new(0, 25, 0, 25)
        refreshBtn.Position = UDim2.new(1, -60, 0, 3)
        refreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        refreshBtn.Text = "R"
        refreshBtn.TextColor3 = Color3.fromRGB(120, 200, 255)
        refreshBtn.Font = Enum.Font.GothamBold
        refreshBtn.TextSize = 14
        refreshBtn.BorderSizePixel = 0
        refreshBtn.Parent = main
        Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)

        local clearBtn = Instance.new("TextButton", main)
        clearBtn.Size = UDim2.new(0, 25, 0, 25)
        clearBtn.Position = UDim2.new(1, -90, 0, 3)
        clearBtn.BackgroundColor3 = Color3.fromRGB(60, 25, 25)
        clearBtn.Text = "C"
        clearBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
        clearBtn.Font = Enum.Font.GothamBold
        clearBtn.TextSize = 14
        clearBtn.BorderSizePixel = 0
        clearBtn.Parent = main
        Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 4)
        clearBtn.MouseButton1Click:Connect(function()
            H.Whitelist = {}
            if H.Flags.RefreshWLList then H.Flags.RefreshWLList() end
        end)

        local scroll = Instance.new("ScrollingFrame", main)
        scroll.Size = UDim2.new(1, -20, 1, -50)
        scroll.Position = UDim2.new(0, 10, 0, 40)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = main

        local layout = Instance.new("UIListLayout", scroll)
        layout.Padding = UDim.new(0, 4)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local function rebuild()
            for _, c in ipairs(scroll:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            local list = Players:GetPlayers()
            table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)
            for _, plr in ipairs(list) do
                if plr ~= LocalPlayer then
                    local row = Instance.new("TextButton", scroll)
                    row.Size = UDim2.new(1, -8, 0, 32)
                    row.BackgroundColor3 = H.IsWhitelisted(plr) and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(30, 30, 42)
                    row.Text = ""
                    row.BorderSizePixel = 0
                    row.AutoButtonColor = false
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
                    local rowStroke = Instance.new("UIStroke", row)
                    rowStroke.Color = H.IsWhitelisted(plr) and Color3.fromRGB(60, 180, 90) or Color3.fromRGB(50, 50, 70)
                    rowStroke.Thickness = 1
                    local name = Instance.new("TextLabel", row)
                    name.Size = UDim2.new(1, -10, 1, 0)
                    name.Position = UDim2.new(0, 8, 0, 0)
                    name.BackgroundTransparency = 1
                    name.Text = plr.DisplayName .. "  (@" .. plr.Name .. ")"
                    name.TextColor3 = Color3.fromRGB(230, 230, 245)
                    name.Font = Enum.Font.Gotham
                    name.TextSize = 12
                    name.TextXAlignment = Enum.TextXAlignment.Left
                    local status = Instance.new("TextLabel", row)
                    status.Size = UDim2.new(0, 60, 1, 0)
                    status.Position = UDim2.new(1, -65, 0, 0)
                    status.BackgroundTransparency = 1
                    status.Text = H.IsWhitelisted(plr) and "WL ON" or "WL OFF"
                    status.TextColor3 = H.IsWhitelisted(plr) and Color3.fromRGB(120, 255, 150) or Color3.fromRGB(160, 160, 180)
                    status.Font = Enum.Font.GothamBold
                    status.TextSize = 11
                    status.TextXAlignment = Enum.TextXAlignment.Right
                    row.MouseButton1Click:Connect(function()
                        if H.IsWhitelisted(plr) then
                            H.Whitelist[plr.UserId] = nil
                            H.Whitelist[plr.Name] = nil
                        else
                            H.Whitelist[plr.UserId] = true
                            H.Whitelist[plr.Name] = true
                        end
                        rebuild()
                    end)
                end
            end
        end

        refreshBtn.MouseButton1Click:Connect(rebuild)
        rebuild()
        H.WL_CONN = Players.PlayerAdded:Connect(function() task.wait(0.5) rebuild() end)
    end

    H.Flags.RefreshWLList = function() H.BuildWhitelistGUI() end
end

do
    local Players = H.Players
    local LocalPlayer = H.LocalPlayer
    local Camera = H.Camera
    local RunService = H.RunService
    local CFG = H.CFG

    function H.RageIsFullyLoaded(plr)
        local c = plr and plr.Character
        if not c then return false end
        return c:FindFirstChild("Head") and c:FindFirstChild("HumanoidRootPart") and H.IsAlive(plr)
    end

    function H.RageGetHead(plr)
        return plr and plr.Character and plr.Character:FindFirstChild("Head")
    end

    function H.RageGetHRP(plr)
        return plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    end

    function H.RageFindGun()
        local c = LocalPlayer.Character
        if not c then return nil end
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and t:FindFirstChild("Handle") then
                local n = t.Name:lower()
                if not n:find("knife") and not n:find("fist") and not n:find("bat") then
                    return t
                end
            end
        end
        return nil
    end

    function H.RageGetHitbox(plr)
        local char = plr and plr.Character
        if not char then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local rootAtt = hrp:FindFirstChild("RootAttachment")
        if rootAtt then
            local hb = rootAtt:FindFirstChild("Hitbox")
            if hb then return hb end
        end
        for _, d in ipairs(char:GetDescendants()) do
            if d.Name == "Hitbox" and (d:IsA("BasePart") or d:IsA("Attachment")) then
                return d
            end
        end
        return hrp:FindFirstChild("RootAttachment") or char:FindFirstChild("Head") or hrp
    end

    function H.RageGetAimPosition(hitbox)
        if not hitbox then return nil end
        if hitbox:IsA("Attachment") then return hitbox.WorldPosition end
        if hitbox:IsA("BasePart")     then return hitbox.Position      end
        return nil
    end

    function H.RageIsShotgun(tool)
        if not tool then return false end
        local n = tool.Name:lower()
        return n:find("shotgun") or n:find("double") or n:find("tactical")
            or n:find("barrel") or n:find("sg") or n:find("db")
            or tool:FindFirstChild("GunClientShotgun") ~= nil
    end

    function H.RageGetWeaponStats(gun)
        if not gun then return {range = 250, damage = 34.8} end
        local r, d
        r = gun:GetAttribute("Range") or gun:GetAttribute("MaxRange") or gun:GetAttribute("MaxDistance")
        d = gun:GetAttribute("Damage") or gun:GetAttribute("BaseDamage")
        if not r then
            local ro = gun:FindFirstChild("Range") or gun:FindFirstChild("MaxRange")
            if ro and ro:IsA("ValueBase") then r = ro.Value end
        end
        if not d then
            local dobj = gun:FindFirstChild("Damage") or gun:FindFirstChild("BaseDamage")
            if dobj and dobj:IsA("ValueBase") then d = dobj.Value end
        end
        if not r or not d then
            local n = gun.Name:lower()
            if n:find("double") or n:find("barrel") or n:find("db") then r, d = 95, 28.6
            elseif n:find("tactical") then r, d = 75, 29.3
            elseif n:find("shotgun") or n:find("sg") then r, d = 95, 28.6
            else r, d = 250, 34.8 end
        end
        return {range = r, damage = d}
    end

    function H.RageBuildPellet(origin, centerAim, hitbox, dir)
        local off1 = Vector3.new(
            (math.random() - 0.5) * 1.0,
            (math.random() - 0.5) * 1.0,
            (math.random() - 0.5) * 1.0
        )
        local off2 = Vector3.new(
            (math.random() - 0.5) * 8.0,
            (math.random() - 0.5) * 8.0,
            (math.random() - 0.5) * 8.0
        )
        return {
            AimPosition    = centerAim + off2,
            RawAimPosition = centerAim + off2,
            Result1        = origin + dir * 12.8 + off1,
            Result2        = hitbox,
            Result3        = -dir,
        }
    end

    function H.RageFirstSelected()
        for plr, _ in pairs(H.RageTargets) do
            if plr and plr.Parent then return plr end
        end
        return nil
    end

    function H.RageCanShoot(plr)
        if not plr or not plr.Parent or plr == LocalPlayer then return false end
        if not H.RageTargetReady[plr] then return false end
        if not H.RageIsFullyLoaded(plr) then return false end
        local knocked, grabbed = H.IsKO(plr)
        if knocked or grabbed then return false end
        if H.HasForceField(plr) then return false end
        return true
    end

    function H.TriggerReloadTool(tool)
        if not tool then return false end
        local ammo = tool:FindFirstChild("Ammo")
        local cap = tool:FindFirstChild("MaxAmmo") or tool:FindFirstChild("MaxAmmoValue") or tool:FindFirstChild("Clip") or tool:FindFirstChild("MagSize") or tool:FindFirstChild("AmmoCapacity")
        local maxValue = cap and tonumber(cap.Value) or (ammo and tonumber(ammo.Value)) or 0
        if ammo and maxValue > 0 then
            pcall(function() ammo.Value = maxValue end)
        end
        if H.MainRemote then
            local names = { "Reload", "ReloadGun", "ReloadWeapon", "ReloadAmmo", "RequestReload", "ReloadMagazine" }
            for _, name in ipairs(names) do
                local ok = pcall(function() H.MainRemote:FireServer(name, tool) end)
                if ok then return true end
            end
        end
        local reloadRemote = tool:FindFirstChild("Reload") or tool:FindFirstChild("ReloadGun") or tool:FindFirstChild("ReloadWeapon")
        if reloadRemote then
            if reloadRemote:IsA("RemoteEvent") then
                pcall(function() reloadRemote:FireServer() end)
                return true
            elseif reloadRemote:IsA("RemoteFunction") then
                pcall(function() reloadRemote:InvokeServer() end)
                return true
            end
        end
        return false
    end

    function H.GetWeaponOrigin(tool)
        if not tool then return nil end
        local muzzle = tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Barrel") or tool:FindFirstChild("Handle")
        if muzzle and muzzle:IsA("BasePart") then
            return muzzle.CFrame.Position
        end
        local handle = tool:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            return handle.CFrame.Position
        end
        local hrp = H.GetHRP()
        return hrp and hrp.Position or Vector3.new()
    end

    function H.PutTargetInFrontOfMe(head, distance, heightOffset)
        if not head or head.Name ~= "Head" then return false end
        local char = head.Parent
        if not char or not char:IsA("Model") then return false end
        local target = Players:GetPlayerFromCharacter(char)
        if not target or target == LocalPlayer then return false end
        local myHRP = H.GetHRP()
        local targetHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP or not targetHRP then return false end
        if H.RageTargetOriginalCF[target] == nil then
            H.RageTargetOriginalCF[target] = targetHRP.CFrame
        end
        distance = distance or 2.5
        heightOffset = heightOffset or 0.5
        local forward = myHRP.CFrame.LookVector
        if forward.Magnitude <= 0 then forward = Vector3.new(0, 0, -1) end
        local targetPos = myHRP.Position + (forward * distance) + Vector3.new(0, heightOffset, 0)
        local lookAt = myHRP.Position + Vector3.new(forward.X, 0, forward.Z) * 4
        pcall(function()
            targetHRP.CFrame = CFrame.new(targetPos, lookAt)
            targetHRP.Velocity = Vector3.zero
            targetHRP.AssemblyLinearVelocity = Vector3.zero
            targetHRP.RotVelocity = Vector3.zero
        end)
        return true
    end

    function H.RageShootAtMethod1(plr)
        if H.GetRageMethod() ~= "Method 1" then return false end
        if not plr or not H.MainRemote then return false end
        if not H.RageTargets[plr] then return false end

        local gun = H.RageFindGun()
        if not gun then return false end

        local hitbox = H.RageGetHitbox(plr)
        if not hitbox then return false end

        local aimPos = H.RageGetAimPosition(hitbox)
        if not aimPos then return false end

        local handle = gun:FindFirstChild("Handle")
        if not handle then return false end

        local stats = H.RageGetWeaponStats(gun)
        local origin = handle.Position
        local dir = (aimPos - origin).Unit

        local ammo = gun:FindFirstChild("Ammo")
        if ammo and ammo.Value <= 0 then
            H.TriggerReloadTool(gun)
            return false
        end
        local ok = pcall(function()
            if H.RageIsShotgun(gun) then
                local pellets = {}
                for i = 1, 5 do
                    table.insert(pellets, H.RageBuildPellet(origin, aimPos, hitbox, dir))
                end
                H.MainRemote:FireServer("ShootGun", handle, origin, pellets, nil, nil, nil, stats.range, stats.damage)
            else
                local result1 = origin + dir * 12.8
                H.MainRemote:FireServer("ShootGun", handle, origin, nil, aimPos, hitbox, dir, stats.range, stats.damage, result1, nil)
            end
        end)

        if ok then H.TriggerReloadTool(gun) end
        return ok
    end

    function H.GetRageMethod()
        local v = H.Flags.RageMethodDropdown
        if type(v) == "table" then v = v[1] end
        if v == "Method 1" or v == "Method 2" then
            H.RageMethod = v
            return v
        end
        return H.RageMethod
    end

    function H.RageShootAtMethod2(plr)
        if H.GetRageMethod() ~= "Method 2" then return false end
        if not plr or not H.MainRemote then return false end
        local head = H.RageGetHead(plr)
        if not head then return false end

        H.PutTargetInFrontOfMe(head, 2.5, 0.5)

        local gun = H.RageFindGun()
        if not gun or gun.Parent ~= LocalPlayer.Character then return false end

        local previousSilent = H.Flags.SilentAimEnabled
        if not previousSilent then H.Flags.SilentAimEnabled = true end
        H.SilentCachedPart = head

        local handle = gun:FindFirstChild("Handle")
        if not handle then
            if not previousSilent then H.Flags.SilentAimEnabled = false end
            return false
        end

        local origin = H.GetWeaponOrigin(gun)
        if not origin then
            if not previousSilent then H.Flags.SilentAimEnabled = false end
            return false
        end

        local Ammo = gun:FindFirstChild("Ammo")
        if Ammo and Ammo.Value <= 0 then
            H.TriggerReloadTool(gun)
            if not previousSilent then H.Flags.SilentAimEnabled = false end
            return false
        end

        local dmgObj = gun:FindFirstChild("Damage") or gun:FindFirstChild("damage")
        local damage = (dmgObj and dmgObj.Value) or gun:GetAttribute("Damage") or 30
        local rangeObj = gun:FindFirstChild("Range")
        local range = rangeObj and rangeObj.Value or 250
        if range < 250 then range = 250 end
        local pos = head.Position
        local normal = Vector3.new(0, 1, 0)
        pcall(function() H.MainRemote:FireServer("UpdateMousePosI2", pos) end)

        local ok = pcall(function()
            if H.RageIsShotgun(gun) then
                local pellets = {}
                for i = 1, 5 do
                    table.insert(pellets, { AimPosition = pos, RawAimPosition = pos, Result1 = pos, Result2 = head, Result3 = normal, AimLockPart = head })
                end
                H.MainRemote:FireServer("ShootGun", handle, origin, pellets, nil, nil, nil, range, damage)
                H.MainRemote:FireServer("ShootGun", handle, origin, pellets, pos, head, normal, range, damage)
                gun:Activate()
            else
                H.MainRemote:FireServer("ShootGun", handle, origin, nil, pos, head, normal, range, damage)
            end
        end)

        task.delay(0.15, function()
            if not previousSilent then H.Flags.SilentAimEnabled = false end
        end)

        if ok then H.TriggerReloadTool(gun) end
        return ok
    end

    function H.RageStartTPLock(plr)
        if H.RageTPQueue then return end
        if not plr or not plr.Parent then return end
        local hrp = H.RageGetHRP(plr)
        if not hrp then return end
        local myHRP = H.GetHRP()
        if not myHRP then return end
        local myPos = myHRP.Position
        local targetPos = hrp.Position
        local dir = Vector3.new(targetPos.X - myPos.X, 0, targetPos.Z - myPos.Z)
        if dir.Magnitude < 0.01 then dir = myHRP.CFrame.LookVector end
        H.RageTPQueue = {
            plr = plr,
            expires = tick() + 1.5,
            last = tick(),
            phase = "fly",
            stomped = false,
            home = myHRP.CFrame,
        }
        local myHum = H.GetHum()
        if myHum then pcall(function() myHum.PlatformStand = true end) end
    end

    local function endTPLock()
        local lock = H.RageTPQueue
        H.RageTPQueue = nil
        local myHRP = H.GetHRP()
        local myHum = H.GetHum()
        if myHRP then
            pcall(function()
                if lock and lock.home then myHRP.CFrame = lock.home end
                myHRP.AssemblyLinearVelocity = Vector3.zero
                myHRP.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        if myHum then
            pcall(function()
                myHum.PlatformStand = false
                myHum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
    end

    -- platform-stand flight at high speed to the target, stomp, then drop
    function H.RageTickTPLock()
        local lock = H.RageTPQueue
        if not lock then return end
        local myHRP = H.GetHRP()
        local tHRP = lock.plr and lock.plr.Parent and H.RageGetHRP(lock.plr)
        if not myHRP or not tHRP or tick() > lock.expires or not H.Flags.RageAutoKill then
            return endTPLock()
        end
        local now = tick()
        local dt = math.clamp(now - lock.last, 0, 0.1)
        lock.last = now
        local myHum = H.GetHum()
        if myHum and not myHum.PlatformStand then pcall(function() myHum.PlatformStand = true end) end
        local body = tHRP.Parent:FindFirstChild("UpperTorso") or tHRP.Parent:FindFirstChild("Torso") or tHRP
        local goal = body.Position + Vector3.new(0, 3.5, 0)
        local cur = myHRP.Position
        local delta = goal - cur
        local step = math.huge
        local arrived = delta.Magnitude <= math.max(step, 2)
        local newPos = arrived and goal or cur + delta.Unit * step
        pcall(function()
            myHRP.AssemblyLinearVelocity = Vector3.zero
            myHRP.AssemblyAngularVelocity = Vector3.zero
            myHRP.CFrame = CFrame.new(newPos, newPos + Vector3.new(delta.X, 0, delta.Z) + Vector3.new(0, 0, 0.001))
        end)
        if not arrived then return end
        lock.arrivedAt = lock.arrivedAt or now
        -- the ragdoll keeps sliding after the KO, so keep following it and re-stomp until it dies or time runs out
        if not lock.lastStomp or now - lock.lastStomp >= 0.1 then
            lock.lastStomp = now
            local char = lock.plr.Character
            if char and H.MainRemote then
                pcall(function()
                    H.MainRemote:FireServer("Stomp")
                    H.MainRemote:FireServer("StompPlayer", char)
                    H.MainRemote:FireServer("Stomp", char)
                end)
            end
        end
        if not H.IsAlive(lock.plr) or now - lock.arrivedAt > 0.7 then
            endTPLock()
        end
    end

    function H.RageTryTP(plr)
        if not H.Flags.RageTPAuto or not H.Flags.RageAutoKill then return end
        if H.RageTPQueue then return end
        local knocked = H.IsKO(plr)
        if not knocked then return end
        local now = tick()
        if H.RageTPLast[plr] and now - H.RageTPLast[plr] < 0.4 then return end
        H.RageTPLast[plr] = now
        H.RageStartTPLock(plr)
    end

    function H.RageManualTP()
        local plr = H.RageFirstSelected()
        if not plr then return end
        local myHRP = H.GetHRP()
        local tHRP = H.RageGetHRP(plr)
        if myHRP and tHRP then
            pcall(function()
                myHRP.AssemblyLinearVelocity = Vector3.zero
                myHRP.CFrame = CFrame.new(tHRP.Position)
            end)
        end
    end

    function H.RageTryStomp(plr)
        if not H.Flags.RageAutoStomp or not H.Flags.RageAutoKill or not H.MainRemote then return end
        local knocked = H.IsKO(plr)
        if not knocked then return end
        local now = tick()
        if H.RageLastStomp[plr] and now - H.RageLastStomp[plr] < 0.6 then return end
        H.RageLastStomp[plr] = now
        pcall(function()
            H.MainRemote:FireServer("Stomp")
            H.MainRemote:FireServer("StompPlayer", plr.Character)
            H.MainRemote:FireServer("Stomp", plr.Character)
        end)
    end

    function H.RageStompAllTick()
        if not H.Flags.RageStompAll or not H.Flags.RageAutoKill or not H.MainRemote then return end
        local now = tick()
        if now - H.RageLastStompAll < 0.4 then return end
        H.RageLastStompAll = now
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if H.IsKO(plr) then
                    pcall(function()
                        H.MainRemote:FireServer("Stomp")
                        H.MainRemote:FireServer("StompPlayer", plr.Character)
                        H.MainRemote:FireServer("Stomp", plr.Character)
                    end)
                end
            end
        end
    end

    function H.RageSetSpectate(on)
        if H.RageSpectateConn then H.RageSpectateConn:Disconnect() H.RageSpectateConn = nil end
        if not on then
            local hum = H.GetHum()
            if hum then pcall(function() Camera.CameraSubject = hum end) end
            return
        end
        H.RageSpectateConn = RunService.RenderStepped:Connect(function()
            if not H.Flags.RageSpectate then return end
            local plr = H.RageFirstSelected()
            if not plr or not plr.Character then return end
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() Camera.CameraSubject = hum end) end
        end)
    end

    function H.SentryBlocked(name)
        local n = string.lower(name or "")
        for k in pairs(CFG.SENTRY_BLOCK) do
            if n:find(k, 1, true) then return true end
        end
        return false
    end

    function H.SafeEquipTool(tool)
        local char = LocalPlayer.Character
        if not char or not tool or typeof(tool) ~= "Instance" or not tool:IsA("Tool") then return false end
        if tool.Parent == char then return true end
        if tool.Parent == LocalPlayer:FindFirstChild("Backpack") then return true end
        return false
    end

    function H.IsSentryGun(name)
        if H.SentryBlocked(name) then return false end
        local n = string.lower(name or "")
        return n:find("revolver") or n:find("shotgun") or n:find("double") or n:find("tactical") or n:find("[", 1, true)
    end

    function H.SentryGunPriority(tool)
        local n = string.lower(tool.Name)
        for i, key in ipairs(CFG.GUN_ORDER) do
            if n:find(key, 1, true) then return i end
        end
        return 100
    end

    function H.ListSentryGuns()
        local guns = {}
        local function scan(parent)
            if not parent then return end
            for _, t in ipairs(parent:GetChildren()) do
                if t:IsA("Tool") and t:FindFirstChild("Handle") and H.IsSentryGun(t.Name) then
                    table.insert(guns, t)
                end
            end
        end
        scan(LocalPlayer.Character)
        scan(LocalPlayer:FindFirstChild("Backpack"))
        table.sort(guns, function(a, b) return H.SentryGunPriority(a) < H.SentryGunPriority(b) end)
        return guns
    end

    function H.EquipSentryGun(tool)
        return H.SafeEquipTool(tool)
    end

    function H.EquipNextSentryGun()
        local guns = H.ListSentryGuns()
        if #guns == 0 then return nil end
        if H.sentryGunIndex > #guns then H.sentryGunIndex = 1 end
        local tool = guns[H.sentryGunIndex]
        H.sentryGunIndex = H.sentryGunIndex + 1
        if H.sentryGunIndex > #guns then H.sentryGunIndex = 1 end
        H.EquipSentryGun(tool)
        return tool
    end

    function H.GuessSentryAttacker()
        local myHRP = H.GetHRP()
        if not myHRP then return nil end
        local myPos = myHRP.Position
        local best, bestScore = nil, -math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local c = plr.Character
                if c then
                    local hrp = c:FindFirstChild("HumanoidRootPart")
                    local head = c:FindFirstChild("Head")
                    local tool = c:FindFirstChildOfClass("Tool")
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    if hrp and tool and hum and hum.Health > 0 then
                        local dirToMe = (myPos - hrp.Position)
                        local dist = dirToMe.Magnitude
                        if dist > 0.5 then
                            local look = head and head.CFrame.LookVector or hrp.CFrame.LookVector
                            local dot = look:Dot(dirToMe.Unit)
                            if dot > 0.5 then
                                local score = dot * 1000 - dist * 0.001
                                if score > bestScore then bestScore = score; best = plr end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    function H.ShootWithSentry(tool, head)
        if not H.MainRemote or not tool or not head then return end
        if head.Name ~= "Head" then return end
        if H.SentryBlocked(tool.Name) or not H.IsSentryGun(tool.Name) then return end
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end
        if tool.Parent ~= LocalPlayer.Character then
            if not H.SafeEquipTool(tool) then return end
        end
        local Ammo = tool:FindFirstChild("Ammo")
        if Ammo and Ammo.Value <= 0 then return end
        local stats = H.RageGetWeaponStats(tool)
        local origin = H.GetWeaponOrigin(tool)
        local pos = head.Position
        local normal = Vector3.new(0, 1, 0)
        pcall(function()
            if H.RageIsShotgun(tool) then
                local pellets = {}
                for i = 1, 5 do
                    table.insert(pellets, { AimPosition = pos, RawAimPosition = pos, Result1 = pos, Result2 = head, Result3 = normal, AimLockPart = head, HitPart = head, HitPosition = pos })
                end
                H.MainRemote:FireServer("ShootGun", handle, origin, pellets, pos, head, normal, stats.range, stats.damage)
            else
                H.MainRemote:FireServer("ShootGun", handle, origin, nil, pos, head, normal, stats.range, stats.damage)
            end
        end)
    end

    function H.TpSentryHigh()
        local myHRP = H.GetHRP()
        if not myHRP then return end
        if not H.sentrySavedCF then H.sentrySavedCF = myHRP.CFrame end
        local p = myHRP.Position
        pcall(function()
            myHRP.AssemblyLinearVelocity = Vector3.zero
            myHRP.CFrame = CFrame.new(p.X, CFG.SENTRY_Y, p.Z)
        end)
        H.sentryVoided = true
    end

    function H.SentryReturnHome()
        if H.sentryReturning then return end
        H.sentryReturning = true
        local myHRP = H.GetHRP()
        if myHRP and H.sentrySavedCF then
            pcall(function()
                myHRP.AssemblyLinearVelocity = Vector3.zero
                myHRP.CFrame = H.sentrySavedCF
            end)
        end
        H.sentryVoided = false
        H.sentryTarget = nil
        H.sentryCenter = nil
        task.delay(0.2, function()
            H.sentryReturning = false
            H.sentrySavedCF = nil
        end)
    end

    -- reload every sentry gun; each is equipped briefly since the game only reloads held tools
    function H.SentryReloadAll()
        local hum = H.GetHum()
        if not hum then return end
        local char = LocalPlayer.Character
        local prev = char and char:FindFirstChildOfClass("Tool")
        for _, tool in ipairs(H.ListSentryGuns()) do
            if not hum.Parent or hum.Health <= 0 then return end
            local busy = H.AutoBuy and H.AutoBuy.isBusy()
            if tool.Parent ~= char and not busy then pcall(function() hum:EquipTool(tool) end) task.wait(0.15) end
            pcall(H.TriggerReloadTool, tool)
            task.wait(busy and 0.15 or 0.5)
        end
        if prev and prev.Parent and hum.Parent and not (H.AutoBuy and H.AutoBuy.isBusy()) then pcall(function() hum:EquipTool(prev) end) end
    end

    -- after the attacker is dealt with, restock armor then reload
    function H.SentryFinish()
        if not H.sentryEngaged then return end
        H.sentryEngaged = false
        task.delay(0.35, function()
            if H.Flags.SentryAutoReload ~= false then task.spawn(pcall, H.SentryReloadAll) end
            if H.Flags.SentryGrabArmor ~= false and H.AutoBuy then pcall(H.AutoBuy.armor) end
            if H.Flags.SentryAutoStim and H.AutoBuy then pcall(H.AutoBuy.stim) end
        end)
    end

    function H.SentryOnDamaged()
        if not H.Flags.RageSentry then return end
        local atk = H.GuessSentryAttacker()
        if not atk then return end
        H.sentryTarget = atk
        H.sentryEngaged = true
        H.sentryLockUntil = tick() + CFG.SENTRY_LOCK_TIME
        H.sentryGunIndex = 1
        if not H.sentryVoided then
            H.TpSentryHigh()
            task.defer(function()
                local guns = H.ListSentryGuns()
                if guns[1] then H.EquipSentryGun(guns[1]) end
            end)
        end
    end

    function H.BindSentryHum(hum)
        if not hum then return end
        H.sentryLastHp = hum.Health
        H.AddConn(hum.HealthChanged:Connect(function(hp)
            if hp < H.sentryLastHp - 0.5 then H.SentryOnDamaged() end
            H.sentryLastHp = hp
        end))
    end

    function H.SentryOnChar(char)
        task.wait(0.3)
        H.sentryVoided = false
        H.sentrySavedCF = nil
        H.sentryTarget = nil
        H.sentryCenter = nil
        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        H.BindSentryHum(hum)
    end

    if LocalPlayer.Character then H.SentryOnChar(LocalPlayer.Character) end
    H.AddConn(LocalPlayer.CharacterAdded:Connect(H.SentryOnChar))

    function H.RageSyncTargets()
        local newList = {}
        for i = 1, CFG.MAX_RAGE_TARGETS do
            local v = H.Flags["RageTarget" .. i]
            if v then
                local plr = H.resolvePlayer(v)
                if plr and plr ~= LocalPlayer then newList[plr] = true end
            end
        end
        local toRemove = {}
        for plr in pairs(H.RageTargets) do
            if not newList[plr] then table.insert(toRemove, plr) end
        end
        for _, plr in ipairs(toRemove) do
            H.RageTargets[plr] = nil
            H.RageTargetReady[plr] = nil
            H.RageWaitingRespawn[plr] = nil
            H.RageTPLast[plr] = nil
        end
        for plr in pairs(newList) do
            if not H.RageTargets[plr] then
                H.RageTargets[plr] = true
                H.RageTargetReady[plr] = not H.HasForceField(plr)
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then H.RageTargetOriginalCF[plr] = hrp.CFrame end
            end
        end
    end

    function H.RestoreRageTargetPositions(src)
        local restoreTable = src or H.RageTargetOriginalCF
        for plr, cf in pairs(restoreTable) do
            if plr and plr.Parent then
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and cf then
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        hrp.CFrame = cf
                    end)
                end
            end
            if src == nil then H.RageTargetOriginalCF[plr] = nil end
        end
    end

    H.KillAllSet = (function()
        local cloneref = cloneref or function(...) return ... end
        local Services = {
            RunService = cloneref(game:GetService("RunService")),
            Players = cloneref(game:GetService("Players")),
            ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage")),
        }
        local Services_LocalPlayer = Services.Players.LocalPlayer
        local FIRE_RATE = 0.08
        local lastFire = 0
        local KillConn = nil

        local function isKnocked(plr)
            local char = plr and plr.Character
            if not char then return false end
            local be = char:FindFirstChild("BodyEffects")
            if not be then return false end
            local ko = be:FindFirstChild("K.O") or be:FindFirstChild("Knocked")
            return ko and ko.Value == true
        end
        local function isGrabbed(plr)
            local char = plr and plr.Character
            if not char then return false end
            local be = char:FindFirstChild("BodyEffects")
            if not be then return false end
            local g = be:FindFirstChild("Grabbed")
            return g and g.Value == true
        end
        local function isAlive(plr)
            local char = plr and plr.Character
            if not char then return false end
            local hum = char:FindFirstChildOfClass("Humanoid")
            return hum and hum.Health > 0
        end
        local function isFullyLoaded(plr)
            local char = plr and plr.Character
            if not char then return false end
            return char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart")
                and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0
        end
        local function hasForceField(plr)
            local char = plr and plr.Character
            if not char then return true end
            if char:FindFirstChildOfClass("ForceField") then return true end
            if char:FindFirstChild("ForceField") then return true end
            if char:GetAttribute("ForceField") then return true end
            local be = char:FindFirstChild("BodyEffects")
            if be then
                local ff = be:FindFirstChild("ForceField")
                if ff and (ff:IsA("BoolValue") and ff.Value or ff:IsA("ForceField")) then
                    return true
                end
            end
            return false
        end
        local function findGun()
            local char = Services_LocalPlayer.Character
            if not char then return nil end
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") and t:FindFirstChild("Handle") then
                    local n = t.Name:lower()
                    if not n:find("knife") and not n:find("fist") and not n:find("bat") then
                        return t
                    end
                end
            end
        end
        local function isShotgun(tool)
            if not tool then return false end
            local n = tool.Name:lower()
            return n:find("shotgun") or n:find("double") or n:find("tactical")
                or n:find("barrel") or n:find("sg") or n:find("db")
                or tool:FindFirstChild("GunClientShotgun") ~= nil
        end
        local function getWeaponStats(gun)
            if not gun then return {range = 250, damage = 34.8} end
            local r, d
            r = gun:GetAttribute("Range") or gun:GetAttribute("MaxRange") or gun:GetAttribute("MaxDistance")
            d = gun:GetAttribute("Damage") or gun:GetAttribute("BaseDamage")
            if not r then
                local ro = gun:FindFirstChild("Range") or gun:FindFirstChild("MaxRange")
                if ro and ro:IsA("ValueBase") then r = ro.Value end
            end
            if not d then
                local dobj = gun:FindFirstChild("Damage") or gun:FindFirstChild("BaseDamage")
                if dobj and dobj:IsA("ValueBase") then d = dobj.Value end
            end
            if not r or not d then
                local n = gun.Name:lower()
                if n:find("double") or n:find("barrel") or n:find("db") then r, d = 95, 28.6
                elseif n:find("tactical") then r, d = 75, 29.3
                elseif n:find("shotgun") or n:find("sg") then r, d = 95, 28.6
                else r, d = 250, 34.8 end
            end
            return {range = r, damage = d}
        end
        local function getHitbox(plr)
            local char = plr and plr.Character
            if not char then return nil end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return nil end
            local rootAtt = hrp:FindFirstChild("RootAttachment")
            if rootAtt then
                local hb = rootAtt:FindFirstChild("Hitbox")
                if hb then return hb end
            end
            for _, d in ipairs(char:GetDescendants()) do
                if d.Name == "Hitbox" and (d:IsA("BasePart") or d:IsA("Attachment")) then
                    return d
                end
            end
            return hrp:FindFirstChild("RootAttachment") or char:FindFirstChild("Head") or hrp
        end
        local function getAimPosition(hitbox)
            if not hitbox then return nil end
            if hitbox:IsA("Attachment") then return hitbox.WorldPosition end
            if hitbox:IsA("BasePart") then return hitbox.Position end
            return nil
        end
        local function buildPellet(origin, centerAim, hitbox, dir)
            local off1 = Vector3.new(
                (math.random() - 0.5) * 1.0,
                (math.random() - 0.5) * 1.0,
                (math.random() - 0.5) * 1.0
            )
            local off2 = Vector3.zero
            if not H.Flags.NoSpread then
                off2 = Vector3.new(
                    (math.random() - 0.5) * 8.0,
                    (math.random() - 0.5) * 8.0,
                    (math.random() - 0.5) * 8.0
                )
            end
            return {
                AimPosition = centerAim + off2,
                RawAimPosition = centerAim + off2,
                Result1 = origin + dir * 12.8 + off1,
                Result2 = hitbox,
                Result3 = -dir,
            }
        end
        local function fireGun(gun, hitbox, origin, aimPos)
            local handle = gun:FindFirstChild("Handle")
            if not handle or not hitbox or not aimPos then return false end
            local stats = getWeaponStats(gun)
            local dir = (aimPos - origin).Unit
            if isShotgun(gun) then
                local pellets = {}
                for i = 1, 5 do
                    table.insert(pellets, buildPellet(origin, aimPos, hitbox, dir))
                end
                return pcall(function()
                    H.MainRemote:FireServer("ShootGun", handle, origin, pellets, nil, nil, nil, stats.range, stats.damage)
                end)
            else
                local result1 = origin + dir * 12.8
                return pcall(function()
                    H.MainRemote:FireServer("ShootGun", handle, origin, nil, aimPos, hitbox, dir, stats.range, stats.damage, result1, nil)
                end)
            end
        end
        local function shootAt(plr)
            if not H.MainRemote then return false end
            local gun = findGun()
            if not gun then return false end
            local hitbox = getHitbox(plr)
            if not hitbox then return false end
            local aimPos = getAimPosition(hitbox)
            if not aimPos then return false end
            local ammo = gun:FindFirstChild("Ammo")
            if ammo and ammo.Value <= 0 then
                H.TriggerReloadTool(gun)
                return false
            end
            local ok = fireGun(gun, hitbox, gun.Handle.Position, aimPos)
            if ok then H.TriggerReloadTool(gun) end
            return ok
        end
        local function getNearestTarget()
            local myHRP = Services_LocalPlayer.Character and Services_LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP then return nil end
            local best, bestDist = nil, math.huge
            for _, plr in ipairs(Services.Players:GetPlayers()) do
                if plr ~= Services_LocalPlayer and plr.Parent then
                    if isAlive(plr) and isFullyLoaded(plr)
                       and not isKnocked(plr) and not isGrabbed(plr)
                       and not hasForceField(plr) then
                        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local d = (hrp.Position - myHRP.Position).Magnitude
                            if d < bestDist then bestDist = d; best = plr end
                        end
                    end
                end
            end
            return best
        end
        return function(on)
            if KillConn then KillConn:Disconnect() KillConn = nil end
            if not on then return end
            local found = Services.ReplicatedStorage:FindFirstChild("MainRemotes")
                and Services.ReplicatedStorage.MainRemotes:FindFirstChild("MainRemoteEvent")
            if not found then
                found = Services.ReplicatedStorage:FindFirstChild("MainRemoteEvent", true)
            end
            H.MainRemote = found or H.MainRemote
            if H.MainRemote then
                pcall(function()
                    H.MainRemote:FireServer("ChangeSettings", "AutoReload", true)
                end)
            end
            KillConn = Services.RunService.Heartbeat:Connect(function()
                if tick() - lastFire < FIRE_RATE then return end
                local target = getNearestTarget()
                if not target then return end
                if shootAt(target) then lastFire = tick() end
            end)
        end
    end)()
end

do
    local LocalPlayer = H.LocalPlayer
    local RunService = H.RunService

    function H.PanicAll()
        H.KillAllSet(false)
        H.Flags.KillAll = false
        H.Flags.AimbotEnabled = false
        H.Flags.SilentAimEnabled = false
        H.Flags.ESPEnabled = false
        H.Flags.SpeedEnabled = false
        H.Flags.FlyEnabled = false
        H.Flags.Noclip = false
        H.Flags.RapidFire = false
        H.Flags.AutoStomp = false
        H.Flags.HitboxEnabled = false
        H.Flags.TriggerEnabled = false
        H.Flags.RageAutoKill = false
        H.Flags.RageSentry = false
        H.Flags.RageTPAuto = false
        H.Flags.RageAutoStomp = false
        H.Flags.RageStompAll = false
        H.Flags.RageSpectate = false
        H.Flags.VoidLoop = false
        H.Flags.OrbitEnabled = false
        pcall(H.StopOrbit)
        H.Flags.FollowEnabled = false
        if H.StopFollow then pcall(H.StopFollow) end
        H.RageTargets = {}
        H.RageTargetReady = {}
        H.RageWaitingRespawn = {}
        H.RestoreRageTargetPositions(H.RageTargetOriginalCF)
        H.RageTargetOriginalCF = {}
        H.RageTPLast = {}
        H.RageLastStomp = {}
        H.RageTPQueue = nil
        if H.sentryVoided then H.SentryReturnHome() end
        if H.RageSpectateConn then
            pcall(function() H.RageSpectateConn:Disconnect() end)
            H.RageSpectateConn = nil
        end
        H.Target = nil
        H.SilentCachedPart = nil
        H.applySpeed(false)
        H.StopSpeedLoop()
        H.StopFly()
        H.StopVoidLoop()
        H.ApplyNoclip()
        H.ApplyHitbox()
        H.CleanupRapidFire()
        for plr in pairs(H.ESPObjects) do H.RemoveESP(plr) end
        H.AutoStompLast = {}
    end
end

do
    local Arvn_ = Arvn
    local H_ = H
    local Players = H.Players
    local LocalPlayer = H.LocalPlayer

    local Group
    do
        local Window = Arvn_:CreateWindow({
            Title = "houhou",
            Author = "nokoo and a1j",
            Version = "betaa",
            Folder = "houhou",
            Subtitle = "made by @rcy8 & @a1j",
            Theme = "Dark",
            Defaults = {},
        })
        Group = Window:Group("Main")
    end

    do
        local AimbotTab = Group:Tab({ Name = "Aimbot", Icon = "crosshair" })
        local AimbotSection = AimbotTab:Section({ Name = "Aimbot Settings", Side = "Left" })
        AimbotSection:Toggle({ Name = "Aimbot Enabled", Flag = "AimbotEnabled", Default = false, Keybind = "V", Callback = function(v) H_.Flags.AimbotEnabled = v end })
        AimbotSection:Dropdown({ Name = "Aimbot Type", Flag = "AimbotType", Values = {"Camera", "Mouse"}, Default = "Camera", Callback = function(v) H_.Flags.AimbotType = v end })
        AimbotSection:Dropdown({ Name = "Hit Part", Flag = "AimbotHitPart", Values = {"Head", "HumanoidRootPart", "Closest"}, Default = "Head", Callback = function(v) H_.Flags.AimbotHitPart = v end })
        AimbotSection:Dropdown({ Name = "Target Method", Flag = "AimbotMethod", Values = {"Closest to Mouse", "Closest Distance", "FOV"}, Default = "Closest to Mouse", Callback = function(v) H_.Flags.AimbotMethod = v end })
        AimbotSection:Toggle({ Name = "Sticky Aim", Flag = "AimbotStickyAim", Default = false, Callback = function(v) H_.Flags.AimbotStickyAim = v end })
        AimbotSection:Toggle({ Name = "Unlock on Death", Flag = "AimbotUnlockOnDeath", Default = true, Callback = function(v) H_.Flags.AimbotUnlockOnDeath = v end })
        AimbotSection:Toggle({ Name = "Prediction", Flag = "AimbotPrediction", Default = false, Callback = function(v) H_.Flags.AimbotPrediction = v end })
        AimbotSection:Slider({ Name = "Prediction Value", Flag = "AimbotPredictionValue", Min = 0, Max = 100, Default = 16, Callback = function(v) H_.Flags.AimbotPredictionValue = v end })

        local FOVSection = AimbotTab:Section({ Name = "FOV Settings", Side = "Right" })
        FOVSection:Toggle({ Name = "Show FOV", Flag = "AimbotShowFOV", Default = true, Callback = function(v) H_.Flags.AimbotShowFOV = v end })
        FOVSection:Slider({ Name = "FOV Radius", Flag = "AimbotFOV", Min = 10, Max = 500, Default = 120, Callback = function(v) H_.Flags.AimbotFOV = v end })
        FOVSection:ColorPicker({ Name = "FOV Color", Flag = "AimbotFOVColor", Default = Color3.new(1, 1, 1) })
        FOVSection:Toggle({ Name = "Use FOV", Flag = "AimbotUseFOV", Default = true, Callback = function(v) H_.Flags.AimbotUseFOV = v end })

        local SmoothSection = AimbotTab:Section("Aimbot Smoothing")
        SmoothSection:Toggle({ Name = "Enable Smoothing", Flag = "AimbotSmoothing", Default = true, Callback = function(v) H_.Flags.AimbotSmoothing = v end })
        SmoothSection:Slider({ Name = "Smoothness", Flag = "AimbotSmoothness", Min = 1, Max = 30, Default = 15, Callback = function(v) H_.Flags.AimbotSmoothness = v end })
        SmoothSection:Toggle({ Name = "Independent Axes", Flag = "AimbotIndependentAxes", Default = false, Callback = function(v) H_.Flags.AimbotIndependentAxes = v end })
        SmoothSection:Slider({ Name = "Smooth X", Flag = "AimbotSmoothX", Min = 1, Max = 30, Default = 15, Callback = function(v) H_.Flags.AimbotSmoothX = v end })
        SmoothSection:Slider({ Name = "Smooth Y", Flag = "AimbotSmoothY", Min = 1, Max = 30, Default = 15, Callback = function(v) H_.Flags.AimbotSmoothY = v end })

        local CheckSection = AimbotTab:Section("Checks")
        CheckSection:Toggle({ Name = "Knocked Check", Flag = "AimbotKnockedCheck", Default = true, Callback = function(v) H_.Flags.AimbotKnockedCheck = v end })
        CheckSection:Toggle({ Name = "Dead Check", Flag = "AimbotDeadCheck", Default = true, Callback = function(v) H_.Flags.AimbotDeadCheck = v end })
        CheckSection:Toggle({ Name = "Wall Check", Flag = "AimbotWallCheck", Default = false, Callback = function(v) H_.Flags.AimbotWallCheck = v end })
        CheckSection:Toggle({ Name = "Team Check", Flag = "AimbotTeamCheck", Default = true, Callback = function(v) H_.Flags.AimbotTeamCheck = v end })
        CheckSection:Toggle({ Name = "Health Check", Flag = "AimbotHealthCheck", Default = false, Callback = function(v) H_.Flags.AimbotHealthCheck = v end })
        CheckSection:Slider({ Name = "Min Health", Flag = "AimbotMinHealth", Min = 0, Max = 200, Default = 0, Callback = function(v) H_.Flags.AimbotMinHealth = v end })
    end

    do
        local SilentTab = Group:Tab({ Name = "Silent Aim (wallbang)", Icon = "focus" })
        local SilentSection = SilentTab:Section("Silent Aim Settings")
        SilentSection:Toggle({ Name = "Silent Aim Enabled", Flag = "SilentAimEnabled", Default = false, Keybind = "P", Callback = function(v) H_.Flags.SilentAimEnabled = v end })
        SilentSection:Dropdown({ Name = "Hit Part", Flag = "SilentAimHitPart", Values = {"Head", "HumanoidRootPart", "Closest"}, Default = "Head", Callback = function(v) H_.Flags.SilentAimHitPart = v end })
        SilentSection:Slider({ Name = "FOV Radius", Flag = "SilentAimFOV", Min = 10, Max = 800, Default = 150, Callback = function(v) H_.Flags.SilentAimFOV = v end })
        SilentSection:Slider({ Name = "Hit Chance", Flag = "SilentAimHitChance", Min = 1, Max = 100, Default = 100, Callback = function(v) H_.Flags.SilentAimHitChance = v end })
        SilentSection:Toggle({ Name = "Show FOV Circle", Flag = "SilentAimShowFOV", Default = true, Callback = function(v) H_.Flags.SilentAimShowFOV = v end })
        SilentSection:ColorPicker({ Name = "FOV Color", Flag = "SilentAimFOVColor", Default = Color3.fromRGB(120, 180, 255) })
        SilentSection:Toggle({ Name = "Knocked Check", Flag = "SilentAimKnockedCheck", Default = true, Callback = function(v) H_.Flags.SilentAimKnockedCheck = v end })
        SilentSection:Toggle({ Name = "Wall Check", Flag = "SilentAimWallCheck", Default = false, Callback = function(v) H_.Flags.SilentAimWallCheck = v end })
        SilentSection:Toggle({ Name = "Team Check", Flag = "SilentAimTeamCheck", Default = true, Callback = function(v) H_.Flags.SilentAimTeamCheck = v end })
        SilentSection:Toggle({ Name = "No Spread", Flag = "NoSpread", Default = false, Callback = function(v) H_.Flags.NoSpread = v end })
    end

    do
        local OrbitTab = Group:Tab({ Name = "Orbit", Icon = "orbit" })
        local OrbitMain = OrbitTab:Section({ Name = "Orbit Settings", Side = "Left" })
        OrbitMain:Toggle({
            Name = "Orbit Enabled",
            Flag = "OrbitEnabled",
            Default = false,
            Keybind = "O",
            Callback = function(v)
                if v and #H_.OrbitGetTargets() == 0 then
                    H_.Flags.OrbitEnabled = false
                    Arvn_:Notify({ Title = "Orbit", Content = "Select a valid target first", Kind = "Warning" })
                    return
                end
                H_.Flags.OrbitEnabled = v
                if v then H_.StartOrbit() else H_.StopOrbit() end
            end,
        })
        OrbitMain:Slider({ Name = "Speed (u/s)", Flag = "OrbitSpeed", Min = 50, Max = 1200, Default = 250, Callback = function(v) H_.Flags.OrbitSpeed = v end })
        OrbitMain:Slider({ Name = "Distance", Flag = "OrbitDistance", Min = 3, Max = 80, Default = 14, Callback = function(v) H_.Flags.OrbitDistance = v end })
        OrbitMain:Slider({ Name = "Height", Flag = "OrbitHeight", Min = -20, Max = 40, Default = 2, Callback = function(v) H_.Flags.OrbitHeight = v end })
        OrbitMain:Slider({ Name = "Random Z", Flag = "OrbitRandZ", Min = 0, Max = 180, Default = 90, Callback = function(v) H_.Flags.OrbitRandZ = v end })
        OrbitMain:Slider({ Name = "Random X", Flag = "OrbitRandX", Min = 0, Max = 180, Default = 60, Callback = function(v) H_.Flags.OrbitRandX = v end })
        OrbitMain:Slider({ Name = "Chaos", Flag = "OrbitChaos", Min = 0, Max = 100, Default = 70, Callback = function(v) H_.Flags.OrbitChaos = v end })
        OrbitMain:Toggle({ Name = "Noclip", Flag = "OrbitNoclip", Default = true, Callback = function(v) H_.Flags.OrbitNoclip = v end })

        -- Follow: stay ahead of the first orbit target along its movement direction and shoot with pellet redirect
        function H_.StopFollow()
            if H_.FollowConn then H_.FollowConn:Disconnect() H_.FollowConn = nil end
            H_.followRedirectPart = nil
        end
        local function followTarget()
            local plr = H_.resolvePlayer(H_.Flags.FollowTarget)
            if plr and plr ~= LocalPlayer and H_.IsAlive(plr) and not H_.HasForceField(plr) then return plr end
            return nil
        end
        function H_.StartFollow()
            H_.StopFollow()
            local lastFire = 0
            H_.FollowConn = game:GetService("RunService").Heartbeat:Connect(function()
                if not H_.Flags.FollowEnabled then return H_.StopFollow() end
                local target = followTarget()
                local myHRP = H_.GetHRP()
                local tHRP = target and H_.RageGetHRP(target)
                if not myHRP or not tHRP or H_.IsKO(target) then
                    H_.followRedirectPart = nil
                    return
                end
                local vel = tHRP.AssemblyLinearVelocity
                local flat = Vector3.new(vel.X, 0, vel.Z)
                local dir = flat.Magnitude > 1 and flat.Unit or Vector3.new(tHRP.CFrame.LookVector.X, 0, tHRP.CFrame.LookVector.Z).Unit
                local predicted = tHRP.Position + vel * 0.1
                local dist = H_.Flags.FollowDistance or 10
                local pos = predicted + dir * dist + Vector3.new(0, H_.Flags.FollowHeight or 0, 0)
                pcall(function()
                    myHRP.AssemblyLinearVelocity = Vector3.zero
                    myHRP.CFrame = CFrame.new(pos, Vector3.new(tHRP.Position.X, pos.Y, tHRP.Position.Z))
                end)
                if H_.Flags.FollowShoot == false then H_.followRedirectPart = nil return end
                local head = H_.RageGetHead(target)
                if head and tick() - lastFire >= 0.05 then
                    lastFire = tick()
                    local lpl = LocalPlayer
                    local tool = (lpl.Character and lpl.Character:FindFirstChild("[Double-Barrel SG]"))
                        or (lpl:FindFirstChildOfClass("Backpack") and lpl.Backpack:FindFirstChild("[Double-Barrel SG]"))
                    if tool then
                        H_.followRedirectPart = head
                        local hum = H_.GetHum()
                        if tool.Parent ~= LocalPlayer.Character and hum then pcall(function() hum:EquipTool(tool) end) end
                        pcall(function() tool:Activate() end)
                    end
                end
            end)
        end
        local FollowTab = Group:Tab({ Name = "Follow", Icon = "orbit" })
        local FollowSec = FollowTab:Section({ Name = "Follow Settings", Side = "Left" })
        local FollowTargetSec = FollowTab:Section({ Name = "Follow Target", Side = "Right" })
        FollowTargetSec:Dropdown({ Name = "Target", Flag = "FollowTarget", Special = "Players", Callback = function(v) H_.Flags.FollowTarget = v end })
        FollowSec:Toggle({
            Name = "Follow",
            Flag = "FollowEnabled",
            Default = false,
            Callback = function(v)
                if v and not followTarget() then
                    H_.Flags.FollowEnabled = false
                    Arvn_:Notify({ Title = "Follow", Content = "Select a valid target first", Kind = "Warning" })
                    return
                end
                H_.Flags.FollowEnabled = v
                if v then H_.StartFollow() else H_.StopFollow() end
            end,
        })
        FollowSec:Slider({ Name = "Follow Distance", Flag = "FollowDistance", Min = 3, Max = 40, Default = 10, Callback = function(v) H_.Flags.FollowDistance = v end })
        FollowSec:Slider({ Name = "Follow Height", Flag = "FollowHeight", Min = -10, Max = 20, Default = 0, Callback = function(v) H_.Flags.FollowHeight = v end })
        FollowSec:Toggle({ Name = "Follow Shoot", Flag = "FollowShoot", Default = true, Callback = function(v) H_.Flags.FollowShoot = v end })

        local OrbitTargetsSec = OrbitTab:Section({ Name = "Orbit Targets", Side = "Right" })
        OrbitTargetsSec:Dropdown({ Name = "Target 1", Flag = "OrbitTarget1", Special = "Players", Callback = function(v) H_.Flags.OrbitTarget1 = v end })
        OrbitTargetsSec:Dropdown({ Name = "Target 2", Flag = "OrbitTarget2", Special = "Players", Callback = function(v) H_.Flags.OrbitTarget2 = v end })
        OrbitTargetsSec:Dropdown({ Name = "Target 3", Flag = "OrbitTarget3", Special = "Players", Callback = function(v) H_.Flags.OrbitTarget3 = v end })
        OrbitTargetsSec:Button({
            Name = "Clear Targets",
            Callback = function()
                H_.Flags.OrbitTarget1 = nil
                H_.Flags.OrbitTarget2 = nil
                H_.Flags.OrbitTarget3 = nil
                H_.StopOrbitView()
                Arvn_:Notify({ Title = "Orbit", Content = "Targets cleared", Kind = "Info" })
            end,
        })
        OrbitTargetsSec:Button({ Name = "Cycle View Target", Callback = function() task.defer(H_.CycleOrbitView) end })
        OrbitTargetsSec:Button({ Name = "Stop Viewing", Callback = function()
            H_.StopOrbitView()
            local hum = H_.GetHum()
            if hum then pcall(function() H_.Camera.CameraSubject = hum end) end
        end })
    end

    do
        local TriggerTab = Group:Tab({ Name = "Trigger Bot", Icon = "zap" })
        local TriggerMainSection = TriggerTab:Section({ Name = "Trigger Bot", Side = "Left" })
        TriggerMainSection:Toggle({ Name = "Trigger Bot Enabled", Flag = "TriggerEnabled", Default = false, Keybind = "E", Callback = function(v) H_.Flags.TriggerEnabled = v end })
        TriggerMainSection:Segmented({ Name = "Trigger Mode", Flag = "TriggerMode", Values = {"Hold", "Always", "OnKey"}, Default = "Hold", Callback = function(v) H_.Flags.TriggerMode = v end })
        TriggerMainSection:Slider({ Name = "Delay (ms)", Flag = "TriggerDelay", Min = 0, Max = 1000, Default = 100, Callback = function(v) H_.Flags.TriggerDelay = v end })

        local TriggerCheckSection = TriggerTab:Section({ Name = "Checks", Side = "Right" })
        TriggerCheckSection:Toggle({ Name = "Team Check", Flag = "TriggerTeamCheck", Default = true, Callback = function(v) H_.Flags.TriggerTeamCheck = v end })
        TriggerCheckSection:Toggle({ Name = "Knocked Check", Flag = "TriggerKnockedCheck", Default = true, Callback = function(v) H_.Flags.TriggerKnockedCheck = v end })

        local WhitelistSection = TriggerTab:Section({ Name = "Whitelist", Side = "Right" })
        WhitelistSection:Button({ Name = "Open Whitelist Manager", Callback = function() task.defer(H_.BuildWhitelistGUI) end })
        WhitelistSection:Button({
            Name = "List Whitelist",
            Callback = function()
                task.defer(function()
                    local count = 0
                    local names = {}
                    for k, _ in pairs(H_.Whitelist) do
                        count = count + 1
                        table.insert(names, tostring(k))
                    end
                    if count == 0 then
                        Arvn_:Notify({ Title = "Whitelist", Content = "List is empty", Kind = "Info" })
                    else
                        Arvn_:Notify({ Title = "Whitelist (" .. count .. ")", Content = table.concat(names, ", "), Time = 6, Kind = "Info" })
                    end
                end)
            end,
        })
        WhitelistSection:Button({
            Name = "Clear Whitelist",
            Callback = function()
                H_.Whitelist = {}
                Arvn_:Notify({ Title = "Whitelist", Content = "Cleared", Kind = "Warning" })
            end,
        })
    end

    do
        local RageTab = Group:Tab({ Name = "Rage", Icon = "crosshair" })
        local RageTargetsSec = RageTab:Section({ Name = "Targets", Side = "Left" })
        RageTargetsSec:Dropdown({ Name = "Target 1", Flag = "RageTarget1", Special = "Players", Callback = function(v) H_.Flags.RageTarget1 = v end })
        RageTargetsSec:Dropdown({ Name = "Target 2", Flag = "RageTarget2", Special = "Players", Callback = function(v) H_.Flags.RageTarget2 = v end })
        RageTargetsSec:Dropdown({ Name = "Target 3", Flag = "RageTarget3", Special = "Players", Callback = function(v) H_.Flags.RageTarget3 = v end })
        RageTargetsSec:Button({
            Name = "Clear Targets",
            Callback = function()
                H_.Flags.RageTarget1 = nil
                H_.Flags.RageTarget2 = nil
                H_.Flags.RageTarget3 = nil
                H_.RageTargets = {}
                H_.RageTargetReady = {}
                H_.RageWaitingRespawn = {}
                H_.RestoreRageTargetPositions(H_.RageTargetOriginalCF)
                H_.RageTargetOriginalCF = {}
                H_.RageTPQueue = nil
                Arvn_:Notify({ Title = "Rage", Content = "Targets cleared", Kind = "Info" })
            end,
        })
        RageTargetsSec:Button({ Name = "TP Manual -> Target", Callback = function() task.defer(H_.RageManualTP) end })

        local RageCombatSec = RageTab:Section({ Name = "Combat", Side = "Right" })
        RageCombatSec:Toggle({ Name = "Auto Kill", Flag = "RageAutoKill", Default = false, Keybind = "V", Callback = function(v)
            H_.Flags.RageAutoKill = v
            if not v then
                H_.RestoreRageTargetPositions(H_.RageTargetOriginalCF)
                H_.RageTargetOriginalCF = {}
            end
        end })
        RageCombatSec:Toggle({ Name = "Wait ForceField", Flag = "RageWaitFF", Default = true, Callback = function(v) H_.Flags.RageWaitFF = v end })
        RageCombatSec:Toggle({ Name = "Kill All", Flag = "KillAll", Default = false, Callback = function(v)
            H_.Flags.KillAll = v
            H_.KillAllSet(v)
        end })
        RageCombatSec:Toggle({ Name = "TP Auto KO", Flag = "RageTPAuto", Default = false, Callback = function(v) H_.Flags.RageTPAuto = v end })
        RageCombatSec:Toggle({ Name = "Stomp Target", Flag = "RageAutoStomp", Default = false, Callback = function(v) H_.Flags.RageAutoStomp = v end })
        RageCombatSec:Toggle({ Name = "Stomp All Knocked", Flag = "RageStompAll", Default = false, Callback = function(v) H_.Flags.RageStompAll = v end })
        RageCombatSec:Toggle({ Name = "Spectate Target", Flag = "RageSpectate", Default = false, Callback = function(v) H_.RageSetSpectate(v) end })
        RageCombatSec:Toggle({ Name = "Auto Switch Gun", Flag = "AutoSwitchGun", Default = false, Callback = function(v)
            H_.Flags.AutoSwitchGun = v
            if v and not H_.AutoSwitchRunning then
                H_.AutoSwitchRunning = true
                task.spawn(function()
                    local names = { "[Double-Barrel SG]", "[TacticalShotgun]" }
                    local idx = 1
                    while H_.Flags.AutoSwitchGun do
                        pcall(function()
                            if not H_.Flags.RageAutoKill then return end
                            local lpl = game:GetService("Players").LocalPlayer
                            local c = lpl.Character
                            local hum = c and c:FindFirstChildOfClass("Humanoid")
                            local bp = lpl:FindFirstChildOfClass("Backpack")
                            if not hum or hum.Health <= 0 then return end
                            local tool = (bp and bp:FindFirstChild(names[idx])) or c:FindFirstChild(names[idx])
                            if not tool then
                                idx = idx % 2 + 1
                                tool = (bp and bp:FindFirstChild(names[idx])) or c:FindFirstChild(names[idx])
                            end
                            if tool then
                                if tool.Parent ~= c then hum:EquipTool(tool) end
                                idx = idx % 2 + 1
                            end
                        end)
                        task.wait(0.15)
                    end
                    H_.AutoSwitchRunning = false
                end)
            end
        end })

        local RageSentrySec = RageTab:Section({ Name = "Sentry", Side = "Left" })
        RageSentrySec:Toggle({
            Name = "Sentry Enabled",
            Flag = "RageSentry",
            Default = false,
            Callback = function(v)
                if not v and H_.sentryVoided then H_.SentryReturnHome() end
                if not v then
                    H_.sentryTarget = nil
                    H_.sentryCenter = nil
                end
            end,
        })
        RageSentrySec:Toggle({ Name = "Sentry Grab Armor", Flag = "SentryGrabArmor", Default = true, Callback = function(v) H_.Flags.SentryGrabArmor = v end })

        RageSentrySec:Toggle({ Name = "Sentry Auto Stim", Flag = "SentryAutoStim", Default = false, Callback = function(v) H_.Flags.SentryAutoStim = v end })
        RageSentrySec:Toggle({ Name = "Sentry Auto Reload", Flag = "SentryAutoReload", Default = true, Callback = function(v) H_.Flags.SentryAutoReload = v end })

        local RageMiscSec = RageTab:Section({ Name = "Misc", Side = "Right" })
        RageMiscSec:Button({
            Name = "Sentry Return Home",
            Callback = function()
                if H_.sentryVoided then H_.SentryReturnHome() end
            end,
        })
    end

    do
        local MethodsTab = Group:Tab({ Name = "Rage Methods", Icon = "crosshair" })
        local MethodsSection = MethodsTab:Section({ Name = "Method Selector", Side = "Left" })
        MethodsSection:Dropdown({
            Name = "Active Method",
            Flag = "RageMethodDropdown",
            Values = {"Method 1", "Method 2"},
            Default = "Method 2",
            Callback = function(v)
                if type(v) == "table" then v = v[1] end
                H_.RageMethod = v
            end,
        })

        local InfoSection = MethodsTab:Section({ Name = "Info", Side = "Right" })
        InfoSection:Paragraph({
            Title = "Method 1",
            Content = "shoot without tp the target to you (maybe cant work sometimes/other games)",
        })
        InfoSection:Paragraph({
            Title = "Method 2",
            Content = "Silent aim + moves the target in front before firing",
        })
        InfoSection:Button({
            Name = "TP Manual -> Target",
            Callback = function() task.defer(H_.RageManualTP) end,
        })
    end

    do
        local ScriptsTab = Group:Tab({ Name = "Scripts", Icon = "file-code" })
        local ScriptsSection = ScriptsTab:Section({ Name = "Available Scripts", Side = "Left" })
        ScriptsSection:Button({
            Name = "Run Infinite Yield",
            Callback = function()
                task.spawn(function()
                    local ok, err = pcall(function()
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
                    end)
                    if ok then
                        Arvn_:Notify({ Title = "Scripts", Content = "Infinite Yield loaded", Kind = "Success" })
                    else
                        Arvn_:Notify({ Title = "Scripts", Content = "Failed: " .. tostring(err), Kind = "Error" })
                    end
                end)
            end,
        })
    end

    do
        local VisualTab = Group:Tab({ Name = "Visuals / ESP", Icon = "eye" })
        local TracerSection = VisualTab:Section({ Name = "Bullet Tracers", Side = "Right" })
        TracerSection:Toggle({ Name = "Bullet Tracers", Flag = "BulletTracers", Default = false, Callback = function(v) H_.Flags.BulletTracers = v end })
        TracerSection:ColorPicker({ Name = "Tracer Color", Flag = "BulletTracerColor", Default = Color3.fromRGB(255, 80, 80) })
        TracerSection:Slider({ Name = "Thickness", Flag = "BulletTracerThickness", Min = 1, Max = 20, Default = 3, Callback = function(v) H_.Flags.BulletTracerThickness = v end })
        TracerSection:Slider({ Name = "Lifetime (x0.1s)", Flag = "BulletTracerLifetime", Min = 1, Max = 50, Default = 8, Callback = function(v) H_.Flags.BulletTracerLifetime = v end })

        TracerSection:Dropdown({ Name = "Tracer Style", Flag = "BulletTracerStyle", Values = {"Solid", "Laser", "Fading", "Lightning", "Pulse", "Dotted", "Rainbow", "Spiral"}, Default = "Solid", Callback = function(v)
            if type(v) == "table" then v = v[1] end
            H_.Flags.BulletTracerStyle = v
        end })

        local lastShot = 0
        local lastReplicated = 0
        local spawnTracer

        -- Read where a game bullet beam/part goes so the custom tracer can overlay the same path
        local function bulletEndpoints(obj)
            if obj:IsA("Beam") then
                local a0, a1 = obj.Attachment0, obj.Attachment1
                if a0 and a1 then return a0.WorldPosition, a1.WorldPosition end
            elseif obj:IsA("BasePart") then
                local s, cf = obj.Size, obj.CFrame
                local axis = (s.X >= s.Y and s.X >= s.Z) and cf.RightVector or (s.Y >= s.Z and cf.UpVector or cf.LookVector)
                local half = math.max(s.X, s.Y, s.Z) / 2
                return cf.Position - axis * half, cf.Position + axis * half
            end
        end
        local function lockHidden(obj)
            local function hide()
                pcall(function()
                    if obj:IsA("Beam") then
                        obj.Enabled = false
                        obj.Width0, obj.Width1 = 0, 0
                    elseif obj:IsA("Trail") or obj:IsA("ParticleEmitter") then
                        obj.Enabled = false
                    elseif obj:IsA("BasePart") then
                        obj.Transparency = 1
                    end
                end)
            end
            hide()
            local props = obj:IsA("Beam") and { "Enabled", "Width0", "Width1" }
                or (obj:IsA("BasePart") and { "Transparency" }) or { "Enabled" }
            for _, p in ipairs(props) do
                obj:GetPropertyChangedSignal(p):Connect(hide)
            end
        end
        -- Hide the game's own bullet visuals so only the custom tracer shows
        local function hideGameBullet(obj)
            if not H_.Flags.BulletTracers then return end
            local name = obj.Name:lower()
            local byName = name == "gunbeam" or name:find("pellet") or name == "bullet"
            local byShot = os.clock() - lastShot < 0.75 and (obj:IsA("Beam") or obj:IsA("Trail"))
            if not (byName or byShot) then return end
            task.defer(function()
                -- Let the game finish positioning the bullet before reading its path
                task.wait()
                local list = { obj }
                for _, d in ipairs(obj:GetDescendants()) do list[#list + 1] = d end
                local beams, parts = {}, {}
                for _, o in ipairs(list) do
                    if o:IsA("Beam") then beams[#beams + 1] = o
                    elseif o:IsA("BasePart") then parts[#parts + 1] = o end
                end
                local sources = #beams > 0 and beams or { parts[1] }
                for _, src in ipairs(sources) do
                    local from, to = bulletEndpoints(src)
                    if from and to then
                        lastReplicated = os.clock()
                        spawnTracer(from, to)
                    end
                end
                for _, o in ipairs(list) do
                    if o:IsA("Beam") or o:IsA("Trail") or o:IsA("ParticleEmitter") or o:IsA("BasePart") then
                        lockHidden(o)
                    end
                end
            end)
        end
        workspace.DescendantAdded:Connect(hideGameBullet)
        local TweenService = game:GetService("TweenService")
        local Debris = game:GetService("Debris")
        local function seg(a, b, width, color, life, startTransparency)
            local len = (b - a).Magnitude
            if len < 0.01 then return end
            local part = Instance.new("Part")
            part.Anchored = true
            part.CanCollide = false
            part.CanQuery = false
            part.CanTouch = false
            part.CastShadow = false
            part.Material = Enum.Material.Neon
            part.Color = color
            part.Transparency = startTransparency or 0
            part.Size = Vector3.new(width, width, len)
            part.CFrame = CFrame.lookAt(a, b) * CFrame.new(0, 0, -len / 2)
            part.Parent = workspace
            TweenService:Create(part, TweenInfo.new(life), { Transparency = 1 }):Play()
            Debris:AddItem(part, life + 0.1)
            return part
        end
        local function basis(dir)
            local right = dir:Cross(Vector3.yAxis)
            if right.Magnitude < 0.01 then right = dir:Cross(Vector3.xAxis) end
            right = right.Unit
            return right, right:Cross(dir).Unit
        end
        local TracerStyles = {}
        function TracerStyles.Solid(from, to, w, color, life)
            seg(from, to, w, color, life)
        end
        function TracerStyles.Laser(from, to, w, color, life)
            seg(from, to, w * 3, color, life, 0.65)
            seg(from, to, w * 0.8, Color3.new(1, 1, 1), life)
        end
        function TracerStyles.Fading(from, to, w, color, life)
            local n = 24
            for i = 1, n do
                local a, b = from:Lerp(to, (i - 1) / n), from:Lerp(to, i / n)
                -- Tail fades quickly, head lingers
                seg(a, b, w, color, life * (0.25 + 0.75 * i / n), 0.8 * (1 - i / n))
            end
        end
        function TracerStyles.Rainbow(from, to, w, _, life)
            local n = 30
            for i = 1, n do
                seg(from:Lerp(to, (i - 1) / n), from:Lerp(to, i / n), w, Color3.fromHSV(i / n, 1, 1), life)
            end
        end
        function TracerStyles.Lightning(from, to, w, color, life)
            local dist = (to - from).Magnitude
            local dir = (to - from).Unit
            local right, up = basis(dir)
            local n = math.clamp(math.floor(dist / 4), 4, 40)
            local jitter = math.clamp(dist / 40, 0.6, 3)
            local pts = { from }
            for i = 1, n - 1 do
                local off = right * (math.random() - 0.5) * 2 * jitter + up * (math.random() - 0.5) * 2 * jitter
                pts[#pts + 1] = from:Lerp(to, i / n) + off
            end
            pts[#pts + 1] = to
            for i = 1, #pts - 1 do
                local l = life * (0.5 + math.random() * 0.5)
                seg(pts[i], pts[i + 1], w * 2.5, color, l, 0.6)
                seg(pts[i], pts[i + 1], w * 0.8, Color3.new(1, 1, 1), l)
            end
        end
        function TracerStyles.Pulse(from, to, w, color, life)
            local dist = (to - from).Magnitude
            seg(from, to, w * 0.5, color, life, 0.7)
            local len = math.min(8, dist)
            local dir = (to - from).Unit
            local bolt = seg(from, from + dir * len, w * 2, color, life)
            if bolt then
                local goal = CFrame.lookAt(to - dir * len, to) * CFrame.new(0, 0, -len / 2)
                TweenService:Create(bolt, TweenInfo.new(life * 0.6, Enum.EasingStyle.Linear), { CFrame = goal }):Play()
            end
        end
        function TracerStyles.Dotted(from, to, w, color, life)
            local dist = (to - from).Magnitude
            local dir = (to - from).Unit
            local count = math.min(150, math.floor(dist / 3))
            for i = 0, count do
                local p = from + dir * (i * 3)
                seg(p, p + dir * w * 2, w * 2, color, life * (0.4 + 0.6 * i / math.max(count, 1)))
            end
        end
        function TracerStyles.Spiral(from, to, w, color, life)
            local dist = (to - from).Magnitude
            local dir = (to - from).Unit
            local right, up = basis(dir)
            local steps = math.clamp(math.floor(dist), 8, 150)
            local radius = 0.7
            local function point(i)
                local t = i / steps
                local ang = t * dist * 0.9
                return from + dir * (t * dist) + (right * math.cos(ang) + up * math.sin(ang)) * radius
            end
            for i = 1, steps do
                seg(point(i - 1), point(i), w, color, life)
            end
        end

        spawnTracer = function(from, to)
            if (to - from).Magnitude < 1 then return end
            local width = (H_.Flags.BulletTracerThickness or 3) / 20
            local life = (H_.Flags.BulletTracerLifetime or 8) / 10
            local color = H_.NormalizeColor(H_.Flags.BulletTracerColor, Color3.fromRGB(255, 80, 80))
            local style = H_.Flags.BulletTracerStyle
            if type(style) == "table" then style = style[1] end
            local fn = TracerStyles[style] or TracerStyles.Solid
            pcall(fn, from, to, width, color, life)
        end
        local function shotOrigin()
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            local handle = tool and (tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart"))
            local root = H_.GetHRP()
            return handle and handle.Position or (root and root.Position)
        end
        -- Real shots are MainRemoteEvent:FireServer("ShootGun", handle, origin, pellets|nil, aimPos, ...)
        if hookmetamethod and newcclosure and getnamecallmethod then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                if H_.Flags.BulletTracers and getnamecallmethod() == "FireServer" and not checkcaller()
                    and typeof(self) == "Instance" and self.Name == "MainRemoteEvent" then
                    local kind, handle, origin, pellets, aim = ...
                    if kind == "ShootGun" then
                        lastShot = os.clock()
                        local from = (typeof(origin) == "Vector3" and origin)
                            or (typeof(handle) == "Instance" and handle:IsA("BasePart") and handle.Position)
                            or shotOrigin()
                        local targets = {}
                        if type(pellets) == "table" then
                            for i, pellet in ipairs(pellets) do
                                if i > 10 then break end
                                if type(pellet) == "table" and typeof(pellet.AimPosition) == "Vector3" then
                                    table.insert(targets, pellet.AimPosition)
                                end
                            end
                        elseif typeof(aim) == "Vector3" then
                            table.insert(targets, aim)
                        end
                        if from then
                            -- Fallback: only draw from the remote if the game's own bullet wasn't replicated
                            task.delay(0.3, function()
                                if lastReplicated >= lastShot then return end
                                for _, t in ipairs(targets) do spawnTracer(from, t) end
                            end)
                        end
                    end
                end
                return oldNamecall(self, ...)
            end))
        end
        local ChamsSection = VisualTab:Section({ Name = "Self Chams", Side = "Right" })
        ChamsSection:Toggle({ Name = "Self Chams", Flag = "SelfChams", Default = false, Callback = function(v) H_.Flags.SelfChams = v end })
        ChamsSection:Toggle({ Name = "Gun Chams Only", Flag = "GunChams", Default = false, Callback = function(v) H_.Flags.GunChams = v end })
        ChamsSection:ColorPicker({ Name = "Chams Color", Flag = "SelfChamsColor", Default = Color3.fromRGB(120, 180, 255) })
        ChamsSection:Slider({ Name = "Transparency", Flag = "SelfChamsTransparency", Min = 0, Max = 100, Default = 0, Callback = function(v) H_.Flags.SelfChamsTransparency = v end })
        ChamsSection:Toggle({ Name = "Glow", Flag = "SelfChamsGlow", Default = false, Callback = function(v) H_.Flags.SelfChamsGlow = v end })

        local chamsOriginals = setmetatable({}, { __mode = "k" })
        local chamsSkip = setmetatable({}, { __mode = "k" })
        local chamsHighlight
        local function restorePart(part, o)
            local function try(f) pcall(f) end
            try(function() part.Material = o.Material end)
            try(function() part.Color = o.Color end)
            try(function() part.Transparency = o.Transparency end)
            try(function() part.CanCollide = o.CanCollide end)
            try(function() if o.TextureID ~= nil then part.TextureID = o.TextureID end end)
            try(function() if o.SA then for _, sa in ipairs(o.SA) do sa.Parent = part end end end)
        end
        local function restoreChams()
            for part, o in pairs(chamsOriginals) do
                if part.Parent then restorePart(part, o) end
                chamsOriginals[part] = nil
            end
            if chamsHighlight then chamsHighlight:Destroy() chamsHighlight = nil end
        end
        local function applyChams()
            local char = LocalPlayer.Character
            if not char then return end
            local color = H_.NormalizeColor(H_.Flags.SelfChamsColor, Color3.fromRGB(120, 180, 255))
            local material = Enum.Material.ForceField
            local transparency = (H_.Flags.SelfChamsTransparency or 0) / 100
            local gunOnly = not H_.Flags.SelfChams
            local tool = char:FindFirstChildOfClass("Tool")
            if gunOnly then
                for part, o in pairs(chamsOriginals) do
                    if not (tool and part:IsDescendantOf(tool)) then
                        restorePart(part, o)
                        chamsOriginals[part] = nil
                    end
                end
            end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not chamsSkip[part]
                    and (not gunOnly or (tool and part:IsDescendantOf(tool))) then
                    if not chamsOriginals[part] then
                        -- Leave parts that were invisible (hitboxes, helpers) untouched
                        if part.Transparency >= 0.95 then
                            chamsSkip[part] = true
                            continue
                        end
                        chamsOriginals[part] = { Material = part.Material, Color = part.Color, Transparency = part.Transparency, CanCollide = part.CanCollide }
                    end
                    if H_.Flags.SelfChamsCollide then
                        if not part.CanCollide then part.CanCollide = true end
                    elseif part.CanCollide ~= chamsOriginals[part].CanCollide then
                        part.CanCollide = chamsOriginals[part].CanCollide
                    end
                    if part.Material ~= material then part.Material = material end
                    if part.Color ~= color then part.Color = color end
                    if part.Transparency ~= transparency then part.Transparency = transparency end
                end
            end
            local glowTarget = gunOnly and tool or char
            if H_.Flags.SelfChamsGlow and glowTarget then
                if not chamsHighlight or chamsHighlight.Parent ~= glowTarget then
                    if chamsHighlight then chamsHighlight:Destroy() end
                    chamsHighlight = Instance.new("Highlight")
                    chamsHighlight.Name = "SelfChamsGlow"
                    chamsHighlight.FillTransparency = 0.6
                    chamsHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    chamsHighlight.Adornee = glowTarget
                    chamsHighlight.Parent = glowTarget
                end
                chamsHighlight.FillColor = color
                chamsHighlight.OutlineColor = color
            elseif chamsHighlight then
                chamsHighlight:Destroy()
                chamsHighlight = nil
            end
        end
        local chamsWasOn = false
        H_.RunService.RenderStepped:Connect(function()
            if H_.Flags.SelfChams or H_.Flags.GunChams then
                chamsWasOn = true
                pcall(applyChams)
            elseif chamsWasOn or next(chamsOriginals) ~= nil or chamsHighlight then
                chamsWasOn = false
                restoreChams()
            end
        end)
        -- Physics resets collisions each step, so reapply before it runs
        H_.RunService.Stepped:Connect(function()
            if not H_.Flags.SelfChamsCollide then return end
            for part in pairs(chamsOriginals) do
                if part.Parent and not part.CanCollide then part.CanCollide = true end
            end
        end)

        local PlayersSection = VisualTab:Section({ Name = "Players", Side = "Left" })
        PlayersSection:Toggle({
            Name = "ESP Master Enable",
            Flag = "ESPEnabled",
            Default = false,
            Keybind = "RightControl",
            Callback = function(v)
                H_.Flags.ESPEnabled = v
                if not v then
                    for plr in pairs(H_.ESPObjects) do H_.RemoveESP(plr) end
                else
                    task.spawn(function()
                        task.wait(0.1)
                        H_.ResetESP()
                    end)
                end
            end,
        })
        PlayersSection:Dropdown({ Name = "Box Type", Flag = "ESPBoxType", Values = {"None", "2D", "3D"}, Default = "None", Callback = function(v) if type(v) == "table" then v = v[1] end H_.Flags.ESPBoxType = v end })
        PlayersSection:Toggle({ Name = "Glowing Boxes", Flag = "ESPGlowingBoxes", Default = false, Callback = function(v) H_.Flags.ESPGlowingBoxes = v end })
        PlayersSection:ColorPicker({ Name = "Box Color", Flag = "ESPBoxColor", Default = Color3.fromRGB(255, 255, 255) })
        PlayersSection:Toggle({ Name = "Name ESP", Flag = "ESPName", Default = false, Callback = function(v) H_.Flags.ESPName = v end })
        PlayersSection:ColorPicker({ Name = "Name Color", Flag = "ESPNameColor", Default = Color3.fromRGB(255, 255, 255) })
        PlayersSection:Dropdown({ Name = "Name Type", Flag = "ESPNameType", Values = {"Normal", "Display"}, Default = "Normal", Callback = function(v) H_.Flags.ESPNameType = v end })
        PlayersSection:Toggle({ Name = "Health Bar", Flag = "ESPHealth", Default = false, Callback = function(v) H_.Flags.ESPHealth = v end })
        PlayersSection:ColorPicker({ Name = "Health Color", Flag = "ESPHealthColor", Default = Color3.fromRGB(0, 255, 0) })
        PlayersSection:Toggle({ Name = "Distance", Flag = "ESPDistance", Default = false, Callback = function(v) H_.Flags.ESPDistance = v end })
        PlayersSection:ColorPicker({ Name = "Distance Color", Flag = "ESPDistanceColor", Default = Color3.fromRGB(255, 255, 255) })
        PlayersSection:Toggle({ Name = "Tool Equip", Flag = "ESPTool", Default = false, Callback = function(v) H_.Flags.ESPTool = v end })
        PlayersSection:ColorPicker({ Name = "Tool Color", Flag = "ESPToolColor", Default = Color3.fromRGB(0, 255, 0) })
        PlayersSection:Toggle({ Name = "Glow", Flag = "ESPGlow", Default = false, Callback = function(v) H_.Flags.ESPGlow = v end })
        PlayersSection:ColorPicker({ Name = "Glow Color", Flag = "ESPGlowColor", Default = Color3.fromRGB(255, 255, 255) })
        PlayersSection:Slider({ Name = "Max Distance", Flag = "ESPMaxDistance", Min = 10, Max = 5000, Default = 500, Callback = function(v) H_.Flags.ESPMaxDistance = v end })
        PlayersSection:Toggle({ Name = "No Limit", Flag = "ESPNoLimit", Default = false, Callback = function(v) H_.Flags.ESPNoLimit = v end })
        PlayersSection:Toggle({ Name = "Team Check", Flag = "ESPTeamCheck", Default = true, Callback = function(v) H_.Flags.ESPTeamCheck = v end })
        PlayersSection:Button({ Name = "Reset ESP", Callback = function() task.defer(H_.ResetESP) end })

        local TracerSection = VisualTab:Section({ Name = "Tracers", Side = "Right" })
        TracerSection:Dropdown({ Name = "Type", Flag = "ESPTracerType", Values = {"Off", "Straight", "Arc"}, Default = "Off", Callback = function(v) H_.Flags.ESPTracerType = v end })
        TracerSection:Dropdown({ Name = "Origin", Flag = "ESPTracerOrigin", Values = {"Cursor", "Bottom", "Center"}, Default = "Bottom", Callback = function(v) H_.Flags.ESPTracerOrigin = v end })
        TracerSection:ColorPicker({ Name = "Color", Flag = "ESPTracerColor", Default = Color3.fromRGB(180, 190, 235) })
    end

    do
        local MoveTab = Group:Tab({ Name = "Movement", Icon = "person-standing" })
        local SpeedSection = MoveTab:Section("Speed")
        SpeedSection:Toggle({
            Name = "Speed Enabled",
            Flag = "SpeedEnabled",
            Default = false,
            Callback = function(v)
                H_.Flags.SpeedEnabled = v
                if v then
                    H_.applySpeed(true)
                    H_.StartSpeedLoop()
                else
                    H_.applySpeed(false)
                    H_.StopSpeedLoop()
                end
            end,
        })
        SpeedSection:Dropdown({ Name = "Speed Method", Flag = "SpeedMethod", Values = {"Velocity", "WalkSpeed", "Hybrid", "CFrame", "BodyVelocity"}, Default = "Velocity", Callback = function(v)
            H_.Flags.SpeedMethod = v
            if H_.Flags.SpeedEnabled then
                H_.applySpeed(false)
                H_.applySpeed(true)
            end
        end })
        SpeedSection:Slider({ Name = "Speed Value", Flag = "SpeedValue", Min = 0, Max = 5000, Default = 16, Callback = function(v) H_.Flags.SpeedValue = v end })

        local JumpSection = MoveTab:Section("Jump Power")
        H_.Flags.JumpPowerValue = H_.Flags.JumpPowerValue or 50
        local JumpConns = {}
        local function clearJumpConns()
            for _, c in ipairs(JumpConns) do pcall(function() c:Disconnect() end) end
            table.clear(JumpConns)
        end
        local function applyJump()
            local hum = H_.GetHum()
            if not hum then return end
            local p = H_.Flags.JumpPowerValue
            local h = p * p / (2 * workspace.Gravity)
            pcall(function()
                hum.UseJumpPower = true
                hum.JumpPower = p
                hum.JumpHeight = h
            end)
        end
        local launched = false
        local boostFrames = 0
        local function boost()
            local root = H_.GetHRP()
            if not root then return end
            local v = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(v.X, H_.Flags.JumpPowerValue, v.Z)
        end
        local function launchCheck()
            local hum, root = H_.GetHum(), H_.GetHRP()
            if not hum or not root or hum.Health <= 0 then return end
            local grounded = hum.FloorMaterial ~= Enum.Material.Air
            if grounded and not hum.Jump then launched = false end
            if not launched and (hum.Jump or hum:GetState() == Enum.HumanoidStateType.Jumping) then
                launched = true
                boostFrames = 3
            end
            -- Re-apply for a few frames in case the game overwrites the launch velocity
            if boostFrames > 0 then
                boostFrames -= 1
                boost()
            end
        end
        local function bindHumanoid(hum)
            -- Re-apply the instant the game changes the values back
            for _, prop in ipairs({ "JumpPower", "JumpHeight", "UseJumpPower" }) do
                table.insert(JumpConns, hum:GetPropertyChangedSignal(prop):Connect(function()
                    if H_.Flags.JumpPowerEnabled then applyJump() end
                end))
            end
            -- Force the launch velocity in case the game ignores the properties
            table.insert(JumpConns, hum.StateChanged:Connect(function(_, new)
                if new ~= Enum.HumanoidStateType.Jumping or not H_.Flags.JumpPowerEnabled then return end
                local root = H_.GetHRP()
                if root then
                    local v = root.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity = Vector3.new(v.X, H_.Flags.JumpPowerValue, v.Z)
                end
            end))
        end
        local function startJump()
            clearJumpConns()
            applyJump()
            local hum = H_.GetHum()
            if hum then bindHumanoid(hum) end
        end
        -- Permanent loops (gated by the flag) so nothing depends on connect/disconnect timing
        local function tick()
            if H_.Flags.JumpPowerEnabled then applyJump() launchCheck() end
        end
        H_.RunService.Stepped:Connect(tick)
        -- Run after everything else in the frame so the game's resets can't win
        pcall(function() H_.RunService:UnbindFromRenderStep("JumpPowerLast") end)
        H_.RunService:BindToRenderStep("JumpPowerLast", Enum.RenderPriority.Last.Value + 1, tick)
        -- Same timing as the slider callback: re-apply at the moment of the jump input
        H_.UserInputService.InputBegan:Connect(function(input)
            if H_.Flags.JumpPowerEnabled and input.KeyCode == Enum.KeyCode.Space then
                applyJump()
                local hum = H_.GetHum()
                if hum and hum.FloorMaterial ~= Enum.Material.Air then boostFrames = 3 end
            end
        end)
        -- Ignore the game's own writes to the jump properties while enabled
        if hookmetamethod and newcclosure and checkcaller then
            local oldNewIndex
            oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
                if H_.Flags.JumpPowerEnabled and not checkcaller() and typeof(self) == "Instance"
                    and (key == "JumpPower" or key == "JumpHeight" or key == "UseJumpPower")
                    and self:IsA("Humanoid") then
                    return
                end
                return oldNewIndex(self, key, value)
            end))
        end
        H_.RunService.Heartbeat:Connect(tick)
        H_.RunService.RenderStepped:Connect(tick)
        H_.UserInputService.JumpRequest:Connect(function()
            if not H_.Flags.JumpPowerEnabled then return end
            applyJump()
            local hum = H_.GetHum()
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                launched = true
                boostFrames = 3
            end
        end)
        LocalPlayer.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid", 10)
            if H_.Flags.JumpPowerEnabled then startJump() end
        end)
        task.spawn(function()
            while true do
                tick()
                task.wait()
            end
        end)
        JumpSection:Toggle({
            Name = "Jump Power Enabled",
            Flag = "JumpPowerEnabled",
            Default = false,
            Callback = function(v)
                H_.Flags.JumpPowerEnabled = v
                clearJumpConns()
                if v then
                    pcall(startJump)
                else
                    local hum = H_.GetHum()
                    if hum then pcall(function() hum.UseJumpPower = true hum.JumpPower = 50 end) end
                end
            end,
        })
        JumpSection:Slider({ Name = "Jump Power", Flag = "JumpPowerValue", Min = 0, Max = 500, Default = 50, Callback = function(v)
            H_.Flags.JumpPowerValue = v
            if H_.Flags.JumpPowerEnabled then applyJump() end
        end })

        local FlySection = MoveTab:Section("Fly")
        FlySection:Toggle({
            Name = "Fly",
            Flag = "FlyEnabled",
            Default = false,
            Keybind = { Key = "LeftAlt", Mode = "Hold" },
            Callback = function(v)
                H_.Flags.FlyEnabled = v
                if v then
                    H_.StopVoidLoop()
                    H_.StartFly()
                else
                    H_.StopFly()
                end
            end,
        })
        FlySection:Slider({ Name = "Fly Speed", Flag = "FlySpeed", Min = 1, Max = 50, Default = 5, Callback = function(v) H_.Flags.FlySpeed = v end })

        local VoidLoopSection = MoveTab:Section("Void Loop")
        VoidLoopSection:Toggle({
            Name = "Void Loop",
            Flag = "VoidLoop",
            Default = false,
            Callback = function(v)
                if v then
                    H_.StopFly()
                    H_.StartVoidLoop()
                else
                    H_.StopVoidLoop()
                end
            end,
        })
        VoidLoopSection:Slider({ Name = "Speed", Flag = "VoidLoopSpeed", Min = 1000, Max = 300000, Default = 42000, Callback = function(v) H_.VoidLoopCFG.speed = v end })
        VoidLoopSection:Slider({ Name = "Height", Flag = "VoidLoopHeight", Min = -20000, Max = 150000, Default = 8200, Callback = function(v) H_.VoidLoopCFG.height = v end })
        VoidLoopSection:Slider({ Name = "Radius", Flag = "VoidLoopRadius", Min = 150, Max = 25000, Default = 1800, Callback = function(v) H_.VoidLoopCFG.radius = v end })
        VoidLoopSection:Slider({ Name = "Dive Chance %", Flag = "VoidLoopDiveChance", Min = 0, Max = 100, Default = 42, Callback = function(v) H_.VoidLoopCFG.diveChance = v / 100 end })
        VoidLoopSection:Slider({ Name = "Target Player %", Flag = "VoidLoopTargetPlayer", Min = 0, Max = 100, Default = 90, Callback = function(v) H_.VoidLoopCFG.targetPlayer = v / 100 end })

        local MiscMoveSection = MoveTab:Section("Misc Movement")
        MiscMoveSection:Toggle({ Name = "Noclip", Flag = "Noclip", Default = false, Callback = function(v) H_.Flags.Noclip = v H_.ApplyNoclip() end })
        MiscMoveSection:Toggle({ Name = "Anchor", Flag = "Anchor", Default = false, Callback = function(v) H_.Flags.Anchor = v H_.ApplyAnchor() end })

        local SpiderParams = RaycastParams.new()
        SpiderParams.FilterType = Enum.RaycastFilterType.Exclude
        H_.RunService.Heartbeat:Connect(function()
            if not H_.Flags.Spider then return end
            local hum, root = H_.GetHum(), H_.GetHRP()
            if not hum or not root or hum.Health <= 0 then return end
            local dir = hum.MoveDirection
            if dir.Magnitude == 0 then return end
            SpiderParams.FilterDescendantsInstances = { LocalPlayer.Character }
            local hit = workspace:Raycast(root.Position, dir.Unit * 3, SpiderParams)
            if hit and math.abs(hit.Normal.Y) < 0.5 then
                local v = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(v.X, 40, v.Z)
            end
        end)
        MiscMoveSection:Toggle({ Name = "Spider", Flag = "Spider", Default = false, Callback = function(v) H_.Flags.Spider = v end })
    end

    do
        local WorldTab = Group:Tab({ Name = "World", Icon = "globe" })
        local WorldSection = WorldTab:Section("World Settings")
        WorldSection:Toggle({ Name = "Fullbright", Flag = "Fullbright", Default = false, Callback = function(v) H_.Flags.Fullbright = v H_.ApplyFullbright() end })
        WorldSection:Toggle({ Name = "No Fog", Flag = "NoFog", Default = false, Callback = function(v) H_.Flags.NoFog = v H_.ApplyNoFog() end })
        WorldSection:Toggle({ Name = "Clock Time Enabled", Flag = "ClockTimeEnabled", Default = false, Callback = function(v) H_.Flags.ClockTimeEnabled = v H_.ApplyClockTime() end })
        WorldSection:Slider({ Name = "Clock Time", Flag = "ClockTime", Min = 0, Max = 24, Default = 12, Callback = function(v) H_.Flags.ClockTime = v H_.ApplyClockTime() end })
        WorldSection:Toggle({ Name = "Ambient Enabled", Flag = "AmbientEnabled", Default = false, Callback = function(v) H_.Flags.AmbientEnabled = v H_.ApplyAmbient() end })
        WorldSection:ColorPicker({ Name = "Ambient Color", Flag = "AmbientColor", Default = Color3.new(0.5, 0.5, 0.5), Callback = function(v)
            H_.ApplyAmbient()
        end })

        local Skyboxes = {
            ["Dark Sky"] = { Up = 570555929, Rt = 570555882, Dn = 570555964, Ft = 570555800, Lf = 570555840, Bk = 570555736 },
            ["Art Mountain"] = { Up = 2128462236, Rt = 2128462027, Dn = 2128462480, Ft = 2128458653, Lf = 2128462027, Bk = 2128458653 },
            ["Vaporwave"] = { Up = 1417494643, Rt = 1417494499, Dn = 1417494146, Ft = 1417494253, Lf = 1417494402, Bk = 1417494030 },
            ["Nebula"] = { Up = 159454288, Rt = 159454300, Dn = 159454296, Ft = 159454293, Lf = 159454286, Bk = 159454299 },
            ["Twilight"] = { Up = 264907379, Rt = 264908886, Dn = 264907909, Ft = 264909420, Lf = 264909758, Bk = 264908339 },
            ["Lake Sky"] = { Up = 6823528533, Rt = 6823531746, Dn = 6823525702, Ft = 6823482923, Lf = 6823530023, Bk = 6823523318 },
            ["Alien Red"] = { Up = 7123412196, Rt = 7123402505, Dn = 7123387679, Ft = 7123390433, Lf = 7123394786, Bk = 7123385217 },
            ["Black Mesa"] = { Up = 9569598752, Rt = 9569601267, Dn = 9569613307, Ft = 9569611418, Lf = 9569608166, Bk = 9569742122 },
            ["Clouds"] = { Up = 570557727, Rt = 570557672, Dn = 570557775, Ft = 570557559, Lf = 570557620, Bk = 570557514 },
        }
        local skyNames = { "Default" }
        for name in pairs(Skyboxes) do table.insert(skyNames, name) end
        table.sort(skyNames, function(a, b)
            if a == "Default" then return true elseif b == "Default" then return false end
            return a < b
        end)
        local hiddenSkies, customSky = {}, nil
        local function applySkybox(name)
            if type(name) == "table" then name = name[1] end
            if customSky then customSky:Destroy() customSky = nil end
            local data = Skyboxes[name]
            if not data then
                for _, s in ipairs(hiddenSkies) do s.Parent = H_.Lighting end
                hiddenSkies = {}
                return
            end
            for _, s in ipairs(H_.Lighting:GetChildren()) do
                if s:IsA("Sky") then
                    table.insert(hiddenSkies, s)
                    s.Parent = nil
                end
            end
            customSky = Instance.new("Sky")
            customSky.Name = "CustomSkybox"
            for face, id in pairs(data) do
                customSky["Skybox" .. face] = "rbxassetid://" .. id
            end
            customSky.Parent = H_.Lighting
        end
        WorldSection:Dropdown({ Name = "Custom Skybox", Flag = "CustomSkybox", Values = skyNames, Default = "Default", Callback = function(v)
            H_.Flags.CustomSkybox = v
            applySkybox(v)
        end })
    end

    do
        local PlayersTab = Group:Tab({ Name = "Players", Icon = "users" })
        local PlayersListSection = PlayersTab:Section("Player List")
        PlayersListSection:PlayerList({
            Name = "Players",
            Flag = "PlayerListSelected",
            Callback = function(plr) H_.Flags.SelectedPlayer = plr end,
        })

        local TargetSection = PlayersTab:Section("Target")
        TargetSection:Dropdown({ Name = "Select Player", Flag = "TargetPlayer", Special = "Players", Callback = function(v) H_.Flags.TargetPlayer = v end })
        TargetSection:Button({
            Name = "Goto",
            Callback = function()
                task.defer(function()
                    local plr = H_.resolvePlayer(Arvn_.Flags.TargetPlayer)
                    if plr then H_.GotoPlayer(plr) end
                end)
            end,
        })
        TargetSection:Button({
            Name = "Spectate",
            Callback = function()
                task.defer(function()
                    local plr = H_.resolvePlayer(Arvn_.Flags.TargetPlayer)
                    if plr then H_.Spectate(plr) end
                end)
            end,
        })
        TargetSection:Button({ Name = "Unspectate", Callback = function() H_.Unspectate() end })
        TargetSection:Button({
            Name = "Copy UserId",
            Callback = function()
                local plr = H_.resolvePlayer(Arvn_.Flags.TargetPlayer)
                if plr then
                    local fn = setclipboard or toclipboard
                    if fn then H_.SafeCall(fn, tostring(plr.UserId)) end
                end
            end,
        })
        TargetSection:Button({
            Name = "Copy Username",
            Callback = function()
                local plr = H_.resolvePlayer(Arvn_.Flags.TargetPlayer)
                if plr then
                    local fn = setclipboard or toclipboard
                    if fn then H_.SafeCall(fn, plr.Name) end
                end
            end,
        })
    end

    do
        local MiscTab = Group:Tab({ Name = "Misc", Icon = "wrench" })
        local MiscSection = MiscTab:Section("Miscellaneous")

        local AutoBuy = {}
        do
            local Players = game:GetService("Players")
            local lpl = Players.LocalPlayer
            local CFG = { standOut = 3, settle = 0.15, arriveWait = 0.35, confirmTimeout = 2.5, shopTimeout = 3, tries = 8, retryDelay = 0.05, verifyWait = 0.2, armorMax = 200 }
            local buying = false
            local shop

            local function getShop()
                if shop and shop.Parent then return shop end
                local ig = workspace:FindFirstChild("Ignored")
                shop = ig and ig:FindFirstChild("Shop")
                return shop
            end
            local function bodyEffects()
                local pf = workspace:FindFirstChild("Players")
                pf = pf and pf:FindFirstChild(lpl.Name)
                return pf and pf:FindFirstChild("BodyEffects")
            end
            local function flagVal(name)
                local b = bodyEffects()
                local f = b and b:FindFirstChild(name)
                return f and f.Value
            end
            local function char() return lpl.Character end
            local function root() local c = char() return c and c:FindFirstChild("HumanoidRootPart") end
            local function humanoid() local c = char() return c and c:FindFirstChildOfClass("Humanoid") end
            local function isKO()
                if flagVal("K.O") == true then return true end
                local h = humanoid()
                return h ~= nil and h.PlatformStand == true
            end
            local function waitShop()
                local t0 = tick()
                while flagVal("Shop") == true and tick() - t0 < CFG.shopTimeout do task.wait(0.1) end
                return flagVal("Shop") ~= true
            end
            local function findStall(pattern)
                local g, s = root(), getShop()
                if not g or not s then return nil end
                local best, dist
                for _, v in ipairs(s:GetChildren()) do
                    if v.Name:lower():find(pattern, 1, true) then
                        local cd = v:FindFirstChildOfClass("ClickDetector")
                        local hd = v:FindFirstChild("Head") or v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
                        if cd and hd then
                            local d = (hd.Position - g.Position).Magnitude
                            if not dist or d < dist then
                                dist = d
                                best = { cd = cd, hd = hd, stand = v:FindFirstChild("HumanoidRootPart") or hd, d = d, pattern = pattern }
                            end
                        end
                    end
                end
                return best
            end
            local function fireStall(t, confirm)
                if type(fireclickdetector) ~= "function" then return false end
                local g = root()
                if not t or not g or not t.cd.Parent or isKO() then return false end
                local old, oldVel, away
                local holding = false
                if t.d > (t.cd.MaxActivationDistance or 0) then
                    old = g.CFrame
                    oldVel = g.AssemblyLinearVelocity
                    away = tick()
                    holding = true
                    task.spawn(function()
                        while holding and g.Parent do
                            pcall(function() g.AssemblyLinearVelocity = Vector3.zero end)
                            task.wait()
                        end
                    end)
                    pcall(function() g.CFrame = CFrame.new(t.stand.Position + Vector3.new(CFG.standOut, 0, 0)) end)
                    task.wait(CFG.arriveWait)
                end
                local ok = pcall(fireclickdetector, t.cd)
                -- stay at the stall until the purchase registers instead of leaving mid-buy
                local t0 = tick()
                while confirm and tick() - t0 < CFG.confirmTimeout do
                    task.wait(0.1)
                    if confirm() then break end
                end
                if not confirm then task.wait(CFG.settle) end
                holding = false
                if old and g.Parent then
                    -- carry on from where the player would be now, not where they started
                    local h = humanoid()
                    local drift = Vector3.zero
                    if h then
                        local md = h.MoveDirection
                        drift = Vector3.new(md.X, 0, md.Z) * h.WalkSpeed * (tick() - away)
                    end
                    pcall(function()
                        g.CFrame = old + drift
                        g.AssemblyLinearVelocity = h and Vector3.new(h.MoveDirection.X * h.WalkSpeed, oldVel.Y, h.MoveDirection.Z * h.WalkSpeed) or oldVel
                    end)
                end
                return ok
            end
            local function findStim()
                local c, bp = char(), lpl:FindFirstChildOfClass("Backpack")
                for _, parent in ipairs({ bp, c }) do
                    if parent then
                        for _, v in ipairs(parent:GetChildren()) do
                            if v:IsA("Tool") and v.Name:lower():find("stim", 1, true) then return v end
                        end
                    end
                end
                return nil
            end

            -- reads the on-screen armor bar; returns fill 0..1, or nil if no bar is found
            local armorGui
            local function guiArmorFill()
                local pg = lpl:FindFirstChildOfClass("PlayerGui")
                if not pg then return nil end
                if not (armorGui and armorGui.Parent) then
                    armorGui = nil
                    for _, d in ipairs(pg:GetDescendants()) do
                        if d.Name == "Armor" and d:IsA("GuiObject") and d:FindFirstChildWhichIsA("GuiObject", true) then
                            armorGui = d
                            break
                        end
                    end
                    if not armorGui then return nil end
                end
                local best
                for _, d in ipairs(armorGui:GetDescendants()) do
                    if d:IsA("TextLabel") then
                        local a, b = d.Text:match("(%d+%.?%d*)%s*/%s*(%d+%.?%d*)")
                        if a and b and tonumber(b) > 0 then return math.clamp(tonumber(a) / tonumber(b), 0, 1) end
                    elseif d:IsA("Frame") and d.Name:lower() == "bar" then
                        best = d
                    end
                end
                if best then
                    local parentW = best.Parent and best.Parent:IsA("GuiObject") and best.Parent.AbsoluteSize.X or 0
                    if best.Size.X.Scale > 0 or parentW == 0 then return math.clamp(best.Size.X.Scale, 0, 1) end
                    return math.clamp(best.AbsoluteSize.X / parentW, 0, 1)
                end
                return nil
            end
            local function armorIsFull()
                local v = flagVal("Armor")
                if not v or v < CFG.armorMax then return false end
                local fill = guiArmorFill()
                return fill == nil or fill >= 0.98
            end
            AutoBuy.armorIsFull = armorIsFull

            function AutoBuy.armor()
                if buying then return false end
                buying = true
                local ok, res = pcall(function()
                    if armorIsFull() then return true end
                    for _ = 1, CFG.tries do
                        if not waitShop() then return false end
                        local before = flagVal("Armor") or 0
                        local function gained() return (flagVal("Armor") or 0) > before or armorIsFull() end
                        fireStall(findStall("full armor"), gained)
                        waitShop()
                        if armorIsFull() then return true end
                        task.wait(CFG.retryDelay)
                    end
                    return false
                end)
                buying = false
                return ok and res
            end

            local function useStim()
                local tool = findStim()
                local hum = humanoid()
                if not tool or not hum then return false end
                local prev
                local c = char()
                for _, v in ipairs(c:GetChildren()) do
                    if v:IsA("Tool") and v ~= tool then prev = v break end
                end
                if tool.Parent ~= c then pcall(function() hum:EquipTool(tool) end) task.wait(0.03) end
                local t0 = tick()
                repeat
                    pcall(function() tool:Activate() end)
                    task.wait(0.05)
                until not findStim() or tick() - t0 > 0.4
                if prev and prev.Parent and hum.Parent then
                    pcall(function() hum:EquipTool(prev) end)
                end
                return true
            end

            local function inReach(t)
                return t and t.cd and t.cd.Parent and t.d <= (t.cd.MaxActivationDistance or 0)
            end

            -- true when both stalls can be clicked from where we stand, no teleport needed
            function AutoBuy.bothInReach()
                if type(fireclickdetector) ~= "function" then return false end
                return inReach(findStall("full armor")) and inReach(findStall("stim")) and true or false
            end

            function AutoBuy.both()
                if buying then return false end
                buying = true
                local ok, res = pcall(function()
                    local needStim = not findStim()
                    for _ = 1, CFG.tries do
                        if not waitShop() then return false end
                        local before = flagVal("Armor") or 0
                        local a, s = findStall("full armor"), needStim and findStall("stim")
                        if not inReach(a) then return false end
                        if needStim and not inReach(s) then return false end
                        task.spawn(pcall, fireclickdetector, a.cd)
                        if needStim then task.spawn(pcall, fireclickdetector, s.cd) end
                        local t0 = tick()
                        while tick() - t0 < CFG.confirmTimeout do
                            task.wait(0.1)
                            local armorOk = (flagVal("Armor") or 0) > before or armorIsFull()
                            if armorOk and (not needStim or findStim()) then break end
                        end
                        waitShop()
                        if armorIsFull() and (not needStim or findStim()) then break end
                        task.wait(CFG.retryDelay)
                    end
                    useStim()
                    return true
                end)
                buying = false
                return ok and res
            end

            function AutoBuy.stim()
                if buying then return false end
                buying = true
                local ok, res = pcall(function()
                    if not findStim() then
                        for _ = 1, CFG.tries do
                            if not waitShop() then return false end
                            fireStall(findStall("stim"), findStim)
                            waitShop()
                            task.wait(CFG.verifyWait)
                            if findStim() then break end
                            task.wait(CFG.retryDelay)
                        end
                    end
                    return useStim()
                end)
                buying = false
                return ok and res
            end

            function AutoBuy.isBusy() return buying end
            H_.AutoBuy = AutoBuy

            local lastHealth, lastArmor, lastDamageAt, stimPending = nil, nil, 0, false
            task.spawn(function()
                while true do
                    task.wait()
                    local wantArmor, wantStim = H_.Flags.AutoArmor, H_.Flags.AutoStim
                    local hum = humanoid()
                    local armor = flagVal("Armor") or 0
                    if hum and (wantArmor or wantStim) and not isKO() then
                        local damaged = (lastHealth and hum.Health < lastHealth - 0.01) or (lastArmor and armor < lastArmor - 0.01)
                        if damaged then
                            lastDamageAt = tick()
                            stimPending = true
                        end
                        -- no cooldown: keep re-buying armor for as long as damage keeps coming
                        if not buying and hum.Health > 0 and tick() - lastDamageAt < 3 then
                            task.spawn(function()
                                local h0 = humanoid()
                                if stimPending and H_.Flags.AutoArmor and H_.Flags.AutoStim and h0 and h0.Health < h0.MaxHealth and AutoBuy.bothInReach() then
                                    stimPending = false
                                    AutoBuy.both()
                                    return
                                end
                                if H_.Flags.AutoArmor then AutoBuy.armor() end
                                local h = humanoid()
                                if stimPending and H_.Flags.AutoStim and h and h.Health > 0 and h.Health < h.MaxHealth then
                                    stimPending = false
                                    AutoBuy.stim()
                                end
                            end)
                        end
                    end
                    lastHealth = hum and hum.Health or nil
                    lastArmor = armor
                end
            end)
        end

        MiscSection:Toggle({ Name = "AutoArmor", Flag = "AutoArmor", Default = false, Callback = function(v) H_.Flags.AutoArmor = v end })
        MiscSection:Toggle({ Name = "AutoStim", Flag = "AutoStim", Default = false, Callback = function(v) H_.Flags.AutoStim = v end })
        MiscSection:Toggle({ Name = "Anti AFK", Flag = "AntiAFK", Default = false, Callback = function(v) H_.Flags.AntiAFK = v H_.ApplyAntiAFK() end })
        MiscSection:Toggle({ Name = "Anti Stomp", Flag = "AntiStomp", Default = true, Callback = function(v) H_.Flags.AntiStomp = v end })
        local DesyncHook
        MiscSection:Toggle({ Name = "Desync", Flag = "Desync", Default = false, Callback = function(v)
            H_.Flags.Desync = v
            local rk = raknet or (getgenv and getgenv().raknet)
            if not (rk and typeof(rk.add_send_hook) == "function") then
                if v then Arvn_:Notify({ Title = "Desync", Content = "RakNet library not found", Kind = "Warning" }) end
                return
            end
            if v and not DesyncHook then
                DesyncHook = function(packet)
                    if H_.Flags.Desync and packet and packet.PacketId == 0xA1 and typeof(packet.Block) == "function" then
                        packet:Block()
                    end
                end
                rk.add_send_hook(DesyncHook)
            elseif not v and DesyncHook then
                if typeof(rk.remove_send_hook) == "function" then pcall(rk.remove_send_hook, DesyncHook) end
                DesyncHook = nil
            end
        end })
        MiscSection:Toggle({ Name = "Watermark", Flag = "Watermark", Default = true, Callback = function(v) H_.Flags.Watermark = v end })
        MiscSection:Toggle({ Name = "Auto Stomp", Flag = "AutoStomp", Default = false, Callback = function(v)
            H_.Flags.AutoStomp = v
            if v then
                if not H_.MainRemote then H_.MainRemote = H_.findMainRemote() end
            else
                H_.AutoStompLast = {}
            end
        end })
        MiscSection:Toggle({ Name = "Rapid Fire", Flag = "RapidFire", Default = false, Callback = function(v)
            H_.Flags.RapidFire = v
            if not v then H_.CleanupRapidFire() else H_.ScanRapidFireTools() end
        end })

        local HitboxSection = MiscTab:Section("Hitbox Expander")
        HitboxSection:Toggle({ Name = "Hitbox Expander", Flag = "HitboxEnabled", Default = false, Callback = function(v)
            H_.Flags.HitboxEnabled = v
            H_.ApplyHitbox()
        end })
        HitboxSection:Slider({ Name = "Hitbox Size", Flag = "HitboxSize", Min = 5, Max = 25, Default = 6, Callback = function(v) H_.Flags.HitboxSize = v end })
        HitboxSection:Slider({ Name = "Transparency", Flag = "HitboxTransparency", Min = 0, Max = 100, Default = 50, Callback = function(v) H_.Flags.HitboxTransparency = v end })

        MiscSection:Button({
            Name = "Respawn",
            Callback = function()
                H_.SafeCall(function()
                    local hum = H_.GetHum()
                    if hum then hum.Health = 0 end
                end)
            end,
        })
        MiscSection:Button({
            Name = "Rejoin",
            Callback = function()
                H_.SafeCall(function() H_.TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
            end,
        })
        MiscSection:Button({
            Name = "Server Hop",
            Callback = function()
                task.spawn(function()
                    local ok = H_.SafeCall(function()
                        local raw = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                        local servers = H_.HttpService:JSONDecode(raw)
                        if servers and servers.data and #servers.data > 0 then
                            H_.TeleportService:TeleportToPlaceInstance(game.PlaceId, servers.data[1].id, LocalPlayer)
                        end
                    end)
                    if not ok then
                        Arvn_:Notify({ Title = "houhou", Content = "Server hop unavailable", Kind = "Warning" })
                    end
                end)
            end,
        })
        MiscSection:Button({
            Name = "Copy Job ID",
            Callback = function()
                local fn = setclipboard or toclipboard
                if fn then H_.SafeCall(fn, game.JobId) end
            end,
        })
        MiscSection:Button({
            Name = "Copy Place ID",
            Callback = function()
                local fn = setclipboard or toclipboard
                if fn then H_.SafeCall(fn, tostring(game.PlaceId)) end
            end,
        })
        MiscSection:Button({ Name = "Panic", Callback = function() task.defer(H_.PanicAll) end })
    end

    do
        local SettingsTab = Group:Tab({ Name = "Settings", Icon = "settings" })
        local SettingsSection = SettingsTab:Section("Settings")
        SettingsSection:Button({
            Name = "Fix UI Quality",
            Callback = function()
                pcall(function()
                    if H_.WL_GUI then
                        H_.WL_GUI.ResetOnSpawn = false
                        H_.WL_GUI.IgnoreGuiInset = false
                    end
                end)
                Arvn_:Notify({ Title = "houhou", Content = "UI fix applied", Kind = "Success" })
            end,
        })
        SettingsSection:Button({
            Name = "Unload houhou",
            Callback = function()
                task.defer(function()
                    H_.PanicAll()
                    H_.Flags.Desync = false
                    H_.DestroyWhitelistGUI()
                    for _, c in ipairs(H_.Connections) do pcall(function() c:Disconnect() end) end
                    H_.Connections = {}
                    pcall(function() H_.RunService:UnbindFromRenderStep("houhouAimbot") end)
                    H_.StopFly()
                    H_.StopSpeedLoop()
                    H_.StopVoidLoop()
                    H_.StopOrbit()
                    if H_.FOVCircle then pcall(function() H_.FOVCircle:Remove() end) H_.FOVCircle = nil end
                    if H_.SilentFOVCircle then pcall(function() H_.SilentFOVCircle:Remove() end) H_.SilentFOVCircle = nil end
                    if H_.Watermark then pcall(function() H_.Watermark:Remove() end) H_.Watermark = nil end
                    for plr in pairs(H_.ESPObjects) do H_.RemoveESP(plr) end
                    H_.Lighting.Brightness = H_.oldLighting.Brightness
                    H_.Lighting.ClockTime = H_.oldLighting.ClockTime
                    H_.Lighting.Ambient = H_.oldLighting.Ambient
                    H_.Lighting.OutdoorAmbient = H_.oldLighting.OutdoorAmbient
                    H_.Lighting.FogEnd = H_.oldLighting.FogEnd
                    H_.Lighting.FogStart = H_.oldLighting.FogStart
                    local hum = H_.GetHum()
                    if hum then hum.WalkSpeed = 16 end
                    local hrp = H_.GetHRP()
                    if hrp then hrp.Anchored = false end
                    H_.Unspectate()
                    if H_.sentryVoided and H_.sentrySavedCF then
                        local myHRP = H_.GetHRP()
                        if myHRP then
                            pcall(function()
                                myHRP.AssemblyLinearVelocity = Vector3.zero
                                myHRP.CFrame = H_.sentrySavedCF
                            end)
                        end
                    end
                    if H_.RageSpectateConn then
                        pcall(function() H_.RageSpectateConn:Disconnect() end)
                        H_.RageSpectateConn = nil
                    end
                    if Arvn_.Unload then pcall(function() Arvn_:Unload() end) end
                end)
            end,
        })
    end
end

do
    local LocalPlayer = H.LocalPlayer
    local Players = H.Players
    local RunService = H.RunService

    pcall(function() RunService:UnbindFromRenderStep("houhouAimbot") end)
    RunService:BindToRenderStep("houhouAimbot", Enum.RenderPriority.Camera.Value + 1, function()
        pcall(H.ApplyAimbot)
    end)

    H.AddConn(RunService.Heartbeat:Connect(function()
        pcall(H.UpdateFOVCircle)
        pcall(H.UpdateSilentFOVCircle)
        pcall(H.UpdateESP)
        pcall(H.CheckESPHealth)
        pcall(H.UpdateRapidFire)
        pcall(H.UpdateTriggerBot)
        pcall(H.SilentScan)
        pcall(H.DoAutoStomp)

        H.RageSyncTargets()
        H.RageTickTPLock()

        do
            local toRemove = {}
            for plr, _ in pairs(H.RageTargets) do
                if not plr or not plr.Parent then
                    table.insert(toRemove, plr)
                elseif not H.IsAlive(plr) or not H.RageIsFullyLoaded(plr) then
                    H.RageWaitingRespawn[plr] = true
                    H.RageTargetReady[plr] = false
                elseif H.HasForceField(plr) then
                    H.RageWaitingRespawn[plr] = true
                    H.RageTargetReady[plr] = false
                else
                    if H.RageWaitingRespawn[plr] then
                        H.RageWaitingRespawn[plr] = false
                        H.RageTargetReady[plr] = false
                        local captured = plr
                        task.delay(H.CFG.FF_CLEAR_DELAY, function()
                            if H.RageTargets[captured]
                                and captured.Parent
                                and H.RageIsFullyLoaded(captured)
                                and H.IsAlive(captured)
                                and not H.HasForceField(captured)
                            then
                                H.RageTargetReady[captured] = true
                            end
                        end)
                    elseif H.RageTargetReady[plr] == nil then
                        H.RageTargetReady[plr] = true
                    end
                end
            end
            for _, plr in ipairs(toRemove) do
                H.RageTargets[plr] = nil
                H.RageTargetReady[plr] = nil
                H.RageWaitingRespawn[plr] = nil
            end
        end

        if H.Flags.RageAutoKill then
            local now = tick()
            local method = H.GetRageMethod()
            local isM1 = method == "Method 1"
            local rate = isM1 and H.CFG.M1_FIRE_RATE or H.CFG.M2_FIRE_RATE
            local lastRef = isM1 and H.RageM1LastFire or H.RageM2LastFire

            if now - lastRef >= rate then
                local shot = false
                for plr, _ in pairs(H.RageTargets) do
                    if plr and plr.Parent and plr ~= LocalPlayer then
                        if H.RageCanShoot(plr) then
                            local fn = isM1 and H.RageShootAtMethod1 or H.RageShootAtMethod2
                            if fn(plr) then shot = true end
                        end
                    end
                end
                if shot then
                    if isM1 then
                        H.RageM1LastFire = now
                    else
                        H.RageM2LastFire = now
                    end
                end
            end
        end

        for plr, _ in pairs(H.RageTargets) do
            if plr and plr.Parent and plr ~= LocalPlayer then
                if H.IsKO(plr) then
                    H.RageTryTP(plr)
                    H.RageTryStomp(plr)
                end
            end
        end

        H.RageStompAllTick()

        if H.Flags.RageSentry and H.sentryTarget then
            if not H.IsAlive(H.sentryTarget) or H.IsKO(H.sentryTarget) or tick() > H.sentryLockUntil then
                H.sentryRedirectPart = nil
                if H.sentryVoided then H.SentryReturnHome() else H.sentryTarget = nil end
                H.SentryFinish()
            else
                if not H.HasForceField(H.sentryTarget) then
                    local myHRP = H.GetHRP()
                    if myHRP and H.sentryVoided then
                        if not H.sentryCenter then
                            H.sentryCenter = myHRP.Position
                            H.sentryNextChange = tick() + (0.25 + math.random() * 0.6)
                        end
                        if tick() >= H.sentryNextChange then
                            H.sentryAngle = H.sentryAngle + (math.random() * 2 - 1) * 2.2
                            H.sentryNextChange = tick() + (0.15 + math.random() * 0.5)
                        end
                        local speed = 4 + math.random() * 5
                        H.sentryAngle = H.sentryAngle + speed * (1 / 60)
                        local tHRP = H.RageGetHRP(H.sentryTarget)
                        local x, y, z
                        local far = tHRP and Vector3.new(tHRP.Position.X - H.sentryCenter.X, 0, tHRP.Position.Z - H.sentryCenter.Z).Magnitude > 120
                        if far then
                            -- shooter is out of range: orbit just above the target instead of staying at the original spot
                            x = tHRP.Position.X + math.cos(H.sentryAngle) * 12
                            z = tHRP.Position.Z + math.sin(H.sentryAngle) * 12
                            y = tHRP.Position.Y + 40 + math.sin(H.sentryAngle * 0.9) * 5
                        else
                            x = H.sentryCenter.X + math.cos(H.sentryAngle) * H.CFG.SENTRY_RADIUS
                            z = H.sentryCenter.Z + math.sin(H.sentryAngle) * H.CFG.SENTRY_RADIUS
                            y = H.CFG.SENTRY_Y + math.sin(H.sentryAngle * 0.9) * 30
                        end
                        pcall(function()
                            myHRP.AssemblyLinearVelocity = Vector3.zero
                            myHRP.CFrame = CFrame.new(x, y, z)
                        end)
                    end
                    if tick() - H.sentryLastFire >= H.CFG.SENTRY_FIRE_RATE then
                        H.sentryLastFire = tick()
                        local head = H.RageGetHead(H.sentryTarget)
                        if head then
                            local tool = H.EquipNextSentryGun()
                            if tool then
                                if H.MainRemote then
                                    -- real shot from the game's own code; the namecall hook redirects its pellets
                                    H.sentryRedirectPart = head
                                    if tool.Parent ~= LocalPlayer.Character then
                                        local hum = H.GetHum()
                                        if hum then pcall(function() hum:EquipTool(tool) end) end
                                    end
                                    pcall(function() tool:Activate() end)
                                else
                                    H.sentryRedirectPart = nil
                                    H.ShootWithSentry(tool, head)
                                end
                            end
                        end
                    end
                end
            end
        else
            H.sentryRedirectPart = nil
        end

        if H.Flags.AntiStomp and H.IsKnocked(LocalPlayer) then
            local now = tick()
            if now - H.AntiStompDebounce > 1.5 then
                H.AntiStompDebounce = now
                H.SafeCall(function()
                    local hum = H.GetHum()
                    if hum then hum.Health = 0 end
                end)
            end
        end
    end))

    task.spawn(function()
        H.BuildWatermark()
        while H.Watermark do
            local ok = pcall(H.UpdateWatermark)
            if not ok then break end
            task.wait(0.5)
        end
    end)

    H.BuildFOVCircle()
    H.BuildSilentFOVCircle()
    H.InstallSilentHooks()
    H.ApplyFullbright()
    H.ApplyNoFog()
    H.ApplyClockTime()
    H.ApplyAmbient()
    H.ApplyNoclip()
    H.ApplyAntiAFK()

    H.MainRemote = H.findMainRemote()

    local function hookPlayerChar(plr)
        if plr == LocalPlayer then return end
        H.AddConn(plr.CharacterAdded:Connect(function()
            H.RemoveESP(plr)
            task.wait(0.4)
            if H.Flags.ESPEnabled then pcall(H.CreateESP, plr) end
        end))
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        hookPlayerChar(plr)
    end

    H.AddConn(Players.PlayerAdded:Connect(function(plr) hookPlayerChar(plr) end))

    H.AddConn(Players.PlayerRemoving:Connect(function(plr)
        H.RemoveESP(plr)
        H.TracerObjects[plr] = nil
        H.AutoStompLast[plr] = nil
        H.RageTargets[plr] = nil
        H.RageTargetReady[plr] = nil
        H.RageWaitingRespawn[plr] = nil
        H.RageTargetOriginalCF[plr] = nil
        H.RageTPLast[plr] = nil
        H.RageLastStomp[plr] = nil
    end))

    H.AddConn(LocalPlayer.CharacterAdded:Connect(function()
        H.Target = nil
        H.SilentCachedPart = nil
        H.RageTPQueue = nil
        task.wait(0.4)
        if H.Flags.SpeedEnabled then
            H.applySpeed(true)
            H.StartSpeedLoop()
        end
        if H.Flags.FlyEnabled then H.StartFly() end
        if H.Flags.Anchor then H.ApplyAnchor() end
        if H.Flags.RapidFire then H.ScanRapidFireTools() end
        if H.Flags.HitboxEnabled then H.ApplyHitbox() end
        if H.Flags.ESPEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    if H.ESPObjects[plr] then H.RemoveESP(plr) end
                    pcall(H.CreateESP, plr)
                end
            end
        end
    end))

    if LocalPlayer.Character then
        task.spawn(function()
            task.wait(0.5)
            if H.Flags.RapidFire then H.ScanRapidFireTools() end
        end)
    end

    H.AddConn(LocalPlayer.ChildAdded:Connect(function(c)
        if c.Name == "Backpack" then
            H.AddConn(c.ChildAdded:Connect(function(t)
                if t:IsA("Tool") and H.Flags.RapidFire then H.HardenTool(t) end
            end))
        end
    end))

    task.delay(2, function()
        pcall(function()
            for flag in pairs(Arvn.Binds) do
                if not Arvn.Elements[flag] then Arvn.Binds[flag] = nil end
            end
        end)
    end)

    Arvn:Notify({ Title = "houhou", Content = "(discord.gg/feuds)", Kind = "uwu" })
end
