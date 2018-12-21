server {
        listen 80;
        server_name www.proxy.example.your.dns.com proxy.example.your.dns.com ;
        return 301 https://proxy.example.your.dns.com;

#        location / {
#                root /var/www/nginx-default;
#                index 50x.html;
#        }

       location / {
                proxy_pass              http://[::1]:8145;
                proxy_set_header        Host            $host;
                proxy_set_header        X-Real-IP       $remote_addr;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                # Tiempo extra (3h) para que los servidores en USA hagan un UPDATE (llamada desde post-commit)
                proxy_read_timeout      10800s;
        }

        access_log  /var/log/nginx/proxy.example.your.dns.com.access.log;
        error_log       /var/log/nginx/proxy.example.your.dns.com.error.log;

        include /etc/nginx/security.conf;
        include /etc/nginx/502.conf;

    # Redirect non-https traffic to https
    # if ($scheme != "https") {
    #     return 301 https://$host$request_uri;
    # } # managed by Certbot

}

server {

        listen 443 ssl; # managed by Certbot
        server_name www.proxy.example.your.dns.com proxy.example.your.dns.com ;

#        location / {
#                root /var/www/nginx-default;
#                index 50x.html;
#        }

       location / {
                proxy_pass              https://[::1]:4146;
                proxy_set_header        Host            $host;
                proxy_set_header        X-Real-IP       $remote_addr;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;

                # Tiempo extra (3h) para que los servidores en USA hagan un UPDATE (llamada desde post-commit)
                proxy_read_timeout      10800s;
                #large_client_header_buffers 4 64k;
        }

        access_log  /var/log/nginx/ssl-proxy.example.your.dns.com.access.log;
        error_log       /var/log/nginx/ssl-proxy.example.your.dns.com.error.log;

        include /etc/nginx/security.conf;
        include /etc/nginx/502.conf;

        #### HTTPS #####
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

	## start perfomance tunning
        ssl_ecdh_curve secp384r1; # see here and here (pg. 485)
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout 24h;
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 8.8.8.8 8.8.4.4 valid=300s;
        resolver_timeout 5s;
        ## end performance tunning

        ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
        ssl_prefer_server_ciphers on;

        ssl_dhparam /etc/nginx/ssl/ssl-dhparams.pem; # managed by Certbot
    	ssl_certificate /etc/nginx/ssl/fullchain.pem; # managed by Certbot
    	ssl_certificate_key /etc/nginx/ssl/privkey.pem; # managed by Certbot
        #### END HTTPS ##### 

	## Uploads file size setting
        client_header_buffer_size 100k;
        large_client_header_buffers 4 100k;
        client_max_body_size 100M;

	## Security Headers
	add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
        add_header X-Frame-Options sameorigin; # read here
        add_header X-Content-Type-Options nosniff; # read here
        add_header X-Xss-Protection "1; mode=block"; #read here


}

