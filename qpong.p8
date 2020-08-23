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
	court_top = 0
	court_bottom = 80
	--court center line
	line_x = 63
	line_y = 0
	line_length = 1.5
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
	line_y = 0 --reset

    --ball
    rectfill(
        ball.x,
        ball.y,
        ball.x + ball.width,
        ball.y + ball.width,
        ball.color
    )

    --player
    rectfill(
        player.x,
        player.y,
        player.x + player.width,
        player.y + player.height,
        player.color
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

function _update60()
    --player controls
    if btn(⬆️)
    and flr(player.y) > court_top + 1 then
        player.y -= player.speed
    end
    if btn(⬇️)
    and flr(player.y) + player.height < court_bottom - 1 then
        player.y += player.speed
    end

    --computer controls
    mid_com = com.y + (com.height/2)

    if ball.dx<0 then
        if mid_com > ball.y
        and com.y>court_top+1 then
            com.y-=com.speed
        end
        if mid_com < ball.y
        and com.y + com.height < court_bottom - 1 then
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

    --collide with player
    if ball.dx > 0
    and ball.x >= player.x
    and ball.x <= player.x + player.width
    and ball.y >= player.y
    and ball.y + ball.width <= player.y + player.height
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
    if ball.y + ball.width >= court_bottom - 1
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
77777770777777707777777077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70777070707770707000007070777070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77070770770707707777077070777070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77707770777077707770777070000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77070770777077707707777070777070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70777070777077707000007070777070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777770777777707777777077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
