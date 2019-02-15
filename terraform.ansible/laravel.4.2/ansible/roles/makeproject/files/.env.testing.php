<?php

    return [
        'aws_credentials' => [
            'key'    => 'edit_this',
            'secret' => 'edit_this',
            'region' => 'us-west-2'
        ],
        'domain' => 'your_testing_domain',
        'username' => 'root',
        'homeClienteUrl' => 'this variable is service specific',
        'MONGODB_HOST' => '127.0.0.1', // this references 
	// Global specific variables for this project called SENDSERVICE
	'hostSendService'  => 'https://localservice',
	'tokenSendService' => 'service_token',

	// Global specific variables for this project called STOREWEBSERVICE
	'hostStoreWebService'  => 'https://localservice',
	'tokenStoreWebService' => 'service_token',
	//Slack
        'slackHook' => 'https://hooks.slack.com/services/path/to/your/account'
    ];

