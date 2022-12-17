-- kişi başı sipariş sayısı ve toplam işlem tutarını bulunuz, buyukten küçüğe sıralayınız
-- find transaction number per customer and total orders cost for customer then rank it descending
select first_name, count(first_name) as order_count_per_person, sum(order_quantity * order_cost) as total_cost
from (select *
      from interviews.customers c
               left join interviews.orders o on o.cust_id = c.id) as sub1
group by sub1.first_name
order by total_cost desc


-- en çok para harcayan ilk 3 müşteri
-- first three customers who spend more
select first_name, last_name, sum(sub1.order_cost) as total_cost
from (select *
      from interviews.customers c
               left join interviews.orders o on c.id = o.cust_id) sub1
group by sub1.first_name, sub1.last_name
having sum(sub1.order_cost) > 0 -- null degerlerden kurtulmak için
order by total_cost desc
limit 3

-- şehirlerin ortalama harcamaları ilk 3
-- first 3 cities with average spent of cities
select city, avg(sub1.order_quantity * sub1.order_cost) total_cost, count(city) num_of_trans
from (select *
      from interviews.customers c
               left join interviews.orders o on c.id = o.cust_id) sub1
group by city
having avg(sub1.order_quantity * sub1.order_cost) > 0
order by num_of_trans desc
limit 3

-- hangi şehirden kaç sipariş verildi
-- how many orders cities have
select distinct city, count(first_name) from
(select * from interviews.customers c
          left join interviews.orders o on c.id = o.cust_id) sub1
where city is not null
group by city
order by count(first_name) desc

-- hangi üründen kaç tane  satılmış
-- how many times sold particular products
select distinct order_details,  sum(order_quantity) from interviews.orders
group by order_details


-- ülkeler kırılımında en çok para harcayan müşteri
-- sort the people who spend much more money than the others according to the cities
select first_name,last_name,city, sum(order_quantity*order_cost) total_spent from
    (select c.first_name,c.last_name,c.city,o.order_cost,o.order_quantity from interviews.customers c
left join interviews.orders o on c.id = o.cust_id) sub1
group by city,first_name, last_name
having sum(order_quantity*order_cost)  is not null
order by total_spent DESC


-- belirtilen iki tarih arasında kaç birimlik alışveriş yapılmış
-- how much money spent between specifick two date
select sum(order_quantity*order_cost) consumption from interviews.orders
where order_date between '2018-12-31' and '2019-03-10'


-- belirtilen iki tarih arasında nerelerden alışveriş yapılmış
-- where was shopping made from between specified dates
select distinct city from interviews.orders o
left join interviews.customers c on o.cust_id = c.id
where order_date between '2019-03-03' and '2019-04-03'