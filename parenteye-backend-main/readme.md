## ParentEye Backend

a CF worker that provides api access to events info stored in a d1 database, which are crawled from parentmap.com

### Global Dependencies

1. nodejs
2. pnpm
3. wrangler

### How to run the project

1. install the local dependencies by `pnpm install`
2. all the commands are in package.json > script
   - setup the wrangler api token (so that you can publish the worker to my cf account and keep the url unchanged) `export CF_API_TOKEN=<your_cloudflare_api_token>`
   - start the project by `wrangler dev`
   - publish the project to cloudflare by `wrangler deploy`

### Project Structure

- parenteye-fetch-demo/ -- a swift demo for calling the apis provided by the worker
- src/index.ts -- the worker code
- backup.sql -- the backed up database, in case sth fuck up
- test.sql -- the query to test if remote/local database works or not
- package.json -- all the commands for developing the project is here
- wrangler.toml -- setting up d1 database bindings
