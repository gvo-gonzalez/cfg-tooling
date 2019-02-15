--
name: Role baseconfig
- Replace roles/baseconfig/files/bitbucket_id_rsa for yoour private key to clone/pull changes to your project
- define your service on roles/baseconfig/vars/main.yml

name: Role nginxconf
- Add your ssl certificates here if available: roles/nginxconf/files/
- Define your site specific variables in roles/nginxconf/vars/main.yml
	servicename: your_domain_name
	domains: your_domain_name
	wildcardcrt: your_ssl_certificate_crt_name
	wildcardkey: your_ssl_certificate_key_name





