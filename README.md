# Welcome to the Orby & Uche Wedding Website Repository! 🎉

## Description
This repository holds the code for my wedding website, designed to manage invitations, share event details, and showcase our cherished moments together. It's the one-stop-shop for everything related to our big day! Check out the live website at [orbyanduche.nebed.io](https://orbyanduche.nebed.io).

## Features
- **Invitation Management:** handle RSVPs and approve them, sending out wedding invites automatically.
- **Gallery:** View beautiful moments from our relationship.
- **Event Details:** Access all the need-to-know information about the event.

## Installation

1. **Clone the Repository:**
    ```bash
    git clone https://github.com/nebed/orbyanduche.git
    cd orbyanduche
    ```

2. **Install Frontend Dependencies:**
    ```bash
    npm install
    ```

3. **Run the Frontend Development Server:**
    ```bash
    npm run dev
    ```

4. **Setup and Run the Backend:**
    - Create a virtual environment:
      ```bash
      python -m venv venv
      source venv/bin/activate   # On Windows use `venv\Scripts\activate`
      ```
    - Install backend dependencies:
      ```bash
      pip install -r requirements.txt
      ```
    - Run the Flask server:
      ```bash
      python wsgi.py
      ```

## Production deployment

The production deployment script builds the API image, runs it as an unprivileged
container bound to loopback, smoke-tests `/api/ping`, publishes the prebuilt
`dist/` frontend, and reloads the existing Nginx site. It reuses the existing
Let's Encrypt certificate and does not issue or renew certificates.

Before running `sudo ./deploy.sh`, provision the runtime environment file at
`/etc/orbyanduche/runtime.env` and, when using a service-account key instead of
attached Google Cloud identity, the key at
`/etc/orbyanduche/gcp-key.json`. These files are runtime-only: do not add them to
the repository or Docker image. The data disk must already be mounted at
`/mnt/data`; the script uses its `qrcodes/` and `orbyanduche/instance/`
directories for persistent data. It requires the site's Nginx certificate under
`/etc/letsencrypt/live/orbyanduche.nebed.io/`.

Build the static frontend before running the server-side deploy script:

```bash
npm ci
VITE_API_HOST=https://orbyanduche.nebed.io npm run build
```

Do not set or build with `VITE_API_USERNAME` or `VITE_API_PASSWORD`; those values
are no longer used by the frontend and anything prefixed `VITE_` is public.

The runtime env file contains Mailgun and Twilio settings. Admin authentication is
stored as a password hash in the persistent SQLite database. After deployment,
run `./setup-admin-password.sh` from your laptop; it generates a random password,
sets its hash through the running backend, and writes the plaintext once to
`/tmp/orbyanduche-admin-password` with mode 0600. Move that password to a password
manager after viewing it. The API accepts it only on admin routes; public RSVP
submission does not use admin credentials.

`GOOGLE_APPLICATION_CREDENTIALS` is optional when the host provides Google
Application Default Credentials. Otherwise stage the service-account key at
`/etc/orbyanduche/gcp-key.json`; it is mounted read-only and not copied into the
image. If rebuilding the static frontend, set only its public API host, for
example `VITE_API_HOST=https://orbyanduche.nebed.io`; all `VITE_*` values are
embedded in browser JavaScript and must not contain secrets.

## Contributing
Feel free to fork this repo and make any contributions you deem necessary. Don't forget to open a pull request!

## License
This project is licensed under the MIT License.
