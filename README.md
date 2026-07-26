# Podman Quadlet - Plex Media Server

This is a fairly simple pod design incorporating Plex Media Server and
Tautulli for monitoring; more containers can be added to the pod following
this pattern. Currently absent is a reverse proxy but I may add one in the
future. As a rootless pod, only unprivileged ports are available so for a
reverse proxy serving on port 80 or 443 it will need to be managed
outside this pod under a sufficiently privileged user.

The scope of this repo is focused specifically on getting a rootless pod
up and running; this shouldn't be considered a full guide to setting up a
Plex Media Server and won't cover details such as router or network
configuration. Refer to official documentation for the details not
covered here.

Currently, SSL is not covered here but I may add this later along with an
example reverse proxy. It's not practical to have Plex manage its own SSL
certs (technically is possible), so for a typical homelab setup a
reasonable approach is to have the reverse proxy manage the SSL cert
request and renewals then provide a PKCS formatted credential to Plex
through a volume mount.

Broadly, when using an external reverse proxy it's sufficient to keep the
SSL handling contained in the proxy itself. But if direct connection to
Plex Media Server is intended (eg, through a port forward to 32400) then
the PMS container should have its own certs. If using, for example, nginx
plus certbot then you can use a script in the hooks directory (eg,
`/etc/letsencrypt/renewal-hooks/deploy/`) to create the PKCS cert, copy or
move it to a safe/secure location accessible only to the `plex` user, set
appropriate permissions then trigger the Plex container to restart and
use the newly renewed cert.

To also use SSL with Tautulli (and any other services added to the pod)
it can be helpful to request a certificate and include all subdomains in
the SAN then make the certs available to the entire pod in `plex.pod`

## Installation & Setup

1. Create a new user for the rootless pod (requires root/admin):

   `useradd plex`

2. Enable linger to allow running services while not logged in:

   `loginctl enable-linger plex`

3. Start a shell as the user:

   `machinectl shell plex@`

4. As the new user `plex` clone this repo:

   `git clone https://gitlab.com/james-cws/podman-quadlet-pms.git`

5. Setup the necessary file structure in the user's home:

   `mkdir -p ~/.config/containers/systemd ~/plex-config ~/tautulli-config`

6. Install the quadlet unit files:

   `cp -R podman-quadlet-pms/quadlets/* ~/.config/containers/systemd/`

7. Using your favourite text editor, edit/change the following files to
   suit the specific local setup, eg:

   `cd ~/.config/containers/systemd`
   `vim -p plex-media-server.container plex-media-server.container.d/pms.env plex.network plex.pod tautulli.container`

8. Reload the daemon & start the pod:

   `systemctl --user daemon-reload`
   `systemctl --user start plex-pod`

9. Check the logs for errors:

   `journalctl --user -xe`

10. Enable auto updates:

   `systemctl --user enable --now podman-auto-update.timer`
