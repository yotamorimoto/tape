-- :.
-- tape

engine.name = 'Interpret'
function i(x) engine.interpret(x) end

playrate = 1

function osc.event(path, args, from)
  if is_recording then redraw(args[1], args[2]) end
end

function init()
  screen.blend_mode(12)
  i([[
    ~tape = Buffer.alloc(Server.default, 48000*15, 2);
    ~addr = NetAddr("localhost", 10111);
    ~pass = OSCFunc({ |m| ~addr.sendMsg("/hi", m[3], m[4]) }, '/reply');
    ]])
  i([[
  ~machine = { |playrate=0.5, feed=1|
	  var trig, pos, sig, rec, rate;
	  var scale = BufRateScale.ir(~tape);
	  var frames = BufFrames.ir(~tape);
	  trig = Dust.kr(1);
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
  if n==1 then
    playrate = util.clamp(playrate+d/20,-2.0,2.0)
    i(string.format([[~tape.set(\playrate,%f)]], playrate))
  end
  -- redraw()
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


function redraw(rate, pos)
  screen.rect(pos*0.000177, 0, math.random(10,20), 64)
  screen.level(rate*4+8)
  screen.fill()
  screen.update()
end

function cleanup()
  i([[~tape.free;~machine.free;~addr=nil;~pass.free;]])
end
