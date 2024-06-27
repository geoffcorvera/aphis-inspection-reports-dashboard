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

prejoin-data:
	.venv/bin/sqlite-utils drop-table aphis_reports.db citation_inspection
	.venv/bin/sqlite-utils aphis_reports.db "select narrative, desc, web_siteName, kind, hash_id, web_inspectionDate, code, repeat, pdf_insp_type, pdf_animals_total, web_certType, pdf_customer_id, pdf_customer_name, pdf_customer_addr, customer_state, pdf_site_id from citations natural join inspections" --csv > prejoined.csv
	.venv/bin/sqlite-utils insert aphis_reports.db citation_inspection prejoined.csv --csv
	.venv/bin/sqlite-utils transform aphis_reports.db citation_inspection --add-foreign-key hash_id inspections hash_id
	rm prejoined.csv

create-db:
	.venv/bin/python3 scripts/create_db.py
	.venv/bin/sqlite-utils enable-fts aphis_reports.db citations narrative
	.venv/bin/sqlite-utils transform aphis_reports.db citations --pk rowid

load-embeddings:
	sqlite3 aphis_reports_embeddings.db ".dump _embeddings_citations" > embeddings.sql
	sqlite3 aphis_reports.db < embeddings.sql
	sqlite-utils rename-table aphis_reports.db _embeddings_citations _embeddings_citation_inspection
	sqlite-utils transform aphis_reports.db citation_inspection --pk rowid
	
database: fetch-data create-db prejoin-data load-embeddings

serve:
	.venv/bin/datasette ./aphis_reports.db --plugins-dir=plugins/ --metadata metadata.json --setting sql_time_limit_ms 5000 --template-dir=templates/

serve-root:
	.venv/bin/datasette ./aphis_reports.db --root --plugins-dir=plugins/ --metadata metadata.json

serve-prod:
	.venv/bin/datasette ./aphis_reports.db --plugins-dir=plugins/ --metadata metadata.json --setting sql_time_limit_ms 20000 --template-dir=templates/ -h 127.0.0.1 -p 8000
