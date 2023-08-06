-- :.
-- tape:two
-- 
-- from the softcut study
-- k2 clear

file = _path.dust.."code/here/there-8795.wav"

feed = 1.0
preserve = 0.25
tapelen = 8

positions = {0,0}

m = metro.init()
m.time = 0.5
m.event = function()
  local p = {1, 2, 1.5, 0.25, 0.5}
  m.time = 0.1+math.random()
  softcut.position(2, math.random()*tapelen)
  softcut.rate(4, p[math.random(#p)])
end

function update_positions(i,pos)
  positions[i] = pos - 1
  redraw()
end

function init()
  softcut.buffer_clear()
  softcut.buffer_read_mono(file,0,1,-1,1,1)
  -- mono monitor
  audio.monitor_mono()
	audio.level_adc_cut(1)
	audio.level_eng_cut(1)
	-- both inputs -> 2 (record head)
  softcut.level_input_cut(1,2,1)
  softcut.level_input_cut(2,2,1)
  softcut.level_input_cut(1,4,1)
  softcut.level_input_cut(2,4,1)
  -- pL(1) -> rR() / pR(3) -> rL()
  softcut.level_cut_cut(1,4,1)
  softcut.level_cut_cut(3,2,1)

  -- sample player L
  softcut.enable(1,1)
  softcut.buffer(1,1)
  softcut.loop_start(1,1)
  softcut.loop_end(1,tapelen)
  softcut.loop(1,1)
  softcut.position(1,1)
  softcut.rate(1,1)
  softcut.pan(1,-1)
  softcut.play(1,1)
  softcut.level(1,1)
  -- sample player R
  softcut.enable(3,1)
  softcut.buffer(3,2)
  softcut.loop_start(3,1)
  softcut.loop_end(3,tapelen)
  softcut.loop(3,1)
  softcut.position(3,1)
  softcut.rate(3,1)
  softcut.pan(3,1)
  softcut.play(3,1)
  softcut.level(3,1)
 
  -- record head
  softcut.enable(2,1)
  softcut.buffer(2,1)
  softcut.rate(2,1)
  softcut.loop(2,1)
  softcut.loop_start(2,1)
  softcut.loop_end(2,tapelen)
  softcut.position(2,1)
  softcut.play(2,1)
  softcut.rec(2,1)
  softcut.rec_level(2,0.75)
  softcut.pre_level(2,0.25)
  softcut.level(2,0)
  softcut.fade_time(2,0.01)
    -- record head
  softcut.enable(4,1)
  softcut.buffer(4,2)
  softcut.rate(4,1)
  softcut.loop(4,1)
  softcut.loop_start(4,1)
  softcut.loop_end(4,tapelen)
  softcut.position(4,1)
  softcut.play(4,1)
  softcut.rec(4,1)
  softcut.rec_level(4,0.75)
  softcut.pre_level(4,0.25)
  softcut.level(4,0)
  softcut.fade_time(4,0.01)

  softcut.phase_quant(1,0.025)
  softcut.phase_quant(2,0.025)
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()

  m:start()
end

function enc(n,d)
  if n==1 then
    tapelen = util.clamp(tapelen+d/10,0.1,8)
    softcut.loop_end(1,tapelen)
    softcut.loop_end(2,tapelen)
    softcut.loop_end(3,tapelen)
    softcut.loop_end(4,tapelen)
  elseif n==2 then
    feed = util.clamp(feed+d/20,0,1)
    softcut.level_cut_cut(1,4,feed)
    softcut.level_cut_cut(3,2,feed)
  elseif n==3 then
    preserve = util.clamp(preserve+d/20,0,1)
    softcut.pre_level(2,preserve)
  end
  redraw()
end

function key(n,z)
  if n==2 and z==1 then
    softcut.buffer_clear()
  elseif n==3 and z==1 then
    softcut.buffer_read_mono(file,0,1,-1,1,1)
  end
end


function redraw()
  screen.clear()
  -- heads
  screen.move(10,20)
  screen.line_rel(positions[1]*10,0)
  screen.move(10,24)
  screen.line_rel(positions[2]*10,0)
  screen.stroke()
  -- enc
  screen.move(10,40)
  screen.text("tape: ")
  screen.move(118,40)
  screen.text_right(string.format("%.2f",tapelen))
  screen.move(10,50)
  screen.text("feed: ")
  screen.move(118,50)
  screen.text_right(string.format("%.2f",feed))
  screen.move(10,60)
  screen.text("preserve: ")
  screen.move(118,60)
  screen.text_right(string.format("%.2f",preserve))
  screen.update()
end

