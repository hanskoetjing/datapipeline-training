create view gold.pending_payments as
select sp.payment_id, sp.order_id, so.customer_id, 
sc.email, sc.phone, sp.method, sp.amount 
from silver.payments sp join silver.orders so 
on sp.order_id = so.order_id
join silver.customers sc on so.customer_id = sc.customer_id
where sp.status = 'pending';
