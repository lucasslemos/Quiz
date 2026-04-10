## Requirements

### Requirement: Create quiz
An approved organizer SHALL be able to create a new quiz by providing at minimum a title.

#### Scenario: Creating a quiz with valid title
- **WHEN** an approved organizer submits the new quiz form with a non-empty title
- **THEN** the system creates the quiz owned by that organizer with default identifier field configuration (name required, email and phone not asked) and zero questions

#### Scenario: Creating a quiz with empty title
- **WHEN** an organizer submits the new quiz form with an empty title
- **THEN** the system rejects the submission and shows a validation error

### Requirement: List own quizzes
An approved organizer SHALL see a list of all quizzes they own and SHALL NOT see quizzes belonging to other organizers.

#### Scenario: Organizer views quiz list
- **WHEN** an approved organizer opens their quiz list
- **THEN** the system displays only quizzes where the organizer is the owner

### Requirement: Edit quiz
An organizer SHALL be able to edit the title and identifier field configuration of a quiz they own.

#### Scenario: Updating quiz title
- **WHEN** an organizer submits an edit with a new valid title
- **THEN** the system persists the new title

#### Scenario: Editing a quiz owned by another organizer
- **WHEN** an organizer attempts to edit a quiz they do not own
- **THEN** the system denies the action with a not-found or forbidden response

### Requirement: Delete quiz
An organizer SHALL be able to delete a quiz they own. If the quiz has campaigns with responses, the system SHALL require explicit confirmation before deletion.

#### Scenario: Deleting a quiz with no campaigns
- **WHEN** an organizer deletes a quiz that has no campaigns
- **THEN** the system removes the quiz and its questions

#### Scenario: Deleting a quiz with campaigns and responses
- **WHEN** an organizer attempts to delete a quiz that has campaigns with responses
- **THEN** the system requires a second explicit confirmation before proceeding

### Requirement: Add questions to quiz
An organizer SHALL be able to add questions to a quiz they own. Each question SHALL have a text, at least two answer options, and exactly one option marked as correct.

#### Scenario: Adding a valid question
- **WHEN** an organizer submits a new question with non-empty text, two or more answer options, and exactly one marked correct
- **THEN** the system creates the question and its options

#### Scenario: Question without correct answer
- **WHEN** an organizer submits a question with no option marked as correct
- **THEN** the system rejects with a validation error

#### Scenario: Question with multiple correct answers
- **WHEN** an organizer submits a question with more than one option marked as correct
- **THEN** the system rejects with a validation error

#### Scenario: Question with fewer than two options
- **WHEN** an organizer submits a question with fewer than two answer options
- **THEN** the system rejects with a validation error

### Requirement: Edit and reorder questions
An organizer SHALL be able to edit existing questions and reorder them within a quiz.

#### Scenario: Editing question text
- **WHEN** an organizer updates the text or options of an existing question
- **THEN** the system persists the changes

#### Scenario: Reordering questions
- **WHEN** an organizer changes the position of questions within a quiz
- **THEN** the system updates the question positions and the new order is reflected when participants take the quiz

### Requirement: Delete question
An organizer SHALL be able to delete a question from a quiz they own.

#### Scenario: Deleting a question
- **WHEN** an organizer deletes a question
- **THEN** the system removes the question and its options from the quiz

### Requirement: Configure participant identifier fields
Each quiz SHALL have a configuration for the three special identifier fields: name (always required, not configurable), email, and phone. Email and phone SHALL each have one of three states: `not_asked`, `optional`, or `required`.

#### Scenario: Default configuration
- **WHEN** a quiz is created
- **THEN** name is required, email is `not_asked`, and phone is `not_asked`

#### Scenario: Organizer changes email state to required
- **WHEN** an organizer sets the email field state to `required`
- **THEN** the system persists the new state and participants of campaigns of this quiz must provide an email

#### Scenario: All identifier fields are not required
- **WHEN** an organizer saves a configuration where neither email nor phone is `required`
- **THEN** the system displays a non-blocking warning explaining that the duplicate-response block can only rely on browser cookies

### Requirement: Configure custom participant fields
An organizer SHALL be able to add, edit, reorder, and remove custom participant fields on a quiz. Each custom field SHALL have a label, a type from the supported set (text, email, phone, select), a required flag, and (for select type) a list of options.

#### Scenario: Adding a text custom field
- **WHEN** an organizer adds a custom field with label "Empresa" and type `text`
- **THEN** the system persists the field and it appears in the participant form for any campaign of this quiz

#### Scenario: Adding a select custom field with options
- **WHEN** an organizer adds a custom field with type `select` and a list of options
- **THEN** the system persists the field with its options and renders it as a select input to participants

#### Scenario: Reordering custom fields
- **WHEN** an organizer changes the order of custom fields
- **THEN** the new order is reflected in the participant form
