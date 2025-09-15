#!/bin/bash

echo "🗄️  Setting up database tables..."

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 5

# Run the SQL script
echo "📝 Creating tables..."
docker compose -f docker-compose.test.yml exec -T postgres psql -U postgres -d nestdb < scripts/create-tables.sql

echo "✅ Database setup complete!"
