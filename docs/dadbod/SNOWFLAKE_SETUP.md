# Vim-Dadbod Snowflake Setup Guide

This guide covers setting up vim-dadbod for direct Snowflake database access using private key authentication.

## Overview

**vim-dadbod** provides:
- 🔄 **Direct database connections** - No dbt needed
- 📊 **Interactive database UI** - Browse schemas, tables, execute ad-hoc queries
- ✨ **SQL autocompletion** - Context-aware completions from your database
- 🔐 **Secure authentication** - Private key support (no password needed)

## Architecture

Three plugins work together:

1. **vim-dadbod** - Core database interface
2. **vim-dadbod-ui** - Interactive UI for browsing databases
3. **vim-dadbod-completion** - Database-aware SQL autocompletion

Config location: `lua/plugins/data-tools/dadbod.lua`

## Setup Requirements

### 1. Environment Variables

You need to set these environment variables before launching Neovim:

```bash
# Snowflake credentials
export SNOWFLAKE_USER="your_username"
export SNOWFLAKE_ACCOUNT="xy12345.us-east-1"          # Without .snowflakecomputing.com
export SNOWFLAKE_WAREHOUSE="COMPUTE_WH"
export SNOWFLAKE_ROLE="TRANSFORMER"                    # Optional, defaults to TRANSFORMER
export SNOWFLAKE_PRIVATE_KEY_PATH="~/.ssh/snowflake_key"

# Database names (optional, defaults shown)
export SNOWFLAKE_RAW_DB="RAW"                          # Default database
export SNOWFLAKE_ANALYTICS_DB="ANALYTICS"
export SNOWFLAKE_STAGING_DB="STAGING"
export SNOWFLAKE_DEV_DB="DEV"
```

### 2. Snowflake Private Key Setup

Generate your private key if you haven't already:

```bash
# Generate unencrypted private key (NOT recommended for production)
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out ~/.ssh/snowflake_key -nocrypt

# Generate encrypted private key (RECOMMENDED)
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out ~/.ssh/snowflake_key

# Set permissions
chmod 600 ~/.ssh/snowflake_key
```

Then upload your public key to Snowflake:

```bash
# Get public key from private key
openssl pkey -in ~/.ssh/snowflake_key -pubout

# In Snowflake SQL:
ALTER USER your_username SET RSA_PUBLIC_KEY='<paste_your_public_key>';
```

**OR** use your existing company Snowflake key if available.

### 3. Persistent Environment Variables

Add to your shell config (`~/.zshrc`, `~/.bashrc`, or `~/.fish/config.fish`):

```bash
# ~/.zshrc example
export SNOWFLAKE_USER="your_username"
export SNOWFLAKE_ACCOUNT="xy12345.us-east-1"
export SNOWFLAKE_WAREHOUSE="COMPUTE_WH"
export SNOWFLAKE_PRIVATE_KEY_PATH="$HOME/.ssh/snowflake_key"
```

Or set them per-project in a `.envrc` file (if using direnv):

```bash
# .envrc in your project root
export SNOWFLAKE_USER="your_username"
export SNOWFLAKE_ACCOUNT="xy12345.us-east-1"
export SNOWFLAKE_WAREHOUSE="COMPUTE_WH"
export SNOWFLAKE_PRIVATE_KEY_PATH="$HOME/.ssh/snowflake_key"
```

Then run:
```bash
direnv allow
```

## Usage

### Launch Database UI

```vim
:DBUIToggle
```

This opens the database browser on the right side. You can:
- Browse databases and schemas
- Expand tables to see columns
- Right-click for operations
- Double-click to see table data

### Execute Queries

#### Method 1: In SQL files

Create a `.sql` file and write SQL:

```sql
-- queries/my_query.sql
SELECT * FROM RAW.PUBLIC.USERS LIMIT 10;
```

In Neovim:
```vim
" Execute entire buffer or selection
<leader>dB
```

#### Method 2: Quick DB command

```vim
" Direct database command
:DB snowflake_raw SELECT * FROM TABLES LIMIT 5;

" List databases
:DB snowflake_raw SHOW DATABASES;

" List tables
:DB snowflake_raw SHOW TABLES IN RAW.PUBLIC;
```

#### Method 3: Write and execute SQL

```vim
:DBUIToggle
" In the DBUI, you can directly write and execute SQL
" Results appear in a new buffer
```

### Database Connections

The config automatically creates connections for each database:

```
snowflake_raw        # RAW database (default)
snowflake_analytics  # ANALYTICS database
snowflake_staging    # STAGING database
snowflake_dev        # DEV database
```

Switch between them in DBUI or with:

```vim
:DB snowflake_analytics SELECT * FROM TABLES;
```

### SQL Autocompletion

In `.sql` files, you get database-aware autocomplete:

```sql
SELECT * FROM <C-x><C-u>  " Shows available tables
SELECT * FROM users.
                    ^     " Shows columns from users table
```

## Configuration

The dadbod plugin is configured in `lua/plugins/data-tools/dadbod.lua`. Key settings:

```lua
-- UI position and size
vim.g.db_ui_win_position = "right"    -- "left", "right", "top", "bottom"
vim.g.db_ui_winwidth = 50             -- Width of UI panel

-- Auto-execute on save
vim.g.db_ui_auto_execute_table_helpers = 1

-- Helper queries for Snowflake
vim.g.db_ui_table_helpers = {
  snowflake = {
    List = "SELECT * FROM {table}",
    Columns = "DESC TABLE {table}",
    Count = "SELECT COUNT(*) FROM {table}",
  },
}
```

## Troubleshooting

### "Missing Snowflake environment variables"

Check if vars are set:
```bash
echo $SNOWFLAKE_USER
echo $SNOWFLAKE_ACCOUNT
echo $SNOWFLAKE_WAREHOUSE
echo $SNOWFLAKE_PRIVATE_KEY_PATH
```

Then reload Neovim.

### "Private key not found" error

1. Check key exists:
```bash
ls -l ~/.ssh/snowflake_key
ls -l ~/.ssh/snowflake_key.pub
```

2. Verify path is correct in env var
3. Check file permissions (should be `600`)
4. Test key manually:
```bash
# You shouldn't be prompted for password if key is unencrypted
ssh-keygen -y -f ~/.ssh/snowflake_key > /dev/null && echo "Key OK" || echo "Key problem"
```

### "Authentication failed"

1. Verify public key is set in Snowflake:
```sql
DESC USER your_username;
```

2. Check key matches:
```bash
# Extract public key from your private key
openssl pkey -in ~/.ssh/snowflake_key -pubout

# Compare with what's in Snowflake
-- In Snowflake SQL
DESC USER your_username;
-- Look for RSA_PUBLIC_KEY value
```

3. Regenerate keys if needed:
```bash
rm ~/.ssh/snowflake_key ~/.ssh/snowflake_key.pub
# Generate new key (see "Snowflake Private Key Setup" above)
```

### "Connection timeout"

1. Verify network connectivity:
```bash
# Snowflake account check
curl -I https://xy12345.us-east-1.snowflakecomputing.com
```

2. Check account ID format:
```
❌ xy12345.us-east-1.snowflakecomputing.com  (wrong - don't include .snowflakecomputing.com)
✅ xy12345.us-east-1                         (correct format)
```

3. Verify warehouse is running:
```sql
SHOW WAREHOUSES;
-- Your warehouse should show "STARTED"
```

### "No results" or "Query execution timeout"

1. Check query syntax (Snowflake uses uppercase):
```sql
-- ✅ Correct
SELECT * FROM RAW.PUBLIC.USERS LIMIT 10;

-- ⚠️ Might work but inconsistent
SELECT * FROM raw.public.users LIMIT 10;
```

2. Add explicit LIMIT:
```sql
SELECT * FROM RAW.PUBLIC.LARGE_TABLE LIMIT 100;
```

3. Test with simpler query:
```sql
SELECT 1;
SELECT CURRENT_USER();
```

### Vim-dadbod UI not opening

```vim
" Check if plugin loaded
:checkhealth dadbod

" Manually load plugin
:packadd vim-dadbod
:packadd vim-dadbod-ui

" Try again
:DBUIToggle
```

## Tips & Tricks

### Save frequent queries

Create `.sql` files in a `queries/` folder:

```bash
mkdir -p ~/queries/snowflake
```

```sql
-- ~/queries/snowflake/user_summary.sql
SELECT
  COUNT(*) as total_users,
  COUNT(DISTINCT user_id) as unique_users
FROM RAW.PUBLIC.USERS;
```

Execute any time:
```vim
:e ~/queries/snowflake/user_summary.sql
<leader>dB
```

### Preview large datasets safely

Always use LIMIT:

```sql
-- Bad - could return millions of rows
SELECT * FROM RAW.PUBLIC.EVENT_LOG;

-- Good
SELECT * FROM RAW.PUBLIC.EVENT_LOG LIMIT 100;
```

### Use temporary view for complex queries

```sql
-- Create temp view for exploration
CREATE TEMP VIEW my_analysis AS
SELECT user_id, COUNT(*) as event_count
FROM RAW.PUBLIC.EVENT_LOG
GROUP BY user_id;

-- Now query it
SELECT * FROM my_analysis LIMIT 20;

-- Clean up
DROP VIEW my_analysis;
```

### Compare dbt vs vim-dadbod workflows

| Feature | dbt-power | vim-dadbod |
|---------|-----------|-----------|
| Uses dbt compilation | ✅ | ❌ |
| Direct SQL execution | ❌ | ✅ |
| Table browsing | ❌ | ✅ |
| Schema/column exploration | ❌ | ✅ |
| Source introspection | ✅ | ❌ |
| Ad-hoc queries | ✅ (via ad-hoc models) | ✅ |
| Database-aware autocomplete | ⚠️ (dbt sources) | ✅ |

**Use vim-dadbod when:**
- Exploring unfamiliar schemas
- Writing and testing SQL before adding to dbt
- Running operational queries
- Investigating data issues quickly

**Use dbt-power when:**
- Working within your dbt project
- Using dbt models/sources
- Previewing model outputs
- Enforcing dbt conventions

## Related Docs

- [DATABASE_CONFIG.md](../database/DATABASE_CONFIG.md) - dbt database configuration
- [Snowflake Documentation](https://docs.snowflake.com/)
- [vim-dadbod GitHub](https://github.com/tpope/vim-dadbod)
- [Private Key Authentication](https://docs.snowflake.com/en/user-guide/key-pair-auth)
