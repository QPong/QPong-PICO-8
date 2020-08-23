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
    gates={
        x = 0,
        y = 1,
        z = 2,
        h = 3
    }
    cursor = 16
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
    and flr(player.y) > court.top + 1 then
        player.y -= player.speed
    end
    if btn(⬇️)
    and flr(player.y) + player.height < court.bottom - 1 then
        player.y += player.speed
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
77777770777777707777777077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70777070707770707000007070777070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77070770770707707777077070777070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77707770777077707770777070000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77070770777077707707777070777070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70777070777077707000007070777070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777770777777707777777077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
