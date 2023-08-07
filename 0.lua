-- :.
-- tape:zero
-- 
-- k2 clear
-- k3 rec
-- e2 rate

engine.name = 'Interpret'
function i(x) engine.interpret(x) end

playrate = 1
trigrate = 1
rate = 0
pos = 0

function osc.event(path, args, from)
  if is_recording then 
    rate = args[1]
    pos = args[2]
    redraw()
  end
end

function init()
  screen.blend_mode(12)
  i([[
    ~tape = Buffer.alloc(s, 48000*15, 2);
    ~addr = NetAddr("localhost", 10111);
    ~pass = OSCFunc({ |m| ~addr.sendMsg("/hi", m[3], m[4]) }, '/reply');
    ]])
  i([[
  ~machine = { |playrate=0.5, trigrate=1, feed=1|
	  var trig, pos, sig, rec, rate;
	  var scale = BufRateScale.ir(~tape);
	  var frames = BufFrames.ir(~tape);
	  trig = Dust.kr(trigrate);
	  rate = TChoose.kr(trig, [-2, 2, 1, -1, 1, 0.5]);
	  pos = TRand.kr(0, frames, trig);
	  sig = PlayBuf.ar(2, ~tape, scale*playrate, loop: 1) + (feed*SoundIn.ar([0,1]));
	  rec = Phasor.ar(trig, rate*scale, 0, frames, pos);
	  SendReply.kr(trig, '/reply', [rate, pos]);
	  BufWr.ar(sig, ~tape, rec);
	  sig
  }.play;
  ]])
end

function enc(n,d)
  if n==2 then
    playrate = util.clamp(playrate+d*0.5,-2.0,2.0)
    i(string.format([[~machine.set(\playrate,%f)]], playrate))
  elseif n==3 then
    trigrate = util.clamp(trigrate+d,1,20)
    i(string.format([[~machine.set(\trigrate,%f)]], trigrate))
  end
  screen.clear()
  redraw()
end

is_recording = true
function key(n,z)
  if n==2 and z==1 then
    i([[~tape.zero]])
    screen.clear()
    screen.update()
  elseif n==3 and z==1 then
    is_recording = not is_recording
    if is_recording then i([[~machine.set(\feed,1)]])
      else i([[~machine.set(\feed,0)]])
    end
    redraw()
  end
end

function redraw()
  screen.rect(pos*0.000177, 16, 8, 4)
  screen.level(rate*4+10)
  screen.fill()
  -- playrate
  screen.level(15)
  screen.move(0,30)
  screen.text('playrate: ')
  screen.move(118,30)
  screen.text_right(string.format("%.2f",playrate))
  screen.update()
  -- trigrate
  screen.level(15)
  screen.move(0,40)
  screen.text('trigrate: ')
  screen.move(118,40)
  screen.text_right(string.format("%.2f",trigrate))
  screen.update()
end

function cleanup()
  i([[~tape.free;~machine.free;~addr=nil;~pass.free;]])
end