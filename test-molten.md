---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.17.2
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
---

```python
import requests

def fetch_usd_to_eur():
    url = "https://api.exchangerate.host/latest"
    params = {
        "base": "USD",
        "symbols": "EUR"
    }
    response = requests.get(url, params=params)
    data = response.json()
    rate = data["rates"]["EUR"]
    print(f"1 USD = {rate} EUR")

fetch_usd_to_eur()
```

```python
! python3 -m pip install requests
```

```python
1+1
```


```python
2+22+2
```


```python
2+22+2
```
