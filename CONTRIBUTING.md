# Contributing to Ayet Rehberi

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/your-username/ayet-rehberi.git
   cd ayet-rehberi
   ```
3. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

Follow the main README.md for complete setup instructions:

1. Install dependencies for both backend and frontend
2. Set up PostgreSQL database
3. Configure environment variables
4. Run migrations and seed data

## Code Style

### Backend (NestJS/TypeScript)

- Use TypeScript strict mode
- Follow NestJS conventions
- Use Prettier for formatting
- ESLint configuration is provided

```bash
# Format code
cd backend
npm run format

# Lint code
npm run lint
```

### Frontend (Next.js/TypeScript)

- Use TypeScript
- Follow Next.js conventions
- Use Tailwind CSS for styling
- Components should be functional (React hooks)

```bash
# Lint code
cd frontend
npm run lint
```

## Project Structure

```
ayet-rehberi/
├── backend/          # NestJS backend
│   ├── src/
│   │   ├── chat/    # Chat module
│   │   └── prisma/  # Prisma service
│   └── prisma/      # Database schema
└── frontend/         # Next.js frontend
    └── src/
        ├── app/      # Pages
        ├── components/
        ├── services/
        └── types/
```

## Making Changes

### Backend Changes

1. **Adding a new endpoint:**
   - Create method in controller
   - Implement logic in service
   - Add DTOs for validation
   - Update API documentation

2. **Modifying database schema:**
   ```bash
   cd backend
   # Edit prisma/schema.prisma
   npx prisma migrate dev --name your_migration_name
   npx prisma generate
   ```

3. **Adding new features:**
   - Create new module if needed
   - Write tests
   - Update documentation

### Frontend Changes

1. **Adding new components:**
   - Create in `src/components/`
   - Use TypeScript
   - Follow existing patterns

2. **Adding new pages:**
   - Create in `src/app/`
   - Follow Next.js App Router conventions

3. **Modifying types:**
   - Update `src/types/index.ts`
   - Ensure types match backend DTOs

## Testing

### Backend Tests

```bash
cd backend
npm run test           # Run tests
npm run test:watch     # Watch mode
npm run test:cov       # Coverage
```

### Manual Testing

1. Start backend and frontend
2. Test all endpoints
3. Check console for errors
4. Verify database changes

## Commit Messages

Follow conventional commits:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Test changes
- `chore:` Build/config changes

Examples:
```
feat: add user authentication
fix: resolve verse retrieval bug
docs: update API documentation
refactor: improve chat service logic
```

## Pull Request Process

1. **Before submitting:**
   - Ensure all tests pass
   - Run linters and fix issues
   - Update documentation
   - Test manually

2. **PR description should include:**
   - What changes were made
   - Why the changes were necessary
   - Any breaking changes
   - Screenshots (for UI changes)

3. **PR checklist:**
   - [ ] Code follows project style
   - [ ] Tests added/updated
   - [ ] Documentation updated
   - [ ] No linter errors
   - [ ] Tested locally

## Feature Ideas

Looking for something to work on? Here are some ideas:

### Backend Improvements
- [ ] Implement AI summary generation (OpenAI/Anthropic)
- [ ] Add semantic search with embeddings
- [ ] Implement user authentication
- [ ] Add full-text search
- [ ] Create admin panel API
- [ ] Add verse tagging system
- [ ] Implement rate limiting
- [ ] Add caching layer
- [ ] Create API documentation with Swagger

### Frontend Improvements
- [ ] Add conversation history sidebar
- [ ] Implement dark mode
- [ ] Add search functionality
- [ ] Create user settings page
- [ ] Add verse bookmarking
- [ ] Implement export conversation feature
- [ ] Add keyboard shortcuts
- [ ] Improve mobile responsiveness
- [ ] Add loading skeletons
- [ ] Implement infinite scroll for history

### Data & Content
- [ ] Add complete Quran dataset
- [ ] Add English translations
- [ ] Include tafsir (interpretation)
- [ ] Add multiple translation options
- [ ] Include recitation audio
- [ ] Add verse themes/tags

### DevOps & Tools
- [ ] Set up CI/CD pipeline
- [ ] Add Docker development environment
- [ ] Create migration from other formats
- [ ] Add database backup scripts
- [ ] Create performance monitoring
- [ ] Add error tracking (Sentry)

### AI & ML
- [ ] Implement semantic verse search
- [ ] Add context-aware responses
- [ ] Create verse recommendation system
- [ ] Implement topic classification
- [ ] Add query intent detection
- [ ] Multi-turn conversation support

## Code Review Guidelines

When reviewing PRs:

1. **Functionality:**
   - Does it work as intended?
   - Are there edge cases?

2. **Code Quality:**
   - Is it readable?
   - Is it maintainable?
   - Are there comments where needed?

3. **Performance:**
   - Are there any performance issues?
   - Are database queries optimized?

4. **Security:**
   - Are there any security concerns?
   - Is user input validated?

5. **Tests:**
   - Are there appropriate tests?
   - Do tests cover edge cases?

## Questions?

If you have questions:
1. Check existing documentation
2. Look at similar implementations in the codebase
3. Open an issue for discussion

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the code, not the person
- Help others learn and grow

Thank you for contributing! 🙏


