create view gold.sum_categories_ordered as
select cat.category_id , cat.category_name,
sum(soi.quantity) as total_category_ordered
from silver.order_items soi 
join silver.products sp 
on soi.product_id  = sp.product_id 
join silver.categories cat
on sp.category_id = cat.category_id
group by cat.category_id, cat.category_name;
