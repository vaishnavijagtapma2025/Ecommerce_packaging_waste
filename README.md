# E-commerce Packaging Waste in Pune and Delhi: Survey Analysis

A primary-data project: I collected survey responses on how online shoppers in Maharashtra and Delhi feel about e-commerce packaging waste, cleaned them in **Stata**, and analysed them with **SQL (PostgreSQL)**.

## Data
- 113 survey responses (Google Forms), 27 questions
- Respondents: Maharashtra 52, Delhi 51, Other 10
- Topics: shopping habits, platform choice, packaging experience, willingness to pay, and policy preferences
- Limitation: 90 of 113 respondents are aged 18-25, so results describe a young online sample, not the cities' populations

## Tools
- Stata: cleaning and recoding
- PostgreSQL / pgAdmin: table design and analysis
- SQL: aggregation, `CASE`, window functions

## Project structure
```
stata/clean_packaging_survey.do   cleaning and recoding of the raw survey
sql/01_create_and_load.sql        creates the respondents table and loads the 113 responses
sql/02_analysis.sql               analysis queries, one question each
```

## Cleaning steps (Stata)
- Renamed 27 long question headers to short variable names
- Trimmed text, checked for duplicates, and confirmed rankings were within 1-5
- Recoded ordered answers (e.g. Never to Always) to numeric scores; "Not sure" set to missing
- Turned multi-select questions (platforms, products, materials, incentives, policies) into 0/1 columns
- Handled free-text platform answers such as "Blink it" and "big basket"

## How to run
1. Run `stata/clean_packaging_survey.do` (optional, since the SQL script already includes the cleaned data)
2. In pgAdmin, open a Query Tool on your database and run `sql/01_create_and_load.sql`
3. Run the queries in `sql/02_analysis.sql`

## Key findings
1. **Maharashtra respondents are more willing to pay extra.** 42.3% said "Yes, definitely" to paying Rs 5-20 more for eco-friendly packaging, against 25.5% in Delhi. Delhi also has about twice the share of clear refusals (25.5% vs 13.5%).
2. **Packaging sustainability is the lowest-ranked factor in both cities** when choosing a platform (average rank 2.80 in Delhi, 2.71 in Maharashtra, where 1 is most important), behind price and quality. Stated willingness to pay does not match how little it weighs in platform choice.
3. **Heavy shoppers see more excess packaging.** Those ordering more than 10 times a month average 3.00 on a 0-4 scale, against about 2.3 for others, although that group has only 6 people.
4. **Awareness of eco-packaging options is similar across age groups.** About 25-29% in each group were not aware the option existed.
5. **Plastic limits are the most popular policy in both cities** (35 of 51 in Delhi, 40 of 52 in Maharashtra). Delhi leans more towards tax incentives for businesses.
6. **Most people throw packaging away with household trash.** Proper recycling is more common in Maharashtra (11 respondents) than in Delhi (4).
7. **People who say companies are not doing enough rarely complain.** None of the 19 who hold that view has contacted a company, while 20 of the 32 who think companies are making significant efforts have.

## Caveats
- Small sample and skewed age profile, so differences between cities are indicative, not proven
- Ranking questions contain ties, so averages should be read as rough indicators
- Self-reported intentions, such as willingness to pay, often differ from actual behaviour
