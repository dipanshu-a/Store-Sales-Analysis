create database pizzahut;
use pizzahut;
create table orders (

order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

create table orders_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));


-- --Retrive the total number of order placed

select count(order_id) as Total_Order from orders;

-- Calculate the total number of revenue generated from pizza sales
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_Sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
    
-- Identify The highest-priced pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered

SELECT 
    quantity, COUNT(order_details_id)
FROM
    orders_details
GROUP BY quantity;


SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS Order_Count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY Order_count DESC;

-- list the top most 5 ordered pizza type along with their quantities.
SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;

-- Join The necessary tables to find the total quantity of each pizza category ordered
SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS total_quantity
FROM
    pizza_types
JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    total_quantity DESC;

-- Determine the distribution of order by hour of the day 

SELECT 
    HOUR(orders.order_time) AS hour,
    COUNT(orders.order_id) AS total_orders
FROM
    orders
GROUP BY HOUR(order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.


SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the order by date and calculate the average number of pizzas ordered per day

SELECT 
    ROUND(AVG(total_pizzas), 0) AS avg_pizzas_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(orders_details.quantity) AS total_pizzas
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE

SELECT 
    pizza_types.name AS pizza_type,
    SUM(orders_details.quantity * pizzas.price) AS total_revenue
FROM
    pizza_types
JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
JOIN
    orders ON orders.order_id = orders_details.order_id
GROUP BY 
    pizza_types.name
ORDER BY 
    total_revenue DESC
LIMIT 3;

-- Calculate the percentage of each pizza type to total revenue

SELECT 
    pizza_types.category AS pizza_type,
    ROUND(
        (SUM(orders_details.quantity * pizzas.price) / 
        (SELECT SUM(orders_details.quantity * pizzas.price)
         FROM orders_details
         JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id)
        ) * 100, 2
    ) AS revenue_percentage
FROM
    pizza_types
JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    revenue_percentage DESC;

-- Analyze the commulative revenue generated over time
SELECT 
    orders.order_date,
    SUM(orders_details.quantity * pizzas.price) AS daily_revenue,
    SUM(SUM(orders_details.quantity * pizzas.price)) 
        OVER (ORDER BY orders.order_date) AS cumulative_revenue
FROM
    orders
JOIN
    orders_details ON orders.order_id = orders_details.order_id
JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY 
    orders.order_date
ORDER BY 
    orders.order_date;

-- Determine the top 3 most ordered pizza types based on revenue pizza category.

SELECT 
    pizza_types.category,
    pizza_types.name AS pizza_type,
    SUM(orders_details.quantity * pizzas.price) AS total_revenue
FROM
    pizza_types
JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
JOIN
    orders ON orders.order_id = orders_details.order_id
GROUP BY 
    pizza_types.category, pizza_types.name
ORDER BY 
    pizza_types.category, total_revenue DESC;
