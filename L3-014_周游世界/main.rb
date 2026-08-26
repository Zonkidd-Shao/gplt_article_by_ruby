# frozen_string_literal: true
# == 实现说明 ==
# 题目：周游世界
# 实现原理：
#   将题目关系建模为图，利用 BFS、Dijkstra 或状态搜索维护到达代价，并在代价相同时按题目规则比较附加指标。
# 处理流程：
#   读取并建图 → 从起点搜索 → 松弛/扩展可达状态并记录前驱 → 还原路径或输出最优值。
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
a = py_input_data.split
exit if a.empty?
n = a.shift.to_i
ids = {}
stations = []
graph = []
get_id =
  lambda do |name|
    unless ids.key?(name)
      ids[name] = stations.length
      stations << name
      graph << []
    end
    ids[name]
  end
n.times do |company|
  count = a.shift.to_i
  route = count.times.map { get_id.call(a.shift) }
  route.each_cons(2) do |u, w|
    graph[u] << [w, company + 1]
    graph[w] << [u, company + 1]
  end
end
q = a.shift.to_i
answers = []
q.times do
  source_name = a.shift
  target_name = a.shift
  unless ids.key?(source_name) && ids.key?(target_name)
    answers << "Sorry, no line is available."
    next
  end
  source = ids[source_name]
  target = ids[target_name]
  distances = { [source, 0] => [0, 0] }
  previous = {}
  heap = [[0, 0, source, 0]]
  until heap.empty?
    edges, transfers, u, last_line = heap.shift
    next unless distances[[u, last_line]] == [edges, transfers]
    graph[u].each do |w, line|
      candidate = [edges + 1, transfers + (last_line != 0 && last_line != line ? 1 : 0)]
      key = [w, line]
      if !distances.key?(key) || candidate < distances[key]
        distances[key] = candidate
        previous[key] = [u, last_line]
        heap << [candidate[0], candidate[1], w, line]
        heap.sort_by! { |x| x[0, 2] }
      end
    end
  end
  ends = distances.filter_map { |(u, line), value| [value[0], value[1], line] if u == target }
  if ends.empty?
    answers << "Sorry, no line is available."
    next
  end
  edges, transfers, line = ends.min
  if source == target
    answers << "0"
    next
  end
  states = []
  current = [target, line]
  until current == [source, 0]
    states << current
    current = previous[current]
  end
  states << current
  states.reverse!
  reached = states[1..].map { |u, _| stations[u] }
  lines = states[1..].map { |_, line_id| line_id }
  answers << edges.to_s
  start_station = stations[source]
  current_line = lines[0]
  (1...lines.length).each do |i|
    next if lines[i] == current_line
    answers << format(
      "Go by the line of company #%d from %04d to %04d.",
      current_line,
      start_station.to_i,
      reached[i - 1].to_i
    )
    start_station = reached[i - 1]
    current_line = lines[i]
  end
  answers << format(
    "Go by the line of company #%d from %04d to %04d.",
    current_line,
    start_station.to_i,
    reached[-1].to_i
  )
end
py_print(answers.join("\n"))
