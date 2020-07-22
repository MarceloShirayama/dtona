SELECT  
    DISTINCT T2.seller_id

FROM tb_orders AS T1

LEFT JOIN tb_order_items AS T2
ON T1.order_id = T2.order_id

WHERE order_approved_at 
BETWEEN '2017-04-01'
AND '2017-07-01'
AND T1.order_status = 'delivered'