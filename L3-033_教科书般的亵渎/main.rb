# frozen_string_literal: true
# == 实现说明 ==
# 题目：教科书般的亵渎
# 实现原理：
#   把问题拆成可复用的子问题，使用动态规划或记忆化保存中间结果，避免重复计算。
# 处理流程：
#   定义状态 → 按依赖关系转移 → 处理不可达/边界状态 → 从最终状态恢复答案。
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
  py_mod = 998_244_353
  main =
    lambda do ||
      z = (py_map(->(x) { py_int(x) }, py_tokens).to_a)
      return if (!py_truth(z))
      n, py_k = py_slice(z, nil, 2, nil)
      a = py_slice(z, 2, (2 + n), nil)
      invf = ([1] * (py_k + 1))
      f = ([1] * (py_k + 1))
      for i in py_range(1, (py_k + 1))
        f[i] = ((f[(i - 1)] * i) % py_mod)
      end
      invf[py_k] = py_pow(f[py_k], (py_mod - 2), py_mod)
      for i in py_range(py_k, 0, (-1))
        invf[(i - 1)] = ((invf[i] * i) % py_mod)
      end
      dp = py_iterable(py_range((py_k + 1))).flat_map { |_| [{}] }
      dp[0][0] = 1
      for hp in a
        nd = py_iterable(py_range((py_k + 1))).flat_map { |_| [{}] }
        for used, mp in py_enumerate(dp)
          for mask, w in mp.items()
            for c in py_range((py_min((hp - 1), (py_k - used)) + 1))
              b = (hp - c)
              nm = (mask | (1 << (b - 1)))
              d = nd[(used + c)]
              d[nm] = ((d.fetch(nm, 0) + (w * invf[c])) % py_mod)
            end
          end
        end
        dp = nd
      end
      s =
        (
          py_sum(
            py_iterable(dp[py_k].items()).flat_map do |__item_0|
              mask, v = __item_0
              next [] unless py_truth((((mask & (mask + 1)) == 0)))
              [v]
            end
          ) % py_mod
        )
      py_print(
        (
          (((s * f[py_k]) % py_mod) * py_pow(py_pow(n, py_k, py_mod), (py_mod - 2), py_mod)) %
            py_mod
        ),
        sep: " ",
        ending: "\n"
      )
    end
  main.call
end
entry
