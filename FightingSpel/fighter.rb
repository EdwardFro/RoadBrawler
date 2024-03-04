require 'ruby2d'

set title: "Road Brawler", width: 1000, height: 450

#Backgrund
background = Image.new('sprites\stage1.jpg', width: 1000, height: 450)

#Data för Player 1 med spritesheet och animationer kopplade till olika inputs
player1 = Sprite.new(
  'sprites\player1\ryuFinal2.png',
  x: 200, y: 130,
  width: 270, height: 270,
  clip_width: 114,
  time: 200,
  animations: {
    stand: 0..2,
    walk: 5..7,
    back: 8..10,
    crouch: 11..11,
    guard: 12..12,
    punch: 27..28,
    kick: 24..26,
    hdkn: 14..17,
    ttsmki: 19..23,
    hurt: 13..13,
    win: 29..30,
    lose: 31..32,
  }
)

#Data för Player 2 med sprites och animationer för olika inputs
player2 = Sprite.new(
  'sprites\player2\kenSprites.png',
  x: 800, y: 130,
  width: -270, height: 270,
  clip_width: 114,
  time: 200,
  animations: {
    stand: 0..2,
    walk: 4..6,
    back: 7..9,
    crouch: 10..10,
    guard: 11..11,
    punch: 26..27,
    kick: 23..25,
    hdkn: 13..16,
    ttsmki: 18..22,
    hurt: 12..12,
    win: 28..29,
    lose: 30..31,
  }
)


#Healthbar UI
Rectangle.new(x: 30, y: 25, width: 410, height: 25, color: 'white')
Rectangle.new(x: 32.5, y: 27.5, width: 405, height: 20, color: 'gray')
Rectangle.new(x: 970, y: 25, width: -410, height: 25, color: 'white')
Rectangle.new(x: 967.5, y: 27.5, width: -405, height: 20, color: 'gray')

#Healthbars
player1_health = Rectangle.new(x: 32.5, y: 27.5, width: 405, height: 20, color: 'yellow')
player2_health = Rectangle.new(x: 967.5, y: 27.5, width: -405, height: 20, color: 'yellow')

#Skapar en array där inputs sparas
keys_pressed = []
current_animation_player1 = nil #startar tom för player 1
current_animation_player2 = nil #startar tom för player 2

#Definerar ien kalss för Hadoken
class Hadoken
  attr_reader :sprite, :direction

  #Data för Hadoken, likt spelarna
  def initialize(image_path, x, y, speed, direction)
    @sprite = Sprite.new(
      image_path,
      x: x, y: 240,
      width: 70, height: 70
    )
    @speed = speed
    @direction = direction
  end

  #Anger hur HAdoken ska röra sig för vardera spelare
  def move
    if @direction == :right
      @sprite.x += @speed
    elsif @direction == :left
      @sprite.x -= @speed
    end
  end
end

#Skapar en array för hadokens frambringas
hadokens = []

#Hanterar inputs och hur de ska bete sig
on :key do |event|
  case event.type
  when :down
    keys_pressed << event.key
    case event.key
    when 'c'
      #Hadoken skapas för player 1
      hadokens << Hadoken.new('sprites\player1\hdkn1.png', player1.x+140, player1.y, 2, :right)
      player1.play animation: :hdkn
    when 'm'
      #Hadoken skapas för player 2
      hadokens << Hadoken.new('sprites\player2\hdkn2.png', player2.x-190, player2.y, 2, :left)
      player2.play animation: :hdkn
    end
  when :up
    keys_pressed.delete(event.key)
  end

  # Player 1s kontroller
  case event.key
  when 'a' #Gå bakåt
    player1.x -= 3 unless keys_pressed.include?('s') || keys_pressed.include?('d') || keys_pressed.include?('w') #Villkor för när detta ska hända
    player1.play animation: :back #Vilken animation som ska spelas
    current_animation_player1 = :back #Nuvaranda animation sparas som varabel
  when 'd'
    #Gå framåt
    player1.x += 3.5 unless keys_pressed.include?('a') || keys_pressed.include?('s') || keys_pressed.include?('w')
    player1.play animation: :walk 
    current_animation_player1 = :walk
  when 's'
    #Ducka
    player1.play animation: :crouch
    current_animation_player1 = :crouch
  when 'w'
    #Slå
    player1.play animation: :punch
    current_animation_player1 = :punch
  when 'f'
    #Sparka
    player1.play animation: :kick
    current_animation_player1 = :kick
  when 'x'
    #Tatsumaki (Hurricane kick)
    player1.play animation: :ttsmki
    player1.x += 4.5
    current_animation_player1 = :ttsmki
  end

  # Player 2 kontroller, likande villkor som till player 1
  case event.key
  when 'j'
    player2.x -= 3.5 unless keys_pressed.include?('k') || keys_pressed.include?('l') || keys_pressed.include?('i') 
    player2.play animation: :walk 
    current_animation_player2 = :walk
  when 'l'
    player2.x += 3 unless keys_pressed.include?('j') || keys_pressed.include?('k') || keys_pressed.include?('i')
    player2.play animation: :back
    current_animation_player2 = :back
  when 'k'
    player2.play animation: :crouch
    current_animation_player2 = :crouch
  when 'i'
    player2.play animation: :punch
    current_animation_player2 = :punch
  when 'h'
    player2.play animation: :kick
    current_animation_player2 = :kick
  when 'n'
    player2.play animation: :ttsmki
    player2.x -= 4.5
    current_animation_player2 = :ttsmki
  end
end

update do #En update-loop 
  hadokens.each do |obj|
    obj.move
  end

  #Kontrollerar om hadoken rör vid en spelare
  hadokens.each do |hadoken|
    if hadoken.sprite.x + hadoken.sprite.width == player2.x-70 && hadoken.direction == :right
      #När Hadoken träffar player 2
      player2.play animation: :hurt
      current_animation_player2 = :hurt
      player2_health.width += 25 #Player 2 tar skada
      hadokens.delete(hadoken)
      break
    elsif hadoken.sprite.x + hadoken.sprite.width == player1.x+140 && hadoken.direction == :left
      #När Hadoken träffar player 1
      player1.play animation: :hurt
      current_animation_player1 = :hurt
      player1_health.width -= 25 #PLayer 1 tar skada
      hadokens.delete(hadoken)
      break
    end
  end

  overlap = 25 #Variabel som reglerar hur mycket spelarna kan gå in i varandra

  #Mer kontroller för player 1 och player 2
  if keys_pressed.empty? #Om inget är nedtryckt
    player1.play(animation: :stand)
    player2.play(animation: :stand)
    current_animation_player1 = :stand
    current_animation_player2 = :stand
  end

  if keys_pressed.include?('a') && keys_pressed.include?('s')
    player1.play animation: :guard #blockera
    current_animation_player1 = :guard
  end

  if keys_pressed.include?('k') && keys_pressed.include?('l')
    player2.play animation: :guard
    current_animation_player2 = :guard
  end

  if keys_pressed.include?('a') && keys_pressed.include?('d')
    player1.x -= 0
  end

  if (player2.x <= player1.x + player1.width + overlap) #Kollar om spelarna är tillräckligt nära varandra
    if current_animation_player1 == :guard || current_animation_player2 == :guard #Om någon blockerar tar de inte skada
      player2.x += 2
      player1.x -= 2
    elsif current_animation_player1 == :punch || current_animation_player1 == :ttsmki || current_animation_player1 == :kick #Om player 2 inte blockerar tar man skada från dessa attacker
      player2.play animation: :hurt
      current_animation_player2 = :hurt
      player2_health.width += 10 #Player 2 tar skada
      if player2_health.width > 0 #Ser till att heatlhbaren inte går bakåt
        player2_health.width = 0
      end
    elsif current_animation_player2 == :punch || current_animation_player2 == :ttsmki || current_animation_player2 == :kick #likande kod för player 1
      player1.play animation: :hurt
      current_animation_player1 = :hurt
      player1_health.width -= 10 #Player 1 tar skada
      if player1_health.width < 0
        player1_health.width = 0
      end
    else
      player1.x -= 4
      player2.x += 4
    end
  end

  #reglerar så att spelarna inte går förbi varandra
  if player1.x + player1.width >= player2.x
    player1.x = player2.x - player1.width
  elsif player2.x <= player1.x + player1.width
    player2.x = player1.x + player1.width
  end

  #Ser till att Player 1 inte går utanför skärmen
  if player1.x <= 0
    player1.x = 0
  end

  #Ser till att player 2 inyte går utanför skärmen
  if player2.x > 1000
    player2.x = 1000
  end

  #Kollar vem som vinner och vem som förlorar
  if player1_health.width == 0
    player1.play(animation: :lose)
    player2.play(animation: :win)
    Text.new('Player 2 Wins!', x: 400, y: 100, size: 40, color: 'white')
  elsif player2_health.width == 0
    player1.play(animation: :win)
    player2.play(animation: :lose)
    Text.new('Player 1 Wins!', x: 400, y: 100, size: 40, color: 'white')
  end

end

show