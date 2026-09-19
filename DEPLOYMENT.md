# CheLav Deployment Guide: Vercel + MongoDB Atlas + Flutter Web

This guide walks you through deploying **CheLav** to **Vercel** with a cloud **MongoDB Atlas** database, enabling access from any mobile phone or browser across the world.

---

## 🌟 Architecture Overview

CheLav is configured with a **Unified Full-Stack Vercel Architecture**:
* **Frontend (Flutter Web SPA)**: Served directly from Vercel's global CDN at `/`.
* **Backend (Node.js API)**: Runs as high-performance Vercel Serverless Functions at `/api/*`.
* **Database (MongoDB Atlas)**: Cloud-hosted NoSQL cluster holding all users, categories, and transactions.

Because the frontend and backend share the exact same Vercel domain:
1. **Zero CORS issues** between the web client and server.
2. **Automatic Origin Detection**: The Flutter web app automatically connects to `/api` on your live domain without manual configuration.
3. **Multi-device Sync**: Login with your account from any phone browser or desktop to see your real-time balance and reports.

---

## 🚀 Step 1: Set Up MongoDB Atlas (Free Cloud Database)

1. Go to [mongodb.com/atlas](https://www.mongodb.com/atlas) and sign in or create a free account.
2. Click **Create Deployment** and select the **M0 Free Cluster** (free forever).
3. **Database Access (User)**:
   * Go to **Security** > **Database Access**.
   * Click **Add New Database User**.
   * Choose **Password Authentication**.
   * Set a username (e.g. `chelav_admin`) and a secure password.
   * Assign role: `Read and write to any database`.
4. **Network Access (IP Whitelist)**:
   * Go to **Security** > **Network Access**.
   * Click **Add IP Address**.
   * Click **Allow Access from Anywhere** (`0.0.0.0/0`) so Vercel's serverless nodes can connect.
   * Click **Confirm**.
5. **Configured Connection String**:
   * Your cluster `Cluster0` and `chelav` database are already verified and configured:
     ```text
     mongodb+srv://dilshad:dilshad123@cluster0.p8mxz8t.mongodb.net/chelav?retryWrites=true&w=majority&appName=Cluster0
     ```

---

## 🚢 Step 2: Deploy to Vercel

### Method A: Deploy via GitHub (Recommended)

1. **Initialize Git & Push to GitHub**:
   ```bash
   cd /path/to/Chelav
   git init
   git add .
   git commit -m "Initial commit: CheLav personal finance tracking app"
   ```
   * Create a new repository on [GitHub](https://github.com/new).
   * Push your code:
     ```bash
     git remote add origin https://github.com/<your-username>/chelav.git
     git branch -M main
     git push -u origin main
     ```

2. **Import Project in Vercel**:
   * Go to [vercel.com](https://vercel.com) and log in.
   * Click **Add New...** > **Project**.
   * Select your `chelav` repository and click **Import**.

3. **Configure Environment Variables in Vercel**:
   Under **Environment Variables**, add:
   * `MONGODB_URI`: Your MongoDB Atlas connection string from Step 1.
   * `JWT_SECRET`: A secure random string (e.g., `chelav_prod_secret_token_987654321`).
   * `NODE_ENV`: `production`

4. **Click Deploy**:
   * Vercel will deploy your project in seconds!
   * You will receive a live URL: `https://chelav-xyz.vercel.app`.

---

### Method B: Deploy via Vercel CLI

If you have the Vercel CLI installed:
```bash
cd /path/to/Chelav

# Log in to Vercel
npx vercel login

# Deploy to production
npx vercel --prod
```

When prompted:
* Link to existing project? `N`
* What's your project's name? `chelav`
* In which directory is your code located? `./`

Then add the environment variables via CLI or Vercel dashboard:
```bash
npx vercel env add MONGODB_URI
npx vercel env add JWT_SECRET
```

---

## 📱 Step 3: Accessing CheLav on Your Phone

Once deployed:
1. Open your smartphone browser (Safari, Chrome, etc.).
2. Navigate to your Vercel URL (e.g. `https://chelav-xyz.vercel.app`).
3. Tap **Create Account** and register your credentials.
4. **Tip**: Add to Home Screen:
   * On iOS Safari: Tap **Share** > **Add to Home Screen**.
   * On Android Chrome: Tap **Menu** (three dots) > **Add to Home screen** / **Install app**.
   * CheLav will launch as a standalone, fullscreen native-like app!
5. Open the same link on a family member's phone or secondary device, sign in with the same account, and see your finances sync in real-time.

---

## 🛠️ Local Development Quickstart

If you want to run CheLav locally on your computer:

1. **Start Backend (Port 5001)**:
   ```bash
   cd /path/to/Chelav/backend
   npm run dev
   ```
   * Runs local server on `http://localhost:5001` connected to local MongoDB or your Atlas URI.

2. **Run Flutter Web or Mobile App**:
   ```bash
   cd /path/to/Chelav/chelav_app
   flutter run -d chrome
   ```
   * Or run on an Android device / emulator: `flutter run -d android`.

3. **Rebuild Web Build for Production**:
   ```bash
   npm run build:web
   ```
   This compiles Flutter Web with tree-shaking and copies the static assets directly to `public/` for instant deployment.
