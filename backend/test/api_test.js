const assert = require('assert');
const http = require('http');

const PORT = 5001;
const BASE_URL = `http://localhost:${PORT}/api`;

function request(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(`${BASE_URL}${path}`);
    const options = {
      method,
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, raw: data });
        }
      });
    });

    req.on('error', reject);

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('--- Starting CheLav Backend Integration Tests ---');

  const testEmail = `testuser_${Date.now()}@chelav.app`;
  const testPassword = 'Password123!';

  // 1. Health check
  console.log('1. Checking server health...');
  const health = await request('GET', '/health');
  assert.strictEqual(health.status, 200);
  assert.strictEqual(health.data.status, 'healthy');
  console.log('✓ Health check passed');

  // 2. Register user
  console.log('2. Registering new test user...');
  const regRes = await request('POST', '/auth/register', {
    name: 'Dilshad',
    email: testEmail,
    password: testPassword,
  });
  assert.strictEqual(regRes.status, 201, `Failed to register: ${JSON.stringify(regRes.data)}`);
  const token = regRes.data.token;
  assert(token, 'Token must be returned upon registration');
  console.log('✓ User registration passed with JWT');

  // 3. Verify seeded categories
  console.log('3. Checking seeded Personal and Family categories...');
  const catRes = await request('GET', '/categories', null, token);
  assert.strictEqual(catRes.status, 200);
  const categories = catRes.data.categories;
  const personalCats = categories.filter((c) => c.scope === 'personal');
  const familyCats = categories.filter((c) => c.scope === 'family');
  console.log(`Found ${personalCats.length} personal categories and ${familyCats.length} family categories.`);
  assert(personalCats.some((c) => c.name === 'Food'), 'Personal categories should have Food');
  assert(familyCats.some((c) => c.name === 'Household'), 'Family categories should have Household');
  console.log('✓ Category seeding verified');

  // 4. Create custom category
  console.log('4. Creating custom category...');
  const customCatRes = await request(
    'POST',
    '/categories',
    { name: 'Gym & Fitness', scope: 'personal', icon: 'dumbbell' },
    token
  );
  assert.strictEqual(customCatRes.status, 201);
  console.log('✓ Custom category created');

  // 5. Add Income
  console.log('5. Adding Income: ₹50,000 (Salary)...');
  const incRes = await request(
    'POST',
    '/transactions',
    {
      type: 'income',
      amount: 50000,
      source: 'Salary',
      description: 'Monthly company salary',
    },
    token
  );
  assert.strictEqual(incRes.status, 201);
  console.log('✓ Income recorded');

  // 6. Add Personal Expenses
  console.log('6. Adding Personal Expenses: Food ₹450, Fuel ₹800...');
  const exp1 = await request(
    'POST',
    '/transactions',
    {
      type: 'expense',
      scope: 'personal',
      category: 'Food',
      amount: 450,
      description: 'Dinner with colleagues',
    },
    token
  );
  assert.strictEqual(exp1.status, 201);

  const exp2 = await request(
    'POST',
    '/transactions',
    {
      type: 'expense',
      scope: 'personal',
      category: 'Fuel',
      amount: 800,
      description: 'Petrol refill',
    },
    token
  );
  assert.strictEqual(exp2.status, 201);
  console.log('✓ Personal expenses recorded');

  // 7. Add Family Expense
  console.log('7. Adding Family Expense: Household ₹3,000...');
  const exp3 = await request(
    'POST',
    '/transactions',
    {
      type: 'expense',
      scope: 'family',
      category: 'Household',
      amount: 3000,
      description: 'Monthly groceries and provisions',
    },
    token
  );
  assert.strictEqual(exp3.status, 201);
  console.log('✓ Family expense recorded');

  // 8. Add Savings
  console.log('8. Adding Savings: ₹10,000 (Emergency Fund)...');
  const savRes = await request(
    'POST',
    '/transactions',
    {
      type: 'savings',
      amount: 10000,
      destination: 'Emergency Fund',
      description: 'Transfer to high-yield savings',
    },
    token
  );
  assert.strictEqual(savRes.status, 201);
  console.log('✓ Savings recorded');

  // 9. Verify Dashboard Summary and Balance Formula
  console.log('9. Verifying Dashboard summary & formula: Income - Expenses - Savings = Balance...');
  const sumRes = await request('GET', '/reports/summary', null, token);
  assert.strictEqual(sumRes.status, 200);
  const summary = sumRes.data.data;

  console.log('Summary Result:', {
    totalIncome: summary.totalIncome,
    totalExpenses: summary.totalExpenses,
    personalExpenses: summary.personalExpenses,
    familyExpenses: summary.familyExpenses,
    totalSavings: summary.totalSavings,
    availableBalance: summary.availableBalance,
  });

  assert.strictEqual(summary.totalIncome, 50000);
  assert.strictEqual(summary.personalExpenses, 1250); // 450 + 800
  assert.strictEqual(summary.familyExpenses, 3000);
  assert.strictEqual(summary.totalExpenses, 4250);
  assert.strictEqual(summary.totalSavings, 10000);
  // Balance: 50,000 - 4,250 - 10,000 = 35,750
  assert.strictEqual(summary.availableBalance, 35750);
  console.log('✓ Formula verified: 50000 - 4250 - 10000 = ₹35,750 Available Balance!');

  // 10. Verify Daily Report
  console.log('10. Verifying Daily Report...');
  const dailyRes = await request('GET', `/reports/daily?date=${new Date().toISOString().split('T')[0]}`, null, token);
  assert.strictEqual(dailyRes.status, 200);
  const daily = dailyRes.data.data;
  assert.strictEqual(daily.dayIncome, 50000);
  assert.strictEqual(daily.dayExpenses, 4250);
  assert.strictEqual(daily.daySavings, 10000);
  assert.strictEqual(daily.dayBalance, 35750);
  assert.strictEqual(daily.categories.length, 3); // Food, Fuel, Household
  console.log('✓ Daily report verified');

  // 11. Verify Category Report
  console.log('11. Verifying Category Report...');
  const catReportRes = await request('GET', '/reports/categories?range=month&scope=all', null, token);
  assert.strictEqual(catReportRes.status, 200);
  const catReport = catReportRes.data.data;
  assert.strictEqual(catReport.totalSpending, 4250);
  console.log('✓ Category report verified');

  // 12. Verify Monthly Overview
  console.log('12. Verifying Monthly Overview...');
  const monthRes = await request('GET', `/reports/monthly?year=${new Date().getFullYear()}&month=${new Date().getMonth() + 1}`, null, token);
  assert.strictEqual(monthRes.status, 200);
  assert.strictEqual(monthRes.data.data.availableBalance, 35750);
  console.log('✓ Monthly overview verified');

  console.log('\n========================================');
  console.log('  ALL BACKEND INTEGRATION TESTS PASSED!  ');
  console.log('========================================\n');
}

module.exports = { runTests };

if (require.main === module) {
  runTests().catch((err) => {
    console.error('Test failed with error:', err);
    process.exit(1);
  });
}
