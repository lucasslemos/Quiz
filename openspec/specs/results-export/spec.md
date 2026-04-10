## Requirements

### Requirement: View all responses for a campaign
An organizer SHALL be able to view all participations and their answers for any campaign of a quiz they own.

#### Scenario: Organizer opens campaign responses
- **WHEN** an organizer opens the responses page for a campaign
- **THEN** the system displays all participations with name, email (if collected), phone (if collected), custom field values, score, winner flag, and submission timestamp

#### Scenario: Organizer attempts to view responses of another organizer's campaign
- **WHEN** an organizer requests responses for a campaign of a quiz they do not own
- **THEN** the system denies access

### Requirement: View winners list
The system SHALL provide a filtered view showing only participations marked as winners (all answers correct) for a given campaign.

#### Scenario: Organizer opens winners view
- **WHEN** an organizer opens the winners page for a campaign
- **THEN** the system displays only participations where all answers were correct

#### Scenario: Campaign with no winners
- **WHEN** the winners view is opened for a campaign with no winning participations
- **THEN** the system shows an empty-state message

### Requirement: CSV export of campaign responses
An organizer SHALL be able to export all participations of a campaign as a CSV file. The CSV SHALL include name, email, phone, all custom field values, score, winner flag, and submission timestamp.

#### Scenario: Exporting responses
- **WHEN** an organizer clicks "Export CSV" on a campaign
- **THEN** the system generates and downloads a CSV file containing one row per participation with all relevant columns

#### Scenario: Exporting an empty campaign
- **WHEN** an organizer exports a campaign with no participations
- **THEN** the system generates a CSV with only the header row
