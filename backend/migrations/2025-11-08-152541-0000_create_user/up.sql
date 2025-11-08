CREATE TABLE "user"(
	"id" UUID NOT NULL PRIMARY KEY,
	"email" VARCHAR UNIQUE NOT NULL,
	"password_hash" VARCHAR NOT NULL,
	"created_at" TIMESTAMP NOT NULL DEFAULT NOW(),
	"updated_at" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON "user"
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
