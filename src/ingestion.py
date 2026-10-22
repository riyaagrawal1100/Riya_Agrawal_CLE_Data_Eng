import json
import pandas as pd

def read_csv_file(path):
    return pd.read_csv(path, dtype="object")

def read_json_file(path):
    with open(path, "r", encoding="utf-8") as file:
        return pd.DataFrame(json.load(file))
