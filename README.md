# Dance Performances NYC

An app for discovering and managing dance performance events in New York City.

## Team Members

- Angelina Gargano (ag4645)
- Jenny Leana Fotso Ngompe (jf3433)
- Janie Zhang (jz3569)
- Stanley Omondi (soo2117)

## Links

- **GitHub Repository**: https://github.com/angelinagargano/esaasfinal.git
- **Heroku Deployment**: https://obscure-thicket-83038-db81ae9b0bcb.herokuapp.com/

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/angelinagargano/esaasfinal.git
cd esaasfinal
```

### 2. Install Dependencies
```bash
rbenv install 3.3.8
rbenv local 3.3.8
bundle install
```

### 3. Setup Database
```bash
bundle exec rails db:create db:migrate db:seed
```

### 4. Run Tests
```bash
# Run RSpec tests
bundle exec rspec

# Run Cucumber tests
bundle exec cucumber
```

### 5. Start the Application
```bash
rails server
```

Visit `http://localhost:3000` to access the application.

## Application Features

### User Authentication
- Create a new account with name, email, username, and password
- Log in to access personalized features
- View and edit profile information

### Event Discovery
- Browse all dance events in NYC
- Filter events by date, name, and price
- Set preferences for budget, location, borough, and performance style
- View detailed event information including venue, time, and description

### Event Management
- **Like Events**: Save events to your "Liked Events" collection
- **Going To Events**: Mark events you plan to attend
- **Google Calendar Integration**: Add events directly to your Google Calendar
- View all saved events on your profile page in chronological order

### Personalization
- Set preferences to customize your event feed
- Filter by:
  - Budget ($0-$25, $25-$50, $50-$100, $100+)
  - Performance Type (Hip-hop, Ballet, Contemporary, Swing, Dance Theater)
  - Borough (Manhattan, Brooklyn, Queens, Bronx, Staten Island)
  - Location (specific neighborhoods)
- Based on events that you like you will recieve recommendations of possible events to go to at the top of your event feed

### Social 
- Add friends to your profile so they can see what events your going to and you can see what events they are going to
- send messages to friends about events you want to go to together
- create groups with friends to connect and plan an event to go to

## Testing

### RSpec Tests

Rspec line coverage: 100.0% (191 / 191)

Located in `spec/features/`:
- `authentication_spec.rb` - User signup and login
- `event_details_spec.rb` - Event detail pages and ticket links
- `home_feed_spec.rb` - Homepage and event browsing
- `preferences_spec.rb` - User preference settings
- `like_goto_spec.rb` - Like and going-to functionality
- `user_profile_spec.rb` - User profile and account management

Located in `spec/controllers/`:
- `application_controller_spec.rb` - User signup and login
- `conversations_controller_spec.rb` - creating and destroying converations
- `friendships_controller_spec.rb` - all the friending dunctionality 
- `group_conversations_controller_spec.rb` - creating and destroying groups
- 'group_messages_controller_spec.rb' - sending messages in group
- `messages_controller_spec.rb` - sending messages to friends 

### Cucumber Tests

Cucumber line coverage: 94.76% (181 / 191)


#### Feature Files
Located in `features/`:
- `authentication.feature` - User account creation and login
- `home_feed.feature` - Homepage event viewing and filtering
- `event_details.feature` - Event details and ticket purchasing
- `initial_preferences.feature` - Setting initial preferences
- `borough_preferences.feature` - Borough-based filtering
- `like_goto.feature` - Liking events and marking attendance
- `performances_new.feature` - Creating new performance events
- `user_profile.feature` - User profile management and saved events
-  `conversations.feature` - starting conversations, viewing them and sending message with event
-  `event_sahring.feature` - sharing event with friend
-  `friendship.feature` - adding friends, sending and accepting/rejecting friend requests
-  `group_conversations.feature` - starting conversation with groups
-  `groups.feature` - creating groups based on friends and people going to event
-  'recommendation.feature' - seeing personalized reccomendations  

#### User Scenarios

**Home Page**
```
As a user exploring upcoming performances,
I want to view and filter dance events and set my preferences
so that I can easily find shows that match my interests and budget.
```

**Event Details**
```
As an event-goer,
I want to see more information about a dance event and a link to buy tickets,
so that I can decide if I want to attend and easily purchase tickets.
```

**Preferences**
```
As a user,
I want to set my preferences for budget, location, and performance type,
so that the app can show me events that fit my interests.
```

**Authentication**
```
As a new user,
I want to create a new account with my name, email, username and password.

As a returning user,
I want to log in with my username and password to access my liked events and profile.
```

**User Profile**
```
As a returning user,
I want to view my liked events, going-to events, and account information
so that I can find my saved events and edit my details easily.
```

**Adding Friends**
```
As a  user,
I want to be able to send my friends a friend request. See what events they are going to when planning to go to an event myself. And create groups with different friends going to the same event.
```
**Messaging**
```
As a  user,
I want to be able to send messages and events to my friends if they are not going to that event. I also want to be able to create group chats with groups of friends going to the same event.
```
**Recommendation**
```
As a  user,
I want to be able to see some personalized recommendations for events I could go to. I want to see events that are near and similar to events I am already going to.
```
#### Step Definitions
Located in `features/step_definitions/`:
- `auth_steps.rb`
- `home_feed_steps.rb` 
- `event_details_steps.rb`
- `initial_preferences_steps.rb` 
- `borough_preferences_steps.rb` 
- `performances_new_steps.rb`
- `like_goto_steps.rb` 
- `user_profile_steps.rb` 
- 'conversations_steps.rb'
- 'event_sharing_steps.rb'
- 'friendship_steps.rb'
- 'group_conversation_steps.rb'
- 'groups_steps.rb'
- 'recommendations_steps.rb'

## Future Enhancements

- making users able to send even through imessage or other messaging platforms 

## Technology Stack

- Ruby 3.3.8
- Rails 8.0
- SQLite (development/test)
- PostgreSQL (production - Heroku)
- RSpec for unit/integration testing
- Cucumber for BDD acceptance testing
