SELECT
    '{date}' AS dt_ref,
    T2.seller_city,
    T2.seller_state,
    T1.*

FROM(

    SELECT
        T2.seller_id,
        round(avg(T5.review_score), 2) AS avg_review_score, -- media do score de reviews
        T3.idade_base_dias, -- dias desde a primeira venda
        1 + CAST(T3.idade_base_dias / 30 AS Int) AS idade_base_mes, -- meses desde a primeira venda
        CAST(julianday('{date}') -
            julianday(max(T1.order_approved_at)) AS Int)
            AS qtde_dias_ult_vda,
        count(DISTINCT strftime('%m', T1.order_approved_at)) 
            AS qtde_mes_ativacao, 
        round(CAST(count(DISTINCT strftime('%m', T1.order_approved_at))
            AS Float) /
            min(1 + CAST(T3.idade_base_dias / 30 AS Int), 6), 2)
            AS prop_ativacao, -- proporcao de meses em que vendedor vendeu

        sum(CASE
            WHEN 
                julianday(T1.order_estimated_delivery_date) <
                julianday(T1.order_delivered_customer_date) 
            THEN 1
            ELSE 0
            END) / count(DISTINCT T2.order_id) AS prop_atraso,
        CAST(avg(julianday(T1.order_estimated_delivery_date) - 
            julianday(order_purchase_timestamp)) AS Int)
            AS avg_tempo_entrega_est, -- tempo medio de entrega prevista

        round(sum(T2.price), 2) AS receita_total,
        round(sum(T2.price) / count(DISTINCT T2.order_id), 2) 
            AS avg_vl_vda,
        round(sum(T2.price) / 
            min(1 + CAST(T3.idade_base_dias / 30 AS Int), 6), 2) 
            AS avg_vl_vda_mes, -- receita média por mes simples
        round(sum(T2.price) / 
            count(DISTINCT strftime('%m', T1.order_approved_at)), 2) 
            AS avg_vl_vda_mes_ativado, -- receita média por mes em que vendedor ativa
        count(DISTINCT T2.order_id) as qtde_vdas,
        
        count(T2.product_id) AS qtde_prod,
        count(DISTINCT T2.product_id) AS qtde_prod_dist,
        round(sum(T2.price) / count(T2.product_id), 2) 
            AS avg_vl_prod,
        count(T2.product_id) / count(DISTINCT T2.order_id) 
            AS avg_qtde_prod_vda, -- media de produtos vendidos por venda
        
        -- Variáveis de volume de vendas por categoria de produto
        sum(CASE WHEN product_category_name = 'cama_mesa_banho' THEN 1 ELSE 0 END) AS qtde_cama_mesa_banho,
        sum(CASE WHEN product_category_name = 'beleza_saude' THEN 1 ELSE 0 END) AS qtde_beleza_saude,
        sum(CASE WHEN product_category_name = 'esporte_lazer' THEN 1 ELSE 0 END) AS qtde_esporte_lazer,
        sum(CASE WHEN product_category_name = 'moveis_decoracao' THEN 1 ELSE 0 END) AS qtde_moveis_decoracao,
        sum(CASE WHEN product_category_name = 'informatica_acessorios' THEN 1 ELSE 0 END) AS qtde_informatica_acessorios,
        sum(CASE WHEN product_category_name = 'utilidades_domesticas' THEN 1 ELSE 0 END) AS qtde_utilidades_domesticas,
        sum(CASE WHEN product_category_name = 'relogios_presentes' THEN 1 ELSE 0 END) AS qtde_relogios_presentes,
        sum(CASE WHEN product_category_name = 'telefonia' THEN 1 ELSE 0 END) AS qtde_telefonia,
        sum(CASE WHEN product_category_name = 'ferramentas_jardim' THEN 1 ELSE 0 END) AS qtde_ferramentas_jardim,
        sum(CASE WHEN product_category_name = 'automotivo' THEN 1 ELSE 0 END) AS qtde_automotivo,
        sum(CASE WHEN product_category_name = 'brinquedos' THEN 1 ELSE 0 END) AS qtde_brinquedos,
        sum(CASE WHEN product_category_name = 'cool_stuff' THEN 1 ELSE 0 END) AS qtde_cool_stuff,
        sum(CASE WHEN product_category_name = 'perfumaria' THEN 1 ELSE 0 END) AS qtde_perfumaria,
        sum(CASE WHEN product_category_name = 'bebes' THEN 1 ELSE 0 END) AS qtde_bebes,
        sum(CASE WHEN product_category_name = 'eletronicos' THEN 1 ELSE 0 END) AS qtde_eletronicos,
        sum(CASE WHEN product_category_name = 'papelaria' THEN 1 ELSE 0 END) AS qtde_papelaria,
        sum(CASE WHEN product_category_name = 'fashion_bolsas_e_acessorios' THEN 1 ELSE 0 END) AS qtde_fashion_bolsas_e_acessorios,
        sum(CASE WHEN product_category_name = 'pet_shop' THEN 1 ELSE 0 END) AS qtde_pet_shop,
        sum(CASE WHEN product_category_name = 'moveis_escritorio' THEN 1 ELSE 0 END) AS qtde_moveis_escritorio,
        sum(CASE WHEN product_category_name = 'consoles_games' THEN 1 ELSE 0 END) AS qtde_consoles_games,
        sum(CASE WHEN product_category_name = 'malas_acessorios' THEN 1 ELSE 0 END) AS qtde_malas_acessorios,
        sum(CASE WHEN product_category_name = 'construcao_ferramentas_construcao' THEN 1 ELSE 0 END) AS qtde_construcao_ferramentas_construcao,
        sum(CASE WHEN product_category_name = 'eletrodomesticos' THEN 1 ELSE 0 END) AS qtde_eletrodomesticos,
        sum(CASE WHEN product_category_name = 'instrumentos_musicais' THEN 1 ELSE 0 END) AS qtde_instrumentos_musicais,
        sum(CASE WHEN product_category_name = 'eletroportateis' THEN 1 ELSE 0 END) AS qtde_eletroportateis,
        sum(CASE WHEN product_category_name = 'casa_construcao' THEN 1 ELSE 0 END) AS qtde_casa_construcao,
        sum(CASE WHEN product_category_name = 'livros_interesse_geral' THEN 1 ELSE 0 END) AS qtde_livros_interesse_geral,
        sum(CASE WHEN product_category_name = 'alimentos' THEN 1 ELSE 0 END) AS qtde_alimentos,
        sum(CASE WHEN product_category_name = 'moveis_sala' THEN 1 ELSE 0 END) AS qtde_moveis_sala,
        sum(CASE WHEN product_category_name = 'casa_conforto' THEN 1 ELSE 0 END) AS qtde_casa_conforto,
        sum(CASE WHEN product_category_name = 'bebidas' THEN 1 ELSE 0 END) AS qtde_bebidas,
        sum(CASE WHEN product_category_name = 'audio' THEN 1 ELSE 0 END) AS qtde_audio,
        sum(CASE WHEN product_category_name = 'market_place' THEN 1 ELSE 0 END) AS qtde_market_place,
        sum(CASE WHEN product_category_name = 'construcao_ferramentas_iluminacao' THEN 1 ELSE 0 END) AS qtde_construcao_ferramentas_iluminacao,
        sum(CASE WHEN product_category_name = 'climatizacao' THEN 1 ELSE 0 END) AS qtde_climatizacao,
        sum(CASE WHEN product_category_name = 'moveis_cozinha_area_de_servico_jantar_e_jardim' THEN 1 ELSE 0 END) AS qtde_moveis_cozinha_area_de_servico_jantar_e_jardim,
        sum(CASE WHEN product_category_name = 'alimentos_bebidas' THEN 1 ELSE 0 END) AS qtde_alimentos_bebidas,
        sum(CASE WHEN product_category_name = 'industria_comercio_e_negocios' THEN 1 ELSE 0 END) AS qtde_industria_comercio_e_negocios,
        sum(CASE WHEN product_category_name = 'livros_tecnicos' THEN 1 ELSE 0 END) AS qtde_livros_tecnicos,
        sum(CASE WHEN product_category_name = 'telefonia_fixa' THEN 1 ELSE 0 END) AS qtde_telefonia_fixa,
        sum(CASE WHEN product_category_name = 'fashion_calcados' THEN 1 ELSE 0 END) AS qtde_fashion_calcados,
        sum(CASE WHEN product_category_name = 'eletrodomesticos_2' THEN 1 ELSE 0 END) AS qtde_eletrodomesticos_2,
        sum(CASE WHEN product_category_name = 'construcao_ferramentas_jardim' THEN 1 ELSE 0 END) AS qtde_construcao_ferramentas_jardim,
        sum(CASE WHEN product_category_name = 'agro_industria_e_comercio' THEN 1 ELSE 0 END) AS qtde_agro_industria_e_comercio,
        sum(CASE WHEN product_category_name = 'artes' THEN 1 ELSE 0 END) AS qtde_artes,
        sum(CASE WHEN product_category_name = 'pcs' THEN 1 ELSE 0 END) AS qtde_pcs,
        sum(CASE WHEN product_category_name = 'sinalizacao_e_seguranca' THEN 1 ELSE 0 END) AS qtde_sinalizacao_e_seguranca,
        sum(CASE WHEN product_category_name = 'construcao_ferramentas_seguranca' THEN 1 ELSE 0 END) AS qtde_construcao_ferramentas_seguranca,
        sum(CASE WHEN product_category_name = 'artigos_de_natal' THEN 1 ELSE 0 END) AS qtde_artigos_de_natal

    FROM tb_orders AS T1

    LEFT JOIN tb_order_items AS T2
    ON T1.order_id = T2.order_id

    LEFT JOIN(
        SELECT
            T2.seller_id,
            max(CAST(julianday('{date}') -
            julianday(T1.order_approved_at)
            AS Int)) AS idade_base_dias
            
        FROM tb_orders AS T1

        LEFT JOIN tb_order_items AS T2
        ON T1.order_id = T2.order_id

        WHERE
            -- 6 meses de janela
            T1.order_approved_at < '{date}'
            -- pedidos realmente entregues
            AND T1.order_status = 'delivered'

        GROUP BY T2.seller_id
    ) AS T3
    ON T2.seller_id = T3.seller_id

    LEFT JOIN tb_products AS T4
    ON T2.product_id = T4.product_id

    LEFT JOIN tb_order_reviews AS T5
    ON T1.order_id = T5.order_id

    WHERE
        -- 6 meses de janela
        T1.order_approved_at 
        BETWEEN date('{date}', '-6 months')
        AND '{date}'
        -- pedidos realmente entregues
        AND T1.order_status = 'delivered'

    GROUP BY T2.seller_id

) AS T1

LEFT JOIN tb_sellers AS T2
ON T1.seller_id = T2.seller_id

ORDER BY T1.qtde_vdas DESC

;

