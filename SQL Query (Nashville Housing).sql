--Cleaning Data in SQL Queries,

----------------------------------------------------------------------------------------------------------------------------------------------
select * 
  FROM [portfolio project].[dbo].[NashvilleHousing]


--Standardize Date Format
------------------------------------------------


select SaleDateConverted,Convert(Date,SaleDate)
  FROM [portfolio project].[dbo].[NashvilleHousing]

Update NashvilleHousing 
Set SaleDate = Convert(Date,SaleDate)


Alter TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing 
Set SaleDateConverted = Convert(Date,SaleDate)

----------------------------------------------------------------------------------------------------------------------------------------------

----Populate Property Address data


select *
  FROM [portfolio project].[dbo].[NashvilleHousing]
  --where PropertyAddress is null
  order by ParcelID

  -----Nowhere we will make a Join to make sure that every ParcelId is Populate on PropertyAddress-----

  select a.ParcelID, b.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM [portfolio project].[dbo].[NashvilleHousing] a
  Join [portfolio project].[dbo].[NashvilleHousing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [portfolio project].[dbo].[NashvilleHousing] a
  Join [portfolio project].[dbo].[NashvilleHousing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-----------------------------------------------------------------------------------------------------------------------------------------------

--- Breaking Out Address into Individual Columns (Address, City, State)--

select PropertyAddress
  FROM [portfolio project].[dbo].[NashvilleHousing]
  --where PropertyAddress is null
  --order by ParcelID

  select
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
  ,
  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN (PropertyAddress)) as Address
  
  FROM [portfolio project].[dbo].[NashvilleHousing]


---------ADDING TWO MORE TABLES----

Alter TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)



Alter TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN (PropertyAddress)) 



------------Splitting Column-----
---------------------------------------------------------------------------------

select OwnerAddress
FROM [portfolio project].[dbo].[NashvilleHousing]

Select
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),3),
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),2),
PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),1)
FROM [portfolio project].[dbo].[NashvilleHousing]


Alter TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),3)

Alter TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),2)

Alter TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing 
Set OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),1)

select *
FROM [portfolio project].[dbo].[NashvilleHousing]

---------------------------------------------------------------------------------------------------------------------------------------------------------


---Change Y and N to Yes and NO in 'Sold as Vacant' Field-----


select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM [portfolio project].[dbo].[NashvilleHousing]
Group by SoldAsVacant
Order by 2


select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END

FROM [portfolio project].[dbo].[NashvilleHousing]

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END


--------------------------------------------------------------------------------------------------------------------------------------

----REMOVING DUPLICATES-------

WITH RowNumCTE as (
Select *,
      ROW_NUMBER() OVER(
	  PARTITION BY 
	             ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
	             ORDER BY
				 UniqueID
				) row_num

FROM [portfolio project].[dbo].[NashvilleHousing]
)
SELECT *
FROm RowNumCTE 
Where row_num > 1
Order by PropertyAddress


----------------------------------------------------------------------------------------------------------------------------------


-----DELETE UNUSED COlUMNS------



select *
FROM [portfolio project].[dbo].[NashvilleHousing]


ALTER TABLE [portfolio project].[dbo].[NashvilleHousing]
DROP COlUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

------------------------------------------------------------------------------------------------------------------------------------
