---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Parquet Pushdown Filters"
subtitle: ""
summary: ""
authors: [natbusa]
tags: [analytics, pyspark,]
categories: [datafaucet]
date: 2019-12-24
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

Filters can be applied to parquet files to reduce the volume of the data loaded. In particular parquet objects support partition filters and regular row filtering. Spark dags if proprerly constructed can push down some of the filters to the parquet object reader. Here below you will fine a number of test cases when this works correctly and a number of scenario's where filters pushdown does not apply.  

```python
import datafaucet as dfc
```

```python
engine = dfc.engine('spark')
spark = engine.context
```

### Create a sample dataframe

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
      <td>2520</td>
    </tr>
    <tr>
      <td>1</td>
      <td>1</td>
      <td>2544</td>
    </tr>
    <tr>
      <td>2</td>
      <td>3</td>
      <td>2432</td>
    </tr>
    <tr>
      <td>3</td>
      <td>2</td>
      <td>2504</td>
    </tr>
  </tbody>
</table>
</div>

### Save data as a parquet object

```python
df.repartition('g').save('local', 'groups.parquet');
```

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

### Read data parquet objects

```python
df = dfc.load('data/save/groups.parquet')
```

#### Debugging the physical query plan

Here below we are going to debug the query plan. This can be done with the dataframe method `.explain()`

```python
df.explain()
```

To keep things simple let's focus only on the Parquet File Reader. In particular the function `explainSource(obj)` here below parses and prints out only some of the file reader parameters relevant for parquet filter and partition filter pushdown

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

### Testing Pushdown

This first test does not filter anything. However as you see the partitionj variable `g` is materialized in directories and does not appear in the readSchema, which only includes those columns which are not partitions

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

Counting does not require any column, therefore the next one effectely just count data-less rows

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

Filtering on a column which is not a partition triggers a columnar filter during read

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

Filters can be combined. For example here below a partition and a row (columnar) filter are part of the same filter statement

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

Filters can combined with logical operators

```python
# pushdown partition filters and row (columnar) filters
res = df.filter('id>100 and (g=2 or g=3)').groupby('g').count()
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '2'
    PartitionFilters: '[((g#265 = 2) || (g#265 = 3))]'
    PushedFilters: '[IsNotNull(id), GreaterThan(id,100)]'
    ReadSchema: struct<id:bigint>

Partition filters can also be greater-than and less-than predicates

```python
# pushdown partition filters and row (columnar) filters
res = df.filter('id>100 and g>1').groupby('g').count()
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '2'
    PartitionFilters: '[isnotnull(g#265), (g#265 > 1)]'
    PushedFilters: '[IsNotNull(id), GreaterThan(id,100)]'
    ReadSchema: struct<id:bigint>

Filters can be heaped up and cascaded. Effectively adding more filters will `AND`'ed together

```python
# pushdown partition filters and row (columnar) filters can be added up
res = df.filter('id>100 and g>1').filter('id<500 and g=2').groupby('g').count()
explainSource(res)
```

    Batched: 'true'
    Format: Parquet
    PartitionCount: '1'
    PartitionFilters: '[isnotnull(g#265), (g#265 > 1), (g#265 = 2)]'
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

```
