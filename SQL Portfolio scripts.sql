/* The sample database used in this project was the classicmodels database. https://www.mysqltutorial.org/getting-started-with-mysql/mysql-sample-database/*/


/* Join the orders and products data, filter the orders to only include the shipped ones and calculate the value, margin and discount for each order line and also extract querter and year_month data from the order dates */

select distinct(orders.status) from orders -- checking what types of status are present in the column

select orderdetails.orderNumber, orders.orderDate, date_format(orders.orderDate, '%Y-%m') as yearMonth, quarter(orders.orderDate) as quarter,
orders.status, orders.customerNumber, orderdetails.productCode, orderdetails.quantityOrdered, orderdetails.priceEach,
orderdetails.priceEach*orderdetails.quantityOrdered as orderLineValue, products.productName, products.buyPrice, products.MSRP,
orderdetails.priceEach - products.buyPrice as margin, round(((orderdetails.priceEach - products.buyPrice) / orderdetails.priceEach) * 100, 1) as margin_in_percentage,
products.MSRP - orderdetails.priceEach as discount, round(((products.MSRP - orderdetails.priceEach) / products.MSRP) * 100, 1) as discount_in_percentage

from orderdetails
right join products on orderdetails.productCode = products.productCode

right join orders on orderdetails.orderNumber = orders.orderNumber
where orders.status = 'Shipped'



/* get the value of sales and direct costs of each product in each month*/

select date_format(orders.orderDate, '%Y-%m') as yearMonth, orderdetails.productCode,
sum(orderdetails.quantityOrdered * orderdetails.priceEach) as saleValue, sum(orderdetails.quantityOrdered * products.buyPrice) as directCost,
sum(orderdetails.quantityOrdered * orderdetails.priceEach) - sum(orderdetails.quantityOrdered * products.buyPrice) as aggMargin
 from orderdetails
right join orders on orderdetails.orderNumber = orders.orderNumber
right join products on orderdetails.productCode = products.productCode
where status = 'Shipped'
group by date_format(orders.orderDate, '%Y-%m'), productCode



/* Calculate average order quantity for each product line*/

select orderdetails.productCode, avg(orderdetails.quantityOrdered) as averageOrderQuantity, products.productLine from orderdetails
right join products on products.productCode = orderdetails.productCode
where orderdetails.productCode is not null
group by productLine
order by avg(orderdetails.quantityOrdered) desc


/* Find items that can run out of stock (sales in last month/quarter vs stock)*/

select orderdetails.productCode,date_format(orders.orderDate, '%Y-%m') as yearMonth, 
sum(orderdetails.quantityOrdered) as monthlyOrderQuant
 from orderdetails
right join orders on orderdetails.orderNumber = orders.orderNumber
where status = 'Shipped' and productCode = 'S18_1749'
group by  productCode, date_format(orders.orderDate, '%Y-%m')



/* Get data about sales to customers located in France and Germany*/

select date_format(orders.orderDate, '%Y-%m') as yearMonth, sum(orderdetails.quantityOrdered*priceEach) as orderLineValue, customers.country from orderdetails
left join orders on orderdetails.orderNumber = orders.orderNumber
left join customers on orders.customerNumber = customers.customerNumber
where country = 'France' or country = 'Germany'
group by date_format(orders.orderDate, '%Y-%m'), country
order by (date_format(orders.orderDate, '%Y-%m')) asc