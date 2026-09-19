require('dotenv').config({ path: require('path').join(__dirname, '../backend/.env') });
const mongoose = require('mongoose');

const uri = process.env.MONGODB_URI || 'mongodb+srv://dilshad:dilshad123@cluster0.p8mxz8t.mongodb.net/chelav?retryWrites=true&w=majority&appName=Cluster0';

async function initAtlasDatabase() {
  console.log('Connecting to MongoDB Atlas...');
  console.log(`URI: ${uri.replace(/:([^@]+)@/, ':****@')}`);

  await mongoose.connect(uri);
  console.log('✓ Successfully connected to MongoDB Atlas!');

  const db = mongoose.connection.db;
  console.log(`Database name: ${db.databaseName}`);

  // Ensure collections exist
  const collections = await db.listCollections().toArray();
  const existingNames = collections.map(c => c.name);
  console.log('Existing collections:', existingNames);

  const neededCollections = ['users', 'categories', 'transactions'];
  for (const col of neededCollections) {
    if (!existingNames.includes(col)) {
      console.log(`Creating collection: ${col}...`);
      await db.createCollection(col);
      console.log(`✓ Collection ${col} created!`);
    } else {
      console.log(`✓ Collection ${col} already exists.`);
    }
  }

  // Create indexes
  console.log('Ensuring indexes...');
  await db.collection('users').createIndex({ email: 1 }, { unique: true });
  await db.collection('categories').createIndex({ userId: 1, scope: 1, name: 1 }, { unique: true });
  await db.collection('transactions').createIndex({ userId: 1, date: -1 });
  await db.collection('transactions').createIndex({ userId: 1, type: 1, date: -1 });
  await db.collection('transactions').createIndex({ userId: 1, scope: 1, date: -1 });
  console.log('✓ All indexes successfully created on MongoDB Atlas!');

  console.log('\n======================================================');
  console.log('  CheLav database is ready on MongoDB Atlas cluster!  ');
  console.log('======================================================\n');

  await mongoose.disconnect();
}

initAtlasDatabase().catch(err => {
  console.error('Failed to initialize database:', err);
  process.exit(1);
});
