# GPLT Ruby 题解

团队程序设计天梯赛（GPLT）练习集的 Ruby 语言题解，覆盖基础级、进阶级和高级题目。

## 题目统计

| 级别 | 数量 |
| --- | ---: |
| L1 基础级 | 120 |
| L2 进阶级 | 60 |
| L3 高级 | 45 |
| 合计 | 225 |

## 在线阅读

本仓库通过 Docsify 发布为 GitHub Pages：

<https://zonkidd-shao.github.io/gplt_article_by_ruby/>

进入站点后，可以使用左侧导航、搜索框和题目之间的上一题 / 下一题导航浏览题解。

## 本地预览

仓库根目录就是站点根目录，使用任意静态文件服务器即可预览：

```bash
python3 -m http.server 8899
```

然后打开 <http://127.0.0.1:8899/>。

## 目录结构

- `L1-*.md`：基础级题解
- `L2-*.md`：进阶级题解
- `L3-*.md`：高级题解
- `L1-*/`、`L2-*/`、`L3-*/`：对应题目的 Ruby 源代码目录，每个目录包含 `main.rb`
- `index.html`：Docsify 站点入口
- `_sidebar.md`：题目导航

题解正文包含题目描述、样例、解题思路、Ruby 实现和流程图；例如：

```bash
ruby L2-001_紧急救援/main.rb < input.txt
```
