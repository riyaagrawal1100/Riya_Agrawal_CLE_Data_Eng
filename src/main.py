import json
import logging
from pathlib import Path
import pandas as pd

from ingestion import read_csv_file, read_json_file
from validation import validate_data

ROOT = Path(__file__).resolve().parents[1]

def project_path(path):
    return ROOT / path

def process_dataset(name, settings):
    input_path = project_path(settings["input_path"])
    if settings["format"] == "csv":
        data = read_csv_file(input_path)
    else:
        data = read_json_file(input_path)

    logging.info("%s: read %s rows", name, len(data))
    valid, rejected = validate_data(
        data, settings["required_columns"], settings["key_column"],
        settings.get("date_columns", {})
    )

    valid_path = project_path(settings["valid_output"])
    rejected_path = project_path(settings["rejected_output"])
    valid_path.parent.mkdir(parents=True, exist_ok=True)
    rejected_path.parent.mkdir(parents=True, exist_ok=True)
    valid.to_csv(valid_path, index=False)
    rejected.to_csv(rejected_path, index=False)
    logging.info("%s: %s valid, %s rejected", name, len(valid), len(rejected))
    return {"dataset": name, "input_rows": len(data),
            "valid_rows": len(valid), "rejected_rows": len(rejected)}

def main():
    with open(ROOT / "config.json", "r", encoding="utf-8") as file:
        config = json.load(file)

    log_path = project_path(config["log_file"])
    log_path.parent.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(filename=log_path, level=logging.INFO,
                        format="%(asctime)s - %(levelname)s - %(message)s",
                        force=True)

    summary = []
    for name, settings in config["datasets"].items():
        try:
            summary.append(process_dataset(name, settings))
        except Exception:
            logging.exception("Could not process %s", name)

    summary_path = project_path(config["summary_output"])
    summary_path.parent.mkdir(parents=True, exist_ok=True)
    pd.DataFrame(summary).to_csv(summary_path, index=False)
    print("Pipeline finished. Check the output/ and logs/ folders.")

if __name__ == "__main__":
    main()
