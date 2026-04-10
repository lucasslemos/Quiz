## ADDED Requirements

### Requirement: Organizer self-registration
The system SHALL allow any visitor to register as an organizer by providing email and password. New organizers SHALL be created with status `pending` and SHALL NOT be able to create quizzes or campaigns until approved.

#### Scenario: Successful registration
- **WHEN** a visitor submits the registration form with a valid, unique email and a password meeting minimum length requirements
- **THEN** the system creates a new organizer record with status `pending`, logs the visitor in, and redirects to a "waiting for approval" page

#### Scenario: Duplicate email
- **WHEN** a visitor submits the registration form with an email that already belongs to an existing organizer
- **THEN** the system rejects the registration and shows a clear error message without revealing whether the email exists for security

### Requirement: Organizer login
The system SHALL allow registered organizers to log in with email and password.

#### Scenario: Valid credentials
- **WHEN** an organizer submits valid email and password
- **THEN** the system creates an authenticated session and redirects based on approval status

#### Scenario: Invalid credentials
- **WHEN** an organizer submits invalid email or password
- **THEN** the system rejects the login with a generic error message

### Requirement: Approval gate on protected actions
The system SHALL block organizers whose status is not `approved` from accessing quiz creation, campaign creation, and any organizer area beyond the "waiting for approval" page.

#### Scenario: Pending organizer attempts to access quiz area
- **WHEN** an authenticated organizer with status `pending` navigates to any protected organizer route
- **THEN** the system redirects to the "waiting for approval" page

#### Scenario: Approved organizer accesses quiz area
- **WHEN** an authenticated organizer with status `approved` navigates to the organizer dashboard
- **THEN** the system grants access

#### Scenario: Rejected or suspended organizer attempts login
- **WHEN** an organizer with status `rejected` or `suspended` logs in
- **THEN** the system shows a message explaining the account status and does not grant access to protected areas

### Requirement: Password recovery
The system SHALL provide a password recovery flow that allows organizers to reset their password via a tokenized link sent to their registered email.

#### Scenario: Request password reset
- **WHEN** an organizer submits the "forgot password" form with their email
- **THEN** the system sends a tokenized reset link to that email if it exists, and shows a generic confirmation message regardless of whether the email exists

#### Scenario: Use valid reset token
- **WHEN** an organizer clicks a valid, unexpired reset link and submits a new password
- **THEN** the system updates the password, invalidates the token, and logs the organizer in

#### Scenario: Use expired reset token
- **WHEN** an organizer clicks an expired reset link
- **THEN** the system shows an error and offers to request a new reset

### Requirement: Logout
The system SHALL allow authenticated organizers to log out, terminating their session.

#### Scenario: Organizer logs out
- **WHEN** an authenticated organizer triggers logout
- **THEN** the system terminates the session and redirects to the public landing or login page
