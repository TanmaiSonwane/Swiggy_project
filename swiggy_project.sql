select * from restaurants
	
--Finding total number of distinct-restaurants listed on swiggy 
select count(distinct name) from restaurants; -- 41505
	
-- total number city listed on swiggy
select  count(distinct city) from restaurants; --534

 -- total distinct cuisine listed on swiggy
select count(distinct cuisine) from restaurants; -- 108

-- city with most number of restaurants( considerning outlets)
select city,count(name) from restaurants
group by city
order by count desc 
limit 10; --( banglore, chennai, delhi, hyd, pune)

-- city with most number of customers
select city , sum (rating_count) from restaurants
group by city
order by sum(rating_count) desc;--(hyd,ban,chenn,del,kol)

-- avg rating of restaurants listed on swiggy
select round(avg(rating),2) from restaurants; -- 3.89

-- total consumers of swiggys as of now 
select sum(rating_count) from restaurants; -- 8664100

-- avg rating count of the restaurants listed on swiggy
select round(avg(rating_count),2) from restaurants; -- 141

--Which restaurant chain has the maximum number of outlets
select name, count(name) as outlets_ from restaurants
group by name
order by outlets_ desc
limit 10;	--(dominos.pizzahut,kfc,kwality,baskin)

--Which restaurant chain has generated the maximum revenue
select name, sum(cost*rating_count) as revenue from restaurants
group by name
order by revenue desc; --mcdonal,kfc,burger king,pizza hut,domino

--Which city has generated the maximum revenue all over India?
select city,sum(cost*rating_count) as revenue from restaurants
group by city
order by revenue desc ;--(hyd,ban,chenn,del,kol)

-- most revenue generating cuisine listed on swiggy
select cuisine, sum(rating_count*cost) as revenue from restaurants
group by cuisine
order by revenue desc; --north,biryani,chinese,south

-- most revenue generating individual restaurant(not considering outlets)
select name, city,(cost*rating_count) as revenue from restaurants
order by revenue desc;

--List the  most expensive cuisines.
select cuisine, avg(cost) from restaurants
group by cuisine
order by avg(cost) desc;(malysian,tribal,greek,streakhouse,japanese)

--List the  least expensive cuisines.
select cuisine, avg(cost) from restaurants
group by cuisine
order by avg(cost) asc;

-- List the top 5 cuisines as per the revenue generated by top 5 restaurants of every cuisine
select cuisine, sum(rating_count*cost) as revenue from 	
( 	select *, cost*rating_count, 
	row_number() over(partition by cuisine order by cost*rating_count desc) as rank
    from restaurants
) t 
where t.rank < 6
group by cuisine
order by revenue desc;

-- What is the of the total revenue generated by restaurants
select sum(rating_count*cost) as revenue from restaurants; --2647814350

-- What is the of the total revenue is generated by top 1% restaurants
select sum(cost*rating_count) as revenue from
	(select *, cost*rating_count, row_number() over(order by cost*rating_count desc) as rank
		from restaurants) t
	where t.rank <= 614;

-- Check the same for top 20% restaurants
select sum(cost*rating_count) as revenue from
	(select *, cost*rating_count, row_number() over(order by cost*rating_count desc) as rank
		from restaurants) t
	where t.rank <= 12280;

--  What % of revenue is generated by top 20% of restaurants with respect to total revenue?
with 
	q1 as (select sum(cost*rating_count) as top_revenue from
			(select *, cost*rating_count, row_number() over(order by cost*rating_count desc) as rank
				from restaurants) t
			where t.rank <= 12280),
	q2 as (select sum(cost*rating_count) as total_revenue from restaurants)
    
select round((top_revenue/total_revenue)*100,2) as revenue_perc from q1,q2;-- 75.08%

-- Finding the costliest city
SELECT DISTINCT city, 
       AVG(cost) OVER (PARTITION BY city) AS avg_cost
FROM restaurants
ORDER BY avg_cost desc;

-- List the restaurants whose cost is more than the average cost of the restaurants?
select * from (select *, avg(cost) over() as avg_cost from restaurants) 
as t where t.cost > t.avg_cost;

--  List the restaurants whose cuisine cost is more than the average cost?
select * from (select *, avg(cost) over(partition by cuisine) 
	as avg_cost from restaurants) t where t.cost > t.avg_cost; 

-- revenue generated by tiear-1 cities
select sum(cost*rating_count) as revenue from restaurants
where city in ('Bangalore','Chennai','Delhi','Mumbai','Pune','Hyderabad','Kolkata')
--1645323570

-- city with most number of restaurant having rating >4.5 
select city,count(name) from restaurants 
where rating>4.5
group by city
order by count(name) desc;

-- Finding number of restaurants lie in a particular rating range
SELECT CASE
           WHEN rating BETWEEN 1 AND 3 THEN 'Low'
           WHEN rating BETWEEN 3 AND 4.25 THEN 'Medium'
           WHEN rating BETWEEN 4.25 AND 4.75 THEN 'High'
           ELSE 'Excellent'
       END AS rating_segment,
       COUNT(*)
FROM restaurants
GROUP BY rating_segment;

-- finding total consumer and restaurants in city
select city, sum(rating_count) as customer, count(name) from restaurants
group by city
order by customer desc;

-- top 3 restaurants in each city revenue wise 
select name,city,cost*rating_count as revenue from (select *,cost*rating_count as revenue ,
row_number()over(partition by city order by cost*rating_count desc ) as rank
    from restaurants) t
where t.rank<4

-- top 3 restaurant in each city rating wise
select name,city,rating  from (select *,
row_number()over(partition by city order by rating desc ) as rank
    from restaurants) t
where t.rank<4 

-- top 3 resaturants in each city by number of customers
select name,city,rating_count  from (select *,
row_number()over(partition by city order by rating_count desc ) as rank
    from restaurants) t
where t.rank<4 

-- identifying top restaurants in each city whose rating> avg rating and cost < avg cost

WITH city_avg AS (
    -- Calculate the average rating and cost for each city
    SELECT 
        city,
        AVG(rating) AS avg_rating,
        AVG(cost) AS avg_cost
    FROM 
        restaurants
    GROUP BY 
        city
),
filtered_restaurants AS (
    -- Filter restaurants where rating > avg_rating and cost < avg_cost
    SELECT 
        r.name,
        r.city,
        r.rating,
        r.cost,
        ROW_NUMBER() OVER (
            PARTITION BY r.city 
            ORDER BY r.rating DESC, r.cost ASC
        ) AS rank
    FROM 
        restaurants r
    JOIN 
        city_avg ca 
    ON 
        r.city = ca.city
    WHERE 
        r.rating > ca.avg_rating
        AND r.cost < ca.avg_cost
)
    -- Select the top-ranked restaurants in each city
SELECT 
    name, 
    city, 
    rating, 
    cost
FROM 
    filtered_restaurants
WHERE 
    rank <4;

