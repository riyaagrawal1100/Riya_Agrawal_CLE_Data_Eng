# Lab 3: API-to-Raw Ingestion

## About the Project
This project focuses on fetching data from a public API and storing it in an organized way. The original data is saved in JSON format, while selected information is converted into a CSV file for easy access and further use.

## Tools Used
- Python
- Requests library
- JSON and CSV

## What the Script Does
- Fetches data from the JSONPlaceholder public API.
- Saves the original API response as a JSON file along with basic ingestion details.
- Extracts useful fields and stores them in a CSV file.
- Retries the request if an error occurs.
- Saves the last successfully processed page so the next run can continue from there.

## Output
The raw JSON files are stored in `data/raw/`, and the processed CSV file is saved in `data/processed/`.
