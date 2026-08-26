# frozen_string_literal: true
# == 实现说明 ==
# 题目：迎风一刀斩
# 实现原理：
#   使用坐标的差分、叉积或面积公式判断几何关系，并结合排序或扫描得到全局结果。
# 处理流程：
#   读取坐标 → 计算几何量 → 判断关系或更新最优值 → 输出结果。
#
# OJ 提交说明：本文件内嵌了所有公共辅助方法，无需依赖外部运行时文件。
# 这些方法用于提供竞赛输入、Python 风格切片/迭代和容器操作的 Ruby 实现。
require "set"
def py_input_data
  @py_input_data ||= STDIN.read
end

def py_tokens
  py_input_data.split
end

def py_lines
  py_input_data.lines.map(&:chomp)
end

def py_readline
  STDIN.gets.to_s.chomp
end

def py_int(value)
  Integer(value)
end

def py_float(value)
  Float(value)
end

def py_str(value)
  value.to_s
end

def py_bool_int(value)
  value ? 1 : 0
end

def py_truth(value)
  return false if value.nil? || value == false
  return false if value.respond_to?(:zero?) && value.zero?
  return false if value.respond_to?(:empty?) && value.empty?

  true
end

def py_len(value)
  value.length
end

def py_range(first, last = nil, step = 1)
  start, finish = last.nil? ? [0, first] : [first, last]
  raise ArgumentError, "range() arg 3 must not be zero" if step.zero?

  (start...finish).step(step).to_a
end

def py_map(function, values)
  py_iterable(values).map { |value| function.call(value) }
end

def py_iter(values)
  py_iterable(values).to_enum
end

def py_next(iterator)
  iterator.respond_to?(:next) ? iterator.next : iterator.shift
end

def py_iterable(value)
  return [] if value.nil?
  return value.chars if value.is_a?(String)
  return value if value.is_a?(Array)

  value.respond_to?(:to_a) ? value.to_a : value
end

def py_enumerate(values, start = 0)
  py_iterable(values).each_with_index.map { |value, index| [index + start, value] }
end

def py_zip(*values)
  arrays = values.map { |value| py_iterable(value) }
  length = arrays.map(&:length).min || 0
  (0...length).map { |index| arrays.map { |array| array[index] } }
end

def py_slice(value, start = nil, finish = nil, step = nil)
  sequence = value.is_a?(String) ? value.chars : value.to_a
  length = sequence.length
  step ||= 1
  raise ArgumentError, "slice step cannot be zero" if step.zero?

  if step.positive?
    left = start.nil? ? 0 : start
    right = finish.nil? ? length : finish
    left += length if left.negative?
    right += length if right.negative?
    left = [[left, 0].max, length].min
    right = [[right, 0].max, length].min
    indexes = (left...right).step(step).to_a
  else
    left = start.nil? ? length - 1 : start
    right = finish.nil? ? -1 : finish
    left += length if left.negative?
    right += length if right.negative? && !finish.nil?
    left = [[left, -1].max, length - 1].min
    right = [[right, -1].max, length - 1].min
    indexes = []
    i = left
    while i > right
      indexes << i
      i += step
    end
  end

  result = indexes.map { |index| sequence[index] }
  value.is_a?(String) ? result.join : result
end

def py_replace_slice(array, start, finish, replacement)
  array[start...finish] = replacement
end

def py_sum(values, initial = 0)
  py_iterable(values).reduce(initial) do |sum, value|
    sum + (value == true ? 1 : value == false ? 0 : value)
  end
end

def py_min(*values, default: nil, key: nil)
  values = py_iterable(values.first) if values.length == 1
  return default if values.empty?

  key ? values.min_by { |value| key.call(value) } : values.min
end

def py_max(*values, default: nil, key: nil)
  values = py_iterable(values.first) if values.length == 1
  return default if values.empty?

  key ? values.max_by { |value| key.call(value) } : values.max
end

def py_sorted(values, reverse: false)
  result = py_iterable(values).sort
  reverse ? result.reverse : result
end

def py_div(left, right)
  left.to_f / right
end

def py_divmod(left, right)
  left.divmod(right)
end

def py_abs(value)
  value.abs
end

def py_gcd(left, right)
  left.gcd(right)
end

def py_factorial(value)
  (1..value).reduce(1, :*)
end

def py_pow(base, exponent, modulus = nil)
  modulus.nil? ? base**exponent : base.pow(exponent, modulus)
end

def py_counter(values)
  py_iterable(values).each_with_object(Hash.new(0)) { |value, counts| counts[value] += 1 }
end

def py_in(value, container)
  container.include?(value)
end

def py_lstrip(value, chars = nil)
  return value.lstrip if chars.nil?

  value.sub(/\A[#{Regexp.escape(chars)}]+/, "")
end

def py_re_sub(pattern, replacement, value)
  value.gsub(Regexp.new(pattern), replacement)
end

def py_startswith_at(value, prefix, index)
  value[index, prefix.length] == prefix
end

def py_bisect_left(values, target)
  values.bsearch_index { |value| value >= target } || values.length
end

def py_bisect_right(values, target)
  values.bsearch_index { |value| value > target } || values.length
end

def py_print(*values, sep: " ", ending: "\n")
  STDOUT.write(values.join(sep) + ending)
end

class Array
  include Comparable
end

class Set
  def update(values)
    merge(values)
  end

  def pop
    value = first
    delete(value) if value
    value
  end
end

class Array
  alias append push

  def popleft
    shift
  end

  def extend(values)
    concat(values)
  end
end

class String
  def each(&block)
    each_char(&block)
  end
end

class Hash
  def items
    to_a
  end
end
# 入口：读取标准输入，调用核心逻辑并按题意输出。

def area2(points)
  points.each_with_index.sum do |(x, y), i|
    x2, y2 = points[(i + 1) % points.length]
    x * y2 - y * x2
  end
end

def transforms(points)
  points
    .map { |x, y| [[x, y], [x, -y], [-x, y], [-x, -y], [y, x], [y, -x], [-y, x], [-y, -x]] }
    .transpose
    .map { |rows| rows }
end

def glue(a, ia, b, ib)
  a1 = a[ia]
  a2 = a[(ia + 1) % a.length]
  b1 = b[ib]
  b2 = b[(ib + 1) % b.length]
  va = [a2[0] - a1[0], a2[1] - a1[1]]
  vb = [b2[0] - b1[0], b2[1] - b1[1]]
  return false unless va == [-vb[0], -vb[1]]
  tx = a2[0] - b1[0]
  ty = a2[1] - b1[1]
  bp = b.map { |x, y| [x + tx, y + ty] }
  combined = (0...(a.length - 1)).map { |i| a[(ia + 1 + i) % a.length] }
  combined += (0...(b.length - 1)).map { |i| bp[(ib + 1 + i) % b.length] }
  return false if combined.length < 4
  combined.each_with_index do |point, i|
    other = combined[(i + 1) % combined.length]
    return false if point == other || (point[0] != other[0] && point[1] != other[1])
  end
  xs = combined.map(&:first)
  ys = combined.map(&:last)
  min_x, max_x = xs.minmax
  min_y, max_y = ys.minmax
  return false if min_x == max_x || min_y == max_y
  return false unless area2(combined).abs == area2(a).abs + area2(bp).abs
  return false unless area2(combined).abs == 2 * (max_x - min_x) * (max_y - min_y)
  combined.all? { |x, y| x == min_x || x == max_x || y == min_y || y == max_y }
end

def possible(a, b)
  [a, a.reverse].each do |pa|
    [b, b.reverse].each do |pb|
      transforms(pa).each do |aa|
        bad =
          aa.each_index.select do |i|
            x, y = aa[i]
            xx, yy = aa[(i + 1) % aa.length]
            x != xx && y != yy
          end
        next if bad.length > 1
        cuts_a = bad.empty? ? (0...aa.length).to_a : bad
        transforms(pb).each do |bb|
          bad_b =
            bb.each_index.select do |i|
              x, y = bb[i]
              xx, yy = bb[(i + 1) % bb.length]
              x != xx && y != yy
            end
          next if bad_b.length > 1
          cuts_b = bad_b.empty? ? (0...bb.length).to_a : bad_b
          cuts_a.each { |i| cuts_b.each { |j| return true if glue(aa, i, bb, j) } }
        end
      end
    end
  end
  false
end

v = py_tokens.map(&:to_i)
cases = v.shift
answers = []
cases.times do
  ka = v.shift
  a = ka.times.map { [v.shift, v.shift] }
  kb = v.shift
  b = kb.times.map { [v.shift, v.shift] }
  answers << (possible(a, b) ? "YES" : "NO")
end
py_print(answers.join("\n"))
