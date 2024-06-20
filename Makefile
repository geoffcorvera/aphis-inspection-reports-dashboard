include .env

venv:
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt

install:
	.venv/bin/pip install -r requirements.txt
	.venv/bin/datasette install datasette-enrichments
	.venv/bin/datasette install datasette-embeddings

fetch-data:
	mkdir -p aphis-inspection-reports/data/combined
	wget -P aphis-inspection-reports/data/combined https://raw.githubusercontent.com/data-liberation-project/aphis-inspection-reports/main/data/combined/inspections-citations.csv
	wget -P aphis-inspection-reports/data/combined https://github.com/data-liberation-project/aphis-inspection-reports/raw/main/data/combined/inspections.csv

create-db:
	.venv/bin/python3 scripts/create_db.py
	.venv/bin/sqlite-utils enable-fts aphis_reports.db citations narrative

database: fetch-data create-db

serve:
	.venv/bin/datasette ./aphis_reports.db --plugins-dir=plugins/ --metadata metadata.json

serve-root:
	.venv/bin/datasette ./aphis_reports.db --root --plugins-dir=plugins/ --metadata metadata.json

serve-emb:
	.venv/bin/datasette ./aphis_reports_embeddings.db --plugins-dir=plugins/ --metadata metadata.json --setting sql_time_limit_ms 3500 --template-dir=templates/