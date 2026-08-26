# frozen_string_literal: true
# == 实现说明 ==
# 题目：森森美图
# 实现原理：
#   将输入记录放入数组或哈希中，先完成去重、计数或排序，再按照题目规定的优先级筛选答案。
# 处理流程：
#   读取记录 → 建立计数/分组信息 → 排序或筛选 → 按稳定的 tie-break 规则输出。
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
def entry
  main =
    lambda do ||
      a = (py_map(->(x) { py_int(x) }, py_tokens).to_a)
      return if (!py_truth(a))
      n, m = py_slice(a, nil, 2, nil)
      p = 2
      score =
        py_iterable(py_range(n)).flat_map do |i|
          [py_slice(a, (p + (i * m)), (p + ((i + 1) * m)), nil)]
        end
      p += (n * m)
      sx, sy, ex, ey = py_slice(a, p, (p + 4), nil)
      inf = 1e+100
      cross0 = [(ex - sx), (ey - sy)]
      run =
        lambda do |pos|
          d = py_iterable(py_range(n)).flat_map { |_| [([inf] * m)] }
          d[sy][sx] = score[sy][sx]
          pq = [[d[sy][sx], sx, sy]]
          while py_truth(pq)
            du, x, y = pq.shift
            next if ((du != d[y][x]))
            for dx in [(-1), 0, 1]
              for dy in [(-1), 0, 1]
                next if ((!py_truth(dx)) && (!py_truth(dy)))
                nx, ny = [(x + dx), (y + dy)]
                next if (!py_truth((((0 <= nx) && (nx < m)) && ((0 <= ny) && (ny < n)))))
                if (!py_in([nx, ny], [[sx, sy], [ex, ey]]))
                  cr = ((cross0[0] * (ny - sy)) - (cross0[1] * (nx - sx)))
                  next if (((cr == 0)) || ((((cr > 0)) != pos)))
                end
                extra =
                  (
                    if (py_truth(dx) && py_truth(dy))
                      ((score[y][x] + score[ny][nx]) * (Math.sqrt(2) - 1))
                    else
                      0
                    end
                  )
                nd = ((du + score[ny][nx]) + extra)
                if ((nd < d[ny][nx]))
                  d[ny][nx] = nd
                  pq.push([nd, nx, ny])
                  pq.sort!
                end
              end
            end
          end
          return d[ey][ex]
        end
      x, y = [run.call(true), run.call(false)]
      ans =
        (
          if (((x >= py_div(inf, 2))) || ((y >= py_div(inf, 2))))
            py_min(x, y)
          else
            (((x + y) - score[sy][sx]) - score[ey][ex])
          end
        )
      py_print("%.2f" % [ans], sep: " ", ending: "\n")
    end
  main.call
end
entry
