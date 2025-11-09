DROP TRIGGER IF EXISTS update_households_updated_at ON households;

ALTER TABLE profiles DROP COLUMN household_id;

DROP TABLE households;