--productkey
--productid
--productname
--supplierid
--categoryname
--categorydescription

with stg_products as (
    select * from {{source('northwind','Products')}}
),
stg_categories as (
    select * from {{source('northwind','Categories')}}
)
SELECT 
    {{ dbt_utils.generate_surrogate_key(['productid'])}} as productkey,
    productid, productname, supplierid,
    categoryname, [Description] as categorydescription
  FROM stg_products p 
     join stg_categories c on p.CategoryID = c.CategoryID
