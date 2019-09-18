server {
    listen {{nginx_port}} default_server;
    listen [::]:{{nginx_port}} default_server;

    root /app/concerto/web;
    client_max_body_size 50M;

    location ~ /.well-known {
        root /var/www/html;
        allow all;
    }

    location ~ /(\.|web\.config) {
        deny all;
    }

    location / {
        try_files $uri @rewriteapp;
    }

    location @rewriteapp {
        rewrite ^/(.*)$ /app.php/$1 last;
    }

    location ~ ^/app.php(/|$) {
        fastcgi_pass localhost:9000;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root/app.php;
        fastcgi_param HTTPS off;
    }

    location ~ ^/app_dev.php(/|$) {
        fastcgi_pass localhost:9000;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root/app_dev.php;
        fastcgi_param HTTPS off;
    }
}
