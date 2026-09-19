Build a personal expense and finance tracking app called **CheLav**.

## Core idea

CheLav is a personal finance app where I can track:

* Income
* Personal expenses
* Family expenses
* Savings
* Remaining balance

The same account should be accessible from any phone, so the app needs a backend and cloud database.

## Technology

Use:

* **Flutter** for the mobile app
* **MongoDB Atlas** for the database
* **Vercel** for hosting the backend/server

You can decide the architecture, libraries, API structure, database schema, state management, and other implementation details.

---

## Expense tracking

I should be able to quickly add an expense with:

* Amount
* Category
* Personal or Family
* Date
* Optional description

The main categories could initially include:

* Food
* Fuel
* Travel
* Medical
* Shopping
* Bills
* Entertainment
* Education
* Household
* Other

But categories should **not be fixed**.

I should be able to create my own categories, rename them, disable them, or delete them.

Personal and Family should have **separate category lists**.

For example:

Personal:

* Food
* Fuel
* Travel
* Medical

Family:

* Food
* Household
* Medical
* Education

I should have complete control over both sets of categories.

---

## Personal vs Family

Every expense should belong to either:

**Personal**

or

**Family**

I should be able to easily switch between them when adding an expense.

Reports should also allow me to see:

* Total personal spending
* Total family spending
* Combined spending

---

## Income

I should be able to record income.

For example:

* Salary
* Bonus
* Freelance
* Other income

Each income entry should have:

* Amount
* Date
* Source
* Optional description

There can be multiple income entries.

---

## Savings

Savings should be separate from expenses.

For example:

Income: ₹50,000
Expenses: ₹15,000
Savings: ₹10,000

Available balance:

**₹25,000**

Savings should reduce my available balance but should **not appear as an expense**.

I should be able to record transfers to savings with:

* Amount
* Date
* Destination/description

---

## Balance

The app should clearly show:

**Income - Expenses - Savings = Available Balance**

The dashboard should make this extremely easy to understand.

For example:

Income
₹50,000

Expenses
₹15,000

Savings
₹10,000

**Available Balance
₹25,000**

---

## Dashboard

The dashboard should be the main screen.

Show:

* Current available balance
* Total income
* Total expenses
* Total savings
* Personal spending
* Family spending
* Today's spending

Also show a simple list of today's expenses.

There should be quick actions for:

**+ Expense**

**+ Income**

**+ Savings**

Adding an expense should be very fast, ideally requiring only a few taps.

---

## Daily report

I want to be able to select any date and see a complete report for that day.

For example:

### September 19

Income
₹50,000

Expenses
₹1,750

Savings
₹10,000

Balance
₹38,250

Then show category-wise spending:

Food — ₹450
Fuel — ₹800
Travel — ₹300
Medical — ₹200

Also show:

Personal — ₹1,450
Family — ₹300

I should be able to move between days easily.

---

## Category reports

I want category-wise spending reports.

For example, for September:

Food — ₹4,250
Fuel — ₹3,100
Travel — ₹2,800
Medical — ₹1,200
Shopping — ₹2,500

Show totals and allow filtering by:

* Personal
* Family
* All

Allow selecting:

* Today
* This week
* This month
* Last month
* Custom date range

---

## Monthly overview

Provide a monthly financial summary showing:

* Total income
* Personal expenses
* Family expenses
* Total expenses
* Savings
* Available balance
* Category-wise spending

I should be able to browse different months.

---

## Transaction history

Provide a complete history of all transactions.

I should be able to view:

* Expenses
* Income
* Savings

and filter/search them.

I should be able to edit or delete an existing transaction.

---

## Multi-device access

My financial data should be stored online so I can:

* Login from my phone
* Login from another phone
* See the same data
* Add an expense from either phone
* Immediately see the updated balance and reports

Data must belong to my account and should not be accessible to other users.

---

## Design

The app should have a **minimal black-and-white aesthetic**.

Primary colors:

* Black
* White
* Dark gray
* Light gray

Do not make the application colorful.

Use colors **only when they communicate information**, for example:

* Green for positive/available balance
* Red for expenses or negative balance
* Orange/yellow for warnings
* Blue only when useful for informational states

The informational colors should be subtle.

The overall interface should remain predominantly black and white.

---

## UI style

The app should feel:

* Modern
* Minimal
* Premium
* Clean
* Fast
* Practical

Avoid:

* Excessive gradients
* Bright colorful cards
* Unnecessary illustrations
* Excessive animations
* Gamification
* Clutter

Prioritize typography, spacing, hierarchy, and good information presentation.

Dark mode should be supported and should feel like the primary experience.

Light mode can also be available.

---

## Important UX goal

The most important information should always be easy to find:

**How much money do I have?**

**How much did I spend?**

**How much did I save?**

**Where did I spend it?**

**How much was personal vs family?**

**What did I spend today?**

The app should feel like a simple personal financial ledger rather than a complicated accounting application.

---

## Backend

The app requires a server/backend because the same account and financial data must be accessible from different phones.

Use **MongoDB Atlas** as the cloud database and deploy the backend/server on **Vercel**.

Choose the backend framework, API design, authentication mechanism, database structure, and other implementation details based on what is most appropriate.

Make the system secure and production-ready.

---

## Currency

Use **Indian Rupees (₹)** by default.

Examples should be displayed like:

₹1,250

₹25,000

₹1,05,500

---

## Future flexibility

Keep the app extensible so features can be added later, such as:

* Budgets
* Recurring expenses
* Recurring income
* Multiple savings accounts
* Bank accounts
* Receipt images
* Exporting financial data
* More detailed analytics
* Family members
* Notifications

Don't implement unnecessary future features now. Focus on making the core expense, income, savings, balance, category, and reporting experience excellent.

Build **CheLav as a complete working application, not just a UI prototype**.
