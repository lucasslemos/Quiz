## ADDED Requirements

### Requirement: Create campaign from quiz
An approved organizer SHALL be able to create a campaign as an instance of a quiz they own. A campaign SHALL have a name, a unique slug, optional start and end timestamps, and a status (`draft`, `active`, `closed`).

#### Scenario: Creating a campaign with auto-generated slug
- **WHEN** an organizer creates a campaign with a name and no explicit slug
- **THEN** the system generates a slug from the name, ensures global uniqueness (appending a short hash if needed), and creates the campaign in `draft` status

#### Scenario: Creating a campaign with explicit slug
- **WHEN** an organizer provides a custom slug that does not collide with any existing campaign slug
- **THEN** the system uses the provided slug

#### Scenario: Slug collision with explicit value
- **WHEN** an organizer provides a slug that already exists
- **THEN** the system rejects the submission with a clear error

### Requirement: Edit campaign
An organizer SHALL be able to edit the name, slug, start/end timestamps, and status of a campaign they own, until the campaign has received its first response. After receiving responses, the slug SHALL NOT be editable.

#### Scenario: Editing a draft campaign
- **WHEN** an organizer edits a draft campaign with no responses
- **THEN** the system persists all changes including slug

#### Scenario: Editing a campaign with responses
- **WHEN** an organizer attempts to edit the slug of a campaign that has responses
- **THEN** the system rejects the slug change but allows other field changes

### Requirement: Activate campaign
An organizer SHALL be able to transition a campaign from `draft` to `active`, making it accessible to participants.

#### Scenario: Activating a draft campaign
- **WHEN** an organizer activates a draft campaign
- **THEN** the campaign status changes to `active` and participants can access it via its public URL

### Requirement: Close campaign
An organizer SHALL be able to close an active campaign, blocking further participation while preserving collected responses.

#### Scenario: Closing an active campaign
- **WHEN** an organizer closes an active campaign
- **THEN** the campaign status changes to `closed`, the public URL shows a "campaign closed" message, and the organizer can still view results

### Requirement: Public campaign URL
Each campaign SHALL be accessible via a short, human-readable public URL of the form `/c/:slug`.

#### Scenario: Accessing an active campaign by slug
- **WHEN** any visitor opens `/c/:slug` for a campaign in `active` status
- **THEN** the system serves the participant entry screen

#### Scenario: Accessing a draft campaign by slug
- **WHEN** any visitor opens `/c/:slug` for a campaign in `draft` status
- **THEN** the system shows a "campaign not yet available" message

#### Scenario: Accessing a closed campaign by slug
- **WHEN** any visitor opens `/c/:slug` for a campaign in `closed` status
- **THEN** the system shows a "campaign closed" message

#### Scenario: Slug not found
- **WHEN** any visitor opens `/c/:slug` for a slug that does not exist
- **THEN** the system returns a 404 with a friendly message

### Requirement: QR code generation
The system SHALL generate a QR code image for each campaign that encodes the campaign's public URL. The QR code SHALL be downloadable in a print-ready size.

#### Scenario: Organizer downloads QR code
- **WHEN** an organizer requests the QR code for a campaign
- **THEN** the system provides a downloadable image of sufficient resolution to print on a banner

#### Scenario: Organizer views QR code on screen
- **WHEN** an organizer opens the campaign QR view
- **THEN** the system displays the QR code together with the human-readable public URL as backup

### Requirement: List own campaigns
An organizer SHALL see a list of campaigns belonging to quizzes they own and SHALL NOT see campaigns from other organizers.

#### Scenario: Organizer lists campaigns
- **WHEN** an organizer opens the campaigns list
- **THEN** the system displays only campaigns of quizzes owned by that organizer, with name, status, and response count

### Requirement: Warning when identifier configuration is fragile
When an organizer creates or edits a campaign whose underlying quiz has neither email nor phone as `required`, the system SHALL display a non-blocking warning explaining that duplicate-response blocking will rely only on browser cookies.

#### Scenario: Creating campaign for a quiz with optional identifiers
- **WHEN** an organizer creates a campaign for a quiz where email and phone are both `not_asked` or `optional`
- **THEN** the system shows the warning on the campaign creation/edit screen
