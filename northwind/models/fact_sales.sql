with
    stg_orders as (
        select
            orderid,
            {{ dbt_utils.generate_surrogate_key(["employeeid"]) }} as employeekey,
            {{ dbt_utils.generate_surrogate_key(["customerid"]) }} as customerkey,
            replace(to_date(orderdate)::varchar, '-', '')::int as orderdatekey,
        from {{ source("northwind", "Orders") }}
    ),
    stg_order_details as (
        select
            orderid,
            productid,
            sum(quantity) as quantity,
            sum(quantity * unitprice) as extendedpriceamount,
            sum(quantity * unitprice * discount) as discountamount,
            sum(quantity * unitprice * (1 - discount)) as soldamount
        from {{ source("northwind", "Order_Details") }}
        group by orderid, productid
    ),
    stg_products as (
        select
            productid,
            {{ dbt_utils.generate_surrogate_key(["productid"]) }} as productkey
        from {{ source("northwind", "Products") }}
    )
select
    stg_orders.employeekey,
    stg_orders.customerkey,
    stg_orders.orderdatekey,
    stg_products.productkey,
    stg_order_details.quantity,
    stg_order_details.extendedpriceamount,
    stg_order_details.discountamount,
    stg_order_details.soldamount
from stg_order_details
join stg_orders on stg_order_details.orderid = stg_orders.orderid
join stg_products on stg_products.productid = stg_order_details.productid
