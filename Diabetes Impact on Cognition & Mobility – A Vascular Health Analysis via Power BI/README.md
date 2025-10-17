# Diabetes Impact on Cognition & Mobility – A Vascular Health Analysis via Power BI
This comprehensive data analysis project investigates the complex relationships between diabetes mellitus, vascular health complications, cognitive function, and mobility outcomes using Power BI. The study examines how diabetes duration, glycemic control, and diabetic retinopathy severity impact neurological and physical function in patients through advanced data visualization and interactive dashboards.

The analysis leverages Power BI's robust data modeling capabilities, DAX (Data Analysis Expressions) measures, and interactive visualization features to provide a multi-dimensional view of diabetes-related complications. By integrating metabolic markers (HbA1c, cholesterol, blood pressure), ophthalmological findings (retinopathy severity stages), and functional outcomes (cognitive scores, gait stability), this project delivers actionable clinical insights.

### Dataset Characteristics:

- **Sample Size:** 77 patients across multiple visits
- **Key Variables:** 100+ clinical parameters including diabetes duration, HbA1c levels, retinopathy severity, cognitive domain scores, blood pressure patterns, - lipid profiles, and gait metrics
- **Analysis Type:** Cross-sectional observational study with correlation and comparative analyses
- **Visit Structure:** Longitudinal data (Visit 2 and Visit 8) tracking patient progression

### Technologies Used:

- Power BI Desktop for data modeling and visualization
- Power Query (M language) for data transformation and cleaning
- DAX for calculated columns, measures, and advanced analytics
- Interactive multi-panel dashboard design with drill-through capabilities

### Data Preparation Highlights
- **Column Renaming**: Clarified 100+ cryptic fields with units
- **Race Labels**: Replaced codes (1–4) with full names for demographic clarity
- **Gender Imputation**: Filled nulls using cross-visit lookup logic
- **Age Logic**: Adjusted Visit 8 age using Visit 2 + 2 years
- **Tobacco Validation**: Set years used to 0 if no use was reported
- **Diabetes Duration Fix**: Ensured non-diabetics had duration = 0
- **Family History Parsing**: Converted abbreviations (e.g., "f, m") to full text ("Father, Mother")
- **History Counts**: Numeric fields for family history correlation
- **ACR Risk Stratification**: Created NORMAL, MODERATE, RISK categories
- **Unique Keys**: Combined Patient ID + Visit for proper modeling

### Analytical Framework
#### Descriptive Analytics
- Patient Demographics: Distribution by age, gender, race, diabetes duration
- Disease Prevalence: Glycemic control categories, retinopathy stages, comorbidities
- Clinical Characteristics: Blood pressure patterns, lipid profiles, kidney function
#### Correlation Analysis
- Examined relationships using scatter plots with trend lines
- Metabolic Factors: Cholesterol, blood pressure, HbA1c vs. cognitive scores
- Vascular Indicators: ACR levels vs. retinopathy severity
- Autonomic Function: 24-hour BP dip patterns vs. gait stability metrics
#### Comparative Analysis
- Diabetic vs. Non-Diabetic: Cognitive function, eye health, mobility outcomes
- Retinopathy Status: With vs. without retinopathy cognitive domain performance
- Metabolic Control: Poor, moderate, good control across all outcome measures
- ACR Risk Levels: Normal, moderate, risk categories impact assessment
#### Multi-Dimensional Analysis
- Cognitive Domains: Executive function, language, memory, processing speed
- Combined Risk: Retinopathy + cognitive decline stratification
- Severity Progression: Duration-dependent outcome deterioration

### Key Findings 
- **Critical Glycemic Control**
    - Only 20.45% of patients achieve normal glycemic control
    - 42.05% pre-diabetic (high conversion risk)
    - 37.5% diabetic-range HbA1c
    - 79.55% require immediate intervention
- **Duration-Based Disease Burden**
    - Medium duration (6-10 years) = 36.4% of cohort
    - 23.6% with >15 years diabetes duration
    - Clear correlation between duration and complication severity
- **Severe Retinopathy Crisis**
    - 45.1% proliferative diabetic retinopathy
    - 61% combined severe stages (Severe NPDR + Proliferative DR)
    - 23.53% moderate NPDR
- **Profound Cognitive Impact**
    - 4.3x higher impairment in diabetics (41% vs. 9.5%)
    - 76 (non-DM) vs. 23 (DM) = 3.3x difference
    - Language function (highest scores across groups)
- **Patients with poor metabolic control demonstrate**
   - Retinopathy score: 4.0 (highest clinical severity)
   - Cognitive damage: >1.5 standard deviations below normal
   - Good control outcomes: Near-baseline restoration across all parameters
- **Vascular Correlation Network**
   - Strong positive correlations identified
   - Cholesterol → Cognitive damage: r ≈ 0.45 (moderate correlation)
   - Blood pressure → Cognitive impairment: Clear positive trend
   - Glycemic control → Cognitive decline: Strongest predictor (r > 0.6)
   - 24h SBP dip → Gait stability: Non-linear U-shaped relationship
- **Eye-Brain Connection**
   - Diabetic cognitive impairment: 2.20 severity score
   - Non-diabetic: 0.52 score → 4.2x difference
   - Eye impairment gap: 31x difference (2.20 DM vs. 0.07 non-DM)
   - Shared microvascular pathology affects retina and brain simultaneously
- **ACR as Predictive Biomarker**
   - "RISK" category: Highest retinopathy (2.0) + lowest cognition (1.5)
   - "NORMAL" ACR: Better outcomes despite some vascular changes
   - Kidney-Brain-Eye Axis: ACR predicts multi-organ microvascular damage
- **Stratified Risk Distribution**
   - 44.16% high-risk retinopathy category
   - 22.08% moderate risk (both retinopathy + cognitive decline)
   - 22.08% low risk with decline but no retinopathy
   - 6.49% unknown/unclassified
   - 77.24% have identifiable vascular complication risk
- **Gait Stability Patterns**
   - Optimal dip zone at -0.2 to 0.0 24h SBP dip
   - High-density points at moderate dip values
   - Both non-dippers and extreme dippers show instability

### Conclusion

This Power BI analytics project successfully demonstrates the interconnected nature of diabetic complications across metabolic, vascular, ophthalmological, and neurological systems.Poor metabolic management predicts multisystem decline, while better control is associated with near-normal function, highlighting the need for early intervention, targeted screening, and multi-organ monitoring in diabetic patients.Through comprehensive data cleaning, sophisticated modeling, and interactive visualization, the dashboard provides healthcare stakeholders with actionable insights for improving patient outcomes.
argeted screening, and multi-organ monitoring in diabetic patients.with actionable insights for improving patient outcomes.

