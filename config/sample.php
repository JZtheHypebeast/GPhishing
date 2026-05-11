<?php

declare(strict_types=1);

return [
    'db' => [
        'host' => '127.0.0.1',
        'port' => 3306,
        'name' => 'Cello_Zorg',
        'user' => 'simulation_user',
        'password' => 'change-me',
        'charset' => 'utf8mb4',
    ],
    'app' => [
        'hash_secret' => 'replace-with-a-long-random-secret',
    ],
];
