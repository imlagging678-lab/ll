task.spawn(function()
    local RunService = game:GetService("RunService")
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hum = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Animasyonlar
    local animFaint = Instance.new("Animation")
    animFaint.AnimationId = "rbxassetid://182724289"
    local loadFaint = hum:LoadAnimation(animFaint)

    local animRise = Instance.new("Animation")
    animRise.AnimationId = "rbxassetid://93648331"
    local loadRise = hum:LoadAnimation(animRise)

    -- Fiziksel Değişkenler
    local bg, bpos, bv, forceLoop

    -- --- SİSTEMİ BAŞLAT ---
    loadFaint:Play()
    hum.PlatformStand = true
    hum.WalkSpeed = 0
    hum.JumpPower = 0

    -- 1. ADIM: Kayma Engelleme (Walk Lock)
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    -- 2. ADIM: Yere Çivileme
    bpos = Instance.new("BodyPosition")
    bpos.MaxForce = Vector3.new(0, math.huge, 0)
    bpos.P = 20000
    bpos.Position = hrp.Position - Vector3.new(0, 1.4, 0)
    bpos.Parent = hrp

    -- 3. ADIM: 90 Derece Yatış
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1, 1, 1) * 10^10
    bg.P = 30000
    bg.D = 2000
    bg.CFrame = hrp.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
    bg.Parent = hrp

    -- 4. ADIM: Havada Kalma Engelleyici (Loop)
    forceLoop = RunService.RenderStepped:Connect(function()
        if hum then hum.HipHeight = -1.2 end
    end)

    -- --- 10 SANİYE BEKLEME VE OTOMATİK KALKIŞ ---
    task.wait(10)

    -- Yatış Animasyonunu Durdur ve Loop'u Kapat
    loadFaint:Stop()
    if forceLoop then forceLoop:Disconnect() end

    -- Gyro'yu Eski Yerine Döndür (Doğrulma)
    if bg then
        bg.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(hrp.Orientation.Y), 0)
    end

    -- Seri Kalkış Animasyonu
    loadRise:Play()
    loadRise:AdjustSpeed(1.5) -- Hızlı kalkış
    if loadRise.Length > 2.5 then
        loadRise.TimePosition = loadRise.Length - 2.5
    end

    -- Fiziği Normalleştir (Yere takılmaması için)
    hum.HipHeight = 0
    if bpos then bpos:Destroy() end

    -- Animasyon Bitene Kadar Bekle
    loadRise.Stopped:Wait()

    -- --- TEMİZLİK ---
    if bg then bg:Destroy() end
    if bv then bv:Destroy() end
    hum.PlatformStand = false
    hum.WalkSpeed = 16
    hum.JumpPower = 50
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    hrp.Velocity = Vector3.new(0, 5, 0)

    print("Süreç tamamlandı, karakter ayağa kalktı.")
end)
task.spawn(function()
    task.wait(10) -- Üsttekiyle aynı süreyi bekletiyoruz
    print("İkinci task şimdi başladı (Kalkış vb.)")
end)
task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    -- AYARLAR
    local minHeight = 1   --
    local maxHeight = 2    -- 
    local speed = 2        -- 
    local active = true    -- 

    local function smoothFloat()
        local t = 0
        local connection 
        
        connection = RunService.Heartbeat:Connect(function(deltaTime)
            -- protects the stacking
            if not active or not humanoid or not humanoid.Parent then 
                if connection then connection:Disconnect() end
                return 
            end
            
            t = t + deltaTime * speed
            
            -- 
            local sineWave = (math.sin(t) + 1) / 2 
            local finalHeight = minHeight + (sineWave * (maxHeight - minHeight))
            
            humanoid.HipHeight = finalHeight
        end)
    end

    -- float start
    smoothFloat()
end)
task.spawn(function()
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    local HRP = character:WaitForChild("HumanoidRootPart")
    local animateScript = character:FindFirstChild("Animate") 

    local originalHipHeight = humanoid.HipHeight
    local currentForwardTilt = 0
    local currentSideTilt = 0
    -- LERP speed
    local lerpSpeed = 0.1 

    local function newAnim(id)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. id
        return anim
    end

    local dTracks = {
        idle = animator:LoadAnimation(newAnim(313762630)), 
        right2 = animator:LoadAnimation(newAnim(142495255)),
        left2 = animator:LoadAnimation(newAnim(142495255)),
        idle1 = animator:LoadAnimation(newAnim(97171309)),
        backMain = animator:LoadAnimation(newAnim(214744412))
    }
    
    for _, track in pairs(dTracks) do 
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = true
    end

    local function toggleRobloxAnims(state)
        if animateScript then animateScript.Disabled = not state end
        if state == false then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                local isOurs = false
                for _, our in pairs(dTracks) do if track.Animation.AnimationId == our.Animation.AnimationId then isOurs = true end end
                if not isOurs then track:Stop(0) end
            end
        end
    end

    local currentPlaying = nil
    local function playOnce(target, pos)
        if currentPlaying == target then return end
        for name, track in pairs(dTracks) do if name ~= "idle1" then track:Stop(0.1) end end
        currentPlaying = target
        if target then
            target:Play(0.1)
            target.TimePosition = pos or 0.4
            target:AdjustSpeed(0)
        end
    end

    local bg = nil
    local activeState = false

    RunService.RenderStepped:Connect(function()
        if not character or not character.Parent or humanoid.Health <= 0 then
            if bg then bg:Destroy(); bg = nil end
            return
        end

        local isW = UserInputService:IsKeyDown(Enum.KeyCode.W)
        local isS = UserInputService:IsKeyDown(Enum.KeyCode.S)
        local isA = UserInputService:IsKeyDown(Enum.KeyCode.A)
        local isD = UserInputService:IsKeyDown(Enum.KeyCode.D)

        if isW or isS or isA or isD then
            if not activeState then
                activeState = true
                toggleRobloxAnims(false) 
                humanoid.HipHeight = originalHipHeight - 0.6
                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
                bg.P = 50000 -- Net duruş gücü
                bg.D = 1200  -- Sarsıntı önleyici
                bg.Parent = HRP
            end

            -- Anim
            if isS then playOnce(dTracks.backMain, 0.4) 
            elseif isD and not isA then playOnce(dTracks.right2, 0.4)
            elseif isA and not isD then playOnce(dTracks.left2, 0.4)
            else playOnce(nil) end

            -- target view
            local targetForward = (isW and 40) or (isS and -40) or 0
            local targetSide = (isD and not isA and -35) or (isA and not isD and 35) or 0
            
            -- lerping(smoothens)
            currentForwardTilt = currentForwardTilt + (targetForward - currentForwardTilt) * lerpSpeed
            currentSideTilt = currentSideTilt + (targetSide - currentSideTilt) * lerpSpeed
        else
            if activeState then
                
                currentForwardTilt = currentForwardTilt + (0 - currentForwardTilt) * lerpSpeed
                currentSideTilt = currentSideTilt + (0 - currentSideTilt) * lerpSpeed

                if math.abs(currentForwardTilt) < 0.5 and math.abs(currentSideTilt) < 0.5 then
                    activeState = false
                    currentPlaying = nil
                    if bg then bg:Destroy(); bg = nil end
                    for _, v in pairs(dTracks) do v:Stop(0.1) end
                    humanoid.HipHeight = originalHipHeight
                    toggleRobloxAnims(true) 
                    dTracks.idle1:Play(0); dTracks.idle1.TimePosition = 0.3; dTracks.idle1:AdjustSpeed(0)
                end
            end
        end

        if bg then
            local look = HRP.CFrame.LookVector
            local flatLook = Vector3.new(look.X, 0, look.Z).Unit
            bg.CFrame = CFrame.lookAt(Vector3.new(), flatLook) 
                        * CFrame.Angles(math.rad(-currentForwardTilt), 0, math.rad(currentSideTilt))
        end
    end)
end)
-- ==========================================
-- dash mekanizmasi
-- ==========================================
-- ==========================================
-- (NO COOLDOWN VERSION)
-- ==========================================
task.spawn(function()
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    local HRP = character:WaitForChild("HumanoidRootPart")

    -- Cooldown
    local dashCooldown = 0 

    local function newAnim(id)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. id
        return anim
    end

    local dTracks = {
        frontDash = animator:LoadAnimation(newAnim(97171309)),
        right1 = animator:LoadAnimation(newAnim(136801964)),
        right2 = animator:LoadAnimation(newAnim(142495255)),
        left1 = animator:LoadAnimation(newAnim(136801964)),
        left2 = animator:LoadAnimation(newAnim(142495255)),
        backMain = animator:LoadAnimation(newAnim(214744412)),
        back2 = animator:LoadAnimation(newAnim(106772613)),
        back3 = animator:LoadAnimation(newAnim(42070810))
    }
    for _, track in pairs(dTracks) do track.Priority = Enum.AnimationPriority.Action4 end

    local function stopDashTracks()
        for _, v in pairs(dTracks) do v:Stop(0.1) end
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or input.KeyCode ~= Enum.KeyCode.Q then return end
        
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude == 0 then moveDirection = HRP.CFrame.LookVector end
        local relativeDir = HRP.CFrame:VectorToObjectSpace(moveDirection)
        
        -- COOLDOWN KONTROL
        
        local selectedDirection = ""
        local currentPower = 65

        if relativeDir.Z < -0.5 then selectedDirection = "Front"; currentPower = 75
        elseif relativeDir.Z > 0.5 then selectedDirection = "Back"
        elseif relativeDir.X > 0.5 then selectedDirection = "Right"
        elseif relativeDir.X < -0.5 then selectedDirection = "Left"
        else selectedDirection = "Front"; currentPower = 75 end

        stopDashTracks()

        -- ANİM
        if selectedDirection == "Front" then
            dTracks.frontDash:Play(0.1); dTracks.frontDash.TimePosition = 0.2
            task.delay(0.05, function() dTracks.frontDash:AdjustSpeed(0) end)
        elseif selectedDirection == "Back" then
            dTracks.backMain:Play(0.1); dTracks.back2:Play(0.1); dTracks.back3:Play(0.1)
        elseif selectedDirection == "Right" then
            dTracks.right1:Play(0.1); dTracks.right1.TimePosition = 1.1; dTracks.right1:AdjustSpeed(0); dTracks.right2:Play(0.1)
        elseif selectedDirection == "Left" then
            dTracks.left1:Play(0.1); dTracks.left1.TimePosition = 2.0; dTracks.left1:AdjustSpeed(0); dTracks.left2:Play(0.1)
        end

        --LinearVelocity
        local att = Instance.new("Attachment", HRP)
        local lv = Instance.new("LinearVelocity")
        lv.MaxForce, lv.VelocityConstraintMode = 9999999, Enum.VelocityConstraintMode.Vector
        lv.VectorVelocity, lv.Attachment0, lv.Parent = moveDirection * currentPower, att, HRP

        local bg = Instance.new("BodyGyro", HRP)
        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bg.D, bg.P = 300, 12000
        
        local dashActive = true
        task.spawn(function()
            while dashActive do
                if bg and bg.Parent then
                    local tilt = (selectedDirection == "Front" and -45) or (selectedDirection == "Back" and 45) or 0
                    bg.CFrame = CFrame.new(HRP.Position, HRP.Position + moveDirection * 5) * CFrame.Angles(math.rad(tilt), 0, 0)
                end
                task.wait()
            end
        end)

        task.wait(0.22) -- Dash 
        dashActive = false
        lv:Destroy(); att:Destroy(); bg:Destroy()
        stopDashTracks()
    end)
end)
task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    
    local player = Players.LocalPlayer
    local speaker = player -- 'speaker' 
    local character = speaker.Character or speaker.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    -- setting
    local speed = 1 -- speed (ineedthis=)
    local tpwalkStack = 0 -- stack
    local tpwalking = nil

    -- to prewent 3rd party stacks
    if tpwalking then tpwalking:Disconnect() end

    tpwalking = RunService.Heartbeat:Connect(function(delta)
        -- char cotnrol
        if not (character and humanoid and humanoid.Parent) then
            tpwalking:Disconnect()
            return
        end

task.wait(10)

        -- what u lookingfor twin🙏
        if humanoid.MoveDirection.Magnitude > 0 then
            -- 1.5 speed boost
            character:TranslateBy(humanoid.MoveDirection * (speed + tpwalkStack) * delta * 10)
        end
    end)
end)
