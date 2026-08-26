# frozen_string_literal: true
# == 实现说明 ==
# 题目：代码排版
# 实现原理：
#   先按题目规则解析字符串或字符序列，再通过扫描、替换、计数或格式化完成转换，避免改变无关字符。
# 处理流程：
#   读取原始文本 → 扫描并识别目标模式 → 执行替换/重排/统计 → 输出处理后的文本。
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
  formatter_class =
    Class.new do
      attr_accessor "control", "kw", "n", "one", "out", "p", "paren", "s", "semi", "skip", "stat"
      define_method(:initialize) do |s|
        self.s = s
        self.n = py_len(s)
        self.p = 0
        self.out = []
      end
      define_method(:skip) do ||
        self.p += 1 while (((self.p < self.n)) && py_truth((self.s[self.p].to_s.match?(/\A\s+\z/))))
      end
      define_method(:kw) do |w|
        return(
          py_truth(py_startswith_at(self.s, w, self.p)) &&
            (
              (((self.p + py_len(w)) == self.n)) ||
                (
                  !py_truth(
                    (
                      py_truth((self.s[(self.p + py_len(w))].to_s.match?(/\A[[:alnum:]]+\z/))) ||
                        ((self.s[(self.p + py_len(w))] == "_"))
                    )
                  )
                )
            )
        )
      end
      define_method(:paren) do ||
        start = self.p
        dep = 0
        quote = nil
        esc = false
        while ((self.p < self.n))
          c = self.s[self.p]
          if py_truth(esc)
            esc = false
          else
            if py_truth(quote)
              if ((c == "\\"))
                esc = true
              else
                quote = nil if ((c == quote))
              end
            else
              if (py_in(c, "\"'"))
                quote = c
              else
                if ((c == "("))
                  dep += 1
                else
                  if ((c == ")"))
                    dep -= 1
                    if ((dep == 0))
                      self.p += 1
                      return py_slice(self.s, start, self.p, nil)
                    end
                  end
                end
              end
            end
          end
          self.p += 1
        end
        return py_slice(self.s, start, nil, nil)
      end
      define_method(:semi) do ||
        i = self.p
        dep = 0
        quote = nil
        esc = false
        while ((i < self.n))
          c = self.s[i]
          if py_truth(esc)
            esc = false
          else
            if py_truth(quote)
              if ((c == "\\"))
                esc = true
              else
                quote = nil if ((c == quote))
              end
            else
              if (py_in(c, "\"'"))
                quote = c
              else
                if ((c == "("))
                  dep += 1
                else
                  if ((c == ")"))
                    dep = py_max(0, (dep - 1))
                  else
                    return i if (((c == ";")) && ((dep == 0)))
                  end
                end
              end
            end
          end
          i += 1
        end
        return(self.n - 1)
      end
      define_method(:one) do |ind|
        self.skip()
        return if ((self.p >= self.n))
        if py_truth(self.kw("if"))
          self.control("if", ind)
        else
          if py_truth(self.kw("for"))
            self.control("for", ind)
          else
            if py_truth(self.kw("while"))
              self.control("while", ind)
            else
              if ((self.s[self.p] == "{"))
                self.out.append((("  " * ind) + "{"))
                self.p += 1
                self.stat((ind + 1))
                self.skip()
                if (((self.p < self.n)) && ((self.s[self.p] == "}")))
                  self.out.append((("  " * ind) + "}"))
                  self.p += 1
                end
              else
                j = self.semi()
                self.out.append((("  " * ind) + py_slice(self.s, self.p, (j + 1), nil).strip()))
                self.p = (j + 1)
              end
            end
          end
        end
      end
      define_method(:stat) do |ind|
        while py_truth(true)
          self.skip()
          return if (((self.p >= self.n)) || ((self.s[self.p] == "}")))
          self.one(ind)
        end
      end
      define_method(:control) do |name, ind|
        self.p += py_len(name)
        self.skip()
        cond = ((((self.p < self.n)) && ((self.s[self.p] == "("))) ? self.paren() : "")
        self.out.append(((((("  " * ind) + name) + " ") + cond) + " {"))
        self.skip()
        if (((self.p < self.n)) && ((self.s[self.p] == "{")))
          self.p += 1
          self.stat((ind + 1))
          self.skip()
          self.p += 1 if (((self.p < self.n)) && ((self.s[self.p] == "}")))
        else
          self.one((ind + 1))
        end
        self.out.append((("  " * ind) + "}"))
        if ((name == "if"))
          save = self.p
          self.skip()
          if py_truth(self.kw("else"))
            self.p += 4
            self.skip()
            self.out.append((("  " * ind) + "else {"))
            if py_truth(self.kw("if"))
              self.control("if", (ind + 1))
            else
              if (((self.p < self.n)) && ((self.s[self.p] == "{")))
                self.p += 1
                self.stat((ind + 1))
                self.skip()
                self.p += 1 if (((self.p < self.n)) && ((self.s[self.p] == "}")))
              else
                self.one((ind + 1))
              end
            end
            self.out.append((("  " * ind) + "}"))
          else
            self.p = save
          end
        end
      end
      define_method(:run) do ||
        self.skip()
        j = self.s.index("{") || -1
        if ((j >= 0))
          self.out.append(py_slice(self.s, self.p, j, nil).strip())
          self.out.append("{")
          self.p = (j + 1)
          self.stat(1)
          self.skip()
          if (((self.p < self.n)) && ((self.s[self.p] == "}")))
            self.out.append("}")
            self.p += 1
          end
        else
          self.stat(0)
        end
        return(self.out.join("\n") + "\n")
      end
    end
  main =
    lambda do ||
      s = py_input_data
      py_print(formatter_class.new(s).run(), sep: " ", ending: "") if py_truth(s.strip())
    end
  main.call
end
entry
