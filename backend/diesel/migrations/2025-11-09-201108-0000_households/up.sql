CREATE TABLE households (
    id UUID PRIMARY KEY,
    name VARCHAR NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE profiles ADD COLUMN household_id UUID REFERENCES households(id);

CREATE TRIGGER update_households_updated_at
BEFORE UPDATE ON households
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();
