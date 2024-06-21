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
	.venv/bin/sqlite-utils transform aphis_reports.db citations --pk rowid
	.venv/bin/sqlite-utils create-view aphis_reports.db citation_inspection "select hash_id, web_inspectionDate, code, repeat, pdf_insp_type, pdf_animals_total, web_siteName, web_certType, pdf_customer_id, pdf_customer_name, pdf_customer_addr, customer_state, pdf_site_id, desc, narrative from citations natural join inspections"

database:
	fetch-data
	create-db

serve:
	.venv/bin/datasette ./aphis_reports.db --plugins-dir=plugins/ --metadata metadata.json

serve-root:
	.venv/bin/datasette ./aphis_reports.db --root --plugins-dir=plugins/ --metadata metadata.json

serve-emb:
	.venv/bin/datasette ./aphis_reports_embeddings.db --plugins-dir=plugins/ --metadata metadata.json --setting sql_time_limit_ms 3500 --template-dir=templates/

serve-prod:
	.venv/bin/datasette ./aphis_reports_embeddings.db --plugins-dir=plugins/ --metadata metadata.json --setting sql_time_limit_ms 3500 --template-dir=templates/ -h 127.0.0.1 -p 8000
