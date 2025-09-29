# ResiDesk Database

Let's get some context and information about our database. This is purely informational so let's just read through it and confirm that we understand. 

## Connecting

- Inside the ResiDesk project there's a .env file at the root. There are several database related environment variables but we're specifically looking for DATABASE_URL. 
- That is our production database but we're a startup and often test against production. We know this is not best practice but it's acceptable. Given that, we need to be extremely careful to only ever read data and describe schema, routines, functions, etc. We never use this connection to write, update, or delete.
- Use that connection string and psql to directly query the database. This will help us find good test data, debug issues, analyze trends, etc.

## Schema

The schema for this database isn't totally uniform or intuitive so here's some tips to help us navigate it.

- Users have multiple portfolios through the portfolioUsers table
- To get messages for a portfolio: start with the portfolios table -> portfolios.id to portfolioTeams.portfolioId -> portfolioTeams.teamId to teams.id -> teams.phoneNumber to threads.resideskPhoneNumber -> threads.id to threadMessages.threadId

## Tasks

Here's what we want to accomplish

- Get the connection string from the codebase .env file
- Do the most basic test with psql to make sure the connection is working
- Do NOT explore the database further - wait for instructions after testing
