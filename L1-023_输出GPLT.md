# L1-023 - 输出GPLT（20 分）

- **时间限制**: 150 ms
- **内存限制**: 65536 KB
- **代码长度限制**: 16 KB

---

## 题目描述


给定一个长度不超过10000的、仅由英文字母构成的字符串。请将字符重新调整顺序，按`GPLTGPLT....`这样的顺序输出，并忽略其它字符。当然，四种字符（不区分大小写）的个数不一定是一样多的，若某种字符已经输出完，则余下的字符仍按`GPLT`的顺序打印，直到所有字符都被输出。

### 输入格式:

输入在一行中给出一个长度不超过10000的、仅由英文字母构成的非空字符串。

### 输出格式:

在一行中按题目要求输出排序后的字符串。题目保证输出非空。

### 输入样例:
```in
pcTclnGloRgLrtLhgljkLhGFauPewSKgt
```

### 输出样例:
```out
GPLTGPLTGLTGLGLL
```

## 示例

### 示例 1

**输入:**
```
pcTclnGloRgLrtLhgljkLhGFauPewSKgt
```

**输出:**
```
GPLTGPLTGLTGLGLL
```

### 解题思路

本题的 Ruby 实现采用字符串解析与规则处理。程序先读取题目输入，建立与题意对应的数据结构，按照约束完成核心计算，并按规定格式输出结果。具体实现以同目录的 main.rb 为准。

### 代码流程说明

1. 读取并解析标准输入，转换为题目所需的数据结构。
2. 按题意执行核心算法，维护中间状态并处理边界情况。
3. 整理计算结果，按照输出格式生成答案。

### 代码实现

完整实现位于同目录的 [main.rb](./L1-023_输出GPLT/main.rb)，以下代码与该入口文件保持一致。

```ruby
# frozen_string_literal: true
require_relative '../gplt_runtime'
def entry
  s = py_input_data.upcase
  c = Hash[py_iterable("GPLT").flat_map { |x|; [[x, s.count(x)]] }]
  out = []
  while py_truth(c.values().any?)
    for x in "GPLT"
      if py_truth(c[x])
        out.append(x)
        c[x] -= 1
      end
    end
  end
  py_print(out.join(""), sep: " ", ending: "\n")
end
entry
```

### 代码流程图

```mermaid
flowchart TD
    A[读取输入] --> B[解析数据]
    B --> C[执行核心算法]
    C --> D[整理结果]
    D --> E[输出答案]
```

### 解题流程图

```mermaid
flowchart TD
    S[开始] --> I[输入题目数据]
    I --> P[按照题意处理]
    P --> O[输出结果]
    O --> F[结束]
```
