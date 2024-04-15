class Vector2
  attr_accessor :x, :y

  def initialize(x=0, y=0)
      @x = x
      @y = y
  end

  def +(other)
    Vector2.new(@x + other.x, @y + other.y)
  end

  def add(other)
    @x += other.x
    @y += other.y
    self
  end

  def -(other)
    Vector2.new(@x - other.x, @y - other.y)
  end

  def subtract(other)
    @x -= other.x
    @y -= other.y
    self
  end

  def scale!(scalar)
    @x *= scalar
    @y *= scalar
    self
  end

  def to_s
    "Vector2(#@x, #@y)"
  end

  def clone
    Vector2.new(@x, @y)
  end
end
