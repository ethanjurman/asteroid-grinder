pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- tiny-fire
objects_init = {}
objects_init.game={}
objects_init.menu={}
objects_init.game_over={}
objects_draw = {}
objects_draw.game={}
objects_draw.menu={}
objects_draw.game_over={}
objects_update = {}
objects_update.game={}
objects_update.menu={}
objects_update.game_over={}
debug=""
frame=0
game_state="menu"

function add_game_loop(obj, state)
 state=state or "game"
 add(objects_init[state], obj)
 add(objects_update[state], obj)
 add(objects_draw[state], obj)
end

function _init()
 score=0
 for obj in all(objects_init[game_state]) do
  obj.init()
 end
end

function _update60()
 frame+=1
	for obj in all(objects_update[game_state]) do
  obj.update()
 end
end

function _draw()
 if (game_state != "game_over") then
  cls() 	
 end
 for obj in all(objects_draw[game_state]) do
 	obj.draw()
 end
 --print(debug,0,20,7)
end
-->8
-- stars

stars={}

function init_stars()
 star_objects={}
	for s=0,50 do
  local star={}
  star.x=rnd(128)
  star.y=rnd(128)
	 add(star_objects, star)
 end
end

function update_stars()
 for s in all(star_objects) do
 	s.y+=2
 	--if (s.x<64) s.x-=0.2
 	--if (s.x>64) s.x+=0.2
 	if (s.y>128) then 
 	 s.y=0-rnd(5)
 	 if (s.x>64) then
 	  s.x=s.x-64
 	 else 
 	  s.x=s.x+64
 	 end
 	end
 end
end

function draw_stars()
	for s in all(star_objects) do
		pset(s.x,s.y,1)
	end
end

stars.init = init_stars
stars.update = update_stars
stars.draw = draw_stars
add_game_loop(stars)
add_game_loop(stars,"menu")

-->8
-- rocks

game_rocks={}

function init_rock(x,y,s,spd)
 local rock={}
 rock.x=x
 rock.y=y
 rock.s=s
 rock.spd=spd
 add(rocks, rock)
end

function init_rocks()
 rocks={}
	for i=0,80 do
	 init_rock(rnd(128),-rnd(1000),rnd(4),1)
 end
end

function update_rocks()
 if game_state=="menu" then
 	rocks={}
 end
	for r in all(rocks) do
		r.y+=r.spd
		if (r.y>130) then
 		respawn_rock(r)
		end
	end
end

function respawn_rock(rock,delay)
 delay=delay or 0
 del(rocks,rock)
	init_rock(rnd(128),-rnd(1000)-delay,rnd(4),rock.spd+0.1)
end

function in_rock(rock,x,y,x2,y2)
 x2=x2 or x
 y2=y2 or y
	if (x2 < rock.x) return false
	if (x > rock.x+8) return false
	if (y2 < rock.y) return false
	if (y > rock.y+8) return false
	return true
end

function draw_rocks()
	for r in all(rocks) do
		spr(16+r.s, r.x, r.y)
	end	
end

game_rocks.init = init_rocks
game_rocks.draw = draw_rocks
game_rocks.update = update_rocks
add_game_loop(game_rocks)

-->8
-- hud
hud={}
cam_shake=0

function init_hud()
	
end

function draw_hud()
 camera(
  rnd()*cam_shake,
  rnd()*cam_shake
 )
 -- hp
 palt(0, false)
 palt(11, true)
 if ship.hp<=0 then
  spr(23,0,0)
  spr(24,8,0)
  spr(25,16,0)
 end
 if ship.hp==1 then
  spr(7,0,0)
  spr(24,8,0)
  spr(25,16,0)
 end
 if ship.hp==2 then
  spr(7,0,0)
  spr(8,8,0)
  spr(25,16,0)
 end
 if ship.hp==3 then
  spr(7,0,0)
  spr(8,8,0)
  spr(9,16,0)
 end
 palt(0, true)
 palt(11, false)
 -- score
 print("score: "..score,0,12,7)
end

function update_hud()
	if (cam_shake>0) cam_shake-=1
end

hud.init = init_hud
hud.draw = draw_hud
hud.update = update_hud
add_game_loop(hud)
-->8
-- music

music_obj={}

function set_speed(sfx, speed)
  poke(0x3200 + 68*sfx + 65, speed)
end

function music_init()
	music(0)
end

function music_update()
	set_speed(3,12+2*ship.hp)
	set_speed(4,12+2*ship.hp)
	if (ship.hp==0) then
		music(-1)
	end
end

function music_draw()
	
end

music_obj.init=music_init
music_obj.update=music_update
music_obj.draw=music_draw
add_game_loop(music_obj,"game")
add_game_loop(music_obj,"menu")
-->8
-- menus

menu={}
st_btn={}
st_btn.x=46
st_btn.y=64

function init_menu()
	
end

function is_bullet_on_btn(b)
 -- start btn
 local width=28
 local height=16
 local x=st_btn.x
 local y=st_btn.y
	if (b.x<x) return false
	if (b.y<y) return false
	if (b.x>x+width) return false
	if (b.y>y+height) return false
	return true
end

function update_menu()
	for b in all(ship.blts) do
	 if is_bullet_on_btn(b) then
	 	game_state="game"
	 	_init()
  end
	end
end

function draw_menu()
 -- tiny fire (dark)
	for i=0,9 do
	 y_shift=sin((frame/2-(i+2))%32/32)*6
	 pal(7,1)
	 spr(32+i,23+i*9,y_shift+20)
	 pal(7,7)
	end
	-- tiny fire (light)
	for i=0,9 do
	 y_shift=sin((frame/2-i)%32/32)*6
	 spr(32+i,23+i*9,y_shift+20)
	end
	-- start game button
	local x=st_btn.x
	local y=st_btn.y
	palt(11,true)
	palt(0, false)
	spr(10, x+0, y+0)
	spr(11, x+8, y+0)
	spr(11, x+12, y+0)
	spr(12, x+20, y+0)
	spr(26, x+0, y+8)
	spr(27, x+8, y+8)
	spr(27, x+12, y+8)
	spr(28, x+20, y+8)
	print("start",x+5,70,7)
	palt(11,false)
	palt(0, true)
end

menu.init=init_menu
menu.update=update_menu
menu.draw=draw_menu
add_game_loop(menu,"menu")
-->8
-- ship

ship={}

function init_ship()
 ship.x=0
 ship.y=0
 ship.s=0
 ship.blts={}
 ship.hp=3
end

function take_damage()
	ship.hp-=1
	cam_shake=30
end

function update_ship()
 -- update ship with mouse
 local goal_delta=abs(mouse.x-ship.x)
 local trans_spd=15
 if (ship.x<mouse.x) then
 	ship.x=ship.x+(goal_delta/trans_spd)
 	ship.s=1
 elseif (ship.x>mouse.x) then
 	ship.x=ship.x-(goal_delta/trans_spd)
 	ship.s=2
 end
 if (goal_delta<4) ship.s=0
 ship.y=110
 
 -- update bullets
 for b in all(ship.blts) do
 	b.x+=b.x_delta
 	b.y-=1
 	if (b.y<0) del(ship.blts, b)
 	for r in all(rocks) do
 	 -- hit rock
 		if (in_rock(r,b.x,b.y)) then
 			del(ship.blts, b)
 			respawn_rock(r)
 			sfx(2)
 			score+=1
			end
		end
 end
 
 -- update hp
 for r in all(rocks) do
 	if in_rock(r, ship.x,ship.y,ship.x+7,ship.y+7) then
 	 take_damage()
 		respawn_rock(r)
 		sfx(2)
		end
 end
end

function fire_bullet()
 local goal_delta=mouse.x-ship.x
 local trans_spd=15
 local bullet_x_shift=(goal_delta/trans_spd)

 local bullet={}
 bullet.x = ship.x+3
 bullet.y = ship.y
 bullet.x_delta = bullet_x_shift
	add(ship.blts, bullet)
end

function draw_ship()
 for b in all(ship.blts) do
 	pset(b.x,b.y,7)
 end
 spr(ship.s+4,ship.x,ship.y)
end

ship.init = init_ship
ship.draw = draw_ship
ship.update = update_ship
ship.fire = fire_bullet
add_game_loop(ship)
add_game_loop(ship,"menu")
-->8
-- mouse

mouse={}
mouse.click=0
mouse.x=0
mouse.y=0
function init_mouse()
	poke(0x5f2d, 1)
end

function update_mouse()
 mouse.x=stat(32)-1
 mouse.y=stat(33)-1
 if stat(34) == 1 and 
    mouse.click != 1 then
  mouse.click=1
  sfx(0)
  ship.fire()
 end
 if stat(34) != 1 then
  mouse.click=stat(34)
 end
end

function draw_mouse()
 if mouse.click==1 then
  spr(3,mouse.x,mouse.y)
 else
  spr(1,mouse.x,mouse.y)
 end
end

mouse.init = init_mouse
mouse.draw = draw_mouse
mouse.update = update_mouse
add_game_loop(mouse)
add_game_loop(mouse,"menu")
-->8
-- game over
game_over={}
game_over_frame=-1

function game_over_init()
 game_over_frame=-1
 elapse=0
end

function game_over_update()
 if game_over_frame>0 then
  elapse=frame-game_over_frame 	
 end
	if ship.hp <= 0 and 
	   cam_shake == 0 and 
	   game_over_frame == -1 then
		game_over_frame=frame
		game_state="game_over"	
		music(-1)
	end
	if elapse > 200 and
	   stat(34) == 1 -- mouse click
	   then
	 elapse=0
	 game_over_frame=-1
	 game_state="menu"
	 _init()
	end
end

function game_over_draw()
	-- game over
	if (game_over_frame>0) then
	 -- border
	 local x=35
	 local y=37
 	palt(11,true)
 	palt(0, false)
	 spr(10, x+0, y+0)
 	spr(11, x+8, y+0)
 	spr(11, x+16, y+0)
 	spr(11, x+24, y+0)
 	spr(11, x+32, y+0)
 	spr(12, x+38, y+0)
 	spr(26, x+0, y+8)
 	spr(27, x+8, y+8)
 	spr(27, x+16, y+8)
 	spr(27, x+24, y+8)
 	spr(27, x+32, y+8)
 	spr(28, x+38, y+8)
 	palt(11,false)
 	palt(0, true)
 	-- string
		local str=""
		if (elapse>10) str=str.."g"
		if (elapse>20) str=str.."a"
		if (elapse>30) str=str.."m"
		if (elapse>40) str=str.."e"
		if (elapse>50) str=str.." "
		if (elapse>50) str=str.."o"
		if (elapse>60) str=str.."v"
		if (elapse>70) str=str.."e"
		if (elapse>80) str=str.."r"
		print(str,40,42,7)
		if (elapse>100) then
		 -- click to coninue string
		 local x=20
		 local y=52
		 palt(11,true)
	 	palt(0, false)
		 spr(10, x+0, y+0)
	 	spr(11, x+8, y+0)
	 	spr(11, x+16, y+0)
	 	spr(11, x+24, y+0)
	 	spr(11, x+32, y+0)
	 	spr(11, x+40, y+0)
	 	spr(11, x+48, y+0)
	 	spr(11, x+56, y+0)
	 	spr(11, x+64, y+0)
	 	spr(12, x+72, y+0)
	 	spr(26, x+0, y+8)
	 	spr(27, x+8, y+8)
	 	spr(27, x+16, y+8)
	 	spr(27, x+24, y+8)
	 	spr(27, x+32, y+8)
	 	spr(27, x+40, y+8)
	 	spr(27, x+48, y+8)
	 	spr(27, x+56, y+8)
	 	spr(27, x+64, y+8)
	 	spr(28, x+72, y+8)
	 	palt(11,false)
	 	palt(0, true)
			local str2=""
			if (elapse>120) str2=str2.."click "
			if (elapse>160) str2=str2.."to "
			if (elapse>180) str2=str2.."continue"
			print(str2,26,58,7)
		end
	end
end

game_over.init = game_over_init
game_over.draw = game_over_update
game_over.update = game_over_draw
add_game_loop(game_over, "game")
add_game_loop(game_over, "game_over")
__gfx__
00000000770770000777000000000000000000000000000000000000b7777777777777777777777bbbbbb77777777777777bbbbb000000000000000000000000
00000000700070007707700000700000000000000000000000000000700000000000000000000007bb77777111111111177777bb000000000000000000000000
00700700000000007000700007770000000700000007000000070000707777700777777007777707b7777110000000000117777b000000000000000000000000
000770007000700077077000007000000077700000d770000077d000707777700777777007777707b7711000000000000001177b000000000000000000000000
00077000770770000777000000000000077777000d67770007776d00700000000000000000000007b7710000000000000000177b000000000000000000000000
00700700000000000000000000000000777777701d67777077776d10b7777777777777777777777b771000000000000000000177000000000000000000000000
00000000000000000000000000000000777777701d67777077776d10bbbbbbbbbbbbbbbbbbbbbbbb771000000000000000000177000000000000000000000000
000000000000000000000000000000000770770001d077000770d100bbbbbbbbbbbbbbbbbbbbbbbb710000000000000000000017000000000000000000000000
07777000077770000077700000777770000000000000000000000000b7777777777777777777777b710000000000000000000017000000000000000000000000
77000770770007700770777007700077000000000000000000000000700000000000000000000007771000000000000000000177000000000000000000000000
70000077700000770700007777700007000000000000000000000000700000000000000000000007771000000000000000000177000000000000000000000000
70000007700000077000000770000007000000000000000000000000700000000000000000000007b7710000000000000000177b000000000000000000000000
70000077700000777000000770000007000000000000000000000000700000000000000000000007b7711000000000000001177b000000000000000000000000
77700070777000707000077777000070000000000000000000000000b7777777777777777777777bb7777110000000000117777b000000000000000000000000
07700770077007707700077007770770000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb77777111111111177777bb000000000000000000000000
00777700007777000777770000077700000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777777777777bbbbb000000000000000000000000
07777777000777000770007707700770000000000777777000077700077777700777777000000000000000000000000000000000000000000000000000000000
77777777007777007777077777700777000000007777777700777700777007777777777700000000000000000000000000000000000000000000000000000000
77777777007777007777077707777770000000007777777000777700770000777770000000000000000000000000000000000000000000000000000000000000
77777770007777007777777700777700000000007770000000777700777007777777770000000000000000000000000000000000000000000000000000000000
00777700007777007777777700777700000000007777770000777700777777707777770000000000000000000000000000000000000000000000000000000000
00777700007777007770777700777700000000007777700000777700777777007770000000000000000000000000000000000000000000000000000000000000
00777700007777007770777700777700000000007770000000777700777077707777777700000000000000000000000000000000000000000000000000000000
00777000007770007770077000777700000000000770000000777000077007770777770000000000000000000000000000000000000000000000000000000000
__sfx__
910100001d4501b4501a4500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
91010000154501a450194500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7b0100000c6500e650106500c65000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a910000018125000050000500005181251a125181251f125181250000500005000051f1251c125000051f125181250000500005000051a1251c125181251a1251f1250000500005000051c1251a1250000500000
001000080e553000030e0530e0530000311053000030c053000030000200002000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 03044344

