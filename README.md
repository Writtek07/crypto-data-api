# Crypto Data API

A robust Ruby on Rails API designed to fetch, cache, and serve real-time cryptocurrency price data using the CoinGecko API. This project demonstrates high-level software engineering principles, including background job processing, multi-layer caching, service object patterns, and comprehensive automated testing.

## **Architecture & Design**

### **1. Layered Architecture**
The application follows a clean, layered architecture to ensure separation of concerns:
- **Controllers**: Lightweight entry points that handle HTTP requests/responses.
- **Models**: Business logic related to data persistence and basic caching behavior.
- **Services**: Encapsulated logic for external API interactions (`ExternalApiService`, `CoinGeckoService`).
- **Jobs**: Asynchronous processing for data fetching and periodic updates, ensuring the main thread remains responsive.

### **2. Data Flow**
1. **Initial State**: If the database is empty, a request to `/prices` triggers `AddCoinsJob` to seed the database with supported coins from CoinGecko.
2. **Periodic Updates**: A cron-like scheduler (Sidekiq-Cron) triggers `FetchCoinPriceJob` periodically to update prices.
3. **Caching Strategy**: 
   - **Database**: Stores the latest fetched price as a fallback.
   - **Memory Cache (Redis in Production)**: Stores prices with a short TTL (2 minutes) for ultra-fast retrieval.
   - **Controller Layer**: Returns cached data if available, falling back to the database.

### **3. Resilience & Fallback Logic**
- **API Failures**: If the external API is down, the system continues to serve the last known good price from the database/cache.
- **Job Retries**: Background jobs are configured with retry logic to handle transient network issues.
- **Rate Limiting**: Designed to be mindful of external API rate limits through controlled job execution.

## **Senior Developer Perspective**
As a senior developer, this app highlights:
- **Scalability**: Use of Sidekiq for background processing allows the app to scale with the number of tracked coins.
- **Maintainability**: Clear separation of concerns and descriptive naming conventions.
- **Testability**: 100% logic coverage across Models, Jobs, Controllers, and Services using Minitest and WebMock.
- **Observability**: Structured logging for API failures and background job execution.

## **Getting Started**

### **System Dependencies**
- Ruby 3.3.0+
- PostgreSQL
- Redis (for Sidekiq and Caching)

### **Setup**
1. Clone the repository.
2. Run `bundle install`.
3. Set up environment variables in `.env`:
   ```env
   COINGECKO_API_KEY=your_api_key
   ```
4. Run `bin/rails db:prepare`.
5. Start the server: `bin/rails s`.
6. Start Sidekiq: `bundle exec sidekiq`.

### **Running Tests**
```bash
bin/rails test
```

## **API Endpoints**
- `GET /prices`: List all tracked cryptocurrency prices.
- `GET /prices/:symbol`: Get detailed price info for a specific coin (e.g., `/prices/btc`).
