pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- QPong
-- by Junye Huang

player_points = 0
com_points = 0
scored = ""

function _init()
    --variables
    player={
        x = 8,
        y = 63,
        c = 12,
        w = 2,
        h = 10,
        speed = 1
    }
    com={
        x = 117,
        y = 63,
        c = 8,
        w = 2,
        h = 10,
        speed = 0.75
    }
    ball={
        x = 63,
        y = 63,
        c = 7,
        w = 2,
        dx = 0.6,
        dy = flr(rnd(2))-0.5,
        speed = 1,
        speedup = 0.05
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
	court_left = 0
	court_right = 127
	court_top = 10
	court_bottom = 127
	--court center line
	line_x = 63
	line_y = 10
	line_length = 4
end

function _draw()
    cls()

    --court
    rect(court_left,court_top,court_right,court_bottom,5)

	--dashed center line
	repeat
		line(line_x,line_y,line_x,line_y+line_length,5)
		line_y += line_length*2
	until line_y > court_bottom
	line_y = 10 --reset

    --ball
    rectfill(
        ball.x,
        ball.y,
        ball.x + ball.w,
        ball.y + ball.w,
        ball.c
    )

    --player
    rectfill(
        player.x,
        player.y,
        player.x + player.w,
        player.y + player.h,
        player.c
    )

    --computer
    rectfill(
        com.x,
        com.y,
        com.x + com.w,
        com.y + com.h,
        com.c
    )

    --scores
    print(player_points,30,2,player.c)
    print(com_points,95,2,com.c)

end

function _update60()
    --player controls
    if btn(⬆️)
    and flr(player.y) > court_top + 1 then
        player.y -= player.speed
    end
    if btn(⬇️)
    and flr(player.y) + player.h < court_bottom - 1 then
        player.y += player.speed
    end

    --computer controls
    mid_com = com.y + (com.h/2)

    if ball.dx>0 then
        if mid_com > ball.y
        and com.y>court_top+1 then
            com.y-=com.speed
        end
        if mid_com < ball.y
        and com.y + com.h < court_bottom - 1 then
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
    if ball.dx > 0
    and ball.x + ball.w >= com.x
    and ball.x + ball.w <= com.x + com.w
    and ball.y >= com.y
    and ball.y + ball.w <= com.y + com.h
    then
        ball.dx = -(ball.dx + ball.speedup)
        sfx(0)
    end

    --collide with player
    if ball.dx < 0
    and ball.x >= player.x
    and ball.x <= player.x + player.w
    and ball.y >= player.y
    and ball.y + ball.w <= player.y + player.h
    then
        --control ball DY if hit and press up or down
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
        --flip ball DX and add speed
        ball.dx = -(ball.dx - ball.speedup)
        sfx(1)
    end

    --collide with court
    if ball.y + ball.w >= court_bottom - 1
    or ball.y <= court_top+1 then
        ball.dy = -ball.dy
        sfx(2)
    end

    --score
    if ball.x > court_right then
        player_points += 1
        scored = "player"
        _init() --reset game
    end
    if ball.x < court_left then
        com_points += 1
        scored = "com"
        _init() --reset game
    end

    --ball movement
    ball.x += ball.dx
    ball.y += ball.dy
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
