# Writing Effective Specifications

This guide covers how to write specifications that enable Ralph to build your project effectively.

## What is a Specification?

A specification is a document that describes **what** to build, not **how** to build it. It captures:

- **Requirements** - What the feature must do
- **Use Cases** - How users will interact with it
- **Success Criteria** - How to know when it's done
- **Constraints** - What limitations or requirements exist
- **Context** - Why this feature is needed

## Specification Template

```markdown
# Feature Name

## Overview

Brief description of what this feature does and why it's needed.
Include the problem it solves and the value it provides.

## Requirements

### Functional Requirements

1. **Requirement 1**
   - Detailed description
   - Expected behavior
   - Edge cases to consider

2. **Requirement 2**
   - Another requirement
   - Include examples

### Non-Functional Requirements

- Performance: Response time, throughput, etc.
- Security: Authentication, authorization, data protection
- Scalability: Expected load, growth considerations
- Accessibility: WCAG compliance, keyboard navigation
- Compatibility: Browser support, API versions

## Use Cases

### Use Case 1: Primary Flow

1. User action
2. System response
3. Expected outcome

### Use Case 2: Error Handling

1. User action that triggers error
2. System validation
3. Error message displayed
4. User corrects and succeeds

## Technical Considerations

- Architecture patterns to follow
- Technologies to use
- Integration points with existing code
- Database schema changes
- API contracts

## Success Criteria

- [ ] All functional requirements implemented
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Performance benchmarks met
- [ ] Security review completed

## Out of Scope

- Features explicitly not included
- Future enhancements
- Related work in other specs

## References

- Related specifications
- External documentation
- Design mockups
- API documentation
```

## Best Practices

### 1. Be Specific

**Bad:**
```markdown
- User can login
```

**Good:**
```markdown
- User can login with email and password
- Email validation: Must be valid email format
- Password validation: Minimum 8 characters, at least one uppercase, one lowercase, one number
- Failed login: Display error message "Invalid credentials" after 3 seconds
- Successful login: Redirect to dashboard, set JWT token in localStorage
- Session duration: 24 hours, then require re-login
```

### 2. Include Examples

**Bad:**
```markdown
- API returns user data
```

**Good:**
```markdown
- API returns user data in JSON format:
  ```json
  {
    "id": "123",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2026-02-12T10:00:00Z"
  }
  ```
- Status code: 200 on success
- Status code: 404 if user not found
- Status code: 401 if not authenticated
```

### 3. Define Edge Cases

**Bad:**
```markdown
- Form validates input
```

**Good:**
```markdown
- Form validates input:
  - Empty fields: Display "This field is required"
  - Invalid email: Display "Please enter a valid email"
  - Duplicate email: Display "Email already registered"
  - Network error: Display "Connection failed, please try again"
  - Server error: Display "Something went wrong, please try again later"
  - Success: Display "Registration successful" and redirect to login
```

### 4. Capture the Why

**Bad:**
```markdown
- Add caching layer
```

**Good:**
```markdown
- Add caching layer
  - **Why**: Current API response time is 2-3 seconds, causing poor UX
  - **Goal**: Reduce response time to under 200ms for cached data
  - **Approach**: Redis cache with 5-minute TTL
  - **Invalidation**: Clear cache on data updates
  - **Metrics**: Track cache hit rate, aim for >80%
```

### 5. Define Success Clearly

**Bad:**
```markdown
- Feature works correctly
```

**Good:**
```markdown
Success Criteria:
- [ ] All 15 test cases passing
- [ ] API response time < 200ms (95th percentile)
- [ ] Zero security vulnerabilities in scan
- [ ] Documentation includes API examples
- [ ] Code review approved by 2 team members
- [ ] Deployed to staging and tested
```

## Common Patterns

### API Endpoint Specification

```markdown
## POST /api/users

Create a new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123",
  "name": "John Doe"
}
```

**Response (201 Created):**
```json
{
  "id": "uuid-here",
  "email": "user@example.com",
  "name": "John Doe",
  "created_at": "2026-02-12T10:00:00Z"
}
```

**Error Responses:**
- 400: Invalid input (missing fields, invalid email format)
- 409: Email already exists
- 500: Server error

**Validation:**
- Email: Required, valid format, max 255 chars
- Password: Required, min 8 chars, max 128 chars
- Name: Required, min 2 chars, max 100 chars
```

### Database Schema Specification

```markdown
## Users Table

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
```

**Constraints:**
- Email must be unique
- Password stored as bcrypt hash (cost factor 12)
- Timestamps in UTC
- Soft delete: Add `deleted_at` column (nullable)
```

### UI Component Specification

```markdown
## Login Form Component

**Visual Design:**
- Two input fields: Email, Password
- One submit button: "Login"
- Link below: "Forgot password?"
- Error message area above form

**Behavior:**
- Email field: type="email", required, autofocus
- Password field: type="password", required, show/hide toggle
- Submit button: Disabled while submitting, shows spinner
- Enter key: Submits form
- Error display: Red text, icon, dismissible

**Validation:**
- Client-side: Check email format, password not empty
- Server-side: Verify credentials
- Display errors inline below each field

**Accessibility:**
- Labels associated with inputs
- Error messages announced to screen readers
- Keyboard navigation works
- Focus management on error
```

## Specification Anti-Patterns

### 1. Implementation Details

**Bad:**
```markdown
- Use React hooks useState and useEffect
- Create a UserService class with login() method
- Store token in localStorage with key 'auth_token'
```

**Good:**
```markdown
- User authentication state persists across page refreshes
- Login credentials validated on server
- Authenticated requests include authorization token
```

Let the agent decide implementation details unless there's a specific reason to constrain them.

### 2. Vague Requirements

**Bad:**
```markdown
- Make it fast
- Handle errors properly
- Look good on mobile
```

**Good:**
```markdown
- API response time < 200ms (95th percentile)
- Display user-friendly error messages for all failure cases
- Responsive design: Works on screens 320px to 2560px wide
```

### 3. Missing Context

**Bad:**
```markdown
- Add pagination to user list
```

**Good:**
```markdown
- Add pagination to user list
  - **Why**: Current list loads all 10,000+ users, causing 30s load time
  - **Goal**: Load time < 1s, display 50 users per page
  - **Existing**: User list at /admin/users, uses UserTable component
  - **Integration**: Preserve existing filters and search functionality
```

### 4. Assuming Implementation Status

**Bad:**
```markdown
- Update the existing authentication middleware
```

**Good:**
```markdown
- Implement authentication middleware
  - **Note**: Check if middleware exists; if so, update it; if not, create it
  - **Requirements**: Verify JWT token, attach user to request, handle expired tokens
```

## Organizing Specifications

### Single Feature per Spec

Each spec should cover one cohesive feature:

**Good:**
- `user-authentication.md` - Login, logout, session management
- `user-profile.md` - View profile, edit profile, upload avatar
- `password-reset.md` - Request reset, verify email, set new password

**Bad:**
- `user-stuff.md` - Everything related to users (too broad)
- `login-button.md` - Just the login button (too narrow)

### Spec Index (specs/README.md)

Maintain an index of all specifications:

```markdown
# Specification Index

## Active Specifications

### User Authentication (user-authentication.md)
- **Status:** Active
- **Priority:** High
- **Last Updated:** 2026-02-12
- **Description:** User login, logout, and session management

### User Profile (user-profile.md)
- **Status:** Active
- **Priority:** Medium
- **Last Updated:** 2026-02-10
- **Description:** User profile viewing and editing

## Implemented Specifications

### Database Schema (database-schema.md)
- **Status:** Implemented
- **Completed:** 2026-02-01
- **Description:** Initial database tables and relationships

## Future Specifications

### Email Notifications (email-notifications.md)
- **Status:** Planned
- **Priority:** Low
- **Description:** Send email notifications for key events
```

## Iterating on Specifications

Specifications evolve as you learn:

### When to Update Specs

- Requirements change
- Edge cases discovered during implementation
- Performance issues identified
- Security concerns raised
- User feedback received

### How to Update Specs

1. **Document the change** - Add a "Changelog" section
2. **Update requirements** - Modify affected sections
3. **Update success criteria** - Adjust based on new requirements
4. **Commit the change** - Track spec evolution in git
5. **Update implementation plan** - If needed, add new tasks

**Example changelog:**

```markdown
## Changelog

### 2026-02-12
- Added password strength requirements (min 8 chars, complexity rules)
- Added rate limiting (5 failed attempts = 15 min lockout)
- Clarified error messages for better UX

### 2026-02-10
- Initial specification created
```

## Tips for Success

### Start Simple

Begin with a minimal viable specification:
1. Core requirements only
2. Happy path use case
3. Basic success criteria

Then iterate and add:
- Edge cases
- Error handling
- Performance requirements
- Security considerations

### Use Real Examples

Include actual data, not placeholders:
- Real email addresses (example.com domain)
- Realistic names and values
- Actual error messages
- Real API responses

### Think Like a User

Write use cases from the user's perspective:
- What are they trying to accomplish?
- What could go wrong?
- What would confuse them?
- What would delight them?

### Collaborate

Specifications benefit from multiple perspectives:
- Use cline CLI in plan mode to brainstorm
- Discuss with team members
- Review existing similar features
- Research best practices

### Keep It Updated

Specifications are living documents:
- Update when requirements change
- Add learnings from implementation
- Document decisions and rationale
- Track changes in git

## Examples

See the Ralph project's own specifications for examples:
- `specs/ralph-system-implementation.md` - System specification
- `specs/ralph-portable-integration.md` - Feature specification
- `specs/README.md` - Specification index

## Getting Help

- **Quickstart**: [quickstart.md](quickstart.md) - Getting started
- **Troubleshooting**: [troubleshooting.md](troubleshooting.md) - Common issues
- **Main docs**: [README.md](README.md) - Ralph overview
