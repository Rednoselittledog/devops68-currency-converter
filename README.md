# Currency Converter API

Convert between different currencies using fixed rates.

## Endpoint

### GET `/convert`

**Parameters:**
- `amount` (required): Amount to convert (number)
- `from` (required): Source currency (USD, EUR, GBP, JPY, AUD, CAD, INR)
- `to` (required): Target currency

**Example Request:**
```
http://localhost:3009/convert?amount=100&from=USD&to=EUR
```

**Example Response:**
```json
{
  "amount": 100,
  "from": "USD",
  "to": "EUR",
  "result": 92
}
```
