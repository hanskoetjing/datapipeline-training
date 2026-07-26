create view gold.sum_products_ordered as
select soi.product_id, sp.product_name, cat.category_name,
sum(soi.quantity) as total_product_qty
from silver.order_items soi 
join silver.products sp 
on soi.product_id  = sp.product_id 
join silver.categories cat
on sp.category_id = cat.category_id
group by soi.product_id, sp.product_name, cat.category_name;
