1. source /Users/zoeyzuo/Library/Caches/pypoetry/virtualenvs/friendsapp-7cmik27f-py3.10/bin/activate
2. poetry install --no-root (when you want to install dependencies without the project itself)
3. poetry run python manage.py migrate
   1. applies database schema changes - it reads the migration files and apply them to the database
   2. creates/updates database tables: columns, types etc
   3. when to run: when there's schema changes
4. poetry run python manage.py runserver
   1. starts the development server
   2. serves the application on http://localhost:8000/api/
5. poetry run python manage.py populate_profiles
   1. creates 10 fake profiles with realistic data and profile pictures
   2. can run multiple times - will skip profiles that already exist (by name)
   3. shows total count after creation



2. az login --tenant d2d784bc-0d27-42f0-af6f-b0344a030401 // using gmail account
3. az account set --subscription 28c953a9-8cca-431d-8936-611d1a79878f
4. terraform --version
5. docker info : make sure docker is running

terraform:
1. terraform init
2. terraform plan
3. terraform apply
4. terraform output