const express = require('express');
const app = express();

const rates = {
  'USD': 1,
  'EUR': 0.92,
  'GBP': 0.79,
  'JPY': 149.50,
  'AUD': 1.53,
  'CAD': 1.36,
  'INR': 83.12
};

app.get('/convert', (req, res) => {
  const { amount, from, to } = req.query;
  if (!amount || !from || !to) return res.status(400).json({ error: 'Missing parameters' });
  
  if (!rates[from] || !rates[to]) return res.status(400).json({ error: 'Invalid currency code' });
  
  const amt = parseFloat(amount);
  if (isNaN(amt)) return res.status(400).json({ error: 'Amount must be number' });
  
  const result = (amt / rates[from]) * rates[to];
  res.json({ amount: amt, from, to, result: Math.round(result * 100) / 100 });
});

app.listen(3009, () => console.log('Currency Converter API on port 3009'));
