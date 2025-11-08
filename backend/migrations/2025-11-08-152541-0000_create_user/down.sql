-- This file should undo anything in `up.sql`
DROP TABLE IF EXISTS "user";

DROP FUNCTION IF EXISTS update_updated_at_column();