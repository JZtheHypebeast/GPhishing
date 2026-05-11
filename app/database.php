<?php

declare(strict_types=1);

function app_config(): array
{
    $localConfigPath = dirname(__DIR__) . '/config/local.php';
    $localConfig = is_file($localConfigPath) ? require $localConfigPath : [];

    return array_replace_recursive([
        'db' => [
            'host' => getenv('DB_HOST') ?: '127.0.0.1',
            'port' => (int) (getenv('DB_PORT') ?: 3306),
            'name' => getenv('DB_NAME') ?: '',
            'user' => getenv('DB_USER') ?: '',
            'password' => getenv('DB_PASSWORD') ?: '',
            'charset' => getenv('DB_CHARSET') ?: 'utf8mb4',
        ],
        'app' => [
            'hash_secret' => getenv('APP_HASH_SECRET') ?: '',
        ],
    ], is_array($localConfig) ? $localConfig : []);
}

function app_db(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $config = app_config()['db'];

    if ($config['name'] === '' || $config['user'] === '') {
        throw new RuntimeException('Database configuration is missing.');
    }

    $dsn = sprintf(
        'mysql:host=%s;port=%d;dbname=%s;charset=%s',
        $config['host'],
        $config['port'],
        $config['name'],
        $config['charset']
    );

    $pdo = new PDO($dsn, $config['user'], $config['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);

    return $pdo;
}

function db(): PDO
{
    return app_db();
}

function hashed_client_ip(): ?string
{
    $ip = $_SERVER['REMOTE_ADDR'] ?? '';

    if ($ip === '') {
        return null;
    }

    $secret = app_config()['app']['hash_secret'] ?: 'local-development-secret';

    return hash_hmac('sha256', $ip, $secret);
}
