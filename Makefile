venv:
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt

install:
	.venv/bin/pip install -r requirements.txt

fetch-data:
	mkdir -p aphis-inspection-reports/data/combined
	wget -P aphis-inspection-reports/data/combined https://raw.githubusercontent.com/data-liberation-project/aphis-inspection-reports/main/data/combined/inspections-citations.csv
	wget -P aphis-inspection-reports/data/combined https://github.com/data-liberation-project/aphis-inspection-reports/raw/main/data/combined/inspections.csv

load-csv-to-database:
	python3 scripts/create_db.py

database: fetch-data load-csv-to-database

serve:
	.venv/bin/datasette ./aphis_reports.db