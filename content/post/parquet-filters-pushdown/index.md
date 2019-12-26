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

    <datafaucet.project.Project at 0x7f6e3bfe9630>

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
      <td>2504</td>
    </tr>
    <tr>
      <td>1</td>
      <td>1</td>
      <td>2320</td>
    </tr>
    <tr>
      <td>2</td>
      <td>3</td>
      <td>2640</td>
    </tr>
    <tr>
      <td>3</td>
      <td>2</td>
      <td>2536</td>
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
df = dfc.load('data/save/groups.parquet')
```

     [datafaucet] INFO parquet.ipynb:engine:load_log | load

```python
df.explain()
```

    == Physical Plan ==
    *(1) FileScan parquet [id#91L,g#92] Batched: true, Format: Parquet, Location: InMemoryFileIndex[file:/home/natbusa/Projects/datafaucet/examples/tutorial/data/save/groups.parquet], PartitionCount: 4, PartitionFilters: [], PushedFilters: [], ReadSchema: struct<id:bigint>

```python
def explainSource(obj):
    for s in obj._jdf.queryExecution().simpleString().split('\n'):
        if 'FileScan' in s:
            params = [
                'Batched', 
                'Format', 
                'Location',
                'PartitionCount', 
                'PartitionFilters', 
                'PushedFilters',
                'ReadSchema']
            
            # (partial) parse the Filescan string
            res = {}
            # preamble
            first, _, rest = s.partition(f'{params[0]}:')
            # loop
            for i in range(len(params[1:])):
                first, _, rest = rest.partition(f'{params[i+1]}:')
                res[params[i]]=first[1:-2]
            # store last
            res[params[-1]]=rest[1:]
            
            # hide location data, not relevant here
            del res['Location']
            
            return dfc.yaml.YamlDict(res)
```

```python
### No pushdown on the physical plan

explainSource(df)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '4'
    PartitionFilters: '[]'
    PushedFilters: '[]'
    ReadSchema: struct<id:bigint>

```python
### Pushdown only column selection
res = df.groupby('g').count()
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '4'
    PartitionFilters: '[]'
    PushedFilters: '[]'
    ReadSchema: struct<>

```python
# push down row filter only but take all partitions
res = df.filter('id>100')
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '4'
    PartitionFilters: '[]'
    PushedFilters: '[IsNotNull(id), GreaterThan(id,100)]'
    ReadSchema: struct<id:bigint>

```python
# pushdown partition filters and row (columnar) filters
res = df.filter('id>100 and g=1').groupby('g').count()
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '1'
    PartitionFilters: '[isnotnull(g#92), (g#92 = 1)]'
    PushedFilters: '[IsNotNull(id), GreaterThan(id,100)]'
    ReadSchema: struct<id:bigint>

```python
# pushdown partition filters and row (columnar) filters
res = df.filter('id>100 and (g=2 or g=3)').groupby('g').count()
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '2'
    PartitionFilters: '[((g#92 = 2) || (g#92 = 3))]'
    PushedFilters: '[IsNotNull(id), GreaterThan(id,100)]'
    ReadSchema: struct<id:bigint>

```python
# pushdown partition filters and row (columnar) filters
res = df.filter('id>100 and g>1').groupby('g').count()
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '2'
    PartitionFilters: '[isnotnull(g#92), (g#92 > 1)]'
    PushedFilters: '[IsNotNull(id), GreaterThan(id,100)]'
    ReadSchema: struct<id:bigint>

```python
# pushdown partition filters and row (columnar) filters can be added up
res = df.filter('id>100 and g>1').filter('id<500 and g=2').groupby('g').count()
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '1'
    PartitionFilters: '[isnotnull(g#92), (g#92 > 1), (g#92 = 2)]'
    PushedFilters: '[IsNotNull(id), GreaterThan(id,100), LessThan(id,500)]'
    ReadSchema: struct<id:bigint>

### When pushdown filters are NOT applied.

#### Avoid caching and actions of read data 
Avoid cache(), count() or other action on data, as they will act as a "wall" for filter operations to be pushed down the parquet reader. On the contrary, registering the dataframe as a temorary table is OK. Please be aware that these operation could be hidden in your function call stack, so be always sure that the filters are as close as possible to the read operation.

#### Spark will only read the same data once per session
Once a parquet file has been read in a cached/unfiltered way, any subsequent read operation will fail to push down the filters, as spark assumes that the data has already been loaded once.

```python
df = dfc.load('data/save/groups.parquet')
df.cache()
```

     [datafaucet] INFO parquet.ipynb:engine:load_log | load

    DataFrame[id: bigint, g: int]

```python
# pushdown partition filters and row (columnar) filters are ignored after cache, count, and the like
res = df.filter('id>100 and g=1').groupby('g').count()
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '4'
    PartitionFilters: '[]'
    PushedFilters: '[]'
    ReadSchema: struct<id:bigint>

```python
# re-read will not push down the filters ...
df = dfc.load('data/save/groups.parquet')
```

     [datafaucet] INFO parquet.ipynb:engine:load_log | load

```python
# pushdown partition filters and row (columnar) filters are ignored after cache, count, and the like
res = df.filter('id>100 and g=1').groupby('g').count()
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '4'
    PartitionFilters: '[]'
    PushedFilters: '[]'
    ReadSchema: struct<id:bigint>

