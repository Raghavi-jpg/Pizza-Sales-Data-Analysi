/*Retrieve the total number of orders placed.*/
SELECT 
    COUNT(order_id) AS 'total orders'
FROM
    orders;
    
/*Calculate the total revenue generated from pizza sales.*/
SELECT 
    SUM(orders_details.quantity * pizzas.price) AS 'total sales'
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;

/*Identify the highest-priced pizza.*/
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

/*Identify the most common pizza size ordered.*/
SELECT 
    pizzas.size, COUNT(orders_details.order_details_id) as order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
   GROUP BY size
   ORDER BY order_count DESC;

/*List the top 5 most ordered pizza types along with their quantities.*/
SELECT 
    NAME, SUM(quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.NAME
LIMIT 5;

 /*Join the necessary tables to find the total quantity of each pizza category ordered*/
SELECT 
    pizza_types.category, SUM(orders_details.quantity) as quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity;

 /*Determine the distribution of orders by hour of the day*/
SELECT 
    HOUR(order_time), COUNT(order_id) AS 'count_of_orders'
FROM
    orders
GROUP BY HOUR(order_time);

/*Join relevant tables to find the category-wise distribution of pizzas.*/
SELECT 
    COUNT(NAME), category
FROM
    pizza_types
GROUP BY category;

/*Group the orders by date and calculate the average number of pizzas ordered per day.*/
SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date,
            SUM(orders_details.quantity) AS 'quantity'
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS orders_quantity;

/*Determine the top 3 most ordered pizza types based on revenue.*/
 SELECT 
    name, sum(quantity * price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

/*Calculate the percentage contribution of each pizza type to total revenue.*/

SELECT 
    pizza_types.category,
   ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT ROUND(SUM(orders_details.quantity * pizzas.price),2) AS 'total sales' 
FROM
    orders_details
        JOIN
        pizzas ON pizzas.pizza_id = orders_details.pizza_id)*100,2) AS 'revenue'
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details
    ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY revenue DESC;    


/*Analyze the cumulative revenue generated over time.*/
SELECT order_date,
SUM(revenue) over(order by order_date) as cum_revenue
FROM
(SELECT order_date, SUM(quantity*price)as 'revenue'
FROM orders_details
JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id
JOIN orders
ON  orders.order_id = orders_details.order_id
GROUP BY order_date) as sales;

/*Determine the top 3 most ordered pizza types based on revenue for each pizza category*/
SELECT name,revenue
FROM
(SELECT category,name,revenue,
 rank() over(partition by category order by revenue desc) as rn
 FROM
(SELECT 
    name, category, SUM(quantity * price) AS 'revenue'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY category , name )as a) as b
WHERE rn <= 3;


