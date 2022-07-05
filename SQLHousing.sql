-- ################     Data cleaning in SQL  ###################################### --

select * from [dbo].[Housing]


-- ################  STandardise Date format  #################################### --

select saleDate, convert(date, saleDate)
from [dbo].[Housing]

-- have it save in the table
update [dbo].[Housing]
set SaleDate = convert(date, saledate)

-- ########### Populate Property Adress data ####################### --
-- look at the data

Select *
from[dbo].[Housing]
-- where PropertyAddress is null
order by ParcelID

--- to deal with nulls, some parcel ids are the same so that property address can be found
-- join table to itself

-- finds all null addresses and checks them to addresses in the parcel id is the same
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [dbo].[Housing] a
Join [dbo].[Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- change the null address column to the address of the properties with the same parcel id
-select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) -- (if null the enter this0
from [dbo].[Housing] a
Join [dbo].[Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- update table
update a
set propertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [dbo].[Housing] a
Join [dbo].[Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- ########### breaking out address into individual columns (Address, city, state) ################# --

select PropertyAddress
from [dbo].[Housing]


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
-- from address take first value, up to the delimiter in address -- charindex is the index of the delimiter, use -1 to not include the comma
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address

from [dbo].[Housing]

-- add the columns to the table

ALTER TABLE [dbo].[Housing] -- create a column
add PropertySplitAddress nvarchar(255)

update [dbo].[Housing] -- update the column with values
set propertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);


ALTER TABLE [dbo].[Housing]
add PropertySplitCity nvarchar(255)

update [dbo].[Housing]
set propertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress));


select * from [dbo].[Housing]



-- owner address
select OwnerAddress
from [dbo].[Housing]

-- parse work backwards
select 
PARSENAME(REPLACE(ownerAddress, ',','.'),3), -- easiest way to seperate a substring
PARSENAME(REPLACE(ownerAddress, ',','.'),2),
PARSENAME(REPLACE(ownerAddress, ',','.'),1)
from [dbo].[Housing]


-- so alter tables and uopdate them
ALTER TABLE [dbo].[Housing] -- create a column
add OwnerSplitAddress nvarchar(255)

update [dbo].[Housing] -- update the column with values
set OwnerSplitAddress = PARSENAME(REPLACE(ownerAddress, ',','.'),3);

ALTER TABLE [dbo].[Housing] -- create a column
add OwnerSplitCity nvarchar(255)

update [dbo].[Housing] -- update the column with values
set OwnerSplitCity = PARSENAME(REPLACE(ownerAddress, ',','.'),2);


ALTER TABLE [dbo].[Housing]
add OwnerSplitState nvarchar(255)

update [dbo].[Housing]
set OwnerSplitState = PARSENAME(REPLACE(ownerAddress, ',','.'),1);

select * from [dbo].[Housing]

-- ######## Change Y and N to Yes and No in sold as vacant field ##########################

select distinct(soldasvacant), count(soldAsVacant)
from [dbo].[Housing]
group by SoldAsVacant
order by 2


-- how to change Y to yes and N to N
select SoldAsVacant,
case when soldasvacant = 'Y' Then 'Yes'
	 when soldasvacant = 'N' Then 'No'
	 else SoldAsVacant
	 end
from [dbo].[Housing]

-- Update the table
Update [dbo].[Housing]
set SoldAsVacant =
	case when soldasvacant = 'Y' Then 'Yes'
	 when soldasvacant = 'N' Then 'No'
	 else SoldAsVacant
	 end	


-- ########## Remove duplicates  ################################## --
-- not usually done in SQL, try not to delete data in a database

-- CTE is like a temp table
select *,
ROW_NUMBER() OVER (
Partition by parcelID,
PropertyAddress,
SalePrice,
SaleDate,
legalReference
Order by UniqueID) row_num
from [dbo].[Housing]
Order by ParcelID

-- Create CTE 
With RowNumCTE as (
	select *,
		ROW_NUMBER() OVER (
		Partition by parcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		legalReference
		Order by 
			UniqueID) row_num

from [dbo].[Housing]
		--Order by ParcelID
)
DELETE
from RowNumCTE -- Use delete to delete the duplicate rows
where row_num > 1
-- order by PropertyAddress


-- check if it worked
select *,
ROW_NUMBER() OVER (
Partition by parcelID,
PropertyAddress,
SalePrice,
SaleDate,
legalReference
Order by UniqueID) row_num
from [dbo].[Housing]
Order by ParcelID

-- Create CTE 
With RowNumCTE as (
	select *,
		ROW_NUMBER() OVER (
		Partition by parcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		legalReference
		Order by 
			UniqueID) row_num

from [dbo].[Housing]
		--Order by ParcelID
)
Select *
from RowNumCTE -- Use delete to delete the duplicate rows
where row_num > 1
order by PropertyAddress


-- ############### Delete Unused Columns #################
select *
from [dbo].[Housing]


Alter Table [dbo].[Housing]
drop column ownerAddress, taxdistrict, propertyAddress

Alter Table [dbo].[Housing]
drop column saledate