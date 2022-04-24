# RFM analysis, methodology and customer segmentation

## RFM analysis methodology
For each metric (recency, frequency and monetary value), I:
- wrote queries using aggregate functions to return a single value that corresponds to each customer. Note that orders with the order status "cancelled" or "unavailable" were not included.  

## R(ecency)
1. We write queries to show which customers made the most recent to least recent purchases.
2. Segment them from 1 to 5. 

    1. Normalizing the recency dataset is trickier then normalizing the other two datasets. This is because we are working with timestamps instead of floats or integers.  
    2. I normalized the recency data by converting the timestamps into **JULIANDATE** and substracting it from the earliest date recorded (also converted in Julian days). This measures customer recency based on customer orders x days after the first record (the greater the number, the more recent). 
    3.  Segmentation: 
           1. Group 1: purchased within the recent 3mos (730days - 640days after first record).
           2. Group 2: purhcased within the recent 3-6mos (640days - 550days after first record). 
           3. Group 3: purchased within the recent 6-9mos (550days - 460days afger first record). 
           4. Group 4: purchased within the recent 9-12mos (460-370 days after first record). 
           5. Group 5: purchased over a year ago (less than 370 days after first record). 

### F(requency)
1. First, we write a query to total the amount of times each customer makes a purchase. 
2. Segmentation: 
           1. Group 1:customer with <5x purchases.
           2. Group 2: customer with 4-5x purchases.
           3. Group 3: customer with 3x purchases.
           4. Group 4: customer with 2x purchases.
           5. Group 5: customer with 1x purchase.



### M(onetary) Value
1. First, we write a query to total the amount of money each customer spent. Orders with the order status "cancelled" or "unavailable" were not included. 
2. Segmentation: 
           1. Group 1: customer with expenditure above R$1000.
           2. Group 2: customer with expenditure at R$1000 - R$500.
           3. Group 3: customer with expenditure at R$500 - R$100.
           4. Group 4: customer with expenditure at R$100 range.
           5. Group 5: customer with expenditure below R$100.


## Customer Segmentation
**Loyal**: X1X
**Big spenders**: XX1
**Recent high potential**: 141, 142, 143, 241, 242, 243
**Needs attention**: 21X, 22X
**Average customer**: 33X, 34X
**About to sleep**: 4XX
**Lost high spenders**: 551, 552
**Lost low spenders**: 55X
**Other**: everything else




