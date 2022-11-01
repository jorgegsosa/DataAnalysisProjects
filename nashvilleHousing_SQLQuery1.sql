
--Cleaning Data in SQL
SELECT *
FROM PorfolioProject..nashvilleHousing


-- Standardize Date Fromat
Select SaleDateUpdated, CONVERT(date,SaleDate)
FROM PorfolioProject..nashvilleHousing

ALTER TABLE nashvilleHousing
ADD SaleDateUpdated Date;

Update PorfolioProject..nashvilleHousing
SET SaleDateUpdated= CONVERT(date,SaleDate)

--Populate Property Address data
Select PropertyAddress
FROM PorfolioProject..nashvilleHousing


Select PropertyAddress
FROM PorfolioProject..nashvilleHousing
where PropertyAddress is null

Select *
FROM PorfolioProject..nashvilleHousing
--where PropertyAddress is null
ORDER BY ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PorfolioProject..nashvilleHousing A
JOIN PorfolioProject..nashvilleHousing  B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PorfolioProject..nashvilleHousing A
JOIN PorfolioProject..nashvilleHousing  B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL




-- Breaking out address inti Individual columns 
Select PropertyAddress
FROM PorfolioProject..nashvilleHousing

SELECT 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Adress,
SUBSTRING( PropertyAddress,  CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Adress

FROM PorfolioProject..nashvilleHousing


ALTER TABLE nashvilleHousing
ADD PropertyAdressSplit Nvarchar(255);

Update PorfolioProject..nashvilleHousing
SET PropertyAdressSplit = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE nashvilleHousing
ADD PropertyAdressCity Nvarchar(255);

Update PorfolioProject..nashvilleHousing
SET PropertyAdressCity= SUBSTRING( PropertyAddress,  CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) 







Select OwnerAddress
FROM PorfolioProject..nashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PorfolioProject..nashvilleHousing

ALTER TABLE nashvilleHousing
ADD OwnerAdressSplit Nvarchar(255);

Update PorfolioProject..nashvilleHousing
SET OwnerAdressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE nashvilleHousing
ADD OwnerAdressCity Nvarchar(255);

Update PorfolioProject..nashvilleHousing
SET OwnerAdressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE nashvilleHousing
ADD OwnerAdressState Nvarchar(255);

Update PorfolioProject..nashvilleHousing
SET OwnerAdressState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PorfolioProject..nashvilleHousing
group by SoldAsVacant
order by 2



SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant ='N' THEN 'No'
		ELSE SoldAsVacant
		end
FROM PorfolioProject..nashvilleHousing

Update nashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant ='N' THEN 'No'
		ELSE SoldAsVacant
		end




--remove duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
	ORDER BY UniqueID) as row_num				
FROM PorfolioProject..nashvilleHousing
)
select *
from RowNumCTE
WHERE row_num > 1




--Select unused columns 
SELECT *
FROM PorfolioProject..nashvilleHousing
order by SoldAsVacant desc


ALTER TABLE PorfolioProject..nashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PorfolioProject..nashvilleHousing
DROP COLUMN SaleDate