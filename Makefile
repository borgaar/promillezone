fresh:
	- docker compose --profile dev -f docker-compose.yml down
	docker compose --profile dev -f docker-compose.yml up -d --build
	- sleep 2
	- pnpx prisma migrate dev

db:
	- docker compose --profile dev -f docker-compose.yml down database
	-	docker volume rm promillezone_promillezone_data
	docker compose --profile dev -f docker-compose.yml up -d database
	- sleep 2
	- pnpx prisma migrate dev

.PHONY: prod
prod:
	docker build -t promille.zone .
	- docker rm -f promille.zone
	- prisma migrate deploy
	docker run --env-file .env -p 2808:3000 --name promille.zone --restart unless-stopped -d promille.zone
