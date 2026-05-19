FARTER no-build operational MVP

This version has no package.json, no Vite, no React build.
So Vercel cannot fail with package.json errors.

Before upload:
1. Open index.html in Notepad / VS Code.
2. Replace PASTE_SUPABASE_URL_HERE with your Supabase Project URL.
3. Replace PASTE_SUPABASE_ANON_KEY_HERE with your Supabase Publishable / anon public key.

Supabase:
1. Run supabase.sql in SQL Editor.
2. Authentication > Providers > enable Anonymous Sign-Ins.

GitHub/Vercel:
1. New repo.
2. Upload only index.html, supabase.sql, README.txt.
3. Vercel > Add New > Project.
4. Framework Preset: Other.
5. Build Command: empty.
6. Output Directory: empty.
7. Deploy.
