DROP TABLE IF EXISTS tb_abt_churn;
CREATE TABLE tb_abt_churn AS

SELECT
    T2.*,
    T1.flag_churn

FROM ( 

    SELECT
        T1.dt_ref, 
        T1.seller_id,
        min(coalesce(T2.vda, 1)) AS flag_churn

    FROM tb_book_sellers AS T1

    LEFT JOIN (
        SELECT
            strftime('%Y-%m',T1.order_approved_at) ||"-01" as dt_vda,
            T2.seller_id,
            max(0) as vda

        FROM tb_orders AS T1

        LEFT JOIN tb_order_items AS T2
        ON T1.order_id = T2.order_id

        WHERE dt_vda IS NOT NULL
        AND T2.seller_id IS NOT NULL
        AND T1.order_status = 'delivered'

        GROUP BY dt_vda, T2.seller_id

        ORDER BY T2.seller_id, dt_vda

    ) AS T2
    ON T1.seller_id = T2.seller_id
    AND T2.dt_vda
    BETWEEN T1.dt_ref
    AND date(T1.dt_ref, '+2 months')

    GROUP BY T1.dt_ref, T1.seller_id

    ORDER BY dt_ref

) AS T1

LEFT JOIN tb_book_sellers AS T2
ON T1.seller_id = T2.seller_id
AND T1.dt_ref = T2.dt_ref

ORDER BY T1.seller_id, T1.dt_ref
;

