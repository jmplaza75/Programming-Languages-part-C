class GeometryExpression  
  Epsilon = 0.00001
end

class GeometryValue
  private
  def real_close(r1, r2)
    (r1 - r2).abs < GeometryExpression::Epsilon
  end
  
  def real_close_point(x1, y1, x2, y2)
    real_close(x1, x2) && real_close(y1, y2)
  end
  
  def two_points_to_line(x1, y1, x2, y2)
    if real_close(x1, x2)
      VerticalLine.new(x1)
    else
      m = (y2 - y1).to_f / (x2 - x1)
      b = y1 - m * x1
      Line.new(m, b)
    end
  end
  
  public
  def intersectNoPoints(np)
    np
  end
  
  def intersectLineSegment(seg)
    line_result = intersect(two_points_to_line(seg.x1, seg.y1, seg.x2, seg.y2))
    line_result.intersectWithSegmentAsLineResult(seg)
  end
end

class NoPoints < GeometryValue
  def eval_prog(env)
    self
  end
  
  def preprocess_prog
    self
  end
  
  def shift(dx, dy)
    self
  end
  
  def intersect(other)
    other.intersectNoPoints(self)
  end
  
  def intersectPoint(p)
    self
  end
  
  def intersectLine(line)
    self
  end
  
  def intersectVerticalLine(vline)
    self
  end
  
  def intersectWithSegmentAsLineResult(seg)
    self
  end
end



class Point < GeometryValue
  attr_reader :x, :y
  
  def initialize(x, y)
    @x = x
    @y = y
  end
  
  def preprocess_prog
    self
  end
  
  def eval_prog(env)
    self
  end
  
  def shift(dx, dy)
    Point.new(@x + dx, @y + dy)
  end
  
  def intersect(other)
    other.intersectPoint(self)
  end
  
  def intersectPoint(p)
    if real_close_point(@x, @y, p.x, p.y)
      self
    else
      NoPoints.new
    end
  end
  
  def intersectLine(line)
    if real_close(@y, line.m * @x + line.b)
      self
    else
      NoPoints.new
    end
  end
  
  def intersectVerticalLine(vline)
    if real_close(@x, vline.x)
      self
    else
      NoPoints.new
    end
  end
  
  def intersectWithSegmentAsLineResult(seg)
    if inbetween(@x, seg.x1, seg.x2) && inbetween(@y, seg.y1, seg.y2)
      self
    else
      NoPoints.new
    end
  end
  
  private
  
  def inbetween(v, end1, end2)
    ((end1 - GeometryExpression::Epsilon <= v && v <= end2 + GeometryExpression::Epsilon) ||
     (end2 - GeometryExpression::Epsilon <= v && v <= end1 + GeometryExpression::Epsilon))
  end
end


class Line < GeometryValue
  attr_reader :m, :b
  
  def initialize(m, b)
    @m = m
    @b = b
  end
  
  def preprocess_prog
    self
  end
  
  def eval_prog(env)
    self
  end
  
  def shift(dx, dy)
    Line.new(@m, @b + dy - @m * dx)
  end
  
  def intersect(other)
    other.intersectLine(self)
  end
  
  def intersectPoint(p)
    p.intersectLine(self)
  end
  
  def intersectLine(line)
    if real_close(@m, line.m)
      if real_close(@b, line.b)
        self
      else
        NoPoints.new
      end
    else
      x = (line.b - @b) / (@m - line.m)
      y = @m * x + @b
      Point.new(x, y)
    end
  end
  
  def intersectVerticalLine(vline)
    Point.new(vline.x, @m * vline.x + @b)
  end
  
  def intersectWithSegmentAsLineResult(seg)
    seg
  end
end


class VerticalLine < GeometryValue
  attr_reader :x
  
  def initialize(x)
    @x = x
  end
  
  def preprocess_prog
    self
  end
  
  def eval_prog(env)
    self
  end
  
  def shift(dx, dy)
    VerticalLine.new(@x + dx)
  end
  
  def intersect(other)
    other.intersectVerticalLine(self)
  end
  
  def intersectPoint(p)
    p.intersectVerticalLine(self)
  end
  
  def intersectLine(line)
    line.intersectVerticalLine(self)
  end
  
  def intersectVerticalLine(vline)
    if real_close(@x, vline.x)
      self
    else
      NoPoints.new
    end
  end
  
  def intersectWithSegmentAsLineResult(seg)
    seg
  end
end


class LineSegment < GeometryValue
  attr_reader :x1, :y1, :x2, :y2
  
  def initialize(x1, y1, x2, y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
  end
  
  def preprocess_prog
    if real_close_point(@x1, @y1, @x2, @y2)
      Point.new(@x1, @y1)
    elsif (@x1 > @x2) || (real_close(@x1, @x2) && (@y1 > @y2))
      LineSegment.new(@x2, @y2, @x1, @y1)
    else
      self
    end
  end
  
  def eval_prog(env)
    self
  end
  
  def shift(dx, dy)
    LineSegment.new(@x1 + dx, @y1 + dy, @x2 + dx, @y2 + dy)
  end
  
  def intersect(other)
    other.intersectLineSegment(self)
  end
  
  def intersectPoint(p)
    p.intersectLineSegment(self)
  end
  
  def intersectLine(line)
    line.intersectLineSegment(self)
  end
  
  def intersectVerticalLine(vline)
    vline.intersectLineSegment(self)
  end
  
  def intersectWithSegmentAsLineResult(seg)
    if real_close(@x1, @x2)
      aYstart, aYend = [@y1, @y2].minmax
      bYstart, bYend = [seg.y1, seg.y2].minmax
      aXstart, aXend = @x1, @x2
      bXstart, bXend = seg.x1, seg.x2
    else
      aXstart, aXend = [@x1, @x2].minmax
      bXstart, bXend = [seg.x1, seg.x2].minmax
      aYstart, aYend = @y1, @y2
      bYstart, bYend = seg.y1, seg.y2
    end
    
    if aXend < bXstart || bXend < aXstart || aYend < bYstart || bYend < aYstart
      NoPoints.new
    else
      new_x1, new_y1 = [aXstart, bXstart].max, [aYstart, bYstart].max
      new_x2, new_y2 = [aXend, bXend].min, [aYend, bYend].min
      if real_close(new_x1, new_x2) && real_close(new_y1, new_y2)
        Point.new(new_x1, new_y1)
      else
        LineSegment.new(new_x1, new_y1, new_x2, new_y2)
      end
    end
  end
end




# Note: there is no need for getter methods for the non-value classes

class Intersect < GeometryExpression
  def initialize(e1, e2)
    @e1 = e1
    @e2 = e2
  end
  
  def preprocess_prog
    Intersect.new(@e1.preprocess_prog, @e2.preprocess_prog)
  end
  
  def eval_prog(env)
    @e1.eval_prog(env).intersect(@e2.eval_prog(env))
  end
end


class Let < GeometryExpression
  def initialize(s, e1, e2)
    @s = s
    @e1 = e1
    @e2 = e2
  end
  
  def preprocess_prog
    Let.new(@s, @e1.preprocess_prog, @e2.preprocess_prog)
  end
  
  def eval_prog(env)
    new_env = [[@s, @e1.eval_prog(env)]] + env
    @e2.eval_prog(new_env)
  end
end



class Var < GeometryExpression
  def initialize(s)
    @s = s
  end
  
  def eval_prog(env)
    pr = env.assoc(@s)
    raise "undefined variable" if pr.nil?
    pr[1]
  end
  
  def preprocess_prog
    self
  end
end


class Shift < GeometryExpression
  def initialize(dx, dy, e)
    @dx = dx
    @dy = dy
    @e = e
  end
  
  def preprocess_prog
    Shift.new(@dx, @dy, @e.preprocess_prog)
  end
  
  def eval_prog(env)
    @e.eval_prog(env).shift(@dx, @dy)
  end
end
