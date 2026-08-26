# frozen_string_literal: true
# == 实现说明 ==
# 题目：超能力者大赛
# 实现原理：
#   顺序扫描输入并维护当前最优值或计数器；只保留后续决策真正需要的状态。
# 处理流程：
#   读取数据 → 逐项比较/累计 → 处理并列和边界 → 输出最终统计值。
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

# L3-034 超能力者大赛
# 按题面规定模拟：全局选择能力值最大的可击败对手，平局按距离、
# 最少经过城市数、城市编号处理；到达城市后次日战斗，同城安全时连续清理。

tokens = STDIN.read.split.map!(&:to_i)
exit if tokens.empty?

n, m, edge_count, deadline = tokens.shift(4)
cities = Array.new(n)
powers = Array.new(n)
n.times { |i| cities[i], powers[i] = tokens.shift(2) }

inf = 1_000_000_000
distance = Array.new(m) { Array.new(m, inf) }
hops = Array.new(m) { Array.new(m, inf) }
m.times do |i|
  distance[i][i] = 0
  hops[i][i] = 0
end
edge_count.times do
  a, b, w = tokens.shift(3)
  if w < distance[a][b] || (w == distance[a][b] && 1 < hops[a][b])
    distance[a][b] = distance[b][a] = w
    hops[a][b] = hops[b][a] = 1
  end
end

m.times do |k|
  m.times do |i|
    next if distance[i][k] >= inf
    m.times do |j|
      next if distance[k][j] >= inf
      new_distance = distance[i][k] + distance[k][j]
      new_hops = hops[i][k] + hops[k][j]
      if new_distance < distance[i][j] || (new_distance == distance[i][j] && new_hops < hops[i][j])
        distance[i][j] = new_distance
        hops[i][j] = new_hops
      end
    end
  end
end

foes = Array.new(m) { [] }
(1...n).each { |i| foes[cities[i]] << powers[i] }
current_power = powers[0]
current_city = cities[0]
day = 0
output = []

loop do
  if foes.all?(&:empty?)
    output << "WIN on day #{day} with #{current_power}!"
    break
  end

  # 到达城市后的第二天，若城内没有更强者，必须继续逐一战斗。
  stay_value = nil
  if day.positive?
    local = foes[current_city]
    if !local.empty? && local.none? { |value| value > current_power }
      stay_value = local.select { |value| value <= current_power }.max
    end
  end

  if stay_value
    battle_day = day + 1
    if battle_day > deadline
      output << "Game over with #{current_power}."
      break
    end
    output << "Get #{stay_value} at #{current_city} on day #{battle_day}."
    foes[current_city].delete_at(foes[current_city].index(stay_value))
    day = battle_day
    current_power += stay_value
  else
    candidate = nil
    m.times do |city|
      next if foes[city].empty? || distance[current_city][city] >= inf
      foes[city].each do |value|
        next if value > current_power
        key = [-value, distance[current_city][city], hops[current_city][city], city]
        candidate = [key, city, value] if candidate.nil? || (key <=> candidate[0]) == -1
      end
    end

    if candidate.nil?
      lose_day = day.zero? ? 1 : day + 1
      lose_day = deadline if lose_day > deadline
      output << "Lose on day #{lose_day} with #{current_power}."
      break
    end

    _, target_city, target_value = candidate
    travel = distance[current_city][target_city]
    battle_day = day + 1 + travel
    if battle_day > deadline
      arrival_day = day.zero? ? travel : day + travel
      if travel.positive? && arrival_day <= deadline
        output << "Move from #{current_city} to #{target_city}."
      end
      output << "Game over with #{current_power}."
      break
    end

    if travel.positive?
      output << "Move from #{current_city} to #{target_city}."
      current_city = target_city
    end
    output << "Get #{target_value} at #{target_city} on day #{battle_day}."
    foes[target_city].delete_at(foes[target_city].index(target_value))
    day = battle_day
    current_power += target_value
  end

  # 战斗会把当前城市中所有不超过己方能力的剩余个体合成一个联盟。
  weak, strong = foes[current_city].partition { |value| value <= current_power }
  foes[current_city] = strong
  foes[current_city] << weak.sum unless weak.empty?
end

STDOUT.write(output.join("\n"))
STDOUT.write("\n") unless output.empty?
