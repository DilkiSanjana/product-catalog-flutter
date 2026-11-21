# Product Catalog App

A Flutter-based product catalog application that allows users to browse products, search for items, view product details, and manage a shopping cart.

The application uses the [DummyJSON Products API](https://dummyjson.com/products) to retrieve product information.

## Features

### Product Catalog
- Browse products retrieved from the DummyJSON API.
- Display product images, names, prices, and ratings.
- Load additional products using pagination when scrolling.
- Search products by name with a debounce mechanism.

### Product Details
- View product images and descriptions.
- View product prices, ratings, and available stock.
- Add products to the shopping cart.

### Shopping Cart
- Add products to the cart.
- Increase and decrease product quantities.
- Remove products from the cart.
- Automatically calculate the total price.
- Save cart data locally using SharedPreferences.
- Restore cart data when reopening the application.

### User Experience
- Loading indicators while retrieving products.
- Error messages when API requests fail.
- Retry functionality after network failures.
- Empty states when no products are available.
- Responsive layouts for mobile, tablet, and desktop screens.

## Technologies Used

- **Flutter** – UI development framework.
- **Dart** – Programming language.
- **Provider** – State management.
- **HTTP** – API communication.
- **SharedPreferences** – Local cart persistence.
- **CachedNetworkImage** – Network image caching.
- **DummyJSON** – Product data API.

## Project Architecture

The application follows a layered structure to separate UI, business logic, and data operations.

```text
lib/
├── main.dart
├── models/
│   └── product.dart
├── services/
│   └── product_api_service.dart
├── repositories/
│   └── product_repository.dart
├── providers/
│   ├── product_provider.dart
│   └── cart_provider.dart
├── screens/
│   ├── product_list_screen.dart
│   ├── product_detail_screen.dart
│   └── cart_screen.dart
└── widgets/
    └── product_card.dart

test/
├── product_test.dart
└── cart_provider_test.dart
```

### Architecture Explanation

- **Models:** Define the product data structure and JSON conversion.
- **Services:** Handle HTTP requests and API error handling.
- **Repositories:** Provide an abstraction between the API service and application logic.
- **Providers:** Manage product and shopping cart state using Provider.
- **Screens:** Contain the main application pages.
- **Widgets:** Contain reusable UI components.

## State Management

This project uses the Provider package with ChangeNotifier.

Provider was selected because it offers a straightforward way to manage and share application state across widgets.

The application uses:
- `ProductProvider` to manage product loading, pagination, and search.
- `CartProvider` to manage shopping cart items, quantities, and totals.

## API Integration

Product information is retrieved from the DummyJSON Products API.

Base API URL:

```text
https://dummyjson.com
```

Main endpoints:

| Endpoint | Purpose |
|---|---|
| `/products?limit=10&skip=0` | Retrieve products |
| `/products/search?q=phone` | Search products |
| `/products/1` | Retrieve a product by ID |

API requests include timeout handling, HTTP status checking, and network and response-format error handling.

## Local Data Persistence

The application uses SharedPreferences to store shopping cart information locally.

Cart information is serialized into JSON and restored when the application starts.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- An Android emulator or physical device
- Google Chrome (optional, for web testing)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/DilkiSanjana/product-catalog-flutter.git
```

2. Navigate to the project directory:

```bash
cd product_catalog
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

To run the application in Chrome:

```bash
flutter run -d chrome
```

## Running Tests

Run the automated tests using:

```bash
flutter test
```

The project includes tests for:

- Product model JSON parsing.
- Product default values.
- Adding products to the cart.
- Increasing product quantity.
- Calculating cart totals.
- Removing products from the cart.

## Code Analysis

To check the project for potential errors and code issues, run:

```bash
flutter analyze
```
## License

This project was developed as part of a Flutter Developer internship assignment.
