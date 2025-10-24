---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.17.3
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
---


```python
import this
print(this)
```

```python
print("What magic can I do with this, tho'?")
```

```python
# Count and display the top 5 most common words in the Zen of Python
import this
from collections import Counter
import re

zen = this.s
words = re.findall(r'\b\w+\b', zen.lower())
counter = Counter(words)
top5 = counter.most_common(5)

print("Top 5 most common words in the Zen of Python:")
for word, count in top5:
    print(f"{word}: {count}")
```


```python
# test = input()
# print(test)

```
