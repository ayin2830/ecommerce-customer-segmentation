# RFM analysis, methodology and customer segmentation

## RFM analysis methodology
For each metric (recency, frequency and monetary value), I:
- wrote queries using aggregate functions to return a single value that corresponds to each customer. Note that orders with the order status "cancelled" or "unavailable" were not included.  
- normalized the aggregated data using min-max normalization. Using min-max normalization, the data set is rescaled such that all feature values are in the range [0, 1]. 

### Why normalize the data set?
Normalization assures that our data is set to a similar scale (in this case, a scale of 0-1) without distorting the ranges of values so that it can be used in the same manner across all other databases.
We are using min-max normalization to produce the RFM rankings. The min-max normalization formula is: x - min(x) / x(max) - x(min)


## R(ecency)
1. We write queries to show which customers made the most recent to least recent purchases.
2. We will use min-max normalization by using the formula: (The time x customer makes a purchase - earliest recorded purchase date) / (latest recorded purchase date -  earliest recorded purchase date)

    1. Normalizing the recency dataset is trickier then normalizing the other two datasets. This is because we are working with timestamps instead of floats or integers.  
    2. I normalized the recency data by converting the timestamps into **JULIANDATE** and substracting it from the earliest date recorded (also converted in Julian days).  
    3.  Normalization of data using this formula: Days between current date and earlies recorded purchase date / (Days between latest purchase date and earliest recorded purchase date)


### F(requency)
1. First, we write a query to total the amount of times each customer makes a purchase. 
2. Normalization of data using this formula: Amount of time(s) x customer makes a purchase - min(amount of customer purchases) / x(amount of customer purchases) - x(amount of customer purchases)



### M(onetary) Value
1. First, we write a query to total the amount of money each customer spent. Orders with the order status "cancelled" or "unavailable" were not included. 
2. Normalization of data using this formula: Amount of money x customer spends - min(amount of money a customer spends) / x(amount of customer purchases) - x(amount of money a customer spends)


## Customer Segmentation

### More methodology...
As mentioned above, the rfm scores of each customer is rescaled in such a way that all values are within the range [0,1]. Decimals are hard to decipher mentally. So we are going to convert customer rfm scores into integers! 
What I did was mulitiplied the rfm scores by 10 and rounded them off to the nearest integer (one decimal place). Now we have a ranking scale ranging from [0,6]. 

## 5 Segments!

1. **Champion** (RFM score of 4-6): These users splurge, makes frequent purchases and place reorders!
     *Recommendation: Don't have to do much.These users already trust Olist for their online purchases.*
2. **Loyal** (RFM score of 3): These users either splurge but not often, or doesn't spend too much but often make purchases.
     *Recommendation: Don't have to do much.These users already trust Olist for their online purchases, but not as much as the champion users. Might be beneficial to throw in some extra free shipping or other coupons once in a while. *
3. **Needs attention** (RFM score of 2): These users spend an OK amount of money and does notm make purhcases frequently. 
     *Recommendation: Spend most of the marketing budget on this segment! They are likely users of other e-commerce websites too. The goal is to make them convert to only using Olist. Therefore, the marketing team should focus on providing these users with weekly or fortnightly free shipping. Maybe advertise Olist more using Google Ads for these customers.*
4. **At risk** (RFM score of 1): These users barely made any significant purchases. 
     *Recommendation: Don't have to do much._They are probably avid users of other platforms, and only purchase from Olist seasonally.*
5. **Hibernating** (RFM score of 0): These users have not been active. 
     *Recommendation: These users probably have not opened the website in a long time. Send them push notifications!*




