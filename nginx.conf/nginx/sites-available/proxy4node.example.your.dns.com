server {
        lister 80;
        server_name www.your.dns.com.here your.dns.com.here ;
        return 301 https://your.dns.com.here;

#        location / {
#                root /var/www/nginx-default;
#                index 50x.html;
#        }

#       location / {
#                proxy_pass         http://127.0.0.1:3000;
#                proxy_set_header        Host            $host;
#                proxy_set_header        X-Real-IP       $remote_addr;
#                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
#                # Tiempo extra (3h) para que los servidores en USA hagan un UPDATE (llamada desde post-commit)
#                proxy_read_timeout      10800s;
#        }
#
#        access_log  /var/log/nginx/your.dns.com.here.access.log;
#        error_log       /var/log/nginx/your.dns.com.here.error.log;
#
#        include /etc/nginx/security.conf;
#        include /etc/nginx/502.conf;
}

upstream api_nodecluster {
        server 172.17.1.68:3000 weight=10 max_fails=3 fail_timeout=30s;
        server 172.17.1.72:3000 weight=10 max_fails=3 fail_timeout=30s;
}

server {

        listen 443 ssl; # managed by Certbot
        server_name www.your.dns.com.here your.dns.com.here ;

#        location / {
#                root /var/www/nginx-default;
#                index 50x.html;
#        }

	#################################
	# Wide-open CORS config for nginx
	#
        underscores_in_headers on;
        client_max_body_size 50M;

        add_header  'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE';
        add_header 'Access-Control-Allow-Credentials' 'true';
        add_header 'Access-Control-Allow-Headers' 'X-Requested-With,X-HTTP-Method-Override,Content-Type,Authorization,Accept,token,api_key';
	#################################


        ## Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
        add_header X-Frame-Options sameorigin; # read here
        add_header X-Content-Type-Options nosniff; # read here
        add_header X-Xss-Protection "1; mode=block"; #read here

        location / {
                proxy_set_header        Host            $http_host;
                proxy_set_header        X-Real-IP       $remote_addr;
                proxy_set_header        X-Forwarded-Proto https;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header        Upgrade $http_upgrade;
                proxy_set_header        Connection 'upgrade';
                proxy_cache_bypass      $http_upgrade;
                proxy_redirect          http:// https://;
                # Tiempo extra (3h) para que los servidores en USA hagan un UPDATE (llamada desde post-commit)
                proxy_read_timeout      10800s;
                add_header Pragma "no-cache";
                proxy_pass http://api_nodecluster;

                # Handle a CORS preflight OPTIONS request
                # without passing it through to the proxied server
                if ($request_method = OPTIONS ) {
                        add_header "Access-Control-Allow-Origin"  *;
                        add_header "Access-Control-Allow-Methods" "GET, POST, OPTIONS, HEAD";
                        add_header "Access-Control-Allow-Headers" "Authorization, Origin, X-Requested-With, Content-Type, Accept";
                        return 200;
                }
                location /log {
                        alias /home/123api/logqa;
                        autoindex on;
                }
        }

        access_log      /var/log/nginx/ssl-your.dns.com.here.access.log;
        error_log       /var/log/nginx/ssl-your.dns.com.here.error.log;

        include /etc/nginx/security.conf;
        include /etc/nginx/502.conf;

        #### HTTPS #####

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
        ssl_prefer_server_ciphers on;
        
	ssl_dhparam /etc/nginx/ssl/dhparam.pem;

        ssl_certificate    /etc/nginx/ssl/your_ssl_certificate_here.crt;
        ssl_certificate_key /etc/nginx/ssl/your_ssl-certificate_key_here.key;

        #### END HTTPS #####

}

