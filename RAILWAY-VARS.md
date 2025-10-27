# Railway PostgreSQL Connection Variables
# Add these to Railway Dashboard -> Variables tab

# Option 1: Use DATABASE_URL (Recommended)
DATABASE_URL=postgresql://postgres:ivimUeIKQLYmRUkRuWYMxgFKgUgHYMHh@mainline.proxy.rlwy.net:10238/railway

# Option 2: Use Individual Variables (Backup)
PGHOST=mainline.proxy.rlwy.net
PGPORT=10238
PGUSER=postgres
PGPASSWORD=ivimUeIKQLYmRUkRuWYMxgFKgUgHYMHh
PGDATABASE=railway

# Railway automatically sets these:
NODE_ENV=production
PORT=(auto-assigned)

# IMPORTANT: 
# - Use either DATABASE_URL OR individual PG* variables, not both
# - Railway PostgreSQL service should automatically provide these
# - If not automatic, add them manually in Railway Variables tab