---
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "The AI scene in the valley"
subtitle: "A field trip report"
summary: ""
authors: [natbusa]
tags: [analytics, ventures]
categories: [meetups]
date: 2017-02-07T16:28:27+08:00
lastmod: 2017-02-07T16:28:27+08:00
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

A few weeks back I was lucky enough to attend and present at the [Global AI Summit](http://globalbigdataconference.com/santa-clara/global-artificial-intelligence-conference/schedule-83.html) in the bay area. This is my personal trip report about the people I have met and some of the projects and startups I came across.  

**AI is eating the world.**  
First of all, let me start by saying that literally *everybody* is doing (or claiming to do) AI in the bay area. AI has inflamed the spirits of pretty much every single software engineer, data scientist, business developer, talent scout, and VC in the greater San Francisco area.  

All tools and services presented at the conference embed some form of machine intelligence, and scientists are the new cool kids on the block. Software engineering has probably reached an all-time low in terms of coolness in the bay area, and regarded almost as the "necessary evil" in order to unleash the next AI interface. This is somewhat counter-intuitive, as actually [Machine Learning and AI are more like the raisins in raisin bread](http://www.kdnuggets.com/2016/03/dont-buy-machine-learning.html), as Peter Norvig and [Marcos Sponton](http://twitter.com/marcossponton) say.  

**What's behind AI?**  
Good engineering, and great business focus is still the foundation of many AI-powered tools and services. In my opinion, there is no silver bullet: AI powered applications must still be based on good engineering practices if they want to succeed.  

We have seen a similar wave during the [dot-com](http://en.wikipedia.org/wiki/Dot-com_bubble) bubble in the beginning of the millennium when web-shops were popping up with little understanding of the underlying retail and marketplace businesses. Since then, web applications have matured and today we value those services both for their digital journey as much as for their operational excellence and their ability to deliver. I believe that a similar maturing path will happen for AI powered applications.  

AI is still a very opaque concept. In the worst case it could be just a scripted process, more often is a set of predictive machine learning models. Because of the vagueness of the term, others are branding new terms in order to differentiate themselves: machine intelligence, cognitive/sentient computing, intelligent computing. Advertising more AI-related terms is not really helping clarifying what is running under the hood. After some digging, startups operating in the AI space are mainly interpreting AI as some form of artificial/machine learning (aka [weak AI](http://en.wikipedia.org/wiki/Weak_AI)) tailored to very specific tasks.  

Today, with some exceptions, the term AI is used to describe [Artificial Neural Networks](http://en.wikipedia.org/wiki/Artificial_neural_network) (ANNs), and [Deep Learning](http://en.wikipedia.org/wiki/Deep_learning) (DL) mostly related to text, speech, image, and video processing. Putting the hype aside for a moment, without any doubts we can acknowledge that [the renaissance of deep learning](http://lecture2go.uni-hamburg.de/l2go/-/get/v/16622) has contributed to the development of conversational interfaces.  

The core of this new generation services might by still hard-coded or scripted, but the interface is going to be more and more flexible, understanding our spoken, text, and visual cues. This human-centric approach to UIs is definitely going to shape the way we interact with devices. This trend goes under the buzz of [Natural/Zero UIs](http://blog.careerfoundry.com/ui-design/what-is-zero-ui).  

Let's go deeper in the stack, away from the front-end and human-machine Natural UIs. [Narrow AI](http://en.wikipedia.org/wiki/Weak_AI), in particular deep learning and hierarchical predictive models are getting traction as core data components, in particular for applications such as [recommender systems](http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/45530.pdf), fraud detection, churn and propensity models, anomaly detection and data auditing.  

Before moving on the following list: I am not associated with any of these companies, however I did find their approach worth mentioning and good food for thoughts for the entrepreneurs and the data people following this blog. So, as always, take the following with a pinch of salt and apply your critical & analytical thinking to it. Enjoy :)  

[Numenta](http://numenta.com/applications/) is tackling one of the most important scientific challenges of all time: reverse engineering the neocortex. Studying how the brain works helps us understand the principles of intelligence and build machines that work on the same principles. They have invested heavily in time series research, anomaly detection and natural language processing. By converting text, and geo-spatial data to time series Numenta can detect patterns and anomalies in temporal data.  

[Recognos](http://www.recognos.com/smart-data-platform/)' main product "Smart Data Platform" is meant to normalize and integrate the data that is stored in unstructured, semi-structured and structured content. The data unification process is driven by the business ontology. Data extraction, taxonomy, semantic tagging and structured data mapping are all steps in this modern approach to data preparation and normalization. [Recognos](http://www.recognos.com/smart-data-platform/)' ultimate goal is to allow to use the data that is stored in the un-structured, semi-structured and structured content using a unique semantic meaning and unique query language.  

[Appzen](http://www.appzen.com/) is picking up the challenge of automating the auditing of expenses in real-time. This service collects all receipts, tickets, and other documentation provided and produces a full understanding of the who, where, and why of every expense. [Appzen](http://www.appzen.com/)'s machine learning engine verifies receipts, eliminates duplicates, and searches through hundreds of data sources to verify merchant identities and validate the truthfulness of every expense – ensuring there is no fraud, misuse, or violation of laws.  

[Talla](http://talla.com/features) is a lightweight system which plugs into messaging systems as a virtual team members, executing on-boarding, e-learning, and team building process flows, and engaging with the various team members, taking over from tasks which are usually done by team managers, scrum masters, and facilitating teams. It employs a combination of natural language processing, robotic process automation, and user- and company- defined rules.  

[Inbenta](http://www.inbenta.com/en/features/self-service/) has build an extensive multilingual knowledge supporting over 25 native languages and counting, including English, Spanish, Italian, Dutch and German. Its NLP engine understands the nuances of human conversation, so it answers a query based on meaning, not individual keywords. This is a good example of a company which relies on good business development and a great core team of linguistics and language experts. By combining these elements with NLP and Deep Learning techniques they can power [chatbots](http://medium.com/cyber-tales/ai-and-speech-recognition-a-primer-for-chatbots-a63af042526a#.o8svmik8j), email management, surveys and other text-based use cases for a number of verticals.  


[Lymba](http://www.lymba.com/knowledge-extraction-k-extractor.html) is also tackling textual information, with the goal of extracting insights and non-trivial bits of knowledge from a semantic graph of heterogeneous linked data elements. Lymba offers transformative capabilities that enable discovery of actionable knowledge from structured and unstructured data, providing business with invaluable insights. Lymba has developed a technology for deep semantic processing that extracts semantic relations between all concepts in the text. One of Lymba's product, the "K-extractor" enables intelligent search, question answering, summarization of a document, generating scientific profiles, etc.


[Jetlore](http://www.jetlore.com/dynamic-layouts/) is bringing personalization one step further by creating websites and mobile apps which are extremely tailored to each user, both in terms of content as well as layout, color, highlights, promotions, images, and offers. All site assets are ranked individually for each customer, and selected at the time of interaction based on the layout's configuration. Jetlore can select the best categories, brands, and collections of products from your inventory for each user, and automatically feature the best images to represent them. 


[Ownerlisten](http://ownerlistens.com/) is a smart messaging pipelining solution, rerouting messages in a given organization to the right person or process depending on the nature of the message. Users can filter and process messages combining business rules as well as automated text processing. This is essential in businesses where machine learned models might not be provide sufficiently accuracy for certain topics. [Ownerlisten](http://ownerlistens.com/) is another good example of how AI and NLP can be organically combined with user defined messaging and communication flows. By combining domain expertise, solid engineering and NLP engines, [ownerlisten](http://ownerlistens.com/) can deliver very smooth user and customer journeys in a number of different industries and use cases.


This list would not be complete without at least a company offering AI, Machine Learning, Data plumbing, Data engineering, API and Application engineering services. Software and data engineering, might be less cool a land of scientists, but it's still the backbone on top of which all those awesome solutions and products are built. [Data Monster](http://www.datamonsters.co/) is one of those great studios accelerating mvp and product development, with a strong affinity to data processing at scale and all the right techs in the basket (Scala, Python, R, Java, JavaScript, Hadoop, Spark, Hive, Play, Akka, MySQL, PostgreSQL, AWS, Cassandra, etc ).  


I finish this post mentioning and thanking a number of great people I have met during this trip, for their charisma and inspiring ideas and conversations:
[Hamid Pirahesh](http://www.linkedin.com/in/hamid-pirahesh-38368010/),
[David Talby](http://www.linkedin.com/in/davidtalby/),
[Alexy Khabrov](http://www.linkedin.com/in/chiefscientist/),
[Alexander Tsyplikhin](http://www.linkedin.com/in/atsyplikhin/),
[Christopher Moody](http://www.linkedin.com/in/chrisemoody/),
[Michael Feng](http://www.linkedin.com/in/mifeng/),
[Delip Rao](http://www.linkedin.com/in/deliprao/),
[Eldar Sadikov](http://www.linkedin.com/in/eldarsadikov/),
[Michelle Casbon](http://www.linkedin.com/in/michellecasbon/),
[Mustafa Eisa](http://www.linkedin.com/in/mustafameisa/),
[Ahmed Bakhaty](http://www.linkedin.com/in/ahmed-bakhaty/),
[Adi Bittan](http://www.linkedin.com/in/adibittan/),
[Jordi Torras](http://www.linkedin.com/in/jtorras/), and
[Francesco Corea](http://www.linkedin.com/in/francesco-corea-6b4b4a44/).
