--[[
=====================================================================
 PATCH: Dropdown / MultiDropdown -> Popup "Rarities / Pick any"
 Gồm 3 phần. Làm theo thứ tự:

 PHẦN 1: Dán NGUYÊN khối bên dưới vào ngay TRƯỚC dòng:
         function WindowObj:CreateTab(tabConfig)
 PHẦN 2: XÓA toàn bộ hàm  function BoxObj:AddDropdown(...) ... end  cũ
         rồi dán hàm mới ở PHẦN 2.
 PHẦN 3: XÓA toàn bộ hàm  function BoxObj:AddMultiDropdown(...) ... end  cũ
         rồi dán hàm mới ở PHẦN 3.
=====================================================================
]]


-- =====================================================================
-- PHẦN 1: PICKER MODAL (dán trước "function WindowObj:CreateTab")
-- =====================================================================

local function PickerTitle(s)
    s = tostring(s or ""):lower()
    return (s:gsub("(%a)([%w']*)", function(a, b) return a:upper() .. b end))
end

local PickerOverlay = Instance.new("TextButton", MainWindow)
PickerOverlay.Name = "PickerOverlay"
PickerOverlay.Size = UDim2.new(1, 0, 1, 0)
PickerOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
PickerOverlay.BackgroundTransparency = 0.5
PickerOverlay.BorderSizePixel = 0
PickerOverlay.Text = ""
PickerOverlay.AutoButtonColor = false
PickerOverlay.Visible = false
PickerOverlay.ZIndex = 150
Instance.new("UICorner", PickerOverlay).CornerRadius = UDim.new(0, 16)

local PickerPanel = Instance.new("Frame", PickerOverlay)
PickerPanel.Name = "PickerPanel"
PickerPanel.AnchorPoint = Vector2.new(1, 0.5)
PickerPanel.Position = UDim2.new(1, -14, 0.5, 0)
PickerPanel.Size = UDim2.new(0, 350, 1, -28)
PickerPanel.BackgroundColor3 = Theme.Box
PickerPanel.BorderSizePixel = 0
PickerPanel.Active = true -- chặn click xuyên xuống overlay
Instance.new("UICorner", PickerPanel).CornerRadius = UDim.new(0, 16)
local pkStroke = Instance.new("UIStroke", PickerPanel)
pkStroke.Color = Theme.BorderLight
pkStroke.Thickness = 1.2
RegisterElement("Boxes", PickerPanel)
RegisterElement("Borders", pkStroke)

local pkScale = Instance.new("UIScale", PickerPanel)
pkScale.Scale = 1

local pkTitle = Instance.new("TextLabel", PickerPanel)
pkTitle.Size = UDim2.new(1, -90, 0, 20)
pkTitle.Position = UDim2.new(0, 18, 0, 16)
pkTitle.BackgroundTransparency = 1
pkTitle.Font = Enum.Font.GothamBold
pkTitle.TextSize = 14
pkTitle.TextColor3 = Theme.TextTitle
pkTitle.TextXAlignment = Enum.TextXAlignment.Left
pkTitle.TextTruncate = Enum.TextTruncate.AtEnd
pkTitle.Text = "Select"

local pkSub = Instance.new("TextLabel", PickerPanel)
pkSub.Size = UDim2.new(1, -90, 0, 14)
pkSub.Position = UDim2.new(0, 18, 0, 36)
pkSub.BackgroundTransparency = 1
pkSub.Font = Enum.Font.GothamMedium
pkSub.TextSize = 10
pkSub.TextColor3 = Theme.TextDim
pkSub.TextXAlignment = Enum.TextXAlignment.Left
pkSub.Text = "Pick any"

local pkClose = Instance.new("TextButton", PickerPanel)
pkClose.Size = UDim2.new(0, 36, 0, 36)
pkClose.Position = UDim2.new(1, -52, 0, 14)
pkClose.BackgroundColor3 = Theme.SubBox
pkClose.AutoButtonColor = false
pkClose.Text = "X"
pkClose.Font = Enum.Font.GothamBold
pkClose.TextSize = 13
pkClose.TextColor3 = Theme.TextTitle
Instance.new("UICorner", pkClose).CornerRadius = UDim.new(0, 10)
local pkCloseStroke = Instance.new("UIStroke", pkClose)
pkCloseStroke.Color = Theme.BorderLight
RegisterElement("SubBoxes", pkClose)

local pkFilterBox = Instance.new("Frame", PickerPanel)
pkFilterBox.Size = UDim2.new(1, -32, 0, 36)
pkFilterBox.Position = UDim2.new(0, 16, 0, 64)
pkFilterBox.BackgroundColor3 = Theme.SubBox
pkFilterBox.BorderSizePixel = 0
Instance.new("UICorner", pkFilterBox).CornerRadius = UDim.new(0, 10)
local pkFilterStroke = Instance.new("UIStroke", pkFilterBox)
pkFilterStroke.Color = Theme.Border
RegisterElement("SubBoxes", pkFilterBox)
RegisterElement("Borders", pkFilterStroke)

local pkFilterIcon = Instance.new("ImageLabel", pkFilterBox)
pkFilterIcon.Size = UDim2.new(0, 14, 0, 14)
pkFilterIcon.Position = UDim2.new(0, 12, 0.5, -7)
pkFilterIcon.BackgroundTransparency = 1
pkFilterIcon.Image = StarHubUI.Icons.Search
pkFilterIcon.ImageColor3 = Theme.TextDim

local pkFilterInput = Instance.new("TextBox", pkFilterBox)
pkFilterInput.Size = UDim2.new(1, -40, 1, 0)
pkFilterInput.Position = UDim2.new(0, 34, 0, 0)
pkFilterInput.BackgroundTransparency = 1
pkFilterInput.Font = Enum.Font.GothamMedium
pkFilterInput.TextSize = 11
pkFilterInput.TextColor3 = Theme.TextTitle
pkFilterInput.PlaceholderColor3 = Theme.TextDim
pkFilterInput.PlaceholderText = "Filter"
pkFilterInput.TextXAlignment = Enum.TextXAlignment.Left
pkFilterInput.ClearTextOnFocus = false
pkFilterInput.Text = ""

local pkScroll = Instance.new("ScrollingFrame", PickerPanel)
pkScroll.Position = UDim2.new(0, 16, 0, 112)
pkScroll.Size = UDim2.new(1, -32, 1, -176)
pkScroll.BackgroundTransparency = 1
pkScroll.BorderSizePixel = 0
pkScroll.ScrollBarThickness = 3
pkScroll.ScrollBarImageColor3 = Theme.Accent
pkScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
pkScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local pkGrid = Instance.new("UIGridLayout", pkScroll)
pkGrid.CellSize = UDim2.new(0.5, -4, 0, 38)
pkGrid.CellPadding = UDim2.new(0, 8, 0, 8)
pkGrid.SortOrder = Enum.SortOrder.LayoutOrder

local pkBottom = Instance.new("Frame", PickerPanel)
pkBottom.Size = UDim2.new(1, -32, 0, 40)
pkBottom.Position = UDim2.new(0, 16, 1, -56)
pkBottom.BackgroundTransparency = 1
local pkBottomLayout = Instance.new("UIListLayout", pkBottom)
pkBottomLayout.FillDirection = Enum.FillDirection.Horizontal
pkBottomLayout.Padding = UDim.new(0, 8)
pkBottomLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function MakePickerBtn(text, order, primary)
    local b = Instance.new("TextButton", pkBottom)
    b.Size = UDim2.new(1 / 3, -6, 1, 0)
    b.LayoutOrder = order
    b.AutoButtonColor = false
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
    if primary then
        b.BackgroundColor3 = Color3.fromRGB(240, 240, 244)
        b.TextColor3 = Color3.fromRGB(18, 18, 22)
    else
        b.BackgroundColor3 = Theme.SubBox
        b.TextColor3 = Theme.TextTitle
        local st = Instance.new("UIStroke", b)
        st.Color = Theme.BorderLight
        RegisterElement("SubBoxes", b)
    end
    return b
end

local pkDefaultBtn = MakePickerBtn("Mặc Định", 1, false)
local pkClearBtn   = MakePickerBtn("Clear", 2, false)
local pkAllBtn     = MakePickerBtn("Select all", 3, true)

local pickerCfg = nil
local pickerSet = {}
local pickerChips = {}

local function PickerList()
    local list = {}
    if pickerCfg then
        for _, o in ipairs(pickerCfg.Options) do
            if pickerSet[o] then table.insert(list, o) end
        end
    end
    return list
end

local function PickerRefresh()
    for opt, ref in pairs(pickerChips) do
        local on = pickerSet[opt] == true
        ref.Check.Visible = on
        ref.Stroke.Color = on and Theme.AccentLight or Theme.BorderLight
        ref.Stroke.Transparency = on and 0.1 or 0.35
        ref.Btn.BackgroundColor3 = on and Theme.SubBox or Theme.Box
    end
end

local function PickerCommit()
    if pickerCfg and pickerCfg.OnChange then
        pcall(pickerCfg.OnChange, PickerList())
    end
end

local function ClosePicker()
    PickerOverlay.Visible = false
    pickerCfg = nil
end

local function PickerSetAll()
    pickerSet = {}
    for _, o in ipairs(pickerCfg.Options) do pickerSet[o] = true end
end

pkClose.MouseButton1Click:Connect(function() PlaySound("Click") ClosePicker() end)
PickerOverlay.MouseButton1Click:Connect(function() ClosePicker() end)

pkAllBtn.MouseButton1Click:Connect(function()
    if not pickerCfg then return end
    PlaySound("Click")
    PickerSetAll()
    PickerRefresh()
    PickerCommit()
end)

pkClearBtn.MouseButton1Click:Connect(function()
    if not pickerCfg then return end
    PlaySound("Click")
    pickerSet = {}
    PickerRefresh()
    PickerCommit()
end)

pkDefaultBtn.MouseButton1Click:Connect(function()
    if not pickerCfg then return end
    PlaySound("Click")
    pickerSet = {}
    local def = pickerCfg.Default or pickerCfg.Options
    for _, o in ipairs(def) do pickerSet[o] = true end
    PickerRefresh()
    PickerCommit()
end)

pkFilterInput:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(pkFilterInput.Text)
    for opt, ref in pairs(pickerChips) do
        ref.Btn.Visible = (q == "") or (string.find(string.lower(tostring(opt)), q, 1, true) ~= nil)
    end
end)

-- cfg: Title, Subtitle, Options, Multi, Selected (array), Default (array), OnChange(list)
function WindowObj:OpenPicker(cfg)
    ColorPickerModal.Visible = false
    pickerCfg = cfg

    pkTitle.Text = cfg.Title or "Select"
    pkSub.Text = cfg.Subtitle or (cfg.Multi and "Pick any" or "Pick one")
    pkFilterInput.Text = ""

    pickerSet = {}
    for _, v in ipairs(cfg.Selected or {}) do pickerSet[v] = true end

    for _, ref in pairs(pickerChips) do ref.Btn:Destroy() end
    pickerChips = {}

    for index, opt in ipairs(cfg.Options) do
        local btn = Instance.new("TextButton", pkScroll)
        btn.Name = "Opt_" .. index
        btn.LayoutOrder = index
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.BackgroundColor3 = Theme.Box
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        local st = Instance.new("UIStroke", btn)
        st.Thickness = 1.2

        local lbl = Instance.new("TextLabel", btn)
        lbl.Size = UDim2.new(1, -36, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11.5
        lbl.TextColor3 = Theme.TextTitle
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Text = tostring(opt)

        local chk = Instance.new("TextLabel", btn)
        chk.Size = UDim2.new(0, 18, 1, 0)
        chk.Position = UDim2.new(1, -28, 0, 0)
        chk.BackgroundTransparency = 1
        chk.Font = Enum.Font.GothamBold
        chk.TextSize = 13
        chk.TextColor3 = Theme.TextTitle
        chk.Text = "✓"

        pickerChips[opt] = { Btn = btn, Stroke = st, Check = chk }

        btn.MouseEnter:Connect(function()
            if pickerSet[opt] ~= true then
                Tween(st, 0.15, { Transparency = 0.05 })
            end
        end)
        btn.MouseLeave:Connect(function()
            if pickerSet[opt] ~= true then
                Tween(st, 0.15, { Transparency = 0.35 })
            end
        end)

        btn.MouseButton1Click:Connect(function()
            PlaySound("Click")
            MicroBounce(btn)
            if cfg.Multi then
                pickerSet[opt] = not pickerSet[opt] or nil
                PickerRefresh()
                PickerCommit()
            else
                pickerSet = { [opt] = true }
                PickerRefresh()
                PickerCommit()
                task.delay(0.12, function()
                    if pickerCfg == cfg then ClosePicker() end
                end)
            end
        end)
    end

    -- Single-select: ẩn hàng nút dưới, kéo dài danh sách
    pkBottom.Visible = cfg.Multi == true
    pkScroll.Size = cfg.Multi and UDim2.new(1, -32, 1, -176) or UDim2.new(1, -32, 1, -128)

    PickerRefresh()
    PickerOverlay.Visible = true
    pkScale.Scale = 0.96
    Tween(pkScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
end


-- =====================================================================
-- PHẦN 2: AddDropdown MỚI (thay thế hàm cũ trong CreateGroupBox)
-- =====================================================================

function BoxObj:AddDropdown(title, options, defaultVal, callback)
    callback = callback or function() end
    options = options or {}
    local selected = defaultVal or options[1] or ""

    local row = Instance.new("Frame", Container)
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundTransparency = 1

    local tLbl = Instance.new("TextLabel", row)
    tLbl.Size = UDim2.new(1, 0, 0, 14)
    tLbl.BackgroundTransparency = 1
    tLbl.Font = Enum.Font.GothamMedium
    tLbl.TextSize = 10
    tLbl.TextColor3 = Theme.TextDim
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Text = string.upper(title)

    local Box = Instance.new("TextButton", row)
    Box.Size = UDim2.new(1, 0, 0, 28)
    Box.Position = UDim2.new(0, 0, 0, 18)
    Box.BackgroundColor3 = Theme.SubBox
    Box.Text = ""
    Box.AutoButtonColor = false
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local bSt = Instance.new("UIStroke", Box)
    bSt.Color = Theme.Border
    RegisterElement("SubBoxes", Box)
    RegisterElement("Borders", bSt)

    local vLbl = Instance.new("TextLabel", Box)
    vLbl.Size = UDim2.new(1, -34, 1, 0)
    vLbl.Position = UDim2.new(0, 10, 0, 0)
    vLbl.BackgroundTransparency = 1
    vLbl.Font = Enum.Font.GothamMedium
    vLbl.TextSize = 10.5
    vLbl.TextColor3 = Theme.TextTitle
    vLbl.TextXAlignment = Enum.TextXAlignment.Left
    vLbl.TextTruncate = Enum.TextTruncate.AtEnd
    vLbl.Text = tostring(selected)

    local chev = Instance.new("ImageLabel", Box)
    chev.Size = UDim2.new(0, 12, 0, 12)
    chev.Position = UDim2.new(1, -20, 0.5, -6)
    chev.BackgroundTransparency = 1
    chev.Image = StarHubUI.Icons.ChevronDown
    chev.ImageColor3 = Theme.TextDim

    Box.MouseButton1Click:Connect(function()
        PlaySound("Dropdown")
        WindowObj:OpenPicker({
            Title = PickerTitle(title),
            Subtitle = "Pick one",
            Options = options,
            Multi = false,
            Selected = { selected },
            OnChange = function(list)
                local v = list[1]
                if v == nil then return end
                selected = v
                vLbl.Text = tostring(v)
                pcall(callback, v)
            end
        })
    end)

    return {
        Get = function() return selected end,
        Set = function(v)
            selected = v
            vLbl.Text = tostring(v)
        end
    }
end


-- =====================================================================
-- PHẦN 3: AddMultiDropdown MỚI (thay thế hàm cũ)
-- =====================================================================

function BoxObj:AddMultiDropdown(title, options, defaultVal, callback)
    callback = callback or function() end
    options = options or {}

    local selected = {}
    local allSelected = (defaultVal == nil or defaultVal == "None (Select All)")
    local defaultList = nil
    if type(defaultVal) == "table" then
        defaultList = defaultVal
        for _, value in ipairs(defaultVal) do selected[value] = true end
    end

    local row = Instance.new("Frame", Container)
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundTransparency = 1

    local tLbl = Instance.new("TextLabel", row)
    tLbl.Size = UDim2.new(1, 0, 0, 14)
    tLbl.BackgroundTransparency = 1
    tLbl.Font = Enum.Font.GothamMedium
    tLbl.TextSize = 10
    tLbl.TextColor3 = Theme.TextDim
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Text = string.upper(title)

    local box = Instance.new("TextButton", row)
    box.Size = UDim2.new(1, 0, 0, 28)
    box.Position = UDim2.new(0, 0, 0, 18)
    box.BackgroundColor3 = Theme.SubBox
    box.Text = ""
    box.AutoButtonColor = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color = Theme.Border
    RegisterElement("SubBoxes", box)
    RegisterElement("Borders", boxStroke)

    local valueLabel = Instance.new("TextLabel", box)
    valueLabel.Size = UDim2.new(1, -34, 1, 0)
    valueLabel.Position = UDim2.new(0, 10, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextSize = 10.5
    valueLabel.TextColor3 = Theme.TextTitle
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local chevron = Instance.new("ImageLabel", box)
    chevron.Size = UDim2.new(0, 12, 0, 12)
    chevron.Position = UDim2.new(1, -20, 0.5, -6)
    chevron.BackgroundTransparency = 1
    chevron.Image = StarHubUI.Icons.ChevronDown
    chevron.ImageColor3 = Theme.TextDim

    local function GetValues()
        local values = {}
        for _, option in ipairs(options) do
            if allSelected or selected[option] then
                table.insert(values, option)
            end
        end
        return values
    end

    local function UpdateSummary()
        local values = GetValues()
        local count = #values
        if allSelected or count == #options then
            valueLabel.Text = "None (Select All)"
        elseif count == 0 then
            valueLabel.Text = "Không chọn mục nào"
        elseif count <= 2 then
            valueLabel.Text = table.concat(values, ", ")
        else
            valueLabel.Text = tostring(count) .. " mục đã chọn"
        end
    end

    local function Apply(list)
        selected = {}
        for _, value in ipairs(list) do selected[value] = true end
        allSelected = (#list == #options)
        UpdateSummary()
        pcall(callback, GetValues())
    end

    box.MouseButton1Click:Connect(function()
        PlaySound("Dropdown")
        WindowObj:OpenPicker({
            Title = PickerTitle(title),
            Subtitle = "Pick any",
            Options = options,
            Multi = true,
            Selected = GetValues(),
            Default = defaultList or options,
            OnChange = Apply
        })
    end)

    UpdateSummary()

    local function SelectAll()
        allSelected = true
        selected = {}
        UpdateSummary()
        pcall(callback, GetValues())
    end

    local function ClearAll()
        allSelected = false
        selected = {}
        UpdateSummary()
        pcall(callback, GetValues())
    end

    local function Set(values)
        allSelected = values == nil or values == "None (Select All)"
        selected = {}
        if type(values) == "table" then
            for _, value in ipairs(values) do selected[value] = true end
        end
        UpdateSummary()
        pcall(callback, GetValues())
    end

    return {
        Get = GetValues,
        Set = Set,
        SelectAll = SelectAll,
        ClearAll = ClearAll,
        IsAllSelected = function() return allSelected end
    }
end
