-- title:  Cat-a-tron
-- author: Pete Rielly
-- desc:   Cat shooter
-- script: lua
-- 2d1b2e218a913cc2fa9af6fd4a247c574b67937ac58ae25d8e2b45f04156f272ced3c0a8c5754af2a759f7db53f9f4ea
-- https://lospec.com/palette-list/castpixel-16
sound = true
score = 0
start_lives=2
lives = start_lives
start_level = 1
level = start_level
textcol = 3
show_hit_box = true

t=0
x=96
y=24
shakeT=0
coolT=0
pl={}
debug="no msg"

state="title"
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
	h=1
}

bulletList={}

monList={}

exList={} -- explosion list

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
			isDead=oneShotDead
	   }
	   table.insert(monList,b)
end

function updateMan(obj)
	if(t%120 == 0) then
		obj.vx=math.random(-1,1)/2
		obj.vy=math.random(-1,1)/2
	end
	if onScreen(obj.x+obj.vx,obj.y+obj.vy) then
		obj.x=obj.x+obj.vx
		obj.y=obj.y+obj.vy	
	else
		obj.vx=obj.vx*-1
		obj.vy=obj.vy*-1
	end
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
	if(t%120 == 0) then
		obj.vx=math.random(-1,1)/2
		obj.vy=math.random(-1,1)/2
	end
	if onScreen(obj.x+obj.vx,obj.y+obj.vy) then
		obj.x=obj.x+obj.vx
		obj.y=obj.y+obj.vy	
	else
		obj.vx=obj.vx*-1
		obj.vy=obj.vy*-1
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
	for i,m in ipairs(monList) do
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
	if #monList == 0 then
		coolT=80
		state = "level complete"
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
	for i,m in ipairs(monList) do
		
		local _b1 = {m.x+m.hitBox[1], m.y+m.hitBox[2],m.hitBox[3],m.hitBox[4] }
		local _b2 = {cat.x+cat.hitBox[1], cat.y+cat.hitBox[2],cat.hitBox[3],cat.hitBox[4] }
		if checkCol(_b1,_b2) then
			lives=lives-1
			resetBullets()
			coolT=70
			shakeT=60
			state="hit"
			if sound then
				sfx(0)	
			end
			for k=0,20 do
				createP(cat.x,cat.y,10,math.random(360),20)
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
	print("Score "..score,10,1,textcol)
	print("Lives "..lives,180,1,textcol)
	print("Cat-a-tron",90,1,textcol)
	print(#monList, 0,1,textcol)


	checkMonBull()
	catInput()
	updateCat()
	checkMonCat()
	updateBullets()
	updateMonsters()
	
	updateShake()

	drawBullets()

	drawMonsters()

	drawParticles()
	updateParticles()


	drawSpr(cat)

	t=t+1
end

function hit_tic()
	cls(13)
	rect(0,0,240,9,0)
	rectb(0,9,240,127,11)
	print("Score "..score,10,1,textcol)
	print("Lives "..lives,180,1,textcol)
	print("Cat-a-tron",90,1,textcol)
	
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


	drawSpr(cat)

	t=t+1
end
function title_tic()
	cls(0)
	print("Cat-a-tron",90,60,textcol)
	print("Fire to begin",84,70,textcol)

	if btnp(4) or btnp(5) then
		init_level(1)
		state="play"
	end
end

function go_tic()
	cls(0)
	print("Game Over",90,60,textcol)
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
	for i=1,10+(level*3) do
		createChomper()
	end
	for i=1,5 do
		createMan()
		createOrgan()
	end
	resetMonsters()
end

function level_complete_tic()
	cls(0)
	rect(0,0,240,9,0)
	rectb(0,9,240,127,11)
	print("Score "..score,10,1,textcol)
	print("Lives "..lives,180,1,textcol)
	print("Cat-a-tron",90,1,textcol)
	
	updateShake()

	drawParticles()
	updateParticles()
	
	print("Wave "..level+1,90,60,textcol)

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
	if(t%120 == 0) then
		obj.vx=math.random(-1,1)/2
		obj.vy=math.random(-1,1)/2
	end
	if onScreen(obj.x+obj.vx,obj.y+obj.vy) then
		obj.x=obj.x+obj.vx
		obj.y=obj.y+obj.vy	
	else
		obj.vx=obj.vx*-1
		obj.vy=obj.vy*-1
	end
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
		obj.x=obj.x+(b.vx*2)
		obj.y=obj.y+(b.vy*2)
		return false
	end

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
-- 003:0066660066622600626226606622226606622626006226660062626000666660
-- 004:0066660000622600666226666222222666622666066226600626626006666660
-- 005:0066660000622666066226266622226662622660666226000626260006666600
-- 006:0666666066266266666666666622226662999926662222666666666606666660
-- 007:0666666066266266666226666629926662999926662992666662266606666660
-- 008:0666666066266266666666666666666662222226666666666666666606666660
-- 009:0000000000000000000220000023320000233200000220000000000000000000
-- 016:00000000000000000000888900088999008899990089999a0089999900899999
-- 017:00000000000000000088800099999a00999999a099a999a0999999a099999990
-- 018:00000000000008880000888900088999008899990089999a0089999900899999
-- 019:00000000000000008000000099888a00999998a099a999a0999999a099999990
-- 032:0099999900099999000099990000900000089000000890000008980000009900
-- 033:9999990099999000988990000008900000089000008990000099000000000000
-- 034:0099999900099999000899990008900000089000000898000000990000000000
-- 035:9999990099999000988990000008900000089000000890000089900000990000
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

