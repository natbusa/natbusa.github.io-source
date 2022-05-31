---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Data Science Q&A"
subtitle: "Interview with Prof. Roberto Zicari (www.odbms.org)"
authors: [natbusa]
tags: [analytics, data science]
categories: [meetups]
date: 2017-02-07
lastmod: 2017-02-07
featured: false
draft: true

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



I was kindly asked by Prof. Roberto Zicari to answer a few questions on Data Science and Big Data for www.odbms.org - Let me know what you think of it, looking forward to your feedback in the comment below. Cheers, Natalino

Q1. Is domain knowledge necessary for a data scientist?



It’s not strictly necessary, but it does not harm either. You can produce accurate models without having to understand the domain. However, some domain knowledge will speed up the process of selecting relevant features and will provide a better context for knowledge discovery in the available datasets.



Q2. What should every data scientist know about machine learning?



First of all, the foundation: statistics, algebra and calculus. Vector, matrix and tensor math is absolutely a must. Let’s not forget that datasets after all can be handled as large matrices! Moving on specifically on the topic of machine learning: a good understanding of the role of [bias and variance](https://en.wikipedia.org/wiki/Bias%E2%80%93variance_tradeoff) for predictive models. Understanding the reasons for models and parameters [regularization](https://en.wikipedia.org/wiki/Regularization_(mathematics)). Model [cross-validation](https://en.wikipedia.org/wiki/Cross-validation_(statistics)) techniques. Data [bootstrapping](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)) and [bagging](https://en.wikipedia.org/wiki/Bootstrap_aggregating). Also I believe that cost based, gradient iterative optimization methods are a must, as they implement the “learning” for four very powerful classes of machine learning algorithms: glm’s, boosted trees, svm and kernel methods, neural networks. Last but not least an introduction to Bayesian statistics as many



Q3. What are the most effective machine learning algorithms?



Regularized [Generalized Linear Models](https://en.wikipedia.org/wiki/Generalized_linear_model), and their further generalization as Artificial Neural Networks ([ANN’s](https://en.wikipedia.org/wiki/Artificial_neural_network)), [Boosted](https://en.wikipedia.org/wiki/Gradient_boosting) and [Random Forests](https://en.wikipedia.org/wiki/Random_forest). Also I am very interested in dimensionality reduction and unsupervised machine learning algorithms, such as [T-SNE](https://en.wikipedia.org/wiki/T-distributed_stochastic_neighbor_embedding), [OPTICS](https://en.wikipedia.org/wiki/OPTICS_algorithm), and [TDA](https://en.wikipedia.org/wiki/Topological_data_analysis).



Q4. What is your experience with data blending?



Blending data from different domains and sources might increases the explanatory power of the model. However, it’s not always easy to determine beforehand if this data will improve the models. Data blending provide more features and the may or may be not correlated with what you wish to predict. It’s therefore very important to carefully validate the trained model using cross validation and other statistical methods such as variances analysis on the augmented dataset.



Q5. Predictive Modeling: How can you perform accurate feature engineering/extraction?



Let’s tackle feature extraction and feature engineering separately. Extraction can be as simple as getting a number of fields from a database table, and as complicated as extracting information from a scanned paper document using [OCR](https://en.wikipedia.org/wiki/Optical_character_recognition) and image processing techniques. Feature extraction can easily be the hardest task in a given data science engagement.

Extracting the right features and raw data fields usually requires a good understanding of the organization, the processes and the physical/digital data building blocks deployed in a given enterprise. It’s a task which should never be underestimated as usually the predictive model is just as good as the data which is used to train it.



After extraction, there comes feature engineering. This step consists of a number of data transformations, oftentimes dictated by a combination of intuition, data exploration, and domain knowledge. Engineered features are usually added to the original samples’ features and provided as the input data to the model.



Before the renaissance of neural networks and hierarchical machine learning, feature engineering was as the models were too shallow to properly transform the input data in the model itself. For instance, [decision trees](https://en.wikipedia.org/wiki/Decision_tree) can only split data areas along the features’ axes, therefore to correctly classify donut shaped classes you will need feature engineering to transform the space to polar coordinates.



In the past years, however, models usually have multiple layers, as machine learning experts are deploying increasingly “deeper” models. Those models usually can “embed” feature engineering as part of the internal state representation of data, rendering manual feature engineering less relevant. For some examples applied to text check the section “Visualizing the predictions and the “neuron” firings in the RNN” in [The Unreasonable Effectiveness of Recurrent Neural Networks](http://karpathy.github.io/2015/05/21/rnn-effectiveness/). These models are also usually referred as “end-to-end” learning, although this definition it’s still vague not unanimously accepted in the AI and Data Science communities.



So what about feature engineering today? Personally, I do believe that some feature engineering is still relevant to build good predictive systems, but should not be overdone, as many features can be now learned by the model itself, especially in the audio, video, text, speech domains.



Q6. Can data ingestion be automated?



Yes. But beware of metadata management. In particular, I am a big supporter of “closed loop” analytics on metadata, where changes in the data source formats or semantics are detected by means of analytics and machine learning on the metadata itself.



Q7. How do you ensure data quality?



I tend to rely on the “wisdom of the crowd” by implementing similar analyses using multiple techniques and machine learning algorithms. When the results diverge, I compare the methods to gain any insight about the quality of both data as well as models. This approach works also well to validate the quality of streaming analytics: in this case the batch historical data can be used to double check the result in streaming mode, providing, for instance, end-of-day or end-of-month reporting for data correction and reconciliation.



Q8. What techniques can you use to leverage interesting metadata?



Fingerprinting is definitely an interesting field for metadata generation. I have worked extensively in the past on audio and video fingerprinting. However this technique is very general and can be applied to any sort of data: structure data, time series, etc. Data fingerprinting can be used to summarize web pages retrieved by users or to define the nature and the characteristics of data flows in network traffic. I also work often with time (event time, stream time, capture time), network data (ip/mac addresses, payloads, etc.) and geolocated information to produce rich metadata for my data science projects and tutorials.



Q9. How do you evaluate if the insight you obtain from data analytics is "correct" or "good" or "relevant" to the problem domain?



Initially, I interact with domain experts for a first review on the results. Subsequently, I make sure than the model is brought into “action”. Relevant insight, in my opinion, can always be assessed by measuring their positive impact on the overall application. If human interaction is in the loop, the easiest method is actually to measure the impact of the relevant insight in their digital journey.



Q10. What were your most successful data projects? And why?



1\. Geolocated data pattern analysis, because of its application to fraud prevention and personalized recommendations. 2. time series analytics for anomaly detection and forecasting of temporal signals - in particular for enterprise processes and KPI’s. 3. Converting images to features, because it allows images/videos to be indexed and classified using standard BI tools.



Q11. What are the typical mistakes done when analyzing data for a large scale data project? Can they be avoided in practice?



Aggregating too much will most of the time “flatten” signals in large datasets. To prevent this, try using more features, and/or provide a finer segmentation of the data space. Another common problem is “buring” signals provided by a small class of samples with those of a dominating class. Models discriminating unbalanced classes tend to perform worse as the dataset grows. To solve this problem try to rebalance the classes by applying stratified resampling, or weighting the results, or boosting on the weak signals.



Q12. What are the ethical issues that a data scientist must always consider?



1\. Respect individual privacy and possibly enforce it algorithmically. 2. Be transparent and fair on the use of the provided data with the legal entities and the individuals who have generated the data. 3. Avoid building models discriminating and scoring based on race, religion, sex, age etc as much as possible and be aware of the implication of reinforcing decisions based on the available data labels.



On last point, I would like to close this interview with an interesting idea around “equal opportunity” for ethical machine learning. This concept is visually explained on the following Google Research page [Attacking discrimination with smarter machine learning](https://research.google.com/bigpicture/attacking-discrimination-in-ml/) from a recent paper by [Hardt, Price, Srebro](https://drive.google.com/file/d/0B-wQVEjH9yuhanpyQjUwQS1JOTQ/view).
