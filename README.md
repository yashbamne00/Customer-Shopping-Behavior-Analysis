# Customer Shopping Behavior Analysis

A learning project that explores a 3,900-row shopping behavior dataset with pandas and PostgreSQL. It includes data cleaning and feature engineering, ten business questions answered in SQL, and a screenshot of the supplied dashboard. Results demonstrate analysis methods; they should not be treated as representative market research.

![Customer Behavior Dashboard](images/dashboard.png)

## Repository name

`customer-shopping-behavior-analysis`

## Project contents

```text
customer-shopping-behavior-analysis/
├── data/
│   └── raw/customer_shopping_behavior.csv
├── images/dashboard.png
├── notebooks/customer_shopping_behavior_analysis.ipynb
├── sql/customer_behavior_analysis.sql
├── .env.example
├── .gitignore
├── LICENSE
├── questions.txt
├── README.md
└── requirements.txt
```

## Dataset and reuse

The supplied CSV has 3,900 records and 18 columns. It resembles the [Shopping Behaviour Dataset on Kaggle](https://www.kaggle.com/datasets/saadaliyaseen/shopping-behaviour-dataset), but the original download provenance and its current reuse terms were not included with the files. Confirm the Kaggle dataset license and attribution requirements before publishing the CSV. If the license does not clearly allow redistribution, remove `data/raw/customer_shopping_behavior.csv` from the public repository and link readers to the source instead. The `LICENSE` in this repository covers this project's original code and documentation only; it does not grant rights to the dataset or dashboard software.

The rows contain customer IDs and demographic, location, and purchase attributes. They appear to be an educational/synthetic dataset, but that has not been independently confirmed. Do not replace this with real customer data or publish personal, confidential, or re-identifiable records. Consider dropping `customer_id` and reducing location detail if the data is not confirmed synthetic and openly licensed.

## Analysis notes

- The notebook fills missing review ratings with the median rating within each product category (37 missing values in the supplied copy).
- It standardizes column names, creates age bands (18–29, 30–44, 45–59, 60+), and maps purchase-frequency labels to approximate days. These days are a convenience for analysis, not observed intervals.
- `promo_code_used` exactly matches `discount_applied` in the supplied CSV, so the notebook drops the duplicate field after checking.
- SQL Q7 uses explicit illustrative thresholds: New = 1–10 previous purchases, Returning = 11–30, Loyal = 31+. Adjust these definitions to the project brief if needed.
- Q2 compares each discount-using customer's total qualifying spend against the mean transaction amount across all rows.

## Setup

1. Install Python 3.10 or newer and PostgreSQL. Create a database named `customer_behavior` (or use another database name in your connection string).
2. Clone the repository and enter the project directory.
3. Create and activate a virtual environment, then install dependencies:

   ```bash
   python -m venv .venv
   # Windows PowerShell
   .venv\Scripts\Activate.ps1
   # macOS/Linux: source .venv/bin/activate
   python -m pip install -r requirements.txt
   ```

4. Open `notebooks/customer_shopping_behavior_analysis.ipynb` in Jupyter and run all cells from the top. The PostgreSQL load cell is optional; set `DATABASE_URL` in your local environment first. For example, copy `.env.example` to `.env`, then load it with your preferred local environment manager. `.env` is ignored by Git. Never put a real password into notebook code or commit it.
5. Run `sql/customer_behavior_analysis.sql` against the database after the notebook has created/replaced the `customer` table.

The notebook expects the CSV at `data/raw/customer_shopping_behavior.csv` relative to the repository root.

## SQL overview

The query file answers the ten questions in `questions.txt`: revenue by gender, discount purchasers above average spend, highest-rated products, shipping comparison, subscription spend, discount rates by product, purchase-history segments, top three products per category, repeat-buyer subscription likelihood, and revenue by age band.

## Upload to GitHub

### GitHub website

1. First verify dataset redistribution rights as described above. Remove the CSV from the upload if rights are unclear.
2. Sign in to GitHub, choose **New repository**, and use `customer-shopping-behavior-analysis` as the repository name. Choose Public only after confirming dataset, screenshot, and other asset rights; otherwise choose Private or omit restricted files. Do not initialize with a README because this folder already contains one.
3. In the new repository, choose **Add file → Upload files** and upload the contents of this folder (including hidden files such as `.gitignore` and `.env.example`). Do not upload `.env`, virtual environments, database dumps, or credentials.
4. Review the staged file list, enter a commit message such as `Add customer shopping behavior analysis`, then commit.

### Git command line

From this project folder, after creating an empty GitHub repository:

```bash
git init
git add .
git status  # review the staged file list; confirm .env and restricted data are absent
git commit -m "Add customer shopping behavior analysis"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/customer-shopping-behavior-analysis.git
git push -u origin main
```

Replace `YOUR-USERNAME` with your GitHub username. If you remove the dataset, note its source URL in the README and provide it locally in the expected `data/raw/` path before running the notebook.
