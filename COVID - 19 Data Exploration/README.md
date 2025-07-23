# COVID-19 Data Exploration Project
This SQL-based project explores global COVID-19 data to analyze trends in cases, deaths, and vaccinations. The dataset includes two main tables: CovidDeaths and CovidVaccinations, which have been queried and transformed to derive insights on infection rates, mortality, and vaccine rollout.

### Objectives
- Analyze COVID-19 spread over time and by location
- Compare total cases to population and total deaths
- Evaluate global vaccination progress
- Track country-level trends using window functions, CTEs, temp tables, and views

### Key SQL Concepts Used
- **Filtering & Aggregation:**
    - Identified trends in total cases, deaths, and infection rates by country and continent.
    - Calculated death percentages and infection rates over time.
- **Data Transformation:**
    - Handled nulls and type conversions for accurate arithmetic.
    - Used window functions (SUM() OVER()) to track cumulative vaccinations.
- **Joins:**
    - Merged CovidDeaths and CovidVaccinations on matching location and date.
- **CTEs & Temp Tables:**
    - Created temporary storage and Common Table Expressions to structure and reuse logic.

