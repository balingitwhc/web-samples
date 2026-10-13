--Libraries
local utils = require("utils")

-- Initialize Data
function love.load()

    love.window.setMode(640, 480)
    love.window.setTitle("Block Invaders")

    -- Initialize Player
    player1 = {
        x = love.graphics.getWidth() * 0.33 - 20,
        y = love.graphics.getHeight() - 60,
        width = 40,
        height = 40,
        speed = 500,
        lives = 3
    }

    player2 = {
        x = love.graphics.getWidth() * 0.66 + 20,
        y = love.graphics.getHeight() - 60,
        width = 40,
        height = 40,
        speed = 500,
        lives = 3
    }

    playerCount = player1.lives + player2.lives

    -- Initialize Bullets
    p1bulletWidth = 10
    p1bulletHeight = 10
    p1bullets = {}
    p1canShoot = true
    p1bulletSpeed = 500
    p1bulletTimerMax = 0.5
    p1bulletTimer = p1bulletTimerMax

    p2bulletWidth = 10
    p2bulletHeight = 10
    p2bullets = {}
    p2canShoot = true
    p2bulletSpeed = 500
    p2bulletTimerMax = 0.5
    p2bulletTimer = p2bulletTimerMax

    -- Initialize Enemies
    enemyWidth = 40
    enemyHeight = 40
    enemyRows = 3
    enemyColumns = 7
    totalEnemies = enemyRows * enemyColumns

    enemies = {}
    for i = 1, enemyRows do
        for j = 1, enemyColumns do
          local enemy = {
            x = (j - 1) * (enemyWidth + 20) + 20,
            y = (i - 1) * (enemyHeight + 20) + 20,
            width = enemyWidth,
            height = enemyHeight,
            speed = 50
          }
          table.insert(enemies, enemy)
        end
    end

    -- Initalize Enemy Bullets
    enemyBulletWidth = 10
    enemyBulletHeight = 10
    enemyBullets = {}
    enemyBulletSpeed = 300
    enemyBulletTimerMax = 1.5 -- set the maximum interval between enemy shots
    enemyBulletTimer = enemyBulletTimerMax -- initialize the timer

    -- Initialize Sound Effects

    mainVolume = 0.1

    pShotSound = love.audio.newSource("shoot.wav", "static")
    pShotSound:setVolume(mainVolume)

    eShotSound = love.audio.newSource("eshoot.wav", "static")
    eShotSound:setVolume(mainVolume)

    pHitSound = love.audio.newSource("explosion.wav", "static")
    pHitSound:setVolume(mainVolume)

    eHitSound = love.audio.newSource("invaderkilled.wav", "static")
    eHitSound:setVolume(mainVolume)

    gameoverSound = love.audio.newSource("gameover.wav", "static")
    gameoverSound:setVolume(mainVolume)

    bgSound = love.audio.newSource("spaceinvaders1.wav", "stream")
    bgSound:setVolume(mainVolume)
    

    
end --love.load

-- =============================================================================================================================

-- Screen Updates
function love.update(dt) -- delta time
    love.audio.play(bgSound)
    -- Player Movement Left / Right
    if love.keyboard.isDown("a")
        then player1.x = player1.x - player1.speed * dt
    elseif love.keyboard.isDown("d")
        then player1.x = player1.x + player1.speed * dt
    end

    if love.keyboard.isDown("left")
        then player2.x = player2.x - player2.speed * dt
    elseif love.keyboard.isDown("right")
        then player2.x = player2.x + player2.speed * dt
    end

    -- Player Stop at walls of the screen
    if player1.x < 20
        then player1.x = 20
    elseif player1.x > love.graphics.getWidth() - player1.width - 20
        then player1.x = love.graphics.getWidth() - player1.width - 20
    end

    if player2.x < 20
        then player2.x = 20
    elseif player2.x > love.graphics.getWidth() - player2.width - 20
        then player2.x = love.graphics.getWidth() - player2.width - 20
    end

    -- Bullet Creation and Movement
    p1bulletTimer = p1bulletTimer - dt
    if player1.lives > 0 and p1bulletTimer < 0 then
      p1canShoot = true
    end

    p2bulletTimer = p2bulletTimer - dt
    if player2.lives > 0 and p2bulletTimer < 0 then
      p2canShoot = true
    end
    
    for i, p1bullet in ipairs(p1bullets) do
      p1bullet.y = p1bullet.y - p1bulletSpeed * dt
      if p1bullet.y < 0 then
        table.remove(p1bullets, i)
      end
    end

    for i, p2bullet in ipairs(p2bullets) do
      p2bullet.y = p2bullet.y - p2bulletSpeed * dt
      if p2bullet.y < 0 then
        table.remove(p2bullets, i)
      end
    end

    if love.keyboard.isDown("w") and p1canShoot then
        local newBullet = {
          x = player1.x + player1.width / 2 - p1bulletWidth / 2,
          y = player1.y,
          width = p1bulletWidth,
          height = p1bulletHeight,
          speed = p1bulletSpeed
        }
        table.insert(p1bullets, newBullet)
        p1canShoot = false
        p1bulletTimer = p1bulletTimerMax
        love.audio.play(pShotSound)
    end

    if love.keyboard.isDown("up") and p2canShoot then
        local newBullet = {
          x = player2.x + player2.width / 2 - p2bulletWidth / 2,
          y = player2.y,
          width = p2bulletWidth,
          height = p2bulletHeight,
          speed = p2bulletSpeed
        }
        table.insert(p2bullets, newBullet)
        p2canShoot = false
        p2bulletTimer = p2bulletTimerMax
        love.audio.play(pShotSound)
    end

    -- Enemy Movement
    local hitEdge = false
    for i, enemy in ipairs(enemies) do
      enemy.x = enemy.x + enemy.speed * dt
      if enemy.x < 20 or enemy.x + enemy.width > love.graphics.getWidth() - 20 then
      hitEdge = true
      break
      end
    end

    if hitEdge then
      for _, enemy in ipairs(enemies) do
      enemy.speed = -enemy.speed
      enemy.y = enemy.y + enemy.height / 2
      end
    end

    -- Collision Detection
    for i, p1bullet in ipairs(p1bullets) do
        for j, enemy in ipairs(enemies) do
            if utils.CheckCollision(p1bullet.x, p1bullet.y, p1bullet.width, p1bullet.height, enemy.x, enemy.y, enemy.width, enemy.height) then
                table.remove(p1bullets, i)
                table.remove(enemies, j)
                totalEnemies = totalEnemies - 1
                love.audio.play(eHitSound)
            end
        end
    end

    for i, p2bullet in ipairs(p2bullets) do
      for j, enemy in ipairs(enemies) do
          if utils.CheckCollision(p2bullet.x, p2bullet.y, p2bullet.width, p2bullet.height, enemy.x, enemy.y, enemy.width, enemy.height) then
              table.remove(p2bullets, i)
              table.remove(enemies, j)
              totalEnemies = totalEnemies - 1
              love.audio.play(eHitSound)
          end
      end
    end

    -- ENEMY BULLETS
    -- Update the enemy bullet timer
    enemyBulletTimer = enemyBulletTimer - dt

    -- Check if it's time for an enemy to shoot
    if enemyBulletTimer < 0 and #enemies > 0 then
      -- Choose a random enemy to shoot
      local randomEnemyIndex = love.math.random(1, #enemies)
      local randomEnemy = enemies[randomEnemyIndex]

      -- Create a new bullet fired by the random enemy
      local newEnemyBullet = {
        x = randomEnemy.x + randomEnemy.width / 2 - enemyBulletWidth / 2,
        y = randomEnemy.y + randomEnemy.height,
        width = enemyBulletWidth,
        height = enemyBulletHeight,
        speed = enemyBulletSpeed
      }
      table.insert(enemyBullets, newEnemyBullet)
      love.audio.play(eShotSound)

      -- Reset the enemy bullet timer
      enemyBulletTimer = enemyBulletTimerMax
    end

    -- Update the enemy bullet positions
    for i, enemyBullet in ipairs(enemyBullets) do
      enemyBullet.y = enemyBullet.y + enemyBullet.speed * dt
      if enemyBullet.y > love.graphics.getHeight() then
        table.remove(enemyBullets, i)
      end
    end

    -- Check for collisions between enemy bullets and the Player
    for i, enemyBullet in ipairs(enemyBullets) do
      if utils.CheckCollision(enemyBullet.x, enemyBullet.y, enemyBullet.width, enemyBullet.height, player1.x, player1.y, player1.width, player1.height) then
        -- Player 1 is hit by an enemy bullet
          player1.lives = player1.lives - 1
          playerCount = playerCount - 1
          table.remove(enemyBullets, i)
          love.audio.play(pHitSound)
      end

      if utils.CheckCollision(enemyBullet.x, enemyBullet.y, enemyBullet.width, enemyBullet.height, player2.x, player2.y, player2.width, player2.height) then
        -- Player 2 is hit by an enemy bullet
          player2.lives = player2.lives - 1
          playerCount = playerCount - 1
          table.remove(enemyBullets, i)
          love.audio.play(pHitSound)
      end
    end

end -- love.update

-- =============================================================================================================================

-- Draw the Objects
function love.draw()
    -- Draw the Players
    if player1.lives > 0 then
      love.graphics.setColor(0, 255, 255)
      love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)
      love.graphics.print("P1 Lives = ", 20, love.graphics.getHeight() -40)
      love.graphics.print(player1.lives, 90, love.graphics.getHeight() -40)
    end
    if player2.lives > 0 then
      love.graphics.setColor(255, 0, 255)
      love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)
      love.graphics.print("P2 Lives = ", 20, love.graphics.getHeight() -20)
      love.graphics.print(player2.lives, 90, love.graphics.getHeight() -20)
    end

    love.graphics.setColor(255, 255, 255)

    -- Draw the Bullets
    for i, p1bullet in ipairs(p1bullets) do
      love.graphics.setColor(0, 255, 255)
        love.graphics.rectangle("fill", p1bullet.x, p1bullet.y, p1bulletWidth, p1bulletHeight)
        love.graphics.setColor(255, 255, 255)
    end

    for i, p2bullet in ipairs(p2bullets) do
      love.graphics.setColor(255, 0, 255)
      love.graphics.rectangle("fill", p2bullet.x, p2bullet.y, p2bulletWidth, p2bulletHeight)
      love.graphics.setColor(255, 255, 255)
    end

    -- Draw the enemies
    for i, enemy in ipairs(enemies) do
        if playerCount == -1
          then love.graphics.setColor(0, 0, 0)
        end
        love.graphics.rectangle("fill", enemy.x, enemy.y, enemyWidth, enemyHeight)
    end

    -- Enemy Bullets
    for i, enemyBullet in ipairs(enemyBullets) do
      love.graphics.rectangle("fill", enemyBullet.x, enemyBullet.y, enemyBullet.width, enemyBullet.height)
    end

    if totalEnemies == 0 then
        love.graphics.print("PLAYERS WIN!", love.graphics.getWidth()/2 - 40, love.graphics.getHeight()/2 - 40)
    end

    if player1.lives == 0 then
      player1.y = -1000
      p1canShoot = false
    end
    if player2.lives == 0 then
      player2.y = -1000
      p2canShoot = false
    end

    if playerCount == 0 then
      love.audio.play(gameoverSound)
      playerCount = -1
    elseif playerCount == -1 then
      love.audio.setVolume(mainVolume)
      love.graphics.setColor(255, 0, 0)
      love.graphics.setFont(love.graphics.newFont(24))
      love.graphics.print("GAME OVER!", love.graphics.getWidth()/2 - 70, love.graphics.getHeight()/2 - 40)
      love.graphics.setFont(love.graphics.newFont(12))
    end
end -- love.draw

-- Other Keypress Handlers
function love.keypressed(key)
  if playerCount == -1 and key == "r" then -- Reset the game when the 'r' key is pressed
      utils.resetGame()
  end
end