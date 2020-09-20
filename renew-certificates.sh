podman run --rm -p 80:80 -v certificates:/etc/letsencrypt certbot/certbot certonly -d mx.webradio.space --standalone -m fj@msl.cloud --agree-tos --non-interactive 
