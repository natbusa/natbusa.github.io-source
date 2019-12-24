---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Parquet Pushdown Filters"
subtitle: ""
summary: ""
authors: [natbusa]
tags: [analytics, pyspark,]
categories: [datafaucet]
date: 2019-12-24
lastmod: 2019-12-24
featured: false
draft: false

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: ""
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: []
---


```python
import datafaucet as dfc
```

Datafaucet is a productivity framework for ETL, ML application. Simplifying some of the common activities which are typical in Data pipeline such as project scaffolding, data ingesting, start schema generation, forecasting etc.

## Loading and Saving Parquet Data


```python
dfc.project.load('minimal')
```

     [datafaucet] NOTICE parquet.ipynb:engine:__init__ | Connecting to spark master: local[*]



```python
dfc.metadata.profile()
```

### Filter and projections Filters push down on parquet files

The following show how to selectively read files on parquet files (with partitions)

#### Create data


```python
df = dfc.range(10000).cols.create('g').randchoice([0,1,2,3])
df.cols.groupby('g').agg('count').data.grid()
```

#### Save data as parquet objects


```python
df.repartition('g').save('local', 'groups.parquet');
```


```python
dfc.list('data/save/groups.parquet').data.grid()
```

#### Read data parquet objects (with pushdown filters)


```python
spark = dfc.engine().context
```


```python
df = spark.read.load('data/save/groups.parquet')
```


```python
### No pushdown on the physical plan
df.explain()
```


```python
### Pushdown only column selection
df.groupby('g').count().explain()
```


```python

df.filter('id>100').explain()
```


```python

df.filter('id>100 and g=1').groupby('g').count().explain()
```
