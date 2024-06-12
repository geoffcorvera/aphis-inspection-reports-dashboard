# Installation
Consult the [`Makefile`](Makefile) to understand the available `make` commands.

- From this repository, create virtual environment and install dependencies `make venv`
- Activate your venv
- Fetch data and load to sqlite database `make database`

# Serve Locally
After creating database `make serve`

# Deploy
- Copy the .nginx file into the nginx folder of the server, and make sure it's enabled and not blocked by firewalls
- Copy the .service file to `/etc/systemd/system/datasette.service`
- Make sure that the datasette binary's location is the same as that specified in the .service file by checking `which datasette`
- (re)start the daemon: `sudo systemctl daemon-reload`, `sudo systemctl restart datasette.service` (or `start`), `sudo systemctl status datasette.service` to check if it started successfully 