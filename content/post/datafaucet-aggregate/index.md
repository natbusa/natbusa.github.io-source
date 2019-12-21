---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Aggregating Dataframes"
subtitle: ""
summary: ""
authors: [natbusa]
tags: [analytics, pyspark, pandas]
categories: [datafaucet]
date: 2019-11-11T16:28:27+08:00
lastmod: 2019-11-11T16:28:27+08:00
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



Aggregations are an important step while processing dataframes and tabular data
in general. And therefore, they should be as simple as possible to implement.
Some notable data aggregation semantics are provided by pandas, spark and the SQL
language.

When designing an aggregation API method, the following characteristics make in
my opinion a good aggregation method.

-   easily perform aggregation on a column or a set of columns
-   easily perform multiple aggregation functions on the same columns
-   selectively perform differently aggregations on different columns

As an nice to have to this list, it would be nice to apply aggregation functions
by passing the function name as a string. A good aggregation method should allow
all the above with minimal amount of code required.

## Getting started

Let's start spark using datafaucet.


```python
import datafaucet as dfc
```


```python

dfc.engine('spark')
```




    <datafaucet.spark.engine.SparkEngine at 0x7fbdb66f2128>




```python

spark  = dfc.context()
```

## Generating Data


```python
df = spark.range(100)
```


```python
df = (df
    .cols.create('g').randint(0,3)
    .cols.create('n').randchoice(['Stacy', 'Sandra'])
    .cols.create('x').randint(0,100)
    .cols.create('y').randint(0,100)
)
```


```python
df.data.grid(5)
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
      <th>id</th>
      <th>g</th>
      <th>n</th>
      <th>x</th>
      <th>y</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>Sandra</td>
      <td>91</td>
      <td>89</td>
    </tr>
    <tr>
      <td>1</td>
      <td>1</td>
      <td>0</td>
      <td>Sandra</td>
      <td>19</td>
      <td>57</td>
    </tr>
    <tr>
      <td>2</td>
      <td>2</td>
      <td>2</td>
      <td>Sandra</td>
      <td>34</td>
      <td>97</td>
    </tr>
    <tr>
      <td>3</td>
      <td>3</td>
      <td>1</td>
      <td>Stacy</td>
      <td>35</td>
      <td>15</td>
    </tr>
    <tr>
      <td>4</td>
      <td>4</td>
      <td>2</td>
      <td>Sandra</td>
      <td>93</td>
      <td>90</td>
    </tr>
  </tbody>
</table>
</div>



## Pandas
Let's start by looking how Pandas does aggregations. Pandas is quite flexible on the points noted above and uses hierachical indexes on both columns and rows to store the aggregation names and the groupby values. Here below a simple aggregation and a more complex one with groupby and multiple aggregation functions.


```python
pf = df.data.collect()
```


```python
pf[['n', 'x', 'y']].agg(['max'])
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
      <th>n</th>
      <th>x</th>
      <th>y</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>max</td>
      <td>Stacy</td>
      <td>97</td>
      <td>98</td>
    </tr>
  </tbody>
</table>
</div>




```python
agg = (pf[['g','n', 'x', 'y']]
           .groupby(['g', 'n'])
           .agg({
               'n': 'count',
               'x': ['min', max],
               'y':['min', 'max']
           }))
agg
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead tr th {
        text-align: left;
    }

    .dataframe thead tr:last-of-type th {
        text-align: right;
    }
</style>
<table>
  <thead>
    <tr>
      <th></th>
      <th></th>
      <th>n</th>
      <th colspan="2" halign="left">x</th>
      <th colspan="2" halign="left">y</th>
    </tr>
    <tr>
      <th></th>
      <th></th>
      <th>count</th>
      <th>min</th>
      <th>max</th>
      <th>min</th>
      <th>max</th>
    </tr>
    <tr>
      <th>g</th>
      <th>n</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="2" valign="top">0</td>
      <td>Sandra</td>
      <td>9</td>
      <td>14</td>
      <td>75</td>
      <td>3</td>
      <td>98</td>
    </tr>
    <tr>
      <td>Stacy</td>
      <td>21</td>
      <td>10</td>
      <td>96</td>
      <td>8</td>
      <td>92</td>
    </tr>
    <tr>
      <td rowspan="2" valign="top">1</td>
      <td>Sandra</td>
      <td>20</td>
      <td>8</td>
      <td>91</td>
      <td>9</td>
      <td>91</td>
    </tr>
    <tr>
      <td>Stacy</td>
      <td>18</td>
      <td>2</td>
      <td>89</td>
      <td>4</td>
      <td>97</td>
    </tr>
    <tr>
      <td rowspan="2" valign="top">2</td>
      <td>Sandra</td>
      <td>12</td>
      <td>4</td>
      <td>97</td>
      <td>1</td>
      <td>98</td>
    </tr>
    <tr>
      <td>Stacy</td>
      <td>20</td>
      <td>4</td>
      <td>96</td>
      <td>0</td>
      <td>98</td>
    </tr>
  </tbody>
</table>
</div>



### Stacking 
In pandas, you can stack the multiple column index and move it to a column, as below. The choice of stacking or not after aggregation depends on wht you want to do later with the data. Next to the extra index, stacking also explicitely code NaN / Nulls for evry aggregation which is not shared by each column (in case of dict of aggregation functions.


```python
agg = pf[['g', 'x', 'y']].groupby(['g']).agg(['min', 'max', 'mean'])
agg = agg.stack(0)
agg
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
      <th></th>
      <th>max</th>
      <th>mean</th>
      <th>min</th>
    </tr>
    <tr>
      <th>g</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="2" valign="top">0</td>
      <td>x</td>
      <td>96</td>
      <td>50.966667</td>
      <td>10</td>
    </tr>
    <tr>
      <td>y</td>
      <td>98</td>
      <td>47.133333</td>
      <td>3</td>
    </tr>
    <tr>
      <td rowspan="2" valign="top">1</td>
      <td>x</td>
      <td>91</td>
      <td>45.026316</td>
      <td>2</td>
    </tr>
    <tr>
      <td>y</td>
      <td>97</td>
      <td>48.736842</td>
      <td>4</td>
    </tr>
    <tr>
      <td rowspan="2" valign="top">2</td>
      <td>x</td>
      <td>97</td>
      <td>58.750000</td>
      <td>4</td>
    </tr>
    <tr>
      <td>y</td>
      <td>98</td>
      <td>53.906250</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>



### Index as columns
Index in pandas is not the same as column data, but you can easily move from one to the other, as shown below, by combine the name information of the various index levels with the values of each level.


```python
agg.index.names
```




    FrozenList(['g', None])




```python

agg.index.get_level_values(0)
```




    Int64Index([0, 0, 1, 1, 2, 2], dtype='int64', name='g')



The following script will iterate through all the levels and create a column with the name of the original index level otherwise will use `_<level#>` if no name is available. Remember that pandas allows indexes to be nameless.


```python
levels = agg.index.names
for (name, lvl) in zip(levels, range(len(levels))):
    agg[name or f'_{lvl}'] = agg.index.get_level_values(lvl)
```


```python

agg.reset_index(inplace=True, drop=True)
agg
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
      <th>max</th>
      <th>mean</th>
      <th>min</th>
      <th>g</th>
      <th>_1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>96</td>
      <td>50.966667</td>
      <td>10</td>
      <td>0</td>
      <td>x</td>
    </tr>
    <tr>
      <td>1</td>
      <td>98</td>
      <td>47.133333</td>
      <td>3</td>
      <td>0</td>
      <td>y</td>
    </tr>
    <tr>
      <td>2</td>
      <td>91</td>
      <td>45.026316</td>
      <td>2</td>
      <td>1</td>
      <td>x</td>
    </tr>
    <tr>
      <td>3</td>
      <td>97</td>
      <td>48.736842</td>
      <td>4</td>
      <td>1</td>
      <td>y</td>
    </tr>
    <tr>
      <td>4</td>
      <td>97</td>
      <td>58.750000</td>
      <td>4</td>
      <td>2</td>
      <td>x</td>
    </tr>
    <tr>
      <td>5</td>
      <td>98</td>
      <td>53.906250</td>
      <td>0</td>
      <td>2</td>
      <td>y</td>
    </tr>
  </tbody>
</table>
</div>



## Spark (Python)
Spark aggregation is a bit simpler, but definitely very flexible, so we can achieve the same result with a little more work in some cases. Here below a simple example and a more complex one, reproducing the same three cases as above.


```python
df.select('n', 'x', 'y').agg({'n':'max', 'x':'max', 'y':'max'}).toPandas()
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
      <th>max(x)</th>
      <th>max(y)</th>
      <th>max(n)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>97</td>
      <td>98</td>
      <td>Stacy</td>
    </tr>
  </tbody>
</table>
</div>



Or with a little more work we can exactly reproduce the pandas case:


```python
from pyspark.sql import functions as F

df.select('n', 'x', 'y').agg(
    F.lit('max').alias('_idx'),
    F.max('n').alias('n'), 
    F.max('x').alias('x'), 
    F.max('y').alias('y')).toPandas()
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
      <th>_idx</th>
      <th>n</th>
      <th>x</th>
      <th>y</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>max</td>
      <td>Stacy</td>
      <td>97</td>
      <td>98</td>
    </tr>
  </tbody>
</table>
</div>



More complicated aggregation cannot be called by string and must be provided by functions. Here below a way to reproduce groupby aggregation as in the second pandas example:


```python
(df
    .select('g', 'n', 'x', 'y')
    .groupby('g', 'n')
    .agg(
        F.count('n').alias('n_count'),
        F.min('x').alias('x_min'),
        F.max('x').alias('x_max'),
        F.min('y').alias('y_min'),
        F.max('y').alias('y_max')
    )
).toPandas()
        
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
      <th>n</th>
      <th>n_count</th>
      <th>x_min</th>
      <th>x_max</th>
      <th>y_min</th>
      <th>y_max</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>0</td>
      <td>Sandra</td>
      <td>10</td>
      <td>17</td>
      <td>96</td>
      <td>8</td>
      <td>98</td>
    </tr>
    <tr>
      <td>1</td>
      <td>0</td>
      <td>Stacy</td>
      <td>20</td>
      <td>10</td>
      <td>92</td>
      <td>3</td>
      <td>86</td>
    </tr>
    <tr>
      <td>2</td>
      <td>1</td>
      <td>Stacy</td>
      <td>18</td>
      <td>4</td>
      <td>89</td>
      <td>4</td>
      <td>97</td>
    </tr>
    <tr>
      <td>3</td>
      <td>2</td>
      <td>Sandra</td>
      <td>14</td>
      <td>29</td>
      <td>96</td>
      <td>1</td>
      <td>98</td>
    </tr>
    <tr>
      <td>4</td>
      <td>1</td>
      <td>Sandra</td>
      <td>20</td>
      <td>2</td>
      <td>91</td>
      <td>4</td>
      <td>97</td>
    </tr>
    <tr>
      <td>5</td>
      <td>2</td>
      <td>Stacy</td>
      <td>18</td>
      <td>4</td>
      <td>97</td>
      <td>0</td>
      <td>96</td>
    </tr>
  </tbody>
</table>
</div>



### Stacking

Stacking, as in pandas, can be used to expose the column name on a different index column, unfortunatel stack is currently available only in the SQL initerface and not very flexible as in the pandas counterpart (https://spark.apache.org/docs/2.3.0/api/sql/#stack)

You could use pyspark `expr` to call the SQL function as explained here (https://stackoverflow.com/questions/42465568/unpivot-in-spark-sql-pyspark). However, another way would be to union the various results as shown here below.


```python
agg = pf[['g', 'x', 'y']].groupby(['g']).agg(['min', 'max', 'mean'])
a
```


```python
from pyspark.sql import functions as F

(df
    .select('g', 'x')
    .groupby('g')
    .agg(
        F.lit('x').alias('_idx'),
        F.min('x').alias('min'),
        F.max('x').alias('max'),
        F.mean('x').alias('mean')
    )
).union(
df
    .select('g', 'y')
    .groupby('g')
    .agg(
        F.lit('y').alias('_idx'),
        F.min('y').alias('min'),
        F.max('y').alias('max'),
        F.mean('y').alias('mean')
    )
).toPandas()
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
      <th>_idx</th>
      <th>min</th>
      <th>max</th>
      <th>mean</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>1</td>
      <td>x</td>
      <td>2</td>
      <td>91</td>
      <td>45.026316</td>
    </tr>
    <tr>
      <td>1</td>
      <td>2</td>
      <td>x</td>
      <td>4</td>
      <td>97</td>
      <td>58.750000</td>
    </tr>
    <tr>
      <td>2</td>
      <td>0</td>
      <td>x</td>
      <td>10</td>
      <td>96</td>
      <td>50.966667</td>
    </tr>
    <tr>
      <td>3</td>
      <td>1</td>
      <td>y</td>
      <td>4</td>
      <td>97</td>
      <td>48.736842</td>
    </tr>
    <tr>
      <td>4</td>
      <td>2</td>
      <td>y</td>
      <td>0</td>
      <td>98</td>
      <td>53.906250</td>
    </tr>
    <tr>
      <td>5</td>
      <td>0</td>
      <td>y</td>
      <td>3</td>
      <td>98</td>
      <td>47.133333</td>
    </tr>
  </tbody>
</table>
</div>



### Generatring aggregating code

The code above looks complicated, but is very regular, hence we can generate it! What we need is a to a list of lists for the aggregation functions as shown here below:


```python
dfs = []
for c in ['x','y']:
    print(' '*2, f'col: {c}')
    aggs = []
    for func in [F.min, F.max, F.mean]:
        f = func(c).alias(func.__name__)
        aggs.append(f)
        print(' '*4, f'func: {f}')
        
    dfs.append(df.select('g', c).groupby('g').agg(*aggs))
```

       col: x
         func: Column<b'min(x) AS `min`'>
         func: Column<b'max(x) AS `max`'>
         func: Column<b'avg(x) AS `mean`'>
       col: y
         func: Column<b'min(y) AS `min`'>
         func: Column<b'max(y) AS `max`'>
         func: Column<b'avg(y) AS `mean`'>


The dataframes in this generator have all the same columns and can be reduced with union calls


```python
from functools import reduce

reduce(lambda a,b: a.union(b), dfs).toPandas()
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
      <th>min</th>
      <th>max</th>
      <th>mean</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>1</td>
      <td>2</td>
      <td>91</td>
      <td>45.026316</td>
    </tr>
    <tr>
      <td>1</td>
      <td>2</td>
      <td>4</td>
      <td>97</td>
      <td>58.750000</td>
    </tr>
    <tr>
      <td>2</td>
      <td>0</td>
      <td>10</td>
      <td>96</td>
      <td>50.966667</td>
    </tr>
    <tr>
      <td>3</td>
      <td>1</td>
      <td>4</td>
      <td>97</td>
      <td>48.736842</td>
    </tr>
    <tr>
      <td>4</td>
      <td>2</td>
      <td>0</td>
      <td>98</td>
      <td>53.906250</td>
    </tr>
    <tr>
      <td>5</td>
      <td>0</td>
      <td>3</td>
      <td>98</td>
      <td>47.133333</td>
    </tr>
  </tbody>
</table>
</div>



## Meet DataFaucet agg

One of the goal of datafaucet is to simplify analytics, data wrangling and data
discovery over a set of engine with an intuitive interface. So the sketched
solution above is available, with a few extras. See below the examples

The code here below attempt to produce readable code, engine agnostic data
aggregations. The aggregation api is always in the form:   

`df.cols.get(...).groupby(...).agg(...)`

Alternativaly, you can `find` instead of `get`


```python

d = df.cols.get('x').agg('distinct')
d.data.grid()
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
      <th>x</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>64</td>
    </tr>
  </tbody>
</table>
</div>




```python

d = df.cols.get('x').agg(['distinct', 'avg'])
d.data.grid()
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
      <th>x_distinct</th>
      <th>x_avg</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>64</td>
      <td>51.2</td>
    </tr>
  </tbody>
</table>
</div>




```python

d = df.cols.get('x').agg(['distinct', 'avg'], stack=True)
d.data.grid()
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
      <th>_idx</th>
      <th>distinct</th>
      <th>avg</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>x</td>
      <td>64</td>
      <td>51.2</td>
    </tr>
  </tbody>
</table>
</div>




```python

d = df.cols.get('x').agg(['distinct', 'avg'], stack='colname')
d.data.grid()
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
      <th>colname</th>
      <th>distinct</th>
      <th>avg</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>x</td>
      <td>64</td>
      <td>51.2</td>
    </tr>
  </tbody>
</table>
</div>




```python

d = df.cols.get('x').agg(['distinct', F.min, F.max, 'avg'])
d.data.grid()
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
      <th>x_distinct</th>
      <th>x_min</th>
      <th>x_max</th>
      <th>x_avg</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>64</td>
      <td>2</td>
      <td>97</td>
      <td>51.2</td>
    </tr>
  </tbody>
</table>
</div>




```python

d = df.cols.get('x', 'y').agg(['distinct', F.min, F.max, 'avg'])
d.data.grid()
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
      <th>x_distinct</th>
      <th>x_min</th>
      <th>x_max</th>
      <th>x_avg</th>
      <th>y_distinct</th>
      <th>y_min</th>
      <th>y_max</th>
      <th>y_avg</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>64</td>
      <td>2</td>
      <td>97</td>
      <td>51.2</td>
      <td>67</td>
      <td>0</td>
      <td>98</td>
      <td>49.91</td>
    </tr>
  </tbody>
</table>
</div>




```python

d = df.cols.get('x', 'y').agg({
    'x':['distinct', F.min], 
    'y':['distinct', 'max']})

d.data.grid()
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
      <th>x_distinct</th>
      <th>x_min</th>
      <th>x_max</th>
      <th>y_distinct</th>
      <th>y_min</th>
      <th>y_max</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>64</td>
      <td>2</td>
      <td>None</td>
      <td>67</td>
      <td>None</td>
      <td>98</td>
    </tr>
  </tbody>
</table>
</div>




```python

d = df.cols.get('x', 'y').agg({
    'x':['distinct', F.min], 
    'y':['distinct', 'max']}, stack=True)
d.data.grid()
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
      <th>_idx</th>
      <th>distinct</th>
      <th>min</th>
      <th>max</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>x</td>
      <td>64</td>
      <td>2.0</td>
      <td>NaN</td>
    </tr>
    <tr>
      <td>1</td>
      <td>y</td>
      <td>67</td>
      <td>NaN</td>
      <td>98.0</td>
    </tr>
  </tbody>
</table>
</div>




```python

d = df.cols.get('x', 'y').groupby('g','n').agg({
    'x':['distinct', F.min], 
    'y':['distinct', 'max']}, stack=True)
d.data.grid()
```

### Extended list of aggregation

An extended list of aggregation is available, both by name and by function in the datafaucet library


```python
from datafaucet.spark import aggregations as A

d = df.cols.get('x', 'y').groupby('g','n').agg([
        'type',
        ('uniq', A.distinct),
        'one',
        'top3',
    ], stack=True)

d.data.grid()
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
      <th>n</th>
      <th>_idx</th>
      <th>type</th>
      <th>uniq</th>
      <th>one</th>
      <th>top3</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0</td>
      <td>1</td>
      <td>Stacy</td>
      <td>x</td>
      <td>int</td>
      <td>23</td>
      <td>67</td>
      <td>{32: 2, 25: 2, 39: 2}</td>
    </tr>
    <tr>
      <td>1</td>
      <td>0</td>
      <td>Stacy</td>
      <td>x</td>
      <td>int</td>
      <td>16</td>
      <td>74</td>
      <td>{70: 1, 74: 1, 19: 1}</td>
    </tr>
    <tr>
      <td>2</td>
      <td>2</td>
      <td>Sandra</td>
      <td>x</td>
      <td>int</td>
      <td>10</td>
      <td>40</td>
      <td>{4: 2, 97: 2, 69: 1}</td>
    </tr>
    <tr>
      <td>3</td>
      <td>1</td>
      <td>Sandra</td>
      <td>x</td>
      <td>int</td>
      <td>13</td>
      <td>52</td>
      <td>{56: 1, 8: 1, 2: 1}</td>
    </tr>
    <tr>
      <td>4</td>
      <td>0</td>
      <td>Sandra</td>
      <td>x</td>
      <td>int</td>
      <td>13</td>
      <td>79</td>
      <td>{36: 2, 89: 1, 35: 1}</td>
    </tr>
    <tr>
      <td>5</td>
      <td>2</td>
      <td>Stacy</td>
      <td>x</td>
      <td>int</td>
      <td>20</td>
      <td>45</td>
      <td>{61: 1, 34: 2, 70: 1}</td>
    </tr>
    <tr>
      <td>6</td>
      <td>2</td>
      <td>Stacy</td>
      <td>y</td>
      <td>int</td>
      <td>13</td>
      <td>98</td>
      <td>{30: 2, 66: 2, 35: 2}</td>
    </tr>
    <tr>
      <td>7</td>
      <td>0</td>
      <td>Stacy</td>
      <td>y</td>
      <td>int</td>
      <td>13</td>
      <td>57</td>
      <td>{36: 1, 57: 1, 25: 1}</td>
    </tr>
    <tr>
      <td>8</td>
      <td>1</td>
      <td>Sandra</td>
      <td>y</td>
      <td>int</td>
      <td>16</td>
      <td>79</td>
      <td>{97: 2, 82: 2, 15: 3}</td>
    </tr>
    <tr>
      <td>9</td>
      <td>2</td>
      <td>Sandra</td>
      <td>y</td>
      <td>int</td>
      <td>14</td>
      <td>40</td>
      <td>{1: 1, 98: 1, 7: 1}</td>
    </tr>
    <tr>
      <td>10</td>
      <td>1</td>
      <td>Stacy</td>
      <td>y</td>
      <td>int</td>
      <td>17</td>
      <td>76</td>
      <td>{4: 2, 86: 2, 67: 1}</td>
    </tr>
    <tr>
      <td>11</td>
      <td>0</td>
      <td>Sandra</td>
      <td>y</td>
      <td>int</td>
      <td>15</td>
      <td>24</td>
      <td>{64: 1, 8: 1, 53: 2}</td>
    </tr>
  </tbody>
</table>
</div>




```python

```
