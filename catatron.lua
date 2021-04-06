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
7 = boss1
8 = grunt
9 = tank
]]
local levels={
    {"Start slow", 3,0,0,2,0,0,6,0},
    {"They're multiplying", 4,0,0,4,0,0,10,0},
	{"Don't get too close!",4,4,0,2,0,0,5,0},
	{"Mmmm meaty!",0,3,4,2,0,0,6,0},
	{"It's like a butchers in here",3,0,6,1,0,0,6,0},
	{"I feel like someone is watching me",3,0,0,3,4,0,4,0},
	{"Tank you very much",0,0,0,0,0,0,9,5},
	{"Miniboss",0,0,0,0,0,1,0,0}
}

sound = true
score = 0
start_lives=3
lives = start_lives
start_level = 1
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
radcount=0
groundcolour=0
max_bullet_age=120


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
	icount = itime,
	bounce=true
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
	if o.flash ~= nil then
		if o.flash > 0 then
			o.flash=o.flash-1
		else
			spr(o.anim[o.ai],o.x,o.y,0,1,o.right,0,o.w,o.h)
		end
	else
		spr(o.anim[o.ai],o.x,o.y,0,1,o.right,0,o.w,o.h)
	end
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
			h=1,
			age=0
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
			hit=oneShotDead,
			a=1,
			isHittable=true,
			draw=drawSpr
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

	local d= calc_distance(obj.x,obj.y,cat.x,cat.y)
	if d<60 then 
		if  d<30 then radcount=radcount+1 end

		-- calculate angle to cat
		obj.a = calc_angle(obj.x,obj.y,cat.x,cat.y)
		s=0.75
		radcount=radcount+1
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
		b.age = b.age+1
		if not onScreen(b.x,b.y) then
			if cat.bounce then
				if b.x < 2 or b.x >231 then
					b.vx = -b.vx
				end
				if b.y < 2 or b.y >136 then
					b.vy = -b.vy
				end
			else
				table.remove(bulletList,i)
			end
		end
		if b.age > max_bullet_age then
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
			x=math.random(200)+15,
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
			hit=oneShotDead,
			isHittable=true,
			draw=drawSpr
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

function createGrunt()
	b = {
			x=math.random(200+15),
			y=math.random(110)+9,
			right=0,
			vx=.5,
			vy=.5,
			anim={276,277},
			ai=math.random(1,2),
			as=math.random(18,20),
			at=0,
			type="grunt",
			hitBox={0,0,7,7},
			w=1,
			h=1,
			score=5,
			update=updateGrunt,
			hit=oneShotDead,
			isHittable=true,
			draw=drawSpr
	   }
	   table.insert(monList,b)
end

function updateGrunt(obj)
	local a=0
	if math.random(0,1) ==0 then
		-- calculate angle to cat
		a = calc_angle(obj.x,obj.y,cat.x,cat.y)
	else
		-- target random point
		a = calc_angle(obj.x,obj.y,math.random(0,230), math.random(0,128))
	end
	obj.vx=math.cos(a)*.3
	obj.vy=-math.sin(a)*.3

	if not onScreen(obj.x+obj.vx,obj.y+obj.vy) then
		a = calc_angle(obj.x,obj.y,150,75)
		obj.vx=math.cos(a)*.3
		obj.vy=-math.sin(a)*.3
	end

	obj.x=obj.x+obj.vx
	obj.y=obj.y+obj.vy	
end

function drawMonsters()
	for i,m in ipairs(monList) do
		m:draw()
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
			if checkCol(_b1,_b2) and m.isHittable then
				if m:hit(b) then
					score=score+m.score
					createScoreP(m.x,m.y,40,0,6,m.score)
					for k=0,5 do
						createP(b.x,b.y,20,math.random(360),15)
					end
					m.isDead=true
					shakeT=7
					if sound then
						sfx(2)	
					end
				end
				table.remove(bulletList,j)
				break
			end
		end
	end

	--loop through removing dead things
	for i,m in ipairs(monList) do
		if m.isDead then
			table.remove(monList,i)
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

function createScoreP(_x,_y,_l,_a,_c,_s)
	local p={
		x=_x,
		y=_y,
		life=_l,
		c=_c,
		s=_s,
		vx=0,
		vy=-0.1,
		update = function(p)
			p.life = p.life-1
			p.x = p.x+p.vx
			p.y = p.y+p.vy
		end,
		draw=function(p)
			if p.life%2 == 0 then
				print(p.s,p.x,p.y,9,false,1,true)
		else
			print(p.s,p.x,p.y,14,false,1,true)
			end
		end
		}
table.insert(pl,p)
end
function createP(_x,_y,_l,_a,_c)
	local p={
				x=_x,
				y=_y,
				life=_l,
				c=_c,
				vx=math.cos(_a),
				vy=math.sin(_a),
				update = function(p)
					if p.c == 0 then
						p.c=12
					else
						p.life = p.life-1
					end
					p.x = p.x+p.vx
					p.y = p.y+p.vy
				end,
				draw=function(p)
					circ(p.x,p.y,p.life,p.c)
				end
				}
	table.insert(pl,p)
end

function drawParticles()
	for i,p in pairs(pl) do
		p:draw()
	end
end

function updateParticles()
	for i,p in pairs(pl) do
		p:update()
		if p.life<=0 then
			table.remove(pl,i)
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
				sfx(2)	
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
		--while checkCol({m.x,m.y,8,8},{80,40,80,50}) do
		while calc_distance(m.x,m.y,cat.x,cat.y) < 50 do
			print(calc_distance(m.x,m.y,cat.x,cat.y),10,10,7)
			m.x=m.x+math.random(-1,1)
		end
	end
end


function resetBullets()
	for i,b in ipairs(bulletList) do
		table.remove(bulletList,i)
	end
end

function removeMonsters()
	for i,b in ipairs(monList) do
		table.remove(monList,i)
	end
end

function play_tic()
	radcount=0
	cls(groundcolour)
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

	local u,v
	if radcount > 0 then
		if radcount >3 then radcount=3 end
		for i=0,200 do
			u=math.random(240)
			v=math.random(136)
			--circb(u,v,2,pix(u,v))
			rect(u-radcount,v-radcount,radcount*2,radcount*2,pix(u,v))
		end
	end
	t=t+1
end

function hit_tic()
	cls(groundcolour)
	drawHud()
	
	-- check cat isn't recovering
	if coolT > 0 then
		coolT=coolT-1
	else
		cat.x=100
		cat.y=50
		cat.bounce=false
		resetMonsters()
		t=0
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
	resetBullets()


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
	printc("Score "..score,120,80,textcol)
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

	for i=1,levels[level][7] do
		createBoss1()
	end

	for i=1,levels[level][8] do
		createGrunt()
	end

	for i=1,levels[level][9] do
		createTank()
	end

	resetMonsters()
	t=0
	cat.icount = itime
end

function level_complete_tic()
	cls(0)
 	drawHud()

	resetBullets()
	removeMonsters()
	
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
			x=math.random(200) +10,
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
			hit=multiShotStatic,
			life=10,
			ignore=true,
			isHittable=true,
			draw=drawSpr
	   }
	   table.insert(monList,b)
end

function updateBox()
	return
end

function createBoss1()
	b = {
			x=20,
			y=60,
			right=0,
			vx=0,
			vy=0,
			anim={279},
			ai=math.random(1,3),
			as=12,
			at=0,
			type="Boss1",
			hitBox={0,0,63,30},
			w=8,
			h=4,
			score=10,
			update=updateBoss1,
			hit=multiShotStatic,
			life=200, 
			isHittable = true,
			draw=drawBoss1,
			angry=false,
			fa=0
	   }
	   table.insert(monList,b)
end

function drawBoss1(obj)
	local flash = obj.flash
	drawSpr(obj)
	if obj.angry == true and flash == 0 then
		spr(294,obj.x+28,obj.y+22,0)
	end
	print(obj.life,obj.x,obj.y,7)
end

function updateBoss1(obj)

	local a,vx,vy

	obj.angry=false
	if cat.x < obj.x  and cat.right == 1 then
		obj.angry = true
	end
	if cat.x > obj.x  and cat.right == 0 then
		obj.angry = true
	end

	obj.x = 100+ math.sin(math.rad(t))*40
	obj.y = 60 + math.cos(math.rad(t/2))*30

	if obj.life > 150 then
		if t%10==0 and math.random(0,3)==0 then
			a = calc_angle(obj.x, obj.y,cat.x, cat.y)
			vx=math.cos(a)*shotspeed
			vy=-math.sin(a)*shotspeed
			if sound then sfx(3) end
			createP(obj.x+32,obj.y+16,10,0,0)
			createShot(obj.x+32,obj.y+16,vx,vy)
		end
	end

	if obj.life < 140 and obj.life > 100 then
		if obj.fa <= 2*math.pi then
			vx=math.cos(obj.fa)*shotspeed
			vy=math.sin(obj.fa)*shotspeed
			if sound then sfx(3) end
			createP(obj.x+32,obj.y+16,10,0,0)
			createShot(obj.x+32,obj.y+16,vx,vy)
		end
		obj.fa = obj.fa + 2*math.pi/30

		if obj.fa > 16*math.pi then obj.fa = 0 end
	end

	if obj.life == 100 then obj.fa = 0 end

	if obj.life < 80 and obj.life > 20 then
		if obj.fa < 8*math.pi then
			vx=math.cos(obj.fa)*shotspeed
			vy=math.sin(obj.fa)*shotspeed
			if sound then sfx(3) end
			createP(obj.x+32,obj.y+16,10,0,0)
			createShot(obj.x+32,obj.y+16,vx,vy)
		end
		obj.fa = obj.fa + 2*math.pi/20

		if obj.fa > 20*math.pi then obj.fa = 0 end
	end
	
	if obj.life == 2 then obj.fa = 0 end

	if obj.life < 20 and obj.life > 0 then
		while obj.fa < 8*math.pi do
			local vx=math.cos(obj.fa)*shotspeed
			local vy=math.sin(obj.fa)*shotspeed
			if sound then sfx(3) end
			createP(obj.x+32,obj.y+16,10,0,0)
			createShot(obj.x+32,obj.y+16,vx,vy)
			obj.fa = obj.fa + 2*math.pi/20
		end
		obj.fa = obj.fa + 2*math.pi/20

		if obj.fa > 20*math.pi then obj.fa = 0 end
	end
end

function createSentinel()
	b = {
			x=math.random(200) +10,
			y=math.random(110)+9,
			right=0,
			vx=0,
			vy=0,
			anim={304,306},
			ai=math.random(1,3),
			as=12,
			at=0,
			type="sentinel",
			hitBox={2,0,11,15},
			w=2,
			h=2,
			score=10,
			update=updateSentinel,
			hit=multiShotStatic,
			life=10, 
			isHittable = true,
			draw=drawSpr
	   }
	   table.insert(monList,b)
end

function updateSentinel(obj)
	if t%60==0 and math.random(0,3)==0 then
		local a = calc_angle(obj.x, obj.y,cat.x, cat.y)
		local vx=math.cos(a)*shotspeed
		local vy=-math.sin(a)*shotspeed
		if sound then sfx(3) end
		createShot(obj.x+8,obj.y,vx,vy)
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
			hit=oneShotDead,
			life=10,
			ignore=true,
			isHittable=false,
			draw=drawSpr
	   }
	   table.insert(monList,b)
end

function updateShot(obj)
	if onScreen(obj.x+obj.vx,obj.y+obj.vy) then
		obj.x=obj.x+obj.vx
		obj.y=obj.y+obj.vy	
	else
		obj.isDead=true
	end
end

function createTank()
	b = {
			x=math.random(240),
			y=math.random(110)+9,
			right=0,
			vx=.5,
			vy=.5,
			anim={336,338},
			ai=math.random(1,2),
			as=math.random(28,34),
			at=0,
			type="tank",
			hitBox={0,0,15,11},
			w=2,
			h=2,
			score=10,
			update=updateTank,
			hit=multiShotDead,
			life=5,
			isHittable=true,
			draw=drawSpr,
			fc=math.random(300)
	   }
	   table.insert(monList,b)
end

function updateTank(obj)
	-- which way is the cat
	if cat.x < obj.x then
		obj.right = 1
	else
		obj.right = 0
	end

	local a=calc_angle(obj.x,obj.y,cat.x,cat.y)
	-- decrement fire counter
	obj.fc=obj.fc-1

	if obj.fc < 0 then obj.fc=300 end

	if obj.fc == 10 or obj.fc ==40 or obj.fc ==60 then
		if sound then sfx(3) end
		local vx=math.cos(a)*shotspeed
		local vy=-math.sin(a)*shotspeed
		createP(obj.x+4,obj.y,10,0,0)
		createShot(obj.x+4,obj.y,vx,vy)
	end

	if math.random(20) ==0 then
		-- target random point
		a = calc_angle(obj.x,obj.y,math.random(0,230), math.random(0,128))
		obj.vx=math.cos(a)*.3
		obj.vy=-math.sin(a)*.3
	end
	

	if not onScreen(obj.x+obj.vx,obj.y+obj.vy) then
		a = calc_angle(obj.x,obj.y,150,75)
		obj.vx=math.cos(a)*.3
		obj.vy=-math.sin(a)*.3
	end

	obj.x=obj.x+obj.vx
	obj.y=obj.y+obj.vy	
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
			hitBox={0,0,15,13},
			w=2,
			h=2,
			score=10,
			update=updateOrgan,
			hit=multiShotDead,
			life=5,
			isHittable=true,
			draw=drawSpr
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
			createP(b.x,b.y,10,math.random(360),10)
		end
		if onScreen(obj.x+(b.vx*2),obj.y+(b.vy*2)) then
			obj.x=obj.x+(b.vx*2)
			obj.y=obj.y+(b.vy*2)
		end
		obj.flash = 4
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
			createP(b.x,b.y,10,math.random(360),10)
		end
		obj.flash = 4
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

-- <SPRITES>
-- 000:00000000aaaaaa00a3aa3aaaa3333a3aa23323aaa33333a00a3aa3a00aaaaaa0
-- 001:aaaaaa00a3aa3a00a3333aaaa2332a3aa33333aa0a3333a00a3aa3a00aaaaaa0
-- 002:000660000062260006233260623ff326623ff326062332600062260000066000
-- 003:00999900999aa9009a9aa99099aaaa99099aa9a9009aa999009a9a9000999990
-- 004:00999900009aa900999aa9999aaaaaa9999aa999099aa99009a99a9009999990
-- 005:00999900009aa999099aa9a999aaaa999a9aa990999aa90009a9a90009999900
-- 006:0666666066266266666666666622226662999926662222666666666606666660
-- 007:0666666066266266666226666629926662999926662992666662266606666660
-- 008:0666666066266266666666666666666662222226666666666666666606666660
-- 009:0000000000066000006226000623326006233260006226000006600000000000
-- 010:aaaaaaaaa222222aa266662aa26aa62aa26aa62aa266662aa222222aaaaaaaaa
-- 011:222222222666666226aaaa6226a22a6226a22a6226aaaa622666666222222222
-- 012:666666666aaaaaa66a2222a66a2662a66a2662a66a2222a66aaaaaa666666666
-- 016:00000000000000000000888800088999008899990089999f0089999900899999
-- 017:000000000000000000888000999999009999999099f999909999999099999990
-- 018:00000000000008880000888900088999008899990089999a0089999900899999
-- 019:000000000000000080000000998888009999999099a999909999999099999990
-- 020:0011110001111210111aa121111aa11100111110110111111100001100000011
-- 021:0011110001111210111aa121111aa11101111100111110111100001111000000
-- 022:000000000008800000899800089ee980089ee980008998000008800000000000
-- 024:0000000000000000000000000000000000000000000000ff000fff4400f44444
-- 025:0000000000000000000000ff000fff440ff44444f44444444444444444444444
-- 026:00000000ffffffff444444444444466644466666446666664446666644444466
-- 027:00000000ffffffff444444444444444466644444666644446664444444444444
-- 028:0000000000000000ff00000044fff00044444ff04444444f4444444444444444
-- 029:0000000000000000000000000000000000000000ff00000044fff00044444f00
-- 032:0099999900099999000099990000900000089000000890000008980000009900
-- 033:9999990099999000988990000008900000089000008990000099000000000000
-- 034:0099999900099999000899990008900000089000000898000000990000000000
-- 035:9999990099999000988990000008900000089000000890000089900000990000
-- 036:0000000f00000ff40000f444000f446600f446660f4466660f446664f4444444
-- 037:f00000004ff00000444f00006444f00064444f00444444f0444444f04444444f
-- 038:44444444444444444f4444f444f44f44444ff44444f44f444f4444f444444444
-- 039:0000000000000000000000ff00000f440000f444000f4444000f4444000f4444
-- 040:0f444466f4444666444666644666666446666644666666446666644466666444
-- 041:4444444444444444444466444446ff64446ffff646ffffff46ffffff46ffffff
-- 042:4444444444444444444444444444444466444444ff644444fff64444ffff6444
-- 043:4444444444444444444444444444444444444466444446ff44446fff4446ffff
-- 044:44444444444444444466444446ff64446ffff644ffffff64ffffff64ffffff64
-- 045:444444f04444444f444444444444444444444444444444444444444444444444
-- 046:0000000000000000ff00000044f00000444f00004444f0004444f0004444f000
-- 048:0000000000000003000000320000032a00000022000000020000000a00000013
-- 049:0000000022000000a22000003a220000a220000022000000fa00000011100000
-- 050:00000003000000320000032a0000002200000002000000000000000f00000013
-- 051:22000000a22000003a220000a22000002200000000000000ff00000011100000
-- 052:f44444440f4444440f44444400f44444000f44440000f44400000ff40000000f
-- 053:4444444f444444f0444444f044444f004444f000444f00004ff00000f0000000
-- 055:000f4446000f4446000f4446000f4446000f44460000f4460000f4440000f444
-- 056:6666444466664444666644446666644466666644666666446666666446666666
-- 057:446fffff4446ffff444466ff4444446644444444444444444444444444444444
-- 058:f44ff644f47ff644fff644446664444444444444444444444444444444444444
-- 059:446ff44f446ff74f44446fff4444466644444444444444444444444444444444
-- 060:fffff644ffff6444ff6644446644444444444444444444444444444444444444
-- 061:4444444444444444444444444444444444444444444444444444444444444444
-- 062:4444f0004444f0004444f0004444f0004444f000444f0000444f0000444f0000
-- 064:00000131000000af000001310000131100000afa000013110001311100000000
-- 065:11110000aaa000001111000011111000aaaa0000111110001111110000000000
-- 066:00000131000000af000001310000131100000aff000013110001311100000000
-- 067:11110000ffa000001111000011111000fffa0000111110001111110000000000
-- 071:00000f44000000f40000000f0000000000000000000000000000000000000000
-- 072:4446666644444666f44444440f44444400ff44440000fff40000000f00000000
-- 073:664444446644444444444444444444444444444444444444ffffffff00000000
-- 074:44444f44444444f44444444f444444444444444444444444fff44444000fffff
-- 075:44f444444f444444f444444444444444444444444444444444444ffffffff000
-- 076:444444444444444444444444444444444444444444444444ffffffff00000000
-- 077:44444444444444444444444f444444f04444ff004fff0000f000000000000000
-- 078:44f000004f000000f00000000000000000000000000000000000000000000000
-- 080:0000002300000232000022220000022200000022000066660006666600555666
-- 081:2200000022a000002a3a000022a0000022000000666400006644450066444500
-- 082:0000002300000232000022220000022200000022000066660005556600055566
-- 083:220000002a200000a3a200002a20000022000000666400006644400066444500
-- 096:0055566600555666005550550005000500000000000000000000000000000000
-- 097:6644450066645500500050000000000000000000000000000000000000000000
-- 098:0005556600055566000050050000000000000000000000000000000000000000
-- 099:6644450066645500550555005000500000000000000000000000000000000000
-- 112:0000000000000000000006663000000603000206002020000002000000000000
-- 113:0600000600000000020002000000000003030000000000000303020600000000
-- 114:000000000aa00aa0a99aa99aa999999a0a9999a000a99a00000aa00000000000
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:02000243026302730253f230f240f260f250f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200f200305000000000
-- 001:0100011001500180018001400120f110f190f140f140f150f180f1a0f1b0f1e0f1e0f1a0f140f120f120f170f140f130f100f100f100f100f100f100503000000000
-- 002:03000400060007000800080009000700020000000000010003000600e400f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000000000000000
-- 003:01202164218071be41eb017bf140f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100f100457000000000
-- </SFX>

-- <PALETTE>
-- 000:2d1b2e218a913cc2fa9af6fd4a247c574b67937ac58ae25d8e2b45f04156f272ced3c0a8c5754af2a759f7db53f9f4ea
-- </PALETTE>

