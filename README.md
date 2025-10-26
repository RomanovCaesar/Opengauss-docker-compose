Usage: 

**All the commands below must be executed by root user.**

Install the latest version of docker:
```bash
curl -fsSL https://get.docker.com | sh
```

Create a working directory
```bash
mkdir ./opengauss && cd ./opengauss
```

Create data directory
```bash
mkdir -p data
```

Download [**docker-compose.yml**](https://raw.githubusercontent.com/RomanovCaesar/Opengauss-docker-compose/main/docker-compose.yml) and [**.env**](https://raw.githubusercontent.com/RomanovCaesar/Opengauss-docker-compose/main/.env) files from the repository to current directory. 
```bash
wget https://raw.githubusercontent.com/RomanovCaesar/Opengauss-docker-compose/main/docker-compose.yml -O docker-compose.yml && wget https://raw.githubusercontent.com/RomanovCaesar/Opengauss-docker-compose/main/.env -O .env
```
> ⚠️ **Warning：**
>
> * **These files are only guaranteed to run smoothly on amd64 systems. Executing results are not guaranteed on arm64 systems.**
> * **Don't forget to use your own password for security reasons!!! Password are required to contain lowercase letters, uppercase letters, numeric and special characters.**

Start the container:
```bash
docker compose up -d
```

Enter the container and connect to the database:
```bash
docker exec -it opengauss bash
su - omm
gsql
```

Do some tests after first connect:
```sql
\l       -- View databases
\du      -- View roles
```

Connect with clients (Navicat/psql):

Type：PostgreSQL

Host：127.0.0.1（or server IP）

Port：5432

User：gaussdb

Password：Aa123456!@#Db（If modified, change to the new password）
