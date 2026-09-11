------------------
---- KEYBINDS ----
------------------

local mainMod = "SUPER"

hl.bind("F11", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.kill())

-- floating windows
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + ALT + V", function()
    hl.dispatch(hl.dsp.window.float({ action = "set" }))
    hl.dispatch(hl.dsp.window.center())
end)
hl.bind(mainMod .. " + SHIFT + V", function()
    hl.dispatch(hl.dsp.window.float({ action = "set" }))
    hl.dispatch(hl.dsp.window.pin())
end)

-- mouse resize + move
hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)
hl.bind(
    mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)

-- workspaces
for workspace = 1, 10 do
    local key = workspace % 10

    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = workspace })
    )
    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = workspace })
    )
end

-- special workspaces
hl.bind(mainMod .. " + W", hl.dsp.workspace.toggle_special())
hl.bind(
    mainMod .. " + SHIFT + W",
    hl.dsp.window.move({ workspace = "special", follow = false })
)

local directions = {
    H = "l",
    J = "d",
    K = "u",
    L = "r",
}
for key, direction in pairs(directions) do
    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({ direction = direction })
    )
    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.swap({ direction = direction })
    )
end

hl.config({
    input = {
        touchpad = {
            disable_while_typing = false,
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-------------------
---- DECORATION ----
-------------------

hl.config({
    decoration = {
        blur = {
            brightness = 0.78,
            passes = 4,
            size = 7,
        },
        rounding = 5,
    },
    general = {
        border_size = 2,
        gaps_in = 3,
        gaps_out = 5,
    },
})

hl.curve("overshoot", {
    type = "bezier",
    points = {
        { 0.21, 0.82 },
        { 0.39, 1.3 },
    },
})

hl.curve("overshoot-light", {
    type = "bezier",
    points = {
        { 0.21, 0.82 },
        { 0.39, 1.11 },
    },
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4,
    bezier = "overshoot",
    style = "popin 80%",
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 6,
    bezier = "overshoot-light",
})

hl.animation({
    leaf = "specialWorkspace",
    enabled = true,
    speed = 4,
    bezier = "default",
    style = "slidevert",
})

-----------------
---- GENERAL ----
-----------------

hl.config({
    general = {
        snap = {
            enabled = true,
        },
    },
    misc = {
        force_default_wallpaper = 0,
    },
})
