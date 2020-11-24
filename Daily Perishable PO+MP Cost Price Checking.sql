-- Get The List (11,12,1262,25,61)
/*
select pv.id pvid,p.name
from product p
join productvariant pv on pv.productid=p.id
join product_category_mapping pcm on pcm.productid=p.id
where p.deleted=0
and pv.deleted=0
and pcm.categoryid in (1258)
and pcm.productid in (select productid from product_category_mapping pcm where pcm.categoryid in (61))
--,12,25,61,1262))
and pv.published=1
and pv.id not in
(select productvariantid from ProductVariantAvailabilityRestriction pvar 
where MarketPurchaseNotGuaranteed=1
group by productvariantid
having count(distinct warehouseid)>=11)
group by pv.id,p.name
order by 2 asc
*/


-- Getting PO Price

select pv.id,pv.name, t.costprice CostToday,pv.price MRP,BlockedInWarehouseCount,v.name Vendor,dbo.getenumname('CreationEventType',CreationEventType) CreationEventType,
pv.published Published, LastpriceSet
from thing t
join productvariant pv on pv.id=t.productvariantid
--join product p on p.id=pv.productid
join productvariantCategoryMapping pcm on pcm.ProductVariantId=pv.Id
join vendor v on v.id=pv.vendorid
join (select t.productvariantid, max(cast(dbo.tobdt(t.priceseton) as datetime)) LastPriceSet
from thing t
where priceseton is not null
and t.costprice is not null
and t.purchaseorderid is not null
group by t.productvariantid) la on la.LastPriceSet=cast(dbo.tobdt(t.priceseton) as datetime) and la.productvariantid=pv.id
left join (select productvariantid,count(distinct pvar.warehouseid) BlockedInWarehouseCount
from ProductVariantAvailabilityRestriction pvar 
where MarketPurchaseNotGuaranteed=1 group by productvariantid) re on re.ProductVariantId=pv.id
where t.costprice is not null
and t.priceseton is not null
and t.purchaseorderid is not null
and cast(dbo.tobdt(t.priceseton) as date)>=CONVERT (DATE,(dateadd(day,-7,dbo.ToBdt(GETDATE()))))
and cast(dbo.tobdt(t.priceseton) as date)<=CONVERT (DATE,dbo.ToBdt(GETDATE()))
and pcm.categoryid=1258
and pv.published=1
group by pv.id,pv.name,t.costprice,pv.price,BlockedInWarehouseCount,v.name,dbo.getenumname('CreationEventType',CreationEventType),pv.published,lastpriceset


-- Getting MarketPurchase Price

select pv.id,pv.name, max(t.costprice) CostToday,pv.price MRP,BlockedInWarehouseCount,v.name Vendor,dbo.getenumname('CreationEventType',CreationEventType) CreationEventType,
pv.published Published, LastpriceSet
from thing t
join productvariant pv on pv.id=t.productvariantid
--join product p on p.id=pv.productid
join vendor v on v.id=pv.vendorid
join productvariantCategoryMapping pcm on pcm.ProductVariantId=pv.Id
join (select t.productvariantid, max(cast(dbo.tobdt(t.priceseton) as datetime)) LastPriceSet
from thing t
where priceseton is not null
and t.costprice is not null
and t.creationeventtype in (4,7,9)
group by t.productvariantid) la on la.LastPriceSet=cast(dbo.tobdt(t.priceseton) as datetime) and la.productvariantid=pv.id
left join (select productvariantid,count(distinct pvar.warehouseid) BlockedInWarehouseCount
from ProductVariantAvailabilityRestriction pvar 
where MarketPurchaseNotGuaranteed=1 group by productvariantid) re on re.ProductVariantId=pv.id
where t.costprice is not null
and t.priceseton is not null
and t.creationeventtype in (4,7,9)
and pcm.categoryid=1258
and cast(dbo.tobdt(t.priceseton) as date)>=CONVERT (DATE,(dateadd(day,-7,dbo.ToBdt(GETDATE()))))
and cast(dbo.tobdt(t.priceseton) as date)<=CONVERT (DATE,dbo.ToBdt(GETDATE()))
and pv.id not in
(select productvariantid from ProductVariantAvailabilityRestriction pvar 
where MarketPurchaseNotGuaranteed=1
group by productvariantid
having count(distinct warehouseid)>=11)
and pv.id not in 
(select productvariantid from thing where costprice is not null and creationeventtype in (1,2,10) and priceseton is not null
and cast(dbo.tobdt(priceseton) as date)>=CONVERT (DATE,(dateadd(day,-7,dbo.ToBdt(GETDATE()))))
and cast(dbo.tobdt(priceseton) as date)<=CONVERT (DATE,dbo.ToBdt(GETDATE()))
)
group by pv.id,pv.name,pv.price,BlockedInWarehouseCount,v.name,dbo.getenumname('CreationEventType',CreationEventType),pv.published,lastpriceset



-- Getting Offer Products
select pv.Id, pv.Name,pv.ProductCost, pv.Price, pv.SpecialPrice, pv.SaleMarginPercent, (cast((pv.ProductCost+(pv.ProductCost*(pv.SaleMarginPercent/100))) as int)+1) SalePrice
from ProductVariant pv
join productvariantCategoryMapping pcm on pcm.ProductVariantId=pv.Id
where  ( pv.SaleMarginPercent is not null OR pv.SpecialPrice is not null )
and pcm.categoryid=1258









/*
-- Checking All Kind of Cost Prices Together

select t.ProductVariantId,dbo.getenumname('CreationEventType',creationeventtype) Events,
cast(dbo.tobdt(t.priceseton) as smalldatetime) PriceSetOn,count(*) Quantity,t.costprice UnitCostPrice,pv.price mrp,
t.PurchaseOrderId,t.MarketPurchaseInvoiceId,e.BadgeId,e.FullName,e.WarehouseId
from thing t 
join productvariant pv on pv.id=t.productvariantid
join product p on p.id=pv.productid
join employee e on e.id=t.PriceSetByEmployeeId
where t.ProductVariantId=4248
and t.CostPrice is not null
and t.priceseton is not null
group by t.productvariantid,pv.price,dbo.getenumname('CreationEventType',creationeventtype),cast(dbo.tobdt(t.priceseton) as smalldatetime),costprice,purchaseorderid,MarketPurchaseInvoiceId,badgeid,fullname,e.WarehouseId
order by 3 desc,4 desc
*/




-- Getting ProductVariantID
/*
select pv.id,p.name,p.deleted,pv.deleted
from productvariant pv 
join product p on pv.productid=p.id
where p.name like '%ginger thai%'
*/
/*
-- Getting Other Products (Not in 1258)

select pv.id,p.name, t.costprice CostToday,pv.price MRP,BlockedInWarehouseCount,v.name Vendor,dbo.getenumname('CreationEventType',CreationEventType) CreationEventType,
pv.published Published, LastpriceSet
from thing t
join productvariant pv on pv.id=t.productvariantid
join product p on p.id=pv.productid
join product_category_mapping pcm on pcm.productid=p.id
join vendor v on v.id=p.vendorid
join (select t.productvariantid, max(cast(dbo.tobdt(t.priceseton) as datetime)) LastPriceSet
from thing t
where priceseton is not null
and t.costprice is not null
group by t.productvariantid) la on la.LastPriceSet=cast(dbo.tobdt(t.priceseton) as datetime) and la.productvariantid=pv.id
left join (select productvariantid,count(distinct pvar.warehouseid) BlockedInWarehouseCount
from ProductVariantAvailabilityRestriction pvar 
where MarketPurchaseNotGuaranteed=1 group by productvariantid) re on re.ProductVariantId=pv.id
where t.costprice is not null
and t.priceseton is not null
and cast(dbo.tobdt(t.priceseton) as date)>=CONVERT (DATE,(dateadd(day,-7,dbo.ToBdt(GETDATE()))))
and cast(dbo.tobdt(t.priceseton) as date)<=CONVERT (DATE,dbo.ToBdt(GETDATE()))
and pcm.categoryid in (11,12,1262,25,61)
--and pv.id not in (3161,13670,10011)
and pv.id not in (select pv.id from productvariant pv 
join Product_Category_Mapping pcm on pcm.ProductId=pv.ProductId
where pcm.CategoryId=1258)
group by pv.id,p.name,t.costprice,pv.price,BlockedInWarehouseCount,v.name,dbo.getenumname('CreationEventType',CreationEventType),pv.published,lastpriceset

*/


















/*

select pv.id,p.name,t.costprice Costprice,pv.price MRP,
BlockedInWarehouseCount,v.name,dbo.getenumname('CreationEventType',CreationEventType) Events,pv.published,LastCreated
from thing t 
join productvariant pv on pv.id=t.ProductVariantId
join product p on p.id=pv.productid
join vendor v on v.id=p.vendorid
left join (select productvariantid,count(distinct pvar.warehouseid) BlockedInWarehouseCount
from ProductVariantAvailabilityRestriction pvar 
where MarketPurchaseNotGuaranteed=1 group by productvariantid) re on re.ProductVariantId=pv.id
join (select t.ProductVariantId,max(t.purchaseorderid) MaxPO,max(cast(dbo.tobdt(t.createdon) as date)) LastCreated
from thing t where 
t.CreationEventType in (1,2,10)
and t.costprice is not null
group by t.ProductVariantId) ma on ma.MaxPO=t.PurchaseOrderId and ma.ProductVariantId=pv.id
where 
t.CreationEventType in (1,2,10)
and t.costprice is not null
and p.deleted=0
and pv.deleted=0
and pv.id in
(6015,	6009,	6008,	6024,	6010,	9743,	6022,	6012,	21400,	10052,	14793,	16207,	16322,	6021,	10049,	6424,		8221,	6843,	7118,	6343,	5594,	9134,	6337,	8125,	5935,	6297,	6227,	8323,	6298,	8223,	11694,	8103,	9864,	8102,	5600,	6226,	10224,	5592,	5599,	6449,	6976,	6338,	5929,	6336,	5595,	5938,	5923,	19808,	19987,	5936,	6838,	10944,	6339,	6228,	6304,	5937,	6302,	7117,	6617,	8720,	5602,	11526,	5930,	9589,	7115,	20874,	6844,	5933,	7442,	5931,	6842,	7200,	6839,	18306,	6847,		7196,	7404,	9267,	10765,	3161,	21265,	3184,	4421,	9485,	4420,	4419,		4248,	8474,	15980,	9751,	5609,	3158,	15856,		10011,	13670,	8717,	9670)
group by pv.id,p.name,pv.price,t.costprice,v.name,dbo.getenumname('CreationEventType',CreationEventType),BlockedInWarehouseCount,pv.published,LastCreated
order by 9 asc

*/