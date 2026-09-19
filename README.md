# CheLav (ചെലവ്)

**CheLav** is a minimal personal and family finance tracking application built with a **Flutter** client and a **Node.js/Express** backend designed for **MongoDB Atlas** and **Vercel** serverless deployment.

---

## ✨ Features

- **The Fundamental Formula**:
  $$\text{Available Balance} = \text{Income} - \text{Expenses} - \text{Savings}$$
- **Personal vs. Family Tracking**:
  - Every expense is marked as either **Personal** or **Family**.
  - **Independent category lists** for Personal and Family expenses.
  - Complete control to add custom categories, rename, disable, or delete.
- **Dedicated Savings Accounting**:
  - Transfers to savings reduce available balance without being misclassified as an expense.
- **Comprehensive Reporting**:
  - **Daily Report**: View income, expenses, savings, net day balance, and category-wise spending with intuitive day-by-day navigation (`< Today >`).
  - **Category Reports**: Ranked category spending with interactive time filters (*Today*, *This Week*, *This Month*, *Last Month*, *Custom Date Range*) and scope filters (*All*, *Personal*, *Family*).
  - **Monthly Overview**: Month-by-month financial summary with historical navigation.
- **Transaction Ledger**:
  - Complete transaction history with instant search, multi-criteria filtering, and tap-to-edit/delete.
- **Minimal Black-and-White Aesthetic**:
  - Pure monochrome dark-mode first design (with light mode support).
  - Subtle semantic colors used strictly for financial status: Green (Income/Positive), Red (Expense/Deficit), Amber (Savings).
- **Indian Rupee Standard**:
  - Native formatting using the Indian numbering system (`₹1,250`, `₹25,000`, `₹1,05,500`).
- **Multi-Device Cloud Sync**:
  - Access the same account from any smartphone or browser.

---

## 🏗️ Tech Stack

- **Mobile & Web App**: Flutter 3.47 (Dart 3.13)
- **Backend API**: Node.js, Express, Mongoose, JWT authentication
- **Database**: MongoDB Atlas (Cloud) / Local MongoDB
- **Hosting**: Vercel Serverless Functions + Global Static CDN

---

## 📖 Deployment Guide

See [DEPLOYMENT.md](file:///home/dilshad/Desktop/Chelav/DEPLOYMENT.md) for step-by-step instructions on deploying the backend and Flutter web version to **Vercel** with a free **MongoDB Atlas** database.
