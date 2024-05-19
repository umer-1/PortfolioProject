/*
Cleaning Data in SQL Queries

*/

Select * from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------
--Standarise Date format


Select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

ALTER Table NashvilleHousing
Add SaleDateConverted Date;



Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------
--Populate Property Address Data

Select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null
Order by ParcelID




Update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual columns (Address,City,State)
Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress ,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);


Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress ,1, CHARINDEX(',', PropertyAddress)-1)



ALTER Table NashvilleHousing
Add PropertySplitCity nvarchar(255);


Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
from PortfolioProject.dbo.NashvilleHousing



SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from PortfolioProject.dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);
Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);
Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER Table NashvilleHousing
Add OwnerSplitState nvarchar(255);
Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



SELECT *
from PortfolioProject.dbo.NashvilleHousing

---Change Y and N to Yes and No in "Sold as vacant" field.


SELECT Distinct SoldAsVacant, Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 Else 
		 SoldAsVacant
		 End
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant= CASE When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 Else 
		 SoldAsVacant
		 End
---------------------------------------------------------------------------------------------
--Remove Duplicates

With RowCTE as (
Select *,
ROW_NUMBER() over (
		PARTITION BY ParcelId,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 order By 
					 UniqueId) row_num
from PortfolioProject.dbo.NashvilleHousing
)
Select * from RowCTE
Where row_num > 1
ORDER By PropertyAddress

--------------------------------------------------------------------------------------
---Delete Unused Columns

Select Count(*) as no_columns from INFORMATION_SCHEMA.COLUMNS
Where table_catalog = 'PortfolioProject' AND table_name = 'NashvilleHousing'

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

SELECT * from PortfolioProject.dbo.NashvilleHousing