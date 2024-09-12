-- Cleaning Data in SQL Queries

Select * 
From public."NashvilleHousing"
;
-----------------------------------------------------------------

-- Standardize Date Format

Select sale_date, cast(sale_date as date)
From public."NashvilleHousing"
;

Update public."NashvilleHousing" 
Set sale_date = cast(sale_date as date)
;
-----------------------------------------------------------------

-- Populate Property Address data

Select * 
From public."NashvilleHousing"
Where property_address is null
Order by parcel_id
;
	-- Self join

Select a.parcel_id, a.property_address, b.parcel_id, b.property_address, Coalesce(a.property_address, b.property_address)
From "NashvilleHousing" a
JOIN "NashvilleHousing" b
	ON a.parcel_id = b.Parcel_id
	AND a.unique_id <> b.unique_id
Where a.property_address is null
;
	-- Update

Update public."NashvilleHousing" a
Set property_address = Coalesce(a.property_address, b.property_address)
From public."NashvilleHousing" b
	Where a.parcel_id = b.Parcel_id
	AND a.unique_id <> b.unique_id
	AND a.property_address is null
;

---------------------------------------------------------------------

-- Breaking out Address into Individual Columns (address, city, state)

Select property_address
From public."NashvilleHousing" 
;

--

Select 
SUBSTRING(property_address FROM 1 FOR position(',' in property_address) - 1) as address,
SUBSTRING(property_address FROM position(',' in property_address) + 1 FOR length(property_address)) as city
From public."NashvilleHousing" 
;

--

ALTER TABLE public."NashvilleHousing" 
ADD COLUMN property_split_address varchar
;

Update public."NashvilleHousing" 
SET property_split_address = SUBSTRING(property_address FROM 1 FOR position(',' in property_address) - 1)
;


ALTER TABLE public."NashvilleHousing" 
ADD COLUMN property_split_city varchar
;

Update public."NashvilleHousing" 
SET property_split_city = SUBSTRING(property_address FROM position(',' in property_address) + 1 FOR length(property_address))
;



--

Select owner_address
From public."NashvilleHousing"
;

--

SELECT
Split_part(owner_address, ',',1),
Split_part(owner_address, ',',2),
Split_part(owner_address, ',',3)
From public."NashvilleHousing"
;

--

ALTER TABLE public."NashvilleHousing" 
ADD COLUMN owner_split_address varchar
;

Update public."NashvilleHousing" 
SET owner_split_address = Split_part(owner_address, ',',1)
;
--
ALTER TABLE public."NashvilleHousing" 
ADD COLUMN owner_split_city varchar
;

Update public."NashvilleHousing" 
SET owner_split_city = Split_part(owner_address, ',',2)
;
--
ALTER TABLE public."NashvilleHousing" 
ADD COLUMN owner_split_state varchar
;

Update public."NashvilleHousing" 
SET owner_split_state = Split_part(owner_address, ',',3)
;

----------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct (sold_as_vacant), count(sold_as_vacant)
From public."NashvilleHousing"
Group by sold_as_vacant
Order by 2
;

--

Select sold_as_vacant,
    CASE 
		WHEN sold_as_vacant = 'Y' THEN 'Yes'
        WHEN sold_as_vacant = 'N' THEN 'No'
        ELSE sold_as_vacant
    END 
FROM public."NashvilleHousing"
;

--

Update public."NashvilleHousing"
Set sold_as_vacant = 
	CASE 
		WHEN sold_as_vacant = 'Y' THEN 'Yes'
        WHEN sold_as_vacant = 'N' THEN 'No'
        ELSE sold_as_vacant
    END
;

---------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT unique_id,
           ROW_NUMBER() OVER (
               PARTITION BY parcel_id, 
			   				property_address, 
			   				sale_price, 
			   				sale_date, 
			   				legal_reference
               ORDER BY unique_id
           ) AS row_num
    FROM public."NashvilleHousing"
)
--DELETE FROM public."NashvilleHousing"
--WHERE unique_id IN (
SELECT unique_id 
FROM RowNumCTE
WHERE row_num > 1
--)
;

------------------------------------------------------------------------------


-- Delete Unused Columns

SELECT *
FROM public."NashvilleHousing"
;
--

ALTER TABLE "NashvilleHousing"
DROP COLUMN property_address, 
DROP COLUMN owner_address
;