require 'ruby2d'

require_relative './vector2'

class CONSTANTS
  HEIGHT = 375
  WIDTH = 1.6180339887 * HEIGHT

  PADDLE_SPEED = 5
  PADDLE_WIDTH = 15
  PADDLE_HEIGHT = 75

  BALL_SPEED = 3
  BALL_RADIUS = 8
end

set width: CONSTANTS::WIDTH, height: CONSTANTS::HEIGHT

def clamp(x, min_val, max_val)
  [min_val, [x, max_val].min].max
end

class Paddle < Rectangle
  def initialize(x, y)
    super(x: x, y: y, width: CONSTANTS::PADDLE_WIDTH, height: CONSTANTS::PADDLE_HEIGHT)
  end

  def constraint_y(y)
    clamp(y, 0, CONSTANTS::HEIGHT - CONSTANTS::PADDLE_HEIGHT)
  end

  def up
    self.y = constraint_y(self.y - CONSTANTS::PADDLE_SPEED)
  end

  def down
    self.y = constraint_y(self.y + CONSTANTS::PADDLE_SPEED)
  end
end

SPACING = 35

left_paddle = Paddle.new(SPACING, CONSTANTS::HEIGHT/2 - CONSTANTS::PADDLE_HEIGHT/2)
right_paddle = Paddle.new(CONSTANTS::WIDTH - SPACING - CONSTANTS::PADDLE_WIDTH, CONSTANTS::HEIGHT/2 - CONSTANTS::PADDLE_HEIGHT/2)

$paddles = [left_paddle, right_paddle]

class Ball < Circle
  def initialize(x, y)
    super(x: x, y: y, radius: CONSTANTS::BALL_RADIUS, sectors: 20)

    @origin = Vector2.new(x, y)
  end

  def spawn
    @direction = Vector2.new(
      [-1, 1].sample,
      [-1, 1].sample
    )

    self.x = @origin.x
    self.y = @origin.y
  end

  def bounce_x
    @direction.x = -@direction.x
  end

  def bounce_y
    @direction.y = -@direction.y
  end

  def collides?(ball, paddle)
    closest_x = ball.x.clamp(paddle.x, paddle.x + paddle.width)
    closest_y = ball.y.clamp(paddle.y, paddle.y + paddle.height)

    distance_x = ball.x - closest_x
    distance_y = ball.y - closest_y

    distance = Math.sqrt(distance_x**2 + distance_y**2)

    return distance < ball.radius
  end

  def move
    self.x += @direction.x * CONSTANTS::BALL_SPEED

    next_y = self.y + @direction.y * CONSTANTS::BALL_SPEED
    clamped_y = clamp(next_y, 0 + CONSTANTS::BALL_RADIUS, CONSTANTS::HEIGHT - CONSTANTS::BALL_RADIUS)

    if next_y == clamped_y
      self.y = next_y
    else
      bounce_y
    end

    $paddles.each do |paddle|
      if collides?(self, paddle)
        bounce_x
      end
    end

  end

  def get_x
    return self.x
  end
end

$ball = Ball.new(CONSTANTS::WIDTH/2, CONSTANTS::HEIGHT/2)
$ball.spawn

on :key_held do |event|
  case event.key
  when 'w'
    left_paddle.up
  when 's'
    left_paddle.down
  when 'i', 'up'
    right_paddle.up
  when 'k', 'down'
    right_paddle.down
  end
end

$player_1_score = Text.new('0', size: 25, y: 5, style: 'bold', z: 10)
$player_1_score.x = 10
$player_1_score.add

$player_2_score = Text.new('0', size: 25, y: 5, style: 'bold', z: 10)
$player_2_score.x = CONSTANTS::WIDTH - $player_2_score.width - 10
$player_2_score.add

$player_1_wins = 0
$player_2_wins = 0

def check_winner
  if $ball.get_x < 0
    $ball.spawn
    $player_2_wins += 1
    $player_2_score.text = "#$player_2_wins"
  elsif $ball.get_x > CONSTANTS::WIDTH
    $ball.spawn
    $player_1_wins += 1
    $player_1_score.text = "#$player_1_wins"
  end
end

# Draw middle line
Line.new(
  x1: CONSTANTS::WIDTH/2, y1: 0,
  x2: CONSTANTS::WIDTH/2, y2: CONSTANTS::HEIGHT,
  width: 2,
  color: 'white',
)

update do
  $ball.move

  check_winner
end

show
