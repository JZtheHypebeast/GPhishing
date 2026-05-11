<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Welcome</title>
    <link rel="stylesheet" href="log.css">
</head>
<body>
    <main class="login-page" aria-label="Welcome page mockup">
        <section class="login-card">
            <div class="account-side">
                <svg class="google-logo" viewBox="0 0 48 48" aria-hidden="true">
                    <path fill="#4285f4" d="M45.12 24.5c0-1.54-.14-3.02-.4-4.45H24v8.4h11.84c-.51 2.75-2.06 5.08-4.39 6.64v5.43h7.11c4.16-3.83 6.56-9.47 6.56-16.02z"/>
                    <path fill="#34a853" d="M24 46c5.94 0 10.92-1.97 14.56-5.34l-7.11-5.43c-1.97 1.32-4.49 2.1-7.45 2.1-5.73 0-10.59-3.87-12.33-9.07H4.31v5.6C7.94 41.08 15.4 46 24 46z"/>
                    <path fill="#fbbc05" d="M11.67 28.26c-.44-1.32-.69-2.73-.69-4.26s.25-2.94.69-4.26v-5.6H4.31A21.94 21.94 0 0 0 2 24c0 3.55.85 6.91 2.31 9.86l7.36-5.6z"/>
                    <path fill="#ea4335" d="M24 10.67c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31C34.9 3.43 29.93 1.33 24 1.33c-8.6 0-16.06 4.92-19.69 12.14l7.36 5.6c1.74-5.2 6.6-8.4 12.33-8.4z"/>
                </svg>

                <h1>Welcome</h1>

                <button class="account-pill" type="button" aria-label="Selected account" hidden>
                    <span class="avatar" aria-hidden="true">
                        <svg viewBox="0 0 24 24">
                            <path d="M12 12.15a3.95 3.95 0 1 0 0-7.9 3.95 3.95 0 0 0 0 7.9Zm0 2.05c-3.72 0-6.75 2.11-6.75 4.7 0 .43.35.78.78.78h11.94c.43 0 .78-.35.78-.78 0-2.59-3.03-4.7-6.75-4.7Z"/>
                        </svg>
                    </span>
                    <span class="email"><?php echo isset($_GET['identifier']) ? htmlspecialchars(trim($_GET['identifier']), ENT_QUOTES, 'UTF-8') : ''; ?></span>
                    <span class="pill-arrow" aria-hidden="true"></span>
                </button>
            </div>

            <form class="password-side" action="#" method="post" onsubmit="return false;">
                <label class="password-input">
                    <span class="sr-only">Password</span>
                    <input type="password" name="password" placeholder="Enter your password" autocomplete="off">
                </label>

                <label class="show-password">
                    <input type="checkbox">
                    <span class="checkbox" aria-hidden="true"></span>
                    <span>Show password</span>
                </label>

                <div class="card-actions">
                    <a href="#">Forgot password?</a>
                    <button type="button">Next</button>
                </div>
            </form>
        </section>

        <footer class="page-footer">
            <button class="language" type="button">
                English (United States)
                <span aria-hidden="true"></span>
            </button>
            <nav aria-label="Footer">
                <a href="#">Help</a>
                <a href="#">Privacy</a>
                <a href="#">Terms</a>
            </nav>
        </footer>
    </main>
    <script>
        const accountPill = document.querySelector('.account-pill');
        const emailText = document.querySelector('.email');

        if (emailText.textContent.trim()) {
            accountPill.hidden = false;
        }
    </script>
</body>
</html>
