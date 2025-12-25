# Local Supabase Setup Guide for Mac

This guide provides step-by-step instructions to set up Docker and Supabase locally on your Mac machine. This allows you to develop and test your Supabase projects in a local environment before deploying to production.

## Prerequisites

- macOS (latest version recommended)
- Internet connection for downloads
- Basic familiarity with terminal commands

## Step 1: Install Docker Desktop

Docker is required to run Supabase's local development environment.

1. **Download Docker Desktop:**
   - Visit the [Docker Desktop for Mac website](https://www.docker.com/products/docker-desktop/)
   - Click "Download for Mac" to download the installer

2. **Install Docker Desktop:**
   - Open the downloaded `.dmg` file
   - Drag Docker.app to your Applications folder
   - Launch Docker Desktop from Applications
   - Follow the setup wizard (you may need to enter your system password)

3. **Verify Installation:**
   - Open Terminal and run:
     ```bash
     docker --version
     ```
   - You should see the Docker version displayed
   - Also check that Docker Desktop is running (look for the whale icon in your menu bar)

## Step 2: Install Supabase CLI

The Supabase CLI is a command-line tool for managing your Supabase projects.

1. **Install via Homebrew (Recommended):**
   ```bash
   brew install supabase/tap/supabase
   ```

2. **Alternative: Install via npm (if you have Node.js):**
   ```bash
   npm install supabase --save-dev
   ```

3. **Verify Installation:**
   ```bash
   supabase --version
   ```
   - You should see the Supabase CLI version

## Step 3: Initialize a Supabase Project

Create a new Supabase project or initialize an existing one.

1. **Navigate to your project directory:**
   ```bash
   cd /path/to/your/project
   ```
   (Replace with your actual project path, e.g., `/Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app`)

2. **Initialize Supabase:**
   ```bash
   supabase init
   ```
   - This creates a `supabase` folder in your project with configuration files

3. **Start the local Supabase services:**
   ```bash
   supabase start
   ```
   - This will download and start all necessary Docker containers
   - The first run may take several minutes as it pulls images

4. **Verify services are running:**
   - Check that containers are running in Docker Desktop
   - Or run: `docker ps` to see active containers

## Step 4: Access Local Supabase Dashboard

Once services are running, you can access the local Supabase dashboard.

1. **Open your browser and go to:**
   ```
   http://localhost:54323
   ```

2. **Default credentials:**
   - Email: `admin@example.com`
   - Password: `password`

## Step 5: Set Up Your Database

Configure your local database with schemas, tables, and policies.

1. **Run migrations (if you have them):**
   ```bash
   supabase db reset
   ```
   - This applies any migrations in your `supabase/migrations` folder

2. **Seed your database (if you have seed files):**
   - Seed files are automatically run when you start Supabase
   - Or manually run: `supabase db seed`

## Step 6: Connect Your Application

Update your application to connect to the local Supabase instance.

1. **Update your Supabase URL and keys:**
   - In your application code, use:
     - URL: `http://localhost:54321`
     - Anon Key: Check the dashboard or run `supabase status` for keys

2. **Example for Flutter/Dart:**
   ```dart
   final supabase = SupabaseClient(
     'http://localhost:54321',
     'your-anon-key-here',
   );
   ```

## Step 7: Development Workflow

Typical development cycle with local Supabase:

1. **Make changes to your database:**
   - Edit SQL files in `supabase/migrations/`
   - Or use the dashboard for quick changes

2. **Apply changes:**
   ```bash
   supabase db reset
   ```

3. **Test your application:**
   - Run your app and test against local Supabase

4. **Stop services when done:**
   ```bash
   supabase stop
   ```

## Troubleshooting

### Common Issues:

1. **Docker not starting:**
   - Ensure Docker Desktop is running
   - Check if you have enough disk space

2. **Port conflicts:**
   - If ports 54321-54323 are in use, stop other services or configure different ports

3. **Supabase start fails:**
   - Run `supabase status` to check service health
   - Try `supabase stop` then `supabase start` again

4. **Database connection issues:**
   - Verify the URL and keys in your application
   - Check that Supabase services are running

### Useful Commands:

- `supabase status` - Check status of all services
- `supabase logs` - View logs for troubleshooting
- `supabase db diff` - See differences between local and remote
- `supabase db push` - Push local changes to remote project

## Next Steps

- Read the [Supabase Local Development documentation](https://supabase.com/docs/guides/local-development)
- Explore the [Supabase CLI reference](https://supabase.com/docs/reference/cli)
- Set up your staging environment for testing before production deployment

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/)
- [Supabase Community Forum](https://github.com/supabase/supabase/discussions)

---

*This guide is for local development only. For production deployments, use Supabase's hosted service.*</content>
<parameter name="filePath">/Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/supabase/Local Supabase Setup Guide.md