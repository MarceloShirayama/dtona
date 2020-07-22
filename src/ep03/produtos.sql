SELECT * FROM tb_products LIMIT 1;

SELECT 
    product_category_name,
    count(1) 

FROM tb_order_items AS T1

LEFT JOIN tb_products AS T2
ON T1.product_id = T2.product_id

GROUP BY product_category_name
ORDER BY count(1) DESC
LIMIT 50 
;
