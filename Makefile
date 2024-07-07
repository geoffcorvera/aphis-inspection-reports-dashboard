include .env

venv:
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt

install:
	.venv/bin/pip install -r requirements.txt
	.venv/bin/datasette install datasette-enrichments
	.venv/bin/datasette install datasette-embeddings
	.venv/bin/datasette install datasette-cluster-map

fetch-data:
	mkdir -p aphis-inspection-reports/data/combined
	wget -P aphis-inspection-reports/data/combined https://raw.githubusercontent.com/data-liberation-project/aphis-inspection-reports/main/data/combined/inspections-citations.csv
	wget -P aphis-inspection-reports/data/combined https://github.com/data-liberation-project/aphis-inspection-reports/raw/main/data/combined/inspections.csv

create-db:
	.venv/bin/python3 scripts/create_db.py
	.venv/bin/sqlite-utils enable-fts aphis_reports.db citations narrative
	.venv/bin/sqlite-utils transform aphis_reports.db citations --pk rowid

prejoin-data:
	.venv/bin/python3 scripts/prejoin_data.py

load-embeddings:
	sqlite3 aphis_reports_embeddings.db ".dump _embeddings_citations" > embeddings.sql
	sqlite3 aphis_reports.db < embeddings.sql
	.venv/bin/sqlite-utils rename-table aphis_reports.db _embeddings_citations _embeddings_citation_inspection
	.venv/bin/sqlite-utils transform aphis_reports.db citation_inspection --pk rowid

database: fetch-data create-db prejoin-data load-embeddings

load-geocodes:
	.venv/bin/python3 scripts/insert_geocodes.py
	.venv/bin/sqlite-utils aphis_reports.db "UPDATE inspections SET lng = geocodes.lng FROM geocodes WHERE inspections.hash_id = geocodes.hash_id;"
	.venv/bin/sqlite-utils aphis_reports.db "UPDATE inspections SET lat = geocodes.lat FROM geocodes WHERE inspections.hash_id = geocodes.hash_id;"
	.venv/bin/sqlite-utils aphis_reports.db "UPDATE citation_inspection SET lng = geocodes.lng FROM geocodes WHERE citation_inspection.hash_id = geocodes.hash_id;"
	.venv/bin/sqlite-utils aphis_reports.db "UPDATE citation_inspection SET lat = geocodes.lat FROM geocodes WHERE citation_inspection.hash_id = geocodes.hash_id;"
	.venv/bin/sqlite-utils drop-table aphis_reports.db geocodes

serve:
	.venv/bin/datasette ./aphis_reports.db --plugins-dir=plugins/ --metadata metadata.json --setting sql_time_limit_ms 5000 --template-dir=templates/

serve-root:
	.venv/bin/datasette ./aphis_reports.db --root --plugins-dir=plugins/ --metadata metadata.json

serve-prod:
	.venv/bin/datasette ./aphis_reports.db --plugins-dir=plugins/ --metadata metadata.json --setting sql_time_limit_ms 20000 --template-dir=templates/ -h 127.0.0.1 -p 8000
