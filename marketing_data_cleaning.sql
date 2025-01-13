-- Remove Duplicate Entries
CREATE TEMPORARY TABLE temp_duplicates AS
SELECT CustomerID, MIN(CustomerID) AS min_id
FROM digital_marketing_table
GROUP BY CustomerID
HAVING COUNT(*) > 1;

DELETE FROM digital_marketing_table
WHERE CustomerID IN (SELECT CustomerID FROM temp_duplicates)
AND CustomerID NOT IN (SELECT min_id FROM temp_duplicates);

-- Handle Missing Values (Replace NULLs with Median)
SET @median_adspend = (SELECT AVG(AdSpend) FROM digital_marketing_table WHERE AdSpend IS NOT NULL);

UPDATE digital_marketing_table
SET AdSpend = @median_adspend
WHERE AdSpend IS NULL;

-- Normalize ConversionRate (Standardization)
SET @avg_conversion = (SELECT AVG(ConversionRate) FROM digital_marketing_table);
SET @std_conversion = (SELECT STDDEV(ConversionRate) FROM digital_marketing_table);

UPDATE digital_marketing_table
SET ConversionRate = (ConversionRate - @avg_conversion) / @std_conversion;

-- Handle Negative or Incorrect Values
UPDATE digital_marketing_table
SET AdSpend = 0
WHERE AdSpend < 0;

UPDATE digital_marketing_table
SET ConversionRate = 1
WHERE ConversionRate > 1;

-- Format and Standardize Categorical Data
UPDATE digital_marketing_table
SET CampaignChannel = LOWER(CampaignChannel),
    CampaignType = LOWER(CampaignType);

