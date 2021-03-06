-- title:  Cat-a-tron
-- author: Pete Rielly
-- desc:   Cat shooter
-- script: lua

sound = true
score = 0
start_lives=1
lives = start_lives
start_level = 1
level = start_level

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

manList={}

monList={}

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
			h=1
	   }
	   table.insert(manList,b)
end

function updateMen()
	for i,b in ipairs(manList) do
		if(t%120 == 0) then
			b.vx=math.random(-1,1)/2
			b.vy=math.random(-1,1)/2
		end
		b.x=b.x+b.vx
		b.y=b.y+b.vy
		if not onScreen(b.x,b.y) then
			b.vx=b.vx*-1
			b.vy=b.vy*-1
		end
	end
end

function updateCat()
	cat.x=cat.x+cat.vx
	cat.y=cat.y+cat.vy
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
	if _x < 0 or _x >240 or _y < 9 or _y >136 then
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

function drawMen()
	for i,b in ipairs(manList) do
		drawSpr(b)
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
			score=10
	   }
	   table.insert(monList,b)
end

function updateMonsters()
	for i,b in ipairs(monList) do
		if b.type =="chomper" then
			updateChomper(b)
		end
	end
end

function updateChomper(obj)
	if(t%120 == 0) then
		obj.vx=math.random(-1,1)/2
		obj.vy=math.random(-1,1)/2
	end
	obj.x=obj.x+obj.vx
	obj.y=obj.y+obj.vy
	if not onScreen(obj.x,obj.y) then
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
	rectb(b1[1], b1[2], b1[3], b1[4],3 )
	rectb(b2[1], b2[2], b2[3], b2[4],3 )
	if b1[1] <= b2[1]+b2[3] and b1[1]+b1[3] >= b2[1] then
		if b1[2] <= b2[2]+b2[4] and b1[2] + b1[4] >= b2[2] then
			circ(b1[1],b1[2],20,0)
			circ(b2[1],b2[2],20,0)
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
				--debug="collide"..i" "..j
				score=score+m.score
				for k=0,5 do
					createP(m.x,m.y,20,math.random(360))
				end
				table.remove(monList,i)
				table.remove(bulletList,j)
				shakeT=7
				if sound then
					sfx(0)	
				end
				
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

function createP(_x,_y,_l,_a)
	local p={
				x=_x,
				y=_y,
				life=_l,
				c=0,
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
				createP(cat.x,cat.y,10,math.random(360))
			end
			
			break
		end
		
	end
end

function resetMonsters()
	for i,m in ipairs(monList) do
		m.x=math.random(240)
		m.y=math.random(110)+9
	end
end


function resetBullets()
	for i,b in ipairs(bulletList) do
		table.remove(bulletList,i)
	end
end
-- init things
for i=1,5 do
	createMan()
end



function play_tic()
	cls(4)
	rect(0,0,240,9,0)
	rectb(0,9,240,127,11)
	print("Score "..score,10,1,5)
	print("Lives "..lives,180,1,5)
	print("Cat-a-tron",90,1,5)


	checkMonBull()
	catInput()
	updateCat()
	checkMonCat()
	updateBullets()
	updateMonsters()
	
	updateShake()

	drawBullets()

	updateMen()
	drawMen()

	drawMonsters()

	drawParticles()
	updateParticles()


	drawSpr(cat)

	t=t+1
end

function hit_tic()
	cls(4)
	rect(0,0,240,9,0)
	rectb(0,9,240,127,11)
	print("Score "..score,10,1,5)
	print("Lives "..lives,180,1,5)
	print("Cat-a-tron",90,1,5)
	
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

	drawMen()

	drawMonsters()

	drawParticles()
	updateParticles()


	drawSpr(cat)

	t=t+1
end
function title_tic()
	cls(0)
	print("Cat-a-tron",90,60,5)
	print("Fire to begin",84,70,5)

	if btnp(4) or btnp(5) then
		init_level(1)
		state="play"
	end
end

function go_tic()
	cls(0)
	print("Game Over",90,60,5)
	lives = start_lives
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
end

function level_complete_tic()
	cls(0)
	rect(0,0,240,9,0)
	rectb(0,9,240,127,11)
	print("Score "..score,10,1,5)
	print("Lives "..lives,180,1,5)
	print("Cat-a-tron",90,1,5)
	
	updateShake()

	drawParticles()
	updateParticles()
	
	print("Level "..level+1,90,60,5)

	if btnp(4) or btnp(5) then
		cat.x=100
		cat.y=50
		level=level+1
		init_level(level)

		state="play"
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
-- 000:00000000ccccc000cbcbcccccbbbccbccbbbcbcccbbbbbc00cbccbc00cccccc0
-- 001:ccccc000cbcbc000cbbbcccccbbbccbccbbbbbcc0cbbbbc00cbccbc00cccccc0
-- 002:000000000002200000233200023cc320023cc320002332000002200000000000
-- 003:00cccc00ccc22c00c2c22cc0cc2222cc0cc22c2c00c22ccc00c2c2c000ccccc0
-- 004:00cccc0000c22c00ccc22cccc222222cccc22ccc0cc22cc00c2cc2c00cccccc0
-- 005:00cccc0000c22ccc0cc22c2ccc2222ccc2c22cc0ccc22c000c2c2c000ccccc00
-- 006:0cccccc0c726626cc766666cc722226cc2cccc2cc722226cc776666c0cccccc0
-- 007:0cccccc0c726626cc762266cc72cc26cc2cccc2cc72cc26cc772266c0cccccc0
-- 008:0cccccc0c726626cc766666cc766666cc222222cc776666cc776666c0cccccc0
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
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

