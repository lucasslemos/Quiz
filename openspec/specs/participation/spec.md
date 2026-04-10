## Requirements

### Requirement: Lightweight participant entry screen
The public participant screen SHALL be optimized for unreliable network conditions: no large JavaScript bundles, no web fonts, no decorative images, no Stimulus or Turbo controllers beyond what is strictly necessary, and CSS minimized.

#### Scenario: Participant opens the entry screen on a slow connection
- **WHEN** a participant opens `/c/:slug` for an active campaign over a slow connection
- **THEN** the system serves a minimal HTML document that renders the entry form quickly without depending on heavy assets

### Requirement: Participant identification form
On entering an active campaign, the participant SHALL be presented with a form requesting name (always), and email and/or phone according to the quiz's identifier configuration, plus all custom fields configured on the quiz in their defined order.

#### Scenario: Quiz with only name required
- **WHEN** a participant opens a campaign whose quiz has email and phone set to `not_asked`
- **THEN** the form shows only the name field plus any custom fields

#### Scenario: Quiz with email required
- **WHEN** a participant opens a campaign whose quiz has email set to `required`
- **THEN** the form shows name and email as required, plus any custom fields

#### Scenario: Quiz with phone optional
- **WHEN** a participant opens a campaign whose quiz has phone set to `optional`
- **THEN** the form shows phone as a non-required field

#### Scenario: Submitting form with missing required field
- **WHEN** the participant submits the form omitting a required field
- **THEN** the system rejects the submission with a clear error and re-renders the form preserving entered values

### Requirement: Duplicate participation block
Before recording a new participation, the system SHALL check whether the same participant has already participated in this campaign using a layered strategy: (1) a participant token stored in an HttpOnly cookie set on first visit, (2) email match if the participant provided an email and the quiz has email asked, (3) phone match if the participant provided a phone and the quiz has phone asked. Any match SHALL block the new participation.

#### Scenario: Same browser revisits campaign
- **WHEN** a participant who already submitted in this campaign reopens the campaign URL in the same browser
- **THEN** the system detects the cookie token and shows a "you already participated" message

#### Scenario: Same email submitted from a different browser
- **WHEN** a participant submits with an email that another participation in the same campaign already used
- **THEN** the system blocks the submission with a "you already participated" message

#### Scenario: Same phone submitted from a different browser
- **WHEN** a participant submits with a phone (normalized) that another participation in the same campaign already used
- **THEN** the system blocks the submission

#### Scenario: Cookie cleared and no identifier collected
- **WHEN** a participant whose previous cookie was cleared returns to a campaign whose quiz collects no identifier and submits again
- **THEN** the system records the new participation (acceptable limitation by design)

### Requirement: Question flow
After successfully submitting the identification form, the participant SHALL be presented with the quiz questions in their configured order and SHALL select one answer per question.

#### Scenario: Participant answers all questions
- **WHEN** the participant selects an answer for each question and submits
- **THEN** the system records each response linked to the participation

#### Scenario: Participant submits without answering all questions
- **WHEN** the participant submits with one or more questions unanswered
- **THEN** the system rejects the submission with a clear indication of which questions are missing

### Requirement: Result screen and winner determination
After submitting answers, the participant SHALL see a result screen indicating whether they answered all questions correctly. A participation SHALL be marked as a winner if and only if all answers are correct.

#### Scenario: Participant answers everything correctly
- **WHEN** the participant submits answers and all are correct
- **THEN** the system marks the participation as winner and shows a congratulations screen with instructions to claim the prize at the booth

#### Scenario: Participant answers something incorrectly
- **WHEN** the participant submits with at least one wrong answer
- **THEN** the system marks the participation as not a winner and shows a thank-you screen

### Requirement: Custom field values capture
The system SHALL persist the values entered for each custom field of the quiz, associated with the participation, validating type and required flag.

#### Scenario: Submitting valid custom field values
- **WHEN** the participant submits the form with all required custom fields filled and valid
- **THEN** the system stores each value linked to its field and to the participation

#### Scenario: Submitting invalid select value
- **WHEN** the participant submits a select custom field value not in the configured options
- **THEN** the system rejects with a validation error
