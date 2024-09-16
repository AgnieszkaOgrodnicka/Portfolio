-- Cleaning Data in SQL Queries

SELECT * 
FROM public."NashvilleHousing"
;

-----------------------------------------------------------------

-- Standardize Date Format

SELECT 	sale_date, CAST(sale_date AS date)
FROM public."NashvilleHousing"
;

UPDATE public."NashvilleHousing" 
SET sale_date = CAST(sale_date AS date)
;

-----------------------------------------------------------------

-- Populate Property Address data

SELECT * 
FROM public."NashvilleHousing"
WHERE property_address IS NULL
ORDER BY parcel_id
;

	-- Self join to Fill Property Address

SELECT 	a.parcel_id, 
		a.property_address, 
		b.parcel_id, 
		b.property_address, 
		COALESCE(a.property_address, b.property_address) AS filled_property_addres
FROM "NashvilleHousing" a
JOIN "NashvilleHousing" b
	ON a.parcel_id = b.Parcel_id
	AND a.unique_id <> b.unique_id
WHERE a.property_address IS NULL
;

	-- Update Property Address

UPDATE public."NashvilleHousing" a
SET property_address = COALESCE(a.property_address, b.property_address)
FROM public."NashvilleHousing" b
WHERE a.parcel_id = b.Parcel_id
AND a.unique_id <> b.unique_id
AND a.property_address IS NULL
;

---------------------------------------------------------------------

-- Breaking out Address into Individual Columns (address, city, state)

	-- View Original Property Address
SELECT property_address
FROM public."NashvilleHousing" 
;

	-- Extract Address and City
SELECT 
SUBSTRING(property_address FROM 1 FOR position(',' in property_address) - 1) as address,
SUBSTRING(property_address FROM position(',' in property_address) + 1 FOR length(property_address)) as city
FROM public."NashvilleHousing" 
;

	-- Add Columns for Split Address Data
ALTER TABLE public."NashvilleHousing" 
ADD COLUMN property_split_address varchar
;

UPDATE public."NashvilleHousing" 
SET property_split_address = SUBSTRING(property_address FROM 1 FOR position(',' in property_address) - 1)
;
--
ALTER TABLE public."NashvilleHousing" 
ADD COLUMN property_split_city varchar
;

UPDATE public."NashvilleHousing" 
SET property_split_city = SUBSTRING(property_address FROM position(',' in property_address) + 1 FOR length(property_address))
;



	-- View Original Owner Address
SELECT owner_address
FROM public."NashvilleHousing"
;

	-- Extract Owner Address Components
SELECT
Split_part(owner_address, ',',1),
Split_part(owner_address, ',',2),
Split_part(owner_address, ',',3)
FROM public."NashvilleHousing"
;

	-- Add Columns for Owner Address Data
ALTER TABLE public."NashvilleHousing" 
ADD COLUMN owner_split_address varchar
;

UPDATE public."NashvilleHousing" 
SET owner_split_address = Split_part(owner_address, ',',1)
;
--
ALTER TABLE public."NashvilleHousing" 
ADD COLUMN owner_split_city varchar
;

UPDATE public."NashvilleHousing" 
SET owner_split_city = Split_part(owner_address, ',',2)
;
--
ALTER TABLE public."NashvilleHousing" 
ADD COLUMN owner_split_state varchar
;

UPDATE public."NashvilleHousing" 
SET owner_split_state = Split_part(owner_address, ',',3)
;

----------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (sold_as_vacant), COUNT(sold_as_vacant)
FROM public."NashvilleHousing"
GROUP BY sold_as_vacant
ORDER BY 2
;


	-- Convert Y and N to Yes and No
SELECT sold_as_vacant,
    CASE 
		WHEN sold_as_vacant = 'Y' THEN 'Yes'
        WHEN sold_as_vacant = 'N' THEN 'No'
        ELSE sold_as_vacant
    END 
FROM public."NashvilleHousing"
;

--

UPDATE public."NashvilleHousing"
SET sold_as_vacant = 
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

ALTER TABLE public."NashvilleHousing"
DROP COLUMN property_address, 
DROP COLUMN owner_address
;