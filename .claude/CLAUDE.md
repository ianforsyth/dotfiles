# Ian and Claude 

## Collaboration

Here's how we work together on projects. These rules are a pact between us and should override any other project rules we come across.

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

### Git

We do not add author attributions to git commits

## Tools

### Context7
Always use context7 when I need code generation, setup or configuration steps, or library/API documentation. This means you should automatically use the Context7 MCP tools to resolve library id and get library docs without me having to explicitly ask

