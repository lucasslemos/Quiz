## ADDED Requirements

### Requirement: Separate admin authentication
The system SHALL provide an admin authentication mechanism distinct from organizer authentication, accessible at routes under `/admin`. Admin accounts SHALL NOT be created via public registration.

#### Scenario: Admin logs in
- **WHEN** an admin submits valid credentials at `/admin/login`
- **THEN** the system creates an admin session and grants access to the admin panel

#### Scenario: Non-admin attempts to access admin panel
- **WHEN** an unauthenticated visitor or an authenticated organizer requests any `/admin/*` route
- **THEN** the system denies access and redirects to the admin login page

### Requirement: Pending organizers queue
The admin panel SHALL display a list of organizers with status `pending`, ordered by registration date, showing at minimum the email and registration timestamp.

#### Scenario: Admin views pending queue
- **WHEN** an authenticated admin opens the pending organizers page
- **THEN** the system displays all organizers with status `pending` with their identifying information

#### Scenario: No pending organizers
- **WHEN** the queue is empty
- **THEN** the system displays an empty-state message

### Requirement: Approve organizer
The admin SHALL be able to approve a pending organizer, transitioning their status to `approved` and granting them access to quiz creation.

#### Scenario: Approving a pending organizer
- **WHEN** an admin clicks "approve" on a pending organizer
- **THEN** the system updates the organizer status to `approved` and removes the organizer from the pending queue

### Requirement: Reject organizer
The admin SHALL be able to reject a pending organizer, transitioning their status to `rejected`.

#### Scenario: Rejecting a pending organizer
- **WHEN** an admin clicks "reject" on a pending organizer
- **THEN** the system updates the organizer status to `rejected` and removes them from the pending queue

### Requirement: List of all organizers
The admin panel SHALL provide a view listing all organizers regardless of status, with the ability to filter by status.

#### Scenario: Admin lists all organizers
- **WHEN** an admin opens the organizers list page
- **THEN** the system shows organizers with email, status, and registration date, with status filter controls
