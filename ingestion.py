import json
import os
import time
import csv
from datetime import datetime, timezone
from pathlib import Path
import requests

BASE_DIR = Path(__file__).resolve().parent
RAW_DIR = BASE_DIR / "data" / "raw"
PROCESSED_DIR = BASE_DIR / "data" / "processed"
STATE_FILE = BASE_DIR / "data" / "last_successful_page.txt"

API_URL = "https://jsonplaceholder.typicode.com/posts"
PAGE_SIZE = 10
MAX_PAGES_PER_RUN = 2
MAX_RETRIES = 3
TIMEOUT_SECONDS = 15


def utc_timestamp():
    """Return the current UTC time in a readable format."""
    return datetime.now(timezone.utc).isoformat()


def fetch_page(page):
    """Fetch one page and retry a few times if the request fails."""
    params = {"_page": page, "_limit": PAGE_SIZE}

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = requests.get(API_URL, params=params, timeout=TIMEOUT_SECONDS)
            response.raise_for_status()
            data = response.json()

            if not isinstance(data, list):
                raise ValueError("The API response was not a JSON list.")

            return data, response.url

        except (requests.RequestException, ValueError) as error:
            print(f"Page {page}, attempt {attempt}/{MAX_RETRIES} failed: {error}")
            if attempt < MAX_RETRIES:
                time.sleep(attempt * 2)
            else:
                raise RuntimeError(f"Could not fetch page {page} after {MAX_RETRIES} attempts.") from error


def save_raw_response(page, records, request_url):
    """Save raw records before doing any transformation."""
    ingested_at = utc_timestamp()
    payload = {
        "metadata": {
            "source": API_URL,
            "request_url": request_url,
            "ingested_at_utc": ingested_at,
            "page": page,
            "page_size": PAGE_SIZE,
            "record_count": len(records),
        },
        "data": records,
    }

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    filename = RAW_DIR / f"posts_page_{page}_{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}.json"
    with filename.open("w", encoding="utf-8") as file:
        json.dump(payload, file, indent=2, ensure_ascii=False)

    print(f"Saved raw response: {filename.relative_to(BASE_DIR)}")
    return filename


def transform_records(records, page):
    """Select a few useful fields for a simple table."""
    transformed = []
    for record in records:
        transformed.append({
            "id": record.get("id"),
            "user_id": record.get("userId"),
            "title": record.get("title", ""),
            "body": record.get("body", ""),
            "source_page": page,
        })
    return transformed


def save_processed_csv(rows):
    """Write the selected fields to a CSV file."""
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    output_file = PROCESSED_DIR / "posts_processed.csv"
    fieldnames = ["id", "user_id", "title", "body", "source_page"]

    # Append rows from successful pages while keeping a header.
    file_exists = output_file.exists()
    mode = "a" if file_exists else "w"
    with output_file.open(mode, newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        if not file_exists:
            writer.writeheader()
        writer.writerows(rows)

    print(f"Saved processed rows: {output_file.relative_to(BASE_DIR)}")


def get_start_page():
    """Continue from the last successful page on the next run."""
    if STATE_FILE.exists():
        try:
            return int(STATE_FILE.read_text(encoding="utf-8").strip()) + 1
        except (ValueError, OSError):
            print("Could not read saved page state; starting from page 1.")
    return 1


def save_last_successful_page(page):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(str(page), encoding="utf-8")


def main():
    start_page = get_start_page()
    pages_completed = 0

    print("Starting API-to-raw ingestion...")
    print(f"Source: {API_URL}")
    print(f"Starting page: {start_page}")

    for page in range(start_page, start_page + MAX_PAGES_PER_RUN):
        try:
            records, request_url = fetch_page(page)

            if not records:
                print(f"Page {page} returned no records. Stopping.")
                break

            # Save the unmodified API records first, before transformation.
            save_raw_response(page, records, request_url)

            rows = transform_records(records, page)
            save_processed_csv(rows)

            save_last_successful_page(page)
            pages_completed += 1
            print(f"Page {page} completed successfully ({len(records)} records).")

        except Exception as error:
            print(f"INGESTION FAILED on page {page}: {error}")
            print("The failed page was not marked as successful. Fix the issue and rerun.")
            break

    print(f"Ingestion finished. Pages completed this run: {pages_completed}")


if __name__ == "__main__":
    main()
