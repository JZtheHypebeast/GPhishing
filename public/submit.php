<?php

declare(strict_types=1);

require dirname(__DIR__) . '/app/database.php';
require dirname(__DIR__) . '/app/form-fields.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: index.php', true, 303);
    exit;
}

$identifier = trim((string) ($_POST['identifier'] ?? ''));
$password = (string) ($_POST[PASSWORD_FIELD_NAME] ?? '');
$campaignId = trim((string) ($_POST['campaign_id'] ?? ''));
$participantId = trim((string) ($_POST['participant_id'] ?? ''));
$landingId = trim((string) ($_POST['landing_id'] ?? ''));
$source = trim((string) ($_POST['source'] ?? ''));
$passwordRevealed = isset($_POST[PASSWORD_REVEALED_FIELD_NAME]) && $_POST[PASSWORD_REVEALED_FIELD_NAME] === '1';

$submittedPassword = $password !== '';
$passwordLength = strlen($password);
unset($password);

try {
    $statement = app_db()->prepare(
        'INSERT INTO simulation_submissions
            (
                identifier,
                campaign_id,
                participant_id,
                landing_id,
                source,
                submitted_password,
                password_length,
                password_revealed,
                ip_hash,
                user_agent
            )
         VALUES
            (
                :identifier,
                :campaign_id,
                :participant_id,
                :landing_id,
                :source,
                :submitted_password,
                :password_length,
                :password_revealed,
                :ip_hash,
                :user_agent
            )'
    );

    $statement->execute([
        ':identifier' => $identifier !== '' ? $identifier : null,
        ':campaign_id' => $campaignId !== '' ? $campaignId : null,
        ':participant_id' => $participantId !== '' ? $participantId : null,
        ':landing_id' => $landingId !== '' ? $landingId : null,
        ':source' => $source !== '' ? $source : null,
        ':submitted_password' => $submittedPassword ? 1 : 0,
        ':password_length' => $passwordLength,
        ':password_revealed' => $passwordRevealed ? 1 : 0,
        ':ip_hash' => hashed_client_ip(),
        ':user_agent' => substr((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 512),
    ]);

    $saved = true;
} catch (Throwable $exception) {
    error_log($exception->getMessage());
    $saved = false;
}
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Training result</title>
    <link rel="stylesheet" href="log.css">
</head>
<body>
    <main class="login-page" aria-label="Training result">
        <section class="login-card">
            <div class="account-side">
                <svg class="google-logo" viewBox="0 0 48 48" aria-hidden="true">
                    <path fill="#4285f4" d="M45.12 24.5c0-1.54-.14-3.02-.4-4.45H24v8.4h11.84c-.51 2.75-2.06 5.08-4.39 6.64v5.43h7.11c4.16-3.83 6.56-9.47 6.56-16.02z"/>
                    <path fill="#34a853" d="M24 46c5.94 0 10.92-1.97 14.56-5.34l-7.11-5.43c-1.97 1.32-4.49 2.1-7.45 2.1-5.73 0-10.59-3.87-12.33-9.07H4.31v5.6C7.94 41.08 15.4 46 24 46z"/>
                    <path fill="#fbbc05" d="M11.67 28.26c-.44-1.32-.69-2.73-.69-4.26s.25-2.94.69-4.26v-5.6H4.31A21.94 21.94 0 0 0 2 24c0 3.55.85 6.91 2.31 9.86l7.36-5.6z"/>
                    <path fill="#ea4335" d="M24 10.67c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31C34.9 3.43 29.93 1.33 24 1.33c-8.6 0-16.06 4.92-19.69 12.14l7.36 5.6c1.74-5.2 6.6-8.4 12.33-8.4z"/>
                </svg>
                <h1><?php echo $saved ? 'Recorded' : 'Not saved'; ?></h1>
            </div>

            <div class="password-side">
                <p class="result-note">
                    <?php if ($saved): ?>
                        This training submission was recorded without storing the password value.
                    <?php else: ?>
                        The database is not configured or could not be reached.
                    <?php endif; ?>
                </p>

                <div class="card-actions">
                    <a href="index.php">Start over</a>
                </div>
            </div>
        </section>
    </main>
</body>
</html>
