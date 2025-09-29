# Ian and Claude 

## Collaboration

Here's how we work together on projects. These rules are a pact between us and should override any other project rules we come across.

### Process

- If a prompt starts with or includes "let's chat" we just think and answer questions, we do not implement any code changes or run any commands.
- When we build together, we propose a solution before implementing it. From there, the solution will either be approved or we'll continue to adjust it until it's ready. Once we get the go-ahead, we'll actually start adjusting code.
- If I ask a question, we don't implement any code changes - just answer the question (answer can include code examples just don't actually change anything)
- After a code change, we never have to start the server unless explicitly asked. We'll have one running during development and can just refresh to see the changes. We can verify successful changes together, tell me what to check and I can confirm.

### Coding

- We love refactoring and deleting code way more than we like adding it.
- We strive for DRY (do not repeat yourself) we're constantly on the look out for opporunities to consolidate code.
- Before implementing a new feature, we search through the codebase to find similar examples so we can follow existing patterns.
- Always search for the root cause of issues - if we have an undefined error don't just filter out undefined values, let's understand how the undefined is happening in the first place.

### Frameworks

- We research framework conventions and intended usage patterns first
- We prefer framework-native solutions over custom implementations
- We don't intercept or override framework behavior unless absolutely necessary
- If we find ourselves fighting the framework's natural flow, step back and look for the intended approach
- When we're debugging framework issues, check if we're following the documented patterns

### Comments

- We strive for self-documenting code
- We only add comments if the code it's describing is extremely complex
- We do not leave comments in place of removed code or features

### Testing

For now, we don't write tests in our projects.

## Tools

### Context7
Always use context7 when I need code generation, setup or configuration steps, or library/API documentation. This means you should automatically use the Context7 MCP tools to resolve library id and get library docs without me having to explicitly ask

## Projects

### ResiDesk

### General Patterns and Conventions
- Imports should never be inline, they should always be at the top of files

#### Database Connection

- Inside the ResiDesk project there's a .env file at the root. There are several database related environment variables but we're specifically looking for DATABASE_URL. 
- That is our production database but we're a startup and often test against production. We know this is not best practice but it's acceptable. Given that, we need to be extremely careful to only ever read data and describe schema, routines, functions, etc. We never use this connection to write, update, or delete.
- Use that connection string and psql to directly query the database. This will help us find good test data, debug issues, analyze trends, etc.

#### Scripts

When creating new scripts, check existing files first and follow the CommonJS pattern (require/module.exports) used throughout the codebase.

#### Schema

The schema for this database isn't totally uniform or intuitive so here's some tips to help us navigate it.

- Users have multiple portfolios through the portfolioUsers table
- To get messages for a portfolio: start with the portfolios table -> portfolios.id to portfolioTeams.portfolioId -> portfolioTeams.teamId to teams.id -> teams.phoneNumber to threads.resideskPhoneNumber -> threads.id to threadMessages.threadId

