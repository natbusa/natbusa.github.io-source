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
     [datafaucet] NOTICE parquet.ipynb:engine:__init__ | Engine context spark:2.4.4 successfully started





    <datafaucet.project.Project at 0x7f3f40acb748>




```python
dfc.metadata.profile()
```




    profile: minimal
    variables: {}
    engine:
        type: spark
        master: local[*]
        jobname:
        timezone: naive
        submit:
            jars: []
            packages: []
            pyfiles:
            files:
            repositories:
            conf:
    providers:
        local:
            service: file
            path: data
    resources: {}
    logging:
        level: info
        stdout: true
        file: datafaucet.log
        kafka: []



### Filter and projections Filters push down on parquet files

The following show how to selectively read files on parquet files (with partitions)

#### Create data


```python
df = dfc.range(10000).cols.create('g').randchoice([0,1,2,3])
df.cols.groupby('g').agg('count').data.grid()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>g</th>
      <th>id</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>0</td>
      <td>2552</td>
    </tr>
    <tr>
      <td>1</td>
      <td>1</td>
      <td>2400</td>
    </tr>
    <tr>
      <td>2</td>
      <td>3</td>
      <td>2568</td>
    </tr>
    <tr>
      <td>3</td>
      <td>2</td>
      <td>2480</td>
    </tr>
  </tbody>
</table>
</div>



#### Save data as parquet objects


```python
df.repartition('g').save('local', 'groups.parquet');
```

     [datafaucet] INFO parquet.ipynb:engine:save_log | save



```python
dfc.list('data/save/groups.parquet').data.grid()
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>name</th>
      <th>type</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>g=2</td>
      <td>DIRECTORY</td>
    </tr>
    <tr>
      <td>1</td>
      <td>g=1</td>
      <td>DIRECTORY</td>
    </tr>
    <tr>
      <td>2</td>
      <td>g=3</td>
      <td>DIRECTORY</td>
    </tr>
    <tr>
      <td>3</td>
      <td>g=0</td>
      <td>DIRECTORY</td>
    </tr>
    <tr>
      <td>4</td>
      <td>_SUCCESS</td>
      <td>FILE</td>
    </tr>
    <tr>
      <td>5</td>
      <td>._SUCCESS.crc</td>
      <td>FILE</td>
    </tr>
  </tbody>
</table>
</div>



#### Read data parquet objects (with pushdown filters)


```python
spark = dfc.engine().context
```


```python
df = dfc.load('local', 'groups.parquet')
```

     [datafaucet] INFO parquet.ipynb:engine:load_log | load



```python
### No pushdown on the physical plan
df.explain()
```

    == Physical Plan ==
    *(1) FileScan parquet [id#253L,g#254L] Batched: true, Format: Parquet, Location: InMemoryFileIndex[file:/home/natbusa/Projects/datafaucet/examples/tutorial/groups.parquet/data], PartitionFilters: [], PushedFilters: [], ReadSchema: struct<id:bigint,g:bigint>



```python
### Pushdown only column selection
df.groupby('g').count().explain()
```

    == Physical Plan ==
    *(2) HashAggregate(keys=[g#254L], functions=[count(1)])
    +- Exchange hashpartitioning(g#254L, 200)
       +- *(1) HashAggregate(keys=[g#254L], functions=[partial_count(1)])
          +- *(1) FileScan parquet [g#254L] Batched: true, Format: Parquet, Location: InMemoryFileIndex[file:/home/natbusa/Projects/datafaucet/examples/tutorial/groups.parquet/data], PartitionFilters: [], PushedFilters: [], ReadSchema: struct<g:bigint>



```python

df.filter('id>100').explain()
```

    == Physical Plan ==
    *(1) Project [id#253L, g#254L]
    +- *(1) Filter (isnotnull(id#253L) && (id#253L > 100))
       +- *(1) FileScan parquet [id#253L,g#254L] Batched: true, Format: Parquet, Location: InMemoryFileIndex[file:/home/natbusa/Projects/datafaucet/examples/tutorial/groups.parquet/data], PartitionFilters: [], PushedFilters: [IsNotNull(id), GreaterThan(id,100)], ReadSchema: struct<id:bigint,g:bigint>



```python

df.filter('id>100 and g=1').groupby('g').count().explain()
```

    == Physical Plan ==
    *(2) HashAggregate(keys=[g#254L], functions=[count(1)])
    +- Exchange hashpartitioning(g#254L, 200)
       +- *(1) HashAggregate(keys=[g#254L], functions=[partial_count(1)])
          +- *(1) Project [g#254L]
             +- *(1) Filter (((isnotnull(id#253L) && isnotnull(g#254L)) && (id#253L > 100)) && (g#254L = 1))
                +- *(1) FileScan parquet [id#253L,g#254L] Batched: true, Format: Parquet, Location: InMemoryFileIndex[file:/home/natbusa/Projects/datafaucet/examples/tutorial/groups.parquet/data], PartitionFilters: [], PushedFilters: [IsNotNull(id), IsNotNull(g), GreaterThan(id,100), EqualTo(g,1)], ReadSchema: struct<id:bigint,g:bigint>



```python

```
