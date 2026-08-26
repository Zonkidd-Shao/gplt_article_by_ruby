# frozen_string_literal: true
# == 实现说明 ==
# 题目：攀岩
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

# L3-039 攀岩
# 状态 (i,j) 表示两条机械臂分别抓住两个不同岩点。
# 三个岩点能被同一核心同时覆盖，当且仅当它们的最小包围圆半径不超过 r。
# 在状态图上 BFS，再对 r 二分。

values = STDIN.read.split.map!(&:to_f)
exit if values.empty?
task_count = values.shift.to_i
answers = []

task_count.times do
  n = values.shift.to_i
  points = n.times.map { [values.shift, values.shift] }
  distance = Array.new(n) { Array.new(n, 0.0) }
  n.times do |i|
    (i + 1...n).each do |j|
      d = Math.hypot(points[i][0] - points[j][0], points[i][1] - points[j][1])
      distance[i][j] = distance[j][i] = d
    end
  end

  triple_feasible =
    lambda do |a, b, c, radius|
      a2 = a * a
      b2 = b * b
      c2 = c * c
      longest = [a2, b2, c2].max
      other_sum = a2 + b2 + c2 - longest
      # 钝角/直角三角形的最小包围圆直径就是最长边。
      return true if longest + 1e-12 >= other_sum
      semiperimeter = (a + b + c) / 2.0
      area2 = semiperimeter * (semiperimeter - a) * (semiperimeter - b) * (semiperimeter - c)
      return true if area2 <= 0.0
      circumradius = a * b * c / (4.0 * Math.sqrt(area2))
      circumradius <= radius + 1e-9
    end

  feasible =
    lambda do |radius|
      two_radius = 2.0 * radius
      if distance[0][1] > two_radius + 1e-9
        false
      else
        # 只在两点距离不超过 2r 时建立邻接关系。对每个状态，
        # 从两个邻接表中较短的一个枚举候选点，避免无条件扫描全部 n 个点。
        neighbors = Array.new(n) { [] }
        allowed = Array.new(n) { Array.new(n, false) }
        n.times do |i|
          (i + 1...n).each do |j|
            next unless distance[i][j] <= two_radius + 1e-9
            neighbors[i] << j
            neighbors[j] << i
            allowed[i][j] = allowed[j][i] = true
          end
        end
        visited = Array.new(n) { Array.new(n, false) }
        queue_a = [0]
        queue_b = [1]
        visited[0][1] = visited[1][0] = true
        head = 0
        result = false

        until head == queue_a.length
          u = queue_a[head]
          v = queue_b[head]
          head += 1
          if u == n - 1 || v == n - 1
            result = true
            break
          end

          candidates, other =
            if neighbors[u].length <= neighbors[v].length
              [neighbors[u], v]
            else
              [neighbors[v], u]
            end
          candidates.each do |k|
            next if k == u || k == v
            next unless allowed[other][k]
            next unless triple_feasible.call(distance[v][k], distance[u][k], distance[u][v], radius)

            if !visited[u][k]
              visited[u][k] = visited[k][u] = true
              if k == n - 1
                result = true
                break
              end
              if u < k
                queue_a << u
                queue_b << k
              else
                queue_a << k
                queue_b << u
              end
            end

            if !visited[v][k]
              visited[v][k] = visited[k][v] = true
              if k == n - 1
                result = true
                break
              end
              if v < k
                queue_a << v
                queue_b << k
              else
                queue_a << k
                queue_b << v
              end
            end
          end
          break if result
        end
        result
      end
    end

  low = 0.0
  high = distance.flatten.max
  # 坐标范围不超过 10^6；45 次二分后区间宽度已小于 10^-7，
  # 足以满足题目 10^-6 的绝对/相对误差要求。
  45.times do
    middle = (low + high) / 2.0
    if feasible.call(middle)
      high = middle
    else
      low = middle
    end
  end
  answers << format("%.11f", high)
end

STDOUT.write(answers.join("\n"))
STDOUT.write("\n") unless answers.empty?
