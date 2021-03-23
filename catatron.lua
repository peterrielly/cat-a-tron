-- title:  Cat-a-tron
-- author: Pete Rielly
-- desc:   Cat shooter
-- script: lua
-- 2d1b2e218a913cc2fa9af6fd4a247c574b67937ac58ae25d8e2b45f04156f272ced3c0a8c5754af2a759f7db53f9f4ea
-- https://lospec.com/palette-list/castpixel-16

--[[
1 = text
2 = chomper
3 = radmen
4 = organ
5 = box
6 = sentinel
]]
local levels={
    {"Start slow", 5,0,0,2,0},
    {"They're multiplying", 10,0,0,2,0},
	{"Don't get too close!",4,7,0,0,0},
	{"Mmmm meaty!",0,3,4,2,0},
	{"It's like a butchers in here",0,0,9,3,0},
	{"I fell like someone is watching me",0,0,0,0,4}
}

sound = true
score = 0
start_lives=3
lives = start_lives
start_level = 6
level = start_level
textcol = 3
show_hit_box = false
shotspeed = 0.5 -- enemy shot speed
t=0
x=96
y=24
shakeT=0
coolT=0
pl={}
transition=0
debug="no msg"
rainbow={9,13,14,7,3,6,4}
state="title"
itime=60
cat={
	x=100,
	y=50,
	right=0,
	vy=0,
	vy=0,
	anim={256,257},
	ai=1,
	as=22,
	at=0,
	firespeed=10,
	ft=0,
	fy=0,
	fx=-1,
	hitBox={1,1,4,4},
	goodBox={-1,-1,9,9},
	w=1,
	h=1,
	icount = itime
}

bulletList={}

monList={}

exList={} -- explosion list
function printc(s,x,y,c)
	local w=print(s,0,-8)
	print(s,x-(w/2),y,c or 15)
end

function drawSpr(o)
	-- update animation timer
	o.at=o.at+1
	if o.at == o.as then
		o.at=0
		o.ai=o.ai+1
	end
	if o.ai > #o.anim then
		o.ai=1
	end
	spr(o.anim[o.ai],o.x,o.y,0,1,o.right,0,o.w,o.h)
end

function fire()
 b = {
			x=cat.x+(cat.fx*8),
			y=cat.y+(cat.fy*8),
			right=0,
			vx=(cat.fx*3)+math.random(-1,1)/10,
			vy=(cat.fy*3)+math.random(-1,1)/10,
			anim={258,265},
			ai=1,
			as=5,
			at=0,
			hitBox={0,0,8,8},
			w=1,
			h=1
	}
	table.insert(bulletList,b)
	sfx(1)
end

function createMan()
	b = {
			x=math.random(240),
			y=math.random(110)+9,
			right=0,
			vx=.5,
			vy=.5,
			anim={259,260,261},
			ai=math.random(1,3),
			as=math.random(5,12),
			at=0,
			hitBox={0,0,8,8},
			w=1,
			h=1,
			score=20,
			type="radman",
			update=updateMan,
			isDead=oneShotDead,
			a=1
	   }
	   table.insert(monList,b)
end

function updateMan(obj)
	local a=0
	local s=0.25
	if(t%60 == 0) then
		-- target random point
		obj.a = calc_angle(obj.x,obj.y,math.random(0,230), math.random(0,128))
	end

	if calc_distance(obj.x,obj.y,cat.x,cat.y) <30 then
		-- calculate angle to cat
		obj.a = calc_angle(obj.x,obj.y,cat.x,cat.y)
		s=1.5
	end

	obj.vx=math.cos(obj.a)*s
	obj.vy=-math.sin(obj.a)*s

	if not onScreen(obj.x+obj.vx,obj.y+obj.vy) then
		obj.a = calc_angle(obj.x,obj.y,150,75)
		obj.vx=math.cos(obj.a)*s
		obj.vy=-math.sin(obj.a)*s
	end

	obj.x=obj.x+obj.vx
	obj.y=obj.y+obj.vy	
end

function updateCat()
	if onScreen(cat.x+cat.vx, cat.y+cat.vy) then
		cat.x=cat.x+cat.vx
		cat.y=cat.y+cat.vy
	end
	cat.ft=cat.ft+1
	if cat.ft==cat.firespeed then
		cat.ft=0
		fire()
	end
	if cat.icount > 0 then
		cat.icount = cat.icount-1
	end
end

function drawBullets()
	for i,b in ipairs(bulletList) do
		drawSpr(b)
	end
end

function updateBullets()
	for i,b in ipairs(bulletList) do
		b.x=b.x+b.vx
		b.y=b.y+b.vy
		if not onScreen(b.x,b.y) then
			table.remove(bulletList,i)
		end
	end
end

function onScreen(_x,_y)
	if _x < 1 or _x >231 or _y < 9 or _y >128 then
		return false
	else
		return true
	end 
end

function catInput()
	lock=false
	cat.vx=0
	cat.vy=0

	if btn(4) then
		lock=true
	else
		if btn(0) or btn(1) or btn(2) or btn(3) then
			cat.fx=0
			cat.fy=0
		end
	end
	if btn(0) then --up 
		cat.vy=-1
		if not lock then
			cat.fy=-1
		end
	end
	if btn(1) then 
		cat.vy=1
		if not lock then
			cat.fy=1
		end
	end
	if btn(2) then 
		cat.vx=-1
		if not lock then
			cat.fx=-1
		end
		cat.right=0
	end
	if btn(3) then 
		cat.vx=1
		if not lock then
			cat.fx=1
		end
		cat.right=1
	end
end

function createChomper()
	b = {
			x=math.random(240),
			y=math.random(110)+9,
			right=0,
			vx=.5,
			vy=.5,
			anim={264,262,263,262,264},
			ai=math.random(1,3),
			as=math.random(5,12),
			at=0,
			type="chomper",
			hitBox={0,0,7,7},
			w=1,
			h=1,
			score=10,
			update=updateChomper,
			isDead=oneShotDead
	   }
	   table.insert(monList,b)
end

function updateMonsters()
	for i,b in ipairs(monList) do
		b:update()
	end
end

function updateChomper(obj)
	local a=0
	if(t%120 == 0) then
		if math.random(0,1) ==0 then
			-- calculate angle to cat
			a = calc_angle(obj.x,obj.y,cat.x,cat.y)
		else
			-- target random point
			a = calc_angle(obj.x,obj.y,math.random(0,230), math.random(0,128))
		end
		obj.vx=math.cos(a)*.75
		obj.vy=-math.sin(a)*.75
	end
	if onScreen(obj.x+obj.vx,obj.y+obj.vy) then
		obj.x=obj.x+obj.vx
		obj.y=obj.y+obj.vy	
	else
		a = calc_angle(obj.x,obj.y,150,75)
		obj.vx=math.cos(a)*.75
		obj.vy=-math.sin(a)*.75
		
		obj.x=obj.x+obj.vx
		obj.y=obj.y+obj.vy	
	end
end

function drawMonsters()
	for i,b in ipairs(monList) do
		drawSpr(b)
	end
end

function checkCol(b1,b2)
-- inputs are tables {x1,y1,w,h}
	if show_hit_box then
		rectb(b1[1], b1[2], b1[3], b1[4],3 )
		rectb(b2[1], b2[2], b2[3], b2[4],3 )
	end
	if b1[1] <= b2[1]+b2[3] and b1[1]+b1[3] >= b2[1] then
		if b1[2] <= b2[2]+b2[4] and b1[2] + b1[4] >= b2[2] then
			return true
		end
	end
end

function checkMonBull()
	local num_alive = 0
	for i,m in ipairs(monList) do
		if not m.ignore then
			num_alive = num_alive+1
		end
		for j,b in ipairs(bulletList) do
			local _b1 = {m.x+m.hitBox[1], m.y+m.hitBox[2],m.hitBox[3],m.hitBox[4] }
			local _b2 = {b.x+b.hitBox[1], b.y+b.hitBox[2],b.hitBox[3],b.hitBox[4] }
			if checkCol(_b1,_b2) then
				if m:isDead(b) then
					score=score+m.score
					for k=0,5 do
						createP(m.x,m.y,20,math.random(360),15)
					end
					table.remove(monList,i)
					shakeT=7
					if sound then
						sfx(0)	
					end
				end
				table.remove(bulletList,j)
				break
			end
		end
	end

	-- check if any mosters are still alive
	if num_alive == 0 then
		coolT=80
		state = "level transition"
	end
end

function updateShake()
	if shakeT > 0 then
		shakeT = shakeT-1
		poke(0x3FF9,math.random(-2,2))
		poke(0x3FF9+1,math.random(-2,2))
	else
		poke(0x3FF9,0)
		poke(0x3FF9+1,0)
	end
end

function createP(_x,_y,_l,_a,_c)
	local p={
				x=_x,
				y=_y,
				life=_l,
				c=_c,
				vx=math.cos(_a),
				vy=math.sin(_a)
				}
	table.insert(pl,p)
end

function drawParticles()
	--if t%2 ==0 then return end
	for i=1,#pl do
		local p=pl[i]
		--circ(p.x,p.y,(20-p.life),p.c)
		circ(p.x,p.y,p.life,p.c)
	end
end

function updateParticles()
	for i,p in pairs(pl) do
		if pl[i].c == 0 then
			pl[i].c=12
		else
			pl[i].life = pl[i].life-1
		end
		if pl[i].life<=0 then
			table.remove(pl,i)
		else
			pl[i].x = pl[i].x+pl[i].vx
			pl[i].y = pl[i].y+pl[i].vy
		end 
	end
end

function checkMonCat()
	-- check we are not invincable
	if cat.icount >0 then
		return
	end

	for i,m in ipairs(monList) do
		
		local _b1 = {m.x+m.hitBox[1], m.y+m.hitBox[2],m.hitBox[3],m.hitBox[4] }
		local _b2 = {cat.x+cat.hitBox[1], cat.y+cat.hitBox[2],cat.hitBox[3],cat.hitBox[4] }
		if checkCol(_b1,_b2) then
			lives=lives-1
			cat.icount = itime
			resetBullets()
			coolT=70
			shakeT=60
			state="hit"
			if sound then
				sfx(0)	
			end
			for k=0,20 do
				createP(cat.x,cat.y,20,math.random(360),9)
			end
			
			break
		end
		
	end
end

function resetMonsters()
	for i,m in ipairs(monList) do
		while checkCol({m.x,m.y,8,8},{80,40,80,50}) do
			m.x=math.random(240)
			m.y=math.random(110)+9
		end
	end
end


function resetBullets()
	for i,b in ipairs(bulletList) do
		table.remove(bulletList,i)
	end
end


function play_tic()
	cls(13)
	rect(0,0,240,9,0)
	rectb(0,9,240,127,11)
	drawHud()
	
	catInput()
	updateCat()
	
	updateBullets()
	updateMonsters()
	updateParticles()
	checkMonCat()
	checkMonBull()
	
	updateShake()
	drawBullets()
	drawMonsters()
	drawParticles()

	if cat.icount > 0 then
		if cat.icount <(itime/4) then
			if t%4==0 then
				circ(cat.x+4, cat.y+4,12,10)
			end
		else
			if t%4~=0 then
				circ(cat.x+4, cat.y+4,12,10)
			end
		end
	end
	drawSpr(cat)

	t=t+1
end

function hit_tic()
	cls(13)
	drawHud()
	
	-- check cat isn't recovering
	if coolT > 0 then
		coolT=coolT-1
	else
		cat.x=100
		cat.y=50
		resetMonsters()
		if lives == 0 then
			state="game over"
		else
			state="play"
		end
	end
	updateShake()

	drawMonsters()

	drawParticles()
	updateParticles()


--	drawSpr(cat)

	t=t+1
end
function title_tic()
	level = start_level
	cls(0)
	printc("Cat-a-tron",120,60,textcol)
	printc("Fire to begin",120,70,textcol)
	printc(levels[level][1], 120,80,textcol)


	if btnp(4) or btnp(5) then
		init_level(level)
		state="play"
	end
end

function go_tic()
	cls(0)
	printc("Game Over",120,60,textcol)
	lives = start_lives
	level=start_level
	for i,m in ipairs(monList) do
		table.remove(monList,i)
	end

	if btnp(4) or btnp(5) then
		state="title"
	end
end

function win_tic()
	cls(0)
	printc("You win!",120,60,textcol)
	lives = start_lives
	level=start_level
	for i,m in ipairs(monList) do
		table.remove(monList,i)
	end

	if btnp(4) or btnp(5) then
		state="title"
	end
end

function init_level(level)

	for i=1,levels[level][2] do
		createChomper()
	end

	for i=1,levels[level][3] do
		createMan()
	end

	for i=1,levels[level][4] do
		createOrgan()
	end

	for i=1,levels[level][5] do
		createBox()
	end

	for i=1,levels[level][6] do
		createSentinel()
	end	
	resetMonsters()
	cat.icount = itime
end

function level_complete_tic()
	cls(0)
 	drawHud()
	
	if level == #levels then
		state="win"
		return
	end


	printc("Wave "..level+1,120,60,textcol)
	printc(levels[level+1][1],120,70, textcol)

	if btnp(4) or btnp(5) then
		cat.x=100
		cat.y=50
		level=level+1
		init_level(level)

		state="play"
	end

end

function createExplosion(_x,_y,_s,_c)
	local e={
				x=_x,
				y=_y,
				life=0,
				c=_c,
				size=_s
				}
	table.insert(exList,p)
end

function updateExplosions()
	for i,ex in pairs(exList) do
		ex.life = ex.life+1
		if ex.life > 60 then
			table.remove(exList,i)
		end
	end
end

function drawExplosions()
	for i=1,#exList do
	end
end

function oneShotDead(m)
	return true
end

function createBox()
	b = {
			x=math.random(240),
			y=math.random(110)+9,
			right=0,
			vx=.5,
			vy=.5,
			anim={266,267,268},
			ai=math.random(1,3),
			as=math.random(5,12),
			at=0,
			type="box",
			hitBox={0,0,7,7},
			w=1,
			h=1,
			score=10,
			update=updateBox,
			isDead=multiShotStatic,
			life=10,
			ignore=true
	   }
	   table.insert(monList,b)
end

function updateBox()
	return
end

function createSentinel()
	b = {
			x=math.random(240),
			y=math.random(110)+9,
			right=0,
			vx=.5,
			vy=.5,
			anim={304,306},
			ai=math.random(1,3),
			as=math.random(5,12),
			at=0,
			type="sentinel",
			hitBox={2,0,11,15},
			w=2,
			h=2,
			score=10,
			update=updateSentinel,
			isDead=multiShotStatic,
			life=10
	   }
	   table.insert(monList,b)
end

function updateSentinel(obj)
	if t%240==0 then
		local a = calc_angle(obj.x, obj.y,cat.x, cat.y)
		local vx=math.cos(a)*shotspeed
		local vy=-math.sin(a)*shotspeed
		createShot(obj.x,obj.y,vx,vy)
	end
end

function createShot(_x,_y,_vx,_vy)
	b = {
			x=_x,
			y=_y,
			right=0,
			vx=_vx,
			vy=_vy,
			anim={278},
			ai=math.random(1,3),
			as=math.random(5,12),
			at=0,
			type="shot",
			hitBox={1,1,5,5},
			w=1,
			h=1,
			score=10,
			update=updateShot,
			isDead=oneShotDead,
			life=10,
			ignore=true
	   }
	   table.insert(monList,b)
end

function updateShot(obj)
	if onScreen(obj.x+obj.vx,obj.y+obj.vy) then
		obj.x=obj.x+obj.vx
		obj.y=obj.y+obj.vy	
	else
		a = calc_angle(obj.x,obj.y,150,75)
		obj.vx=math.cos(a)*shotspeed
		obj.vy=-math.sin(a)*shotspeed
		
		obj.x=obj.x+obj.vx
		obj.y=obj.y+obj.vy	
	end
end

function createOrgan()
	b = {
			x=math.random(240),
			y=math.random(110)+9,
			right=0,
			vx=.5,
			vy=.5,
			anim={272,274},
			ai=math.random(1,3),
			as=math.random(5,12),
			at=0,
			type="organ",
			hitBox={0,0,15,9},
			w=2,
			h=2,
			score=10,
			update=updateOrgan,
			isDead=multiShotDead,
			life=5
	   }
	   table.insert(monList,b)
end

function updateOrgan(obj)
	local a=1
	local sx=0.6
	local sy=0.2
	local r=0

	if obj.a == nil then
		obj.a = calc_angle(obj.x,obj.y,cat.x, cat.y)
	end
	if(t%120 == 0) then
		r = math.random(0,2)
		if r == 0 then
			-- target random point left
			obj.a = calc_angle(obj.x,obj.y,math.random(15,100), math.random(10,120))
		elseif r == 1 then
			-- target random point right
			obj.a = calc_angle(obj.x,obj.y,math.random(100,220), math.random(10,120))
		else
			obj.a = calc_angle(obj.x,obj.y,cat.x, cat.y)
		end
	end
	a = obj.a

	obj.vx=math.cos(a)*sx
	obj.vy=-math.sin(a)*sy

	if onScreen(obj.x+obj.vx,obj.y+obj.vy) == false then
		obj.a = calc_angle(obj.x,obj.y,150,75)
		obj.vx=math.cos(obj.a)*sx
		obj.vy=-math.sin(obj.a)*sy
	end

	obj.x=obj.x+obj.vx
	obj.y=obj.y+obj.vy	
end

function multiShotDead(obj,b)
	if sound then
		sfx(0)	
	end
	obj.life = obj.life-1
	if obj.life == 0 then
		return true
	else
		for k=0,5 do
			createP(obj.x,obj.y,10,math.random(360),10)
		end
		if onScreen(obj.x+(b.vx*2),obj.y+(b.vy*2)) then
			obj.x=obj.x+(b.vx*2)
			obj.y=obj.y+(b.vy*2)
		end
		return false
	end
end

function multiShotStatic(obj,b)
	if sound then
		sfx(0)	
	end
	obj.life = obj.life-1
	if obj.life == 0 then
		return true
	else
		for k=0,5 do
			createP(obj.x,obj.y,10,math.random(360),10)
		end
		return false
	end

end

function drawHud()
	rect(0,0,240,9,0)
	rectb(0,9,240,127,11)
	print("Score "..score,10,1,textcol)
	print("Lives "..lives,180,1,textcol)
	printc("Cat-a-tron",120,1,textcol)
end

function level_transition_tic()
	updateShake()

	drawParticles()
	updateParticles()

	for i=0,6 do
		rect(0,1+(19*i),transition,19,rainbow[i+1])
	end
	transition=transition+10
	if transition >= 250 then
		state = "level complete"
		transition = 0 
	end
end

function calc_angle(x1,y1,x2,y2)
	return math.atan2(y1-y2,x2-x1)
end

function calc_distance(x1,y1,x2,y2)
	return math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))
end

function TIC()

	if state == "title" then
		title_tic()
	elseif state =="play" then
		play_tic()
	elseif state == "hit" then
		hit_tic()
	elseif state == "game over" then
		go_tic()
	elseif state== "level complete" then
		level_complete_tic()
	elseif state == "level transition" then
		level_transition_tic()
	elseif state == "win" then
		win_tic()
	end

end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <SPRITES>
-- 000:00000000aaaaa000a3a3aaaaa333aa3aa333a3aaa33333a00a3aa3a00aaaaaa0
-- 001:aaaaa000a3a3a000a333aaaaa333aa3aa33333aa0a3333a00a3aa3a00aaaaaa0
-- 002:000000000002200000233200023ff320023ff320002332000002200000000000
-- 003:00999900999aa9009a9aa99099aaaa99099aa9a9009aa999009a9a9000999990
-- 004:00999900009aa900999aa9999aaaaaa9999aa999099aa99009a99a9009999990
-- 005:00999900009aa999099aa9a999aaaa999a9aa990999aa90009a9a90009999900
-- 006:0666666066266266666666666622226662999926662222666666666606666660
-- 007:0666666066266266666226666629926662999926662992666662266606666660
-- 008:0666666066266266666666666666666662222226666666666666666606666660
-- 009:0000000000000000000220000023320000233200000220000000000000000000
-- 010:aaaaaaaaa222222aa266662aa26aa62aa26aa62aa266662aa222222aaaaaaaaa
-- 011:222222222666666226aaaa6226a22a6226a22a6226aaaa622666666222222222
-- 012:666666666aaaaaa66a2222a66a2662a66a2662a66a2222a66aaaaaa666666666
-- 016:00000000000000000000888900088999008899990089999a0089999900899999
-- 017:00000000000000000088800099999a00999999a099a999a0999999a099999990
-- 018:00000000000008880000888900088999008899990089999a0089999900899999
-- 019:00000000000000008000000099888a00999998a099a999a0999999a099999990
-- 020:0088880008888880888008888880088800888880880888888800008800000000
-- 021:0088880008888880888008888880088808888800888880888800008800000000
-- 022:000000000008800000899800089ee980089ee980008998000008800000000000
-- 032:0099999900099999000099990000900000089000000890000008980000009900
-- 033:9999990099999000988990000008900000089000008990000099000000000000
-- 034:0099999900099999000899990008900000089000000898000000990000000000
-- 035:9999990099999000988990000008900000089000000890000089900000990000
-- 048:0000000000000003000000320000032a00000022000000020000000a00000013
-- 049:0000000022000000a22000003a220000a220000022000000fa00000011100000
-- 050:00000003000000320000032a0000002200000002000000000000000f00000013
-- 051:22000000a22000003a220000a22000002200000000000000ff00000011100000
-- 064:00000131000000af000001310000131100000afa000013110001311100000000
-- 065:11110000aaa000001111000011111000aaaa0000111110001111110000000000
-- 066:00000131000000af000001310000131100000aff000013110001311100000000
-- 067:11110000ffa000001111000011111000fffa0000111110001111110000000000
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:02000243026302730253f230f240f260f250f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200305000000000
-- 001:0100011001500180018001400120f110f190f140f140f150f180f1a0f1b0f1e0f1e0f1a0f140f120f120f170f140f130f100f100f100f100f100f100503000000000
-- </SFX>

-- <PALETTE>
-- 000:2d1b2e218a913cc2fa9af6fd4a247c574b67937ac58ae25d8e2b45f04156f272ced3c0a8c5754af2a759f7db53f9f4ea
-- </PALETTE>

