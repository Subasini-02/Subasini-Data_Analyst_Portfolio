# Data Cleaning of Electric Vehicle Population Dataset in MS SQL

This project focused on transforming a raw Electric Vehicle (EV) Population dataset into a clean, structured format using Microsoft SQL Server (MS SQL). The goal was to address common data quality issues such as inconsistencies, formatting errors, and missing values to prepare the dataset for meaningful analysis and reporting. The cleaning process improved the overall reliability of the data, making it suitable for use in analytics, dashboards, or integration with other systems.

The dataset contains detailed information about registered electric vehicles, including attributes such as Make, Model, Model Year, Electric Vehicle Type (e.g., Battery Electric or Plug-in Hybrid), Electric Range, Vehicle Location (city, ZIP code), and more. This data is typically used to study EV adoption trends, identify regional patterns, and support sustainability and infrastructure planning efforts. However, the raw data presented challenges such as inconsistent naming, missing location details, duplicate records, and improperly formatted fields.

### Key Tasks Performed:
- **Duplicate Handling:** Identified and removed duplicate records to maintain data integrity.

- **Standardization:**

  - Removed leading/trailing white spaces

  - Eliminated unnecessary punctuation (e.g., periods)

  - Corrected inconsistent entries in vehicle make/model and other text fields

- **Data Type Conversion:** Converted columns to appropriate data types (e.g., dates, integers, text).

- **Missing/Null Values:** Detected and handled missing or null values using replacement or exclusion techniques.

- **Irrelevant Data Removal:** Filtered out records outside the scope of analysis (e.g., incomplete entries, outdated formats).

- **Column Naming Conventions:** Renamed columns to follow SQL best practices (e.g., avoiding spaces, special characters, ensuring consistency).

This project not only ensured the dataset was clean and analysis-ready but also laid the foundation for more advanced insights into electric vehicle trends, policy planning, and environmental research.
