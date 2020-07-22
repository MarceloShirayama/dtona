SELECT * FROM tb_order_items LIMIT 1;

SELECT
    T2.seller_id,
    T3.idade_base_dias,
    1 + CAST(T3.idade_base_dias / 30 AS Int) AS idade_base_mes,

    count(DISTINCT strftime('%m', T1.order_approved_at)) 
        AS qtde_mes_ativacao,
    CAST(count(DISTINCT strftime('%m', T1.order_approved_at))
            AS Float) /
            min(1 + CAST(T3.idade_base_dias / 30 AS Int), 6) 
            AS prop_ativacao,

    sum(T2.price) AS receita_total,
    sum(T2.price) / count(DISTINCT T2.order_id) AS avg_vl_vda,
    sum(T2.price) / 
        min(1 + CAST(T3.idade_base_dias / 30 AS Int), 6) 
        AS avg_vl_vda_mes,
    sum(T2.price) / count(DISTINCT strftime('%m', T1.order_approved_at)) 
        AS avg_vl_vda_mes_ativado,
    count(DISTINCT T2.order_id) as qtde_vdas,
    
    count(T2.product_id) AS qtde_prod,
    count(DISTINCT T2.product_id) AS qtde_prod_dist,
    sum(T2.price) / count(T2.product_id) as avg_vl_prod,
    count(T2.product_id) / count(DISTINCT T2.order_id) 
        AS avg_qtde_prod_vda
    
FROM tb_orders AS T1

LEFT JOIN tb_order_items AS T2
ON T1.order_id = T2.order_id

LEFT JOIN(
    SELECT
        T2.seller_id,
        max(CAST(julianday('2017-04-01') -
        julianday(T1.order_approved_at)
        AS Int)) AS idade_base_dias
        
    FROM tb_orders AS T1

    LEFT JOIN tb_order_items AS T2
    ON T1.order_id = T2.order_id

    WHERE
        -- 6 meses de janela
        T1.order_approved_at < '2017-04-01'
        -- pedidos realmente entregues
        AND T1.order_status = 'delivered'

    GROUP BY T2.seller_id
) AS T3
ON T2.seller_id = T3.seller_id

WHERE
    -- 6 meses de janela
    T1.order_approved_at 
    BETWEEN '2016-10-01'
    AND '2017-04-01'
    -- pedidos realmente entregues
    AND T1.order_status = 'delivered'

GROUP BY T2.seller_id
;

