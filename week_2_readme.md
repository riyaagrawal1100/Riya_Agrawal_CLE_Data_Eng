# Week 2: Python Ingestion and Validation Pipeline

## Overview

This project implements a simple data ingestion and validation pipeline using Python and Pandas. It reads customer records from a CSV file and order event records from a JSON file, validates the data, and separates valid records from invalid records.

Invalid records are saved with rejection reasons to make data quality issues easier to identify and resolve. The pipeline also generates a summary report and maintains logs of the processing steps.

## Objectives

- Read structured data from CSV and JSON files.
- Validate required fields and identify missing values.
- Detect duplicate record IDs.
- Validate date formats.
- Separate valid and rejected records.
- Record rejection reasons for invalid data.
- Generate a summary of the ingestion process.
- Maintain logs for monitoring and troubleshooting.

## Technologies Used

- **Python** — pipeline logic and data processing
- **Pandas** — loading, validating, and manipulating tabular data
- **JSON** — reading order event data
- **Logging** — recording pipeline execution details
- **CSV** — storing input data and validation results

## Project Structure

```text
Week-2-Python-Ingestion-Validation/
│
├── config.json
├── requirements.txt
├── README.md
│
├── data/
│   ├── customers.csv
│   └── events.json
│
├── src/
│   ├── main.py
│   ├── ingestion.py
│   └── validation.py
│
├── output/
│   ├── clean_customers.csv
│   ├── rejected_customers.csv
│   ├── clean_events.csv
│   ├── rejected_events.csv
│   └── run_summary.csv
│
└── logs/
    └── ingestion.log
```

## Output Files

| File | Description |
|---|---|
| `clean_customers.csv` | Customer records that pass validation |
| `rejected_customers.csv` | Customer records that fail validation, with rejection reasons |
| `clean_events.csv` | Event records that pass validation |
| `rejected_events.csv` | Event records that fail validation, with rejection reasons |
| `run_summary.csv` | Summary of input, valid, and rejected record counts |
| `ingestion.log` | Log messages generated during pipeline execution |

## Setup and Installation

### Prerequisites

- Python 3.9 or later
- pip
- Git 


## Key Learning Outcomes

- Understanding CSV and JSON data ingestion in Python.
- Using Pandas DataFrames for data quality checks.
- Handling invalid records with clear rejection reasons.
- Applying logging and summary reports to a data pipeline.

