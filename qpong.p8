pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- math.p8
-- This code is part of Qiskit.
--
-- Copyright IBM 2020

-- Custom math table for compatibility with the Pico8

math = {}
math.pi = 3.14159
math.max = max
math.sqrt = sqrt
math.floor = flr
function math.random()
  return rnd(1)
end
function math.cos(theta)
  return cos(theta/(2*math.pi))
end
function math.sin(theta)
  return -sin(theta/(2*math.pi))
end
function math.randomseed(time)
end
os = {}
function os.time()
end

-- MicroQiskit.lua

-- This code is part of Qiskit.
--
-- Copyright IBM 2020

math.randomseed(os.time())

function QuantumCircuit ()

  local qc = {}

  local function set_registers (n,m)
    qc.num_qubits = n
    qc.num_clbits = m or 0
  end
  qc.set_registers = set_registers

  qc.data = {}

  function qc.initialize (ket)
    ket_copy = {}
    for j, amp in pairs(ket) do
      if type(amp)=="number" then
        ket_copy[j] = {amp, 0}
      else
        ket_copy[j] = {amp[0], amp[1]}
      end
    end
    qc.data = {{'init',ket_copy}}
  end

  function qc.add_circuit (qc2)
    qc.num_qubits = math.max(qc.num_qubits,qc2.num_qubits)
    qc.num_clbits = math.max(qc.num_clbits,qc2.num_clbits)
    for g, gate in pairs(qc2.data) do
      qc.data[#qc.data+1] = ( gate )    
    end
  end
      
  function qc.x (q)
    qc.data[#qc.data+1] = ( {'x',q} )
  end

  function qc.rx (theta,q)
    qc.data[#qc.data+1] = ( {'rx',theta,q} )
  end

  function qc.h (q)
    qc.data[#qc.data+1] = ( {'h',q} )
  end

  function qc.cx (s,t)
    qc.data[#qc.data+1] = ( {'cx',s,t} )
  end

  function qc.measure (q,b)
    qc.data[#qc.data+1] = ( {'m',q,b} )
  end

  function qc.rz (theta,q)
    qc.h(q)
    qc.rx(theta,q)
    qc.h(q)
  end

  function qc.ry (theta,q)
    qc.rx(math.pi/2,q)
    qc.rz(theta,q)
    qc.rx(-math.pi/2,q)
  end

  function qc.z (q)
    qc.rz(math.pi,q)
  end

  function qc.y (q)
    qc.z(q)
    qc.x(q)
  end

  return qc

end

function simulate (qc, get, shots)

  if not shots then
    shots = 1024
  end

  function as_bits (num,bits)
    -- returns num converted to a bitstring of length bits
    -- adapted from https://stackoverflow.com/a/9080080/1225661
    local bitstring = {}
    for index = bits, 1, -1 do
        b = num - math.floor(num/2)*2
        num = math.floor((num - b) / 2)
        bitstring[index] = b
    end
    return bitstring
  end

  function get_out (j)
    raw_out = as_bits(j-1,qc.num_qubits)
    out = ""
    for b=0,qc.num_clbits-1 do
      if outputnum_clbitsap[b] then
        out = raw_out[qc.num_qubits-outputnum_clbitsap[b]]..out
      end
    end
    return out
  end


  ket = {}
  for j=1,2^qc.num_qubits do
    ket[j] = {0,0}
  end
  ket[1] = {1,0}

  outputnum_clbitsap = {}

  for g, gate in pairs(qc.data) do

    if gate[1]=='init' then

      for j, amp in pairs(gate[2]) do
          ket[j] = {amp[1], amp[2]}
      end

    elseif gate[1]=='m' then

      outputnum_clbitsap[gate[3]] = gate[2]

    elseif gate[1]=="x" or gate[1]=="rx" or gate[1]=="h" then

      j = gate[#gate]

      for i0=0,2^j-1 do
        for i1=0,2^(qc.num_qubits-j-1)-1 do
          b1=i0+2^(j+1)*i1 + 1
          b2=b1+2^j

          e = {{ket[b1][1],ket[b1][2]},{ket[b2][1],ket[b2][2]}}

          if gate[1]=="x" then
            ket[b1] = e[2]
            ket[b2] = e[1]
          elseif gate[1]=="rx" then
            theta = gate[2]
            ket[b1][1] = e[1][1]*math.cos(theta/2)+e[2][2]*math.sin(theta/2)
            ket[b1][2] = e[1][2]*math.cos(theta/2)-e[2][1]*math.sin(theta/2)
            ket[b2][1] = e[2][1]*math.cos(theta/2)+e[1][2]*math.sin(theta/2)
            ket[b2][2] = e[2][2]*math.cos(theta/2)-e[1][1]*math.sin(theta/2)
          elseif gate[1]=="h" then
            for k=1,2 do
              ket[b1][k] = (e[1][k] + e[2][k])/math.sqrt(2)
              ket[b2][k] = (e[1][k] - e[2][k])/math.sqrt(2)
            end
          end

        end
      end

    elseif gate[1]=="cx" then

      s = gate[2]
      t = gate[3]

      if s>t then
        h = s
        l = t
      else
        h = t
        l = s
      end

      for i0=0,2^l-1 do
        for i1=0,2^(h-l-1)-1 do
          for i2=0,2^(qc.num_qubits-h-1)-1 do
            b1 = i0 + 2^(l+1)*i1 + 2^(h+1)*i2 + 2^s + 1
            b2 = b1 + 2^t
            e = {{ket[b1][1],ket[b1][2]},{ket[b2][1],ket[b2][2]}}
            ket[b1] = e[2]
            ket[b2] = e[1]
          end
        end
      end

    end

  end

  if get=="statevector" then
    return ket
  else

    probs = {}
    for j,amp in pairs(ket) do
      probs[j] = amp[1]^2 + amp[2]^2
    end

    if get=="expected_counts" then

      c = {}
      for j,p in pairs(probs) do
        out = get_out(j)
        if c[out] then
          c[out] = c[out] + probs[j]*shots
        else
          if out then -- in case of pico8 weirdness
            c[out] = probs[j]*shots
          end
        end
      end
      return c

    else

      m = {}
      for s=1,shots do
        cumu = 0
        un = true
        r = math.random()
        for j,p in pairs(probs) do
          cumu = cumu + p
          if r<cumu and un then
            m[s] = get_out(j)
            un = false
          end
        end
      end

      if get=="memory" then
        return m

      elseif get=="counts" then
        c = {}
        for s=1,shots do
          if c[m[s]] then
            c[m[s]] = c[m[s]] + 1
          else
            if m[s] then -- in case of pico8 weirdness
              c[m[s]] = 1
            else
              if c["error"] then
                c["error"] = c["error"]+1
              else
                c["error"] = 1
              end
            end
          end
        end
        return c

      end

    end

  end

end

-- QPong

player_points = 0
com_points = 0
scored = ""

function _init()
    --variables
    counter=0
    player={
        x = 117,
        y = 63,
        color = 12,
        width = 2,
        height = 10,
        speed = 1
    }
    com={
        x = 8,
        y = 63,
        color = 8,
        width = 2,
        height = 10,
        speed = 0.75
    }
    ball={
        x = 63,
        y = 63,
        color = 7,
        width = 2,
        dx = 0.6,
        dy = flr(rnd(2))-0.5,
        speed = 1,
        speedup = 0.05
    }
    gate_type={
        x = 0,
        y = 1,
        z = 2,
        h = 3
    }
    gate_seq={
      I=1,
      X=2,
      Y=3,
      Z=4,
      H=5
    }
    gates={
		{1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1}
	}
	-- Relative frequency of the measurement results
	-- Obtained from simulator
	probs = {0, 0, 0, 0, 0, 0, 0, 0}
  --probs={0.5, 0.5, 0, 0, 0, 0, 0, 0}
  --meas_probs={1, 0, 0, 0, 0, 0, 0, 0}

	-- How many updates left does the paddle stays measured
	measured_timer = 0

    cursor = {
        row=0,
        column=0,
        x=0,
        y=0,
        sprite=16
    }
    --sound
    if scored=="player" then
        sfx(3)
    elseif scored=="com" then
        sfx(4)
    else
        sfx(5)
    end
	--court
    court={
        left=0,
        right=127,
        top=0,
        bottom=81,
        edge=107, --when ball collide this line, measure the circuit
        color=5
    }
	--court center line
    dash_line={
        x=63,
        y=0,
        length=1.5,
        color=5
    }
    --circuit composer
    composer={
        left=0,
        right=127,
        top=82,
        bottom=127,
        color=7
    }
    qubit_line={
        x=10,
        y=90,
        length=108,
        separation=15,
        color=5
    }
end

function _draw()
    cls()

    --court
    rect(court.left,court.top,court.right,court.bottom,court.color)

	--dashed center line
	repeat
		line(dash_line.x,dash_line.y,dash_line.x,dash_line.y+dash_line.length,dash_line.color)
		dash_line.y += dash_line.length*2
	until dash_line.y > court.bottom-1
	dash_line.y = 0 --reset

    --circuit composer
    rectfill(composer.left,composer.top,composer.right,composer.bottom,composer.color)
    --qubit lines
	repeat
		line(qubit_line.x,qubit_line.y,qubit_line.x+qubit_line.length,qubit_line.y,qubit_line.color)
        qubit_line.y += qubit_line.separation
	until qubit_line.y > composer.bottom-1
	qubit_line.y = 90 --reset

	for slot = 1, 8 do
		for wire = 1, 3 do
			gnum = gates[wire][slot] - 2
			if gnum != -1 then
				spr(gnum,
					qubit_line.x + (slot - 1) * qubit_line.separation - 4,
					qubit_line.y + (wire - 1) * qubit_line.separation - 4)
			end
		end
	end

    --cursor
    cursor.x=qubit_line.x+cursor.column*qubit_line.separation-4
    cursor.y=qubit_line.y+cursor.row*qubit_line.separation-4
    spr(cursor.sprite,cursor.x,cursor.y)

    for x=0,7 do
        spr(6,87,8*(x+1))
        a=x%2
        b=flr(x/2)%2
        c=flr(x/4)%2
        spr(c+4,95,8*(x+1))
        spr(b+4,103,8*(x+1))
        spr(a+4,111,8*(x+1))
        spr(7,119,8*(x+1))
    end

    --player
	for y=0,7 do
		local color
		local prob = probs[y + 1] --supposed to be inverse power of 2 but I'm allowing .01 error
		if prob > .99 then
			color = 7
		elseif prob > .49 then
			color = 6
		elseif prob > .24 then
			color = 13
		elseif prob > .11 then
			color = 5
		else
			color = 0
		end
		
		rectfill(
			player.x,
			8 * ( y + 1 ),
			player.x + player.width,
			8 * ( y + 1 ) + player.height,
			color
		)
	end

    --ball
    rectfill(
        ball.x,
        ball.y,
        ball.x + ball.width,
        ball.y + ball.width,
        ball.color
    )

    --computer
    rectfill(
        com.x,
        com.y,
        com.x + com.width,
        com.y + com.height,
        com.color
    )

    --scores
    print(player_points,95,2,player.color)
    print(com_points,30,2,com.color)

end

function simCir()
    qc = QuantumCircuit()
    qc.set_registers(3,3)
    for slots = 1,8 do
      for wires = 1,3 do
       if (gates[wires][slots] == 2) then 
          qc.x(wires-1)
        
        elseif (gates[wires][slots] == 3) then 
          qc.y(wires-1)
        
        elseif (gates[wires][slots] == 4) then
          qc.z(wires-1)
       
        elseif (gates[wires][slots] == 5) then 
          qc.h(wires-1)  
        end 
      end          
    end

    qc.measure(0,0)
    qc.measure(1,1)
    qc.measure(2,2)
    
    result = simulate(qc,'expected_counts',1)

    for key, value in pairs(result) do
      print(key,value)
      idx = tonum('0b'..key) + 1
      probs[idx]=value
    end  
end

function meas_prob()
    idx = -1
    math.randomseed(os.time())
    r=math.random()
    --r =0.2
    --print(r)
    num =0
    for i = 1,8 do
        
        if (r > probs[i]) then
            num=r-probs[i]
            r=num
        
        elseif (r<=probs[i]) then 
            idx = i
            break
        end
    end
    for i = 1,8 do
        if i==idx then
            probs[i]=1.0
        else
            probs[i]=0.0
        end
    end
    return idx
end

function _update60()
    --player controls
    
    if btnp(2)
    and cursor.row > 0 then
        cursor.row -= 1
    end
    if btnp(3)
    and cursor.row < 2 then
        cursor.row += 1
    end
    if btnp(0)
    and cursor.column > 0 then
        cursor.column -= 1
    end
    if btnp(1)
    and cursor.column < 7  then
        cursor.column += 1
    end
    if btnp(4) then 
      cur_gate = gates[cursor.row+1][cursor.column+1]
      if cur_gate==2 then
        gates[cursor.row+1][cursor.column+1]=1
      else
        gates[cursor.row+1][cursor.column+1]=2
      end
	  simCir()
    end
    if btnp(5) then 
      cur_gate = gates[cursor.row+1][cursor.column+1]
      if cur_gate==5 then
        gates[cursor.row+1][cursor.column+1]=1
      else
        gates[cursor.row+1][cursor.column+1]=5
      end
	  simCir()
    end
    --computer controls
    mid_com = com.y + (com.height/2)

    if ball.dx<0 then
        if mid_com > ball.y
        and com.y>court.top+1 then
            com.y-=com.speed
        end
        if mid_com < ball.y
        and com.y + com.height < court.bottom - 1 then
            com.y += com.speed
        end
    else
        if mid_com > 73 then
            com.y -= com.speed
        end
        if mid_com < 53 then
            com.y += com.speed
        end
    end

    --collide with com
    if ball.dx < 0
    and ball.x + ball.width >= com.x
    and ball.x + ball.width <= com.x + com.width
    and ball.y >= com.y
    and ball.y + ball.width <= com.y + com.height
    then
        ball.dx = -(ball.dx + ball.speedup)
        sfx(0)
    end

    --TODO: when ball collide on edge--> measure
    --UNTEST
    if ball.x > court.edge and counter==0 then
      counter=30
      meas_prob()
      
    elseif ball.x < court.edge and counter > 0 then
      counter-=1
      if counter==0 then
        simCir()
      end
    end
    ------------------------

    --collide with player
    if ball.dx > 0
    and ball.x >= player.x
    and ball.x <= player.x + player.width
    and ball.y >= player.y
    and ball.y + ball.width <= player.y + player.height
    then
        ball.dy -= ball.speedup*2
        --control ball DY if hit and press up or down
        [[
        if btn(⬆️) then
            if ball.dy > 0 then
                ball.dy = -ball.dy
                ball.dy -= ball.speedup * 2
            else
                ball.dy -= ball.speedup * 2
            end
        end
        if btn(⬇️) then
            if ball.dy < 0 then
                ball.dy = -ball.dy
                ball.dy += ball.speedup * 2
            else
                ball.dy += ball.speedup * 2
            end
        end
        ]]
        --flip ball DX and add speed
        ball.dx = -(ball.dx - ball.speedup)
        sfx(1)
    end

    --collide with court
    if ball.y + ball.width >= court.bottom - 1
    or ball.y <= court.top+1 then
        ball.dy = -ball.dy
        sfx(2)
    end

    --score
    if ball.x > court.right then
        player_points += 1
        scored = "player"
        _init() --reset game
    end
    if ball.x < court.left then
        com_points += 1
        scored = "com"
        _init() --reset game
    end

    --ball movement
    ball.x += ball.dx
    ball.y += ball.dy
end

__gfx__
6666666166666661666666616666666100000000000000000000c00000c000000000000000000000000000000000000000000000000000000000000000000000
61666161616661616111116161666161000cc0000000c0000000c000000c00000000000000000000000000000000000000000000000000000000000000000000
6616166166161661666616616166616100c00c00000cc0000000c0000000c0000000000000000000000000000000000000000000000000000000000000000000
6661666166616661666166616111116100c00c000000c0000000c00000000c000000000000000000000000000000000000000000000000000000000000000000
6616166166616661661666616166616100c00c000000c0000000c00000000c000000000000000000000000000000000000000000000000000000000000000000
61666161666166616111116161666161000cc0000000c0000000c0000000c0000000000000000000000000000000000000000000000000000000000000000000
6666666166666661666666616666666100000000000000000000c000000c00000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111100000000000000000000c00000c000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
