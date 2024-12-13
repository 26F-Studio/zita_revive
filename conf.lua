function love.conf(t)
    t.identity='Zita'
    t.version="11.5"

    local M=t.modules
    M.window,M.system,M.event,M.thread=true,true,true,true
    M.timer,M.math,M.data=true,true,false
    M.video,M.audio,M.sound=false,false,false
    M.graphics,M.font,M.image=true,true,true
    M.mouse,M.touch,M.keyboard,M.joystick=false,false,false,false
    M.physics=false

    local W=t.window
    W.vsync=0
    W.msaa=false
    W.depth=0
    W.stencil=1
    W.display=1
    W.highdpi=false
    W.borderless=false
    W.resizable=true
    W.width,W.height=260,128
    W.minwidth,W.minheight=260,128
end
