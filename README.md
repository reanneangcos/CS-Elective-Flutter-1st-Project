# Courtside Kits 🏀

An NBA jersey shop built with **Flutter + Supabase** for the CS Elective 2 *Supabase-Flutter Activity: Price Filter + Pagination*.

## Features

| Requirement | How it's done |
| --- | --- |
| **Price filtering** with a price slider | `RangeSlider` in [`lib/widgets/price_filter.dart`](lib/widgets/price_filter.dart). When the thumb is released, the app queries Supabase with `.gte('price', min).lte('price', max)`. The slider's limits come from the cheapest and most expensive jersey in the table. |
| **Pagination**, 6 products per page | Supabase query `.range(from, to)` with `.count(CountOption.exact)` in [`lib/services/jersey_service.dart`](lib/services/jersey_service.dart), so only the current page's rows are downloaded. The total count drives the page buttons. |
| Handled through **state management** | [`lib/providers/shop_provider.dart`](lib/providers/shop_provider.dart) (`provider` package / `ChangeNotifier`) holds the page number, price range, search text and edition filter, and runs the query again when any of them change. Changing a filter jumps back to page 1. |
| Create / update / delete + filter (from the class session) | Add with the **Add jersey** button. Tap a jersey to **edit** or **delete** it. Also search by player or team, and filter by edition. |

Jersey images are drawn in code (`CustomPainter`) from each team's colors, so no image uploads are needed.

## Authentication (Supabase Auth activity)

Users have to sign in before they can see the shop. There are two ways to sign in:

- **Email + password**: sign in or create an account ([`lib/screens/auth_screen.dart`](lib/screens/auth_screen.dart))
- **GitHub**: the additional third-party provider, using `signInWithOAuth(OAuthProvider.github)`

[`lib/providers/auth_provider.dart`](lib/providers/auth_provider.dart) listens to `onAuthStateChange`. `AuthGate` in [`lib/main.dart`](lib/main.dart) shows the sign-in screen or the shop depending on whether someone is signed in. The avatar menu in the shop's top bar shows who is signed in and which provider they used, and has **Sign out**.

### Enabling GitHub sign-in

1. **Create a GitHub OAuth App** at GitHub → Settings → Developer settings → **OAuth Apps → New OAuth App**:
   - Homepage URL: `http://localhost:3000`
   - Authorization callback URL: `https://<your-project-ref>.supabase.co/auth/v1/callback`

   Copy the **Client ID**, then click **Generate a new client secret** and copy that too.
2. **Turn on GitHub in Supabase**: go to Authentication → Sign In / Providers → **GitHub**, enable it, paste the Client ID and secret, and save.
3. **Allow the app's redirect URLs**: go to Authentication → URL Configuration. Set Site URL to `http://localhost:3000` and add these Redirect URLs:
   - `http://localhost:3000/**` (web)
   - `com.courtsidekits.app://login-callback` (Android / iOS / macOS)
4. Run the web app on the port you registered:
   ```bash
   flutter run -d chrome --web-port 3000
   ```

New email accounts must be confirmed by email unless you turn off **Confirm email** under Authentication → Sign In / Providers → Email. Turning it off makes demos easier.

## Setup

1. **Create the table + sample data**: in your Supabase project, open **SQL Editor → New query**, paste [`supabase/schema.sql`](supabase/schema.sql), and click **Run**. This adds 27 jerseys (5 pages).
2. **Add your keys**: copy the **Project URL** and **anon/publishable key** from *Project Settings → API* into [`lib/config/supabase_config.dart`](lib/config/supabase_config.dart), or pass them when you run the app:
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
               --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```
3. `flutter pub get` then `flutter run`. Until keys are set, the app shows a setup screen.

## Project structure

```
lib/
  main.dart                    app entry, Supabase init, Provider setup
  config/supabase_config.dart  Supabase URL + key
  models/jersey.dart           Jersey model (fromMap / toMap)
  services/jersey_service.dart Supabase queries (filter, paginate, CRUD)
  providers/shop_provider.dart state: page, price range, filters, results
  screens/                     shop grid, details sheet, add/edit form
  widgets/                     price slider, pagination bar, jersey card/art
supabase/schema.sql            table, RLS policies, seed data
test/widget_test.dart          pagination + price filter tests
```

> The RLS policies in `schema.sql` let anyone with the anon key add, edit and delete jerseys. That's fine for a class demo, but a real store would restrict writes to admins.
