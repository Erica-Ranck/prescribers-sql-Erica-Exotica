-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT * 
FROM prescriber;

SELECT npi, total_claim_count
FROM prescriber as p1
JOIN prescription as p2
USING(npi)
ORDER BY total_claim_count DESC
LIMIT 1;

    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, total_claim_count
FROM prescriber as p1
JOIN prescription as p2
USING(npi)
ORDER BY total_claim_count DESC
LIMIT 1;

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count) total_claims
FROM prescriber
JOIN prescription
USING(npi) 
GROUP BY specialty_description
ORDER BY total_claims DESC
LIMIT 1;

-- Family Practice had the most claims


--     b. Which specialty had the most total number of claims for opioids?

SELECT DISTINCT specialty_description, SUM(total_claim_count) as opioid_count
FROM prescriber
JOIN prescription
USING(npi)
JOIN drug
USING(drug_name)
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY opioid_count DESC;

-- nurse practitioner had the highest count of opioid related claims at 900,845


--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT drug_name, MAX(total_drug_cost) as highest_price
FROM prescription
GROUP BY drug_name
ORDER BY highest_price DESC
LIMIT 1;

-- ESBRIET has the highest total_drug_cost at $2,829,174


--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**


SELECT drug_name,
	(SELECT ROUND(SUM(total_drug_cost)/SUM(total_30_day_fill_count),2)) as daily_cost
FROM prescription
GROUP BY drug_name
ORDER BY daily_cost DESC
LIMIT 1;

-- chenodal is the priciest per day at $86,741

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT 
	DISTINCT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type
FROM drug;
3260 results

SELECT 
	DISTINCT drug_name
FROM drug;
3253 results

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type,
	SUM(total_drug_cost) as money
FROM drug
JOIN prescription 
USING(drug_name)
GROUP BY drug_type
ORDER BY money DESC;

-- more was spent on opioids than antibiotics

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT * 
FROM cbsa
LIMIT 5;

SELECT COUNT(*)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

-- there are 56 cbsa's in TN


--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT DISTINCT cbsaname, SUM(population) as total_pop
FROM cbsa
LEFT JOIN zip_fips
USING(fipscounty)
LEFT JOIN population as p
USING(fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY total_pop DESC;
--memphis, TN has the largest combined pop at 67,870,189 and morristown, TN has the smallest pop at 1,163,520

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT 
	fipscounty as county,
	population
FROM population
WHERE fipscounty IN
	(SELECT cbsa
	FROM cbsa
	WHERE fipscounty IS NULL);
--county with highest pop is 47157



-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >=3000;

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT 
	p.drug_name, 
	p.total_claim_count,
	d.opioid_drug_flag AS is_opioid
FROM prescription as p
JOIN drug as d
USING(drug_name)
WHERE total_claim_count >=3000;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT 
	p.drug_name, 
	p.total_claim_count,
	d.opioid_drug_flag AS is_opioid
FROM prescription as p
JOIN drug as d
USING(drug_name)
WHERE total_claim_count >=3000;

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
