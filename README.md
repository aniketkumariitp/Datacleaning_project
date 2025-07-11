# 🧼 Layoffs 2022 – SQL Data Cleaning Project

This project is all about getting **messy real-world data** into a clean, analysis-ready state using **SQL**.  
The dataset tracks global tech layoffs during and post-pandemic years.

> 🛠️ Skills Used: SQL, Data Cleaning, CTEs, Window Functions, NULL Handling, Text Standardization

---

## 🚀 Objective

Raw data is often filled with:
- Duplicates 🪞
- Inconsistent text formatting 🧾
- Null or missing values ❌
- Weird characters and date formats 😩

This project walks through how to **systematically clean** the layoffs dataset using pure SQL inside MySQL Workbench.

---

## 📊 Cleaning Steps Overview

### 🔁 STEP 1: Remove Duplicates
Used `ROW_NUMBER()` with `PARTITION BY` to detect and remove duplicate rows based on key attributes.

### ✨ STEP 2: Standardize the Data
- Trimmed white spaces in text columns (like `company`, `country`)
- Fixed inconsistencies like `United States.` vs `United States`
- Converted `date` from string to proper `DATE` format

### ❓ STEP 3: Handle Null or Blank Values
- Replaced missing `industry` values by matching from the same company name
- Deleted rows with **no layoff data at all**

### 🧹 STEP 4: Final Cleanup
- Dropped the helper column `row_num`
- Previewed the final clean dataset

---

## 🧾 Key SQL Concepts Used

- `ROW_NUMBER()` + `CTE` to isolate duplicates
- `TRIM()` and `TRIM(TRAILING '.')` to clean strings
- `STR_TO_DATE()` to convert string to `DATE`
- `JOIN` to update NULL values from non-null duplicates
- Safe deletion using `SET SQL_SAFE_UPDATES = 0`

---

## 📂 Project Files

- `layoffs_data_cleaning.sql` → Full SQL script to reproduce the cleaning process step-by-step

---

## 📌 Before & After Snapshot

| Aspect            | Before                           | After                           |
|-------------------|-----------------------------------|----------------------------------|
| Duplicates        | ✅ Present                        | ❌ Removed                       |
| Inconsistent Text | `United States.`                 | `United States`                 |
| Missing Values    | `industry = NULL` for many rows  | 🛠 Filled using JOIN logic       |
| Dates             | `'1/5/2023' (as TEXT)`           | `2023-01-05` (as DATE)          |

---

## 🧠 Final Thoughts

Data cleaning is **80% of the work** in any real-world data project.  
This project was a great hands-on example of using SQL not just for querying, but for **preparing data for serious analysis**.



