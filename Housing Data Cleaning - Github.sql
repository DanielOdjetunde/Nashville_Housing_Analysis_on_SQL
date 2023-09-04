select *
from HousingData

--Convert the SaleDate Column into date type for further analysis
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM HousingData;

ALTER TABLE	[Housing Data].dbo.HousingData
ADD SalesDateConverted Date;

UPDATE [Housing Data].dbo.HousingData
SET SalesDateConverted = CONVERT(Date, SaleDate);

ALTER TABLE [Housing Data].dbo.HousingData
DROP COLUMN SaleDate;

--Property address data
--There are multiple instances where there is no PropertyAddress. However, a property address is typical associated with a ParcelID so we might be able to populate the missing values
SELECT * 
FROM HousingData
WHERE PropertyAddress is Null
ORDER BY ParcelID;

-- If I select randomly the parcel ID of a row with no PropertyAddress, I see that there is another row with a parcel ID but no property address.
SELECT ParcelID, PropertyAddress
FROM HousingData
WHERE ParcelID = '025 07 0 031.00';

--If the parcel IDs are the same, chance are that the Property address is the same.
--We join the table to itself on the parcel ID and on rows in which the unique ID is different to eliminate duplicates
SELECT *
FROM [Housing Data].dbo.HousingData a
JOIN [Housing Data].dbo.HousingData b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ];

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Housing Data].dbo.HousingData a
JOIN [Housing Data].dbo.HousingData b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Lets break out addresses into address and city
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS 'Address',
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM [Housing Data].dbo.HousingData;

ALTER TABLE [Housing Data].dbo.HousingData
Add PropertySplitAddress Nvarchar(225);

UPDATE [Housing Data].dbo.HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE [Housing Data].dbo.HousingData
Add PropertySplitCity Nvarchar(225);

UPDATE [Housing Data].dbo.HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


-- Split the Owner's address into street, city and state

SELECT
PARSENAME(REPLACE (OwnerAddress, ',','.'), 3) As OwnerStreet,
PARSENAME(REPLACE (OwnerAddress, ',','.'), 2) As OwnerCity,
PARSENAME(REPLACE (OwnerAddress, ',','.'), 1) AS OwnerState
FROM [Housing Data].dbo.HousingData

ALTER TABLE [Housing Data].dbo.HousingData
Add OwnerStreet Nvarchar(225), OwnerCity Nvarchar(225), OwnerState Nvarchar(225); 

UPDATE [Housing Data].dbo.HousingData
SET OwnerStreet = PARSENAME(REPLACE (OwnerAddress, ',','.'), 3);

UPDATE [Housing Data].dbo.HousingData
SET OwnerCity = PARSENAME(REPLACE (OwnerAddress, ',','.'), 2);

UPDATE [Housing Data].dbo.HousingData
SET OwnerState = PARSENAME(REPLACE (OwnerAddress, ',','.'), 1);

-- Turn Y and N into Yes and No in the Sold as Vaccant field
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM [Housing Data].dbo.HousingData
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Housing Data].dbo.HousingData;

UPDATE [Housing Data].dbo.HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;

SELECT DISTINCT(LandUse)
FROM [Housing Data].dbo.HousingData;

--Create a column to see the number of owners. If there are multiple owners, there will be an & in the owner name.

SELECT LEN(OwnerName) - LEN(REPLACE(OwnerName, '&', '')) + 1
AS NumberOfOwners
FROM [Housing Data].dbo.HousingData

ALTER TABLE [Housing Data].dbo.HousingData
ADD NumberOfOwners tinyint;

UPDATE [Housing Data].dbo.HousingData
SET NumberOfOwners = LEN(OwnerName) - LEN(REPLACE(OwnerName, '&', '')) + 1;

SELECT* FROM [Housing Data].dbo.HousingData;