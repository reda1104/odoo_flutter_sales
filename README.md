# Flutter Odoo Client

A Flutter mobile application built as a technical assessment to demonstrate integration with **Odoo 19** using JSON-RPC, role-aware navigation, customer management, sales order workflows, and offline support.

## Features

### Authentication and access
- Sign in using an Odoo username and password.
- Identify internal users through Odoo's `base.group_user` group.
- Show the **Sales Orders** section only to internal users.
- Respect Odoo's server-side access rights and record rules.

### Customers
- Retrieve customers from Odoo (`res.partner`, filtered by `customer_rank > 0`).
- Search the loaded customer list by name.
- View customer details, including contact information and address fields when available.
- Update a customer's phone number when the signed-in user has permission.
- Pull to refresh the customer list.

### Sales orders
- Browse sales orders and quotations accessible to the signed-in user.
- View order details and order lines.
- Confirm eligible quotations through Odoo's `action_confirm` method.
- Refresh the sales order list.

### Offline support (bonus)
- Cache successfully loaded customers locally for later viewing without connectivity.
- Allow phone edits while offline and store them in a persistent pending-update queue.
- Show the locally updated phone number immediately.
- Attempt to synchronize pending edits when connectivity returns or the customer list is refreshed online.
- Separate cached customer data and pending updates by Odoo user ID.

## Tech stack

| Technology | Purpose |
| --- | --- |
| Flutter / Dart | Mobile application and UI |
| `flutter_bloc` (Cubit) | Presentation state management |
| `odoo_rpc` | Communication with Odoo |
| `shared_preferences` | Local customer cache and pending phone edits |
| `connectivity_plus` | Network connectivity status and reconnection events |

## Project structure

The project uses a **feature-first structure** with separate data and presentation layers:

```text
lib/
├── core/
│   ├── constants/          # Application / Odoo configuration
│   └── networks/           # Shared Odoo service
├── features/
│   ├── auth/
│   │   ├── data/           # Authentication repository
│   │   └── presentation/   # Login screen and Cubit
│   ├── customers/
│   │   ├── data/
│   │   │   ├── datasources/ # Local cache
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/   # Customer screens and Cubit
│   ├── sales_orders/
│   │   ├── data/
│   │   └── presentation/   # Sales screens and Cubit
│   └── main/
│       └── presentation/   # Main navigation
└── main.dart
```

**Responsibilities:**
- **Service:** Centralizes communication with Odoo.
- **Repository:** Retrieves, updates, and caches application data.
- **Cubit:** Manages loading, success, failure, and UI updates.
- **Pages/widgets:** Display data and respond to user actions.

## Getting started

### Prerequisites
- Flutter SDK installed and configured.
- Android emulator or physical Android device.
- Access to an **Odoo 19** database.
- An Odoo account with the permissions needed for the features being tested.

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/reda1104/odoo_flutter_sales.git
   cd odoo_flutter_task
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure the Odoo server URL and database name in:

   ```text
   lib/core/constants/app_constants.dart
   ```

   Use the URL and database of your test Odoo instance. Do not commit passwords or production credentials.

4. Run the app:

   ```bash
   flutter run
   ```

5. Sign in using an authorized Odoo account.

### Build an Android APK

```bash
flutter build apk --release
```

The generated APK is located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The Android release configuration must allow internet access to reach the Odoo server.

## Odoo integration

The application uses Odoo RPC methods, including:

| Model | Method | Purpose |
| --- | --- | --- |
| Authentication | `authenticate` | Sign in to Odoo |
| `res.users` | `has_group` | Identify internal users |
| `res.partner` | `search_read` | Load customer records |
| `res.partner` | `write` | Update phone numbers |
| `sale.order` | `search_read` | Load sales orders and quotations |
| `sale.order.line` | `search_read` | Load order lines |
| `sale.order` | `action_confirm` | Confirm quotations |

**Permissions:** Hiding the Sales Orders tab for non-internal users is a UI decision, not a security boundary. Odoo itself controls which records each account can read or modify. Internal users may still require the appropriate Sales permissions. Portal users typically have more restricted customer visibility and may not have permission to update customer phone numbers.

## How offline synchronization works

1. After a successful online customer fetch, the app stores the customer list locally.
2. When the device is offline, the app displays that cached list.
3. A phone edit made offline is saved locally and added to a pending-update queue.
4. The app displays the edited phone number immediately and labels the update as pending synchronization.
5. When connectivity returns or customers are refreshed online, the app attempts to send queued updates to Odoo.
6. Successfully synchronized updates are removed from the queue. Failed updates remain pending for a later attempt.

### Known limitations

- **An internet connection is required to log in.** Offline support applies to customer data already loaded after authentication.
- Offline customer viewing requires at least one successful online fetch for that account.
- `connectivity_plus` detects network connectivity, not whether the Odoo server is reachable. A connected device may still encounter server or RPC errors.
- Queued edits cannot synchronize if the Odoo account lacks permission to update the corresponding record.
- Sales order operations require an online connection.
- The local cache uses `shared_preferences` for this assessment; production applications handling sensitive customer information should consider encrypted storage, stronger session handling, and more robust synchronization/conflict resolution.

## Suggested test scenarios

1. Sign in with an internal user who has Sales permissions; verify both Customers and Sales Orders are available.
2. Search customers, open a customer, and update a phone number online.
3. Open a quotation and confirm it (using an eligible test order).
4. Sign in with a portal user; verify that the Sales Orders tab is hidden and Odoo's record permissions are respected.
5. Load customers online, disconnect the device, edit a phone number, and verify the offline confirmation message.
6. Reconnect the device, refresh customers if necessary, and verify the change in the Odoo web interface.

## Notes for reviewers

- Please use **test accounts and test records**, not production data.
- Demo account credentials should be shared separately from the repository.
- Odoo permissions and record rules determine the operations available to each test account.

---

Developed as a Flutter + Odoo technical assessment.
