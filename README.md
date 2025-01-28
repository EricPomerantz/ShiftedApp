# "Shifted" App

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Schema](#Schema)

## Overview

### Description

Shifted is a marketplace app tailored for car enthusiasts to buy, sell, and trade car parts and vehicles. Additionally, it includes a forum-like area where users can ask questions and share knowledge, fostering a community of car lovers.

### App Evaluation

- **Category:** Social/Marketplace
- **Mobile:** Designed primarily as a mobile application with intuitive navigation and seamless user experience.
- **Story:** Shifted tells the story of connecting car enthusiasts through a marketplace and a supportive Q&A forum.
- **Market:** Car enthusiasts, mechanics, tuners, and hobbyists interested in trading parts, vehicles, or learning from the community.
- **Habit:** Can be used daily to check for new listings or participate in forum discussions.
- **Scope:** Combines two major features—marketplace and forum—making it broad yet focused on the automotive community.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

- [x] User can create an account and log in.
- [x] User can browse listings of car parts and vehicles.
- [x] User can create, edit, and delete their own listings.
- [x] User can search and filter listings.
- [x] User can view detailed information about a listing.
- [x] User can message sellers directly from a listing.
- [x] User can view, post, and answer questions in the forum.
- [x] User can upvote answers in the forum.
- [ ] User profiles show their active listings and forum contributions. (Omitted: Time constraint)

**Optional Nice-to-have Stories**

- [ ] Users receive notifications for new answers or messages.
- [x] Users can mark an answer as the "Best Answer."
- [ ] Users earn badges for participation in the forum.
- [ ] Users can save favorite listings.
- [ ] Real-time updates for new listings and forum posts.

### 2. Screen Archetypes

- **Login Screen**
  - [x] User can log in or create an account.
- **Home Screen (Marketplace)**
  User can browse and search listings.
  - [x] User can filter listings by vehicle.
- **Listing Details Screen**
  - [x] User can view more information about a listing.
  - [x] User can contact the seller directly.
- **Create/Edit Listing Screen**
  - [x] User can add or edit listings with details like title, description, price, and images.
- **Forum Home Screen**
  - [x] User can browse forum categories and recent questions.
  - [x] User can filter forum questions by vehicle
- **Question Details Screen**
  - [x] User can view and answer a question or upvote answers.
- **Ask Question Screen**
  - [x] User can post a new question with a title, description, and category.
- **Profile Screen**
  - [ ] User can view their active listings and forum activity. (ommitted: Time constraint)

### 3. Navigation

**Tab Navigation** (Tab to Screen)

- [x] Home (Marketplace)
- [x] Forum
- [x] Profile
- [x] Chats

**Flow Navigation** (Screen to Screen)

- [x] Login Screen
  * Leads to Home Screen
- [x] Home Screen (Marketplace)
  * Leads to Listing Details Screen
  * Leads to Create/Edit Listing Screen
- [x] Forum Home Screen
  * Leads to Question Details Screen
  * Leads to Ask Question Screen
- [x] Question Screen
  * Leads to User Profile Screen
  * Links back to Home or Forum
- [x] Profile Screen
  * Leads to Edit Profile Screen
  * Links back to Home or Forum
- [x] Chats Screen
  * Leads to Conversation screen
  * Links back to Home or Marketplace


## Schema

### Models

#### User
| Property   | Type   | Description                                   |
|------------|--------|-----------------------------------------------|
| id         | String | Unique identifier for the user               |
| username   | String | User's display name                          |
| email      | String | User's email address                         |
| password   | String | Encrypted password for login authentication  |
| profilePic | File   | User's profile picture                       |
| bio        | String | Short bio describing the user                |
| reputation | Int    | User's reputation score in the forum         |

#### Listing
| Property   | Type   | Description                                   |
|------------|--------|-----------------------------------------------|
| id         | String | Unique identifier for the listing            |
| title      | String | Title of the listing                         |
| description| String | Detailed description of the listing          |
| price      | Double | Price of the item                            |
| images     | Array  | Array of image files for the listing          |
| category   | String | Category of the item (e.g., parts, vehicles) |
| sellerId   | String | ID of the user who posted the listing         |
| createdAt  | Date   | Date the listing was created                 |

#### Question
| Property   | Type   | Description                                   |
|------------|--------|-----------------------------------------------|
| id         | String | Unique identifier for the question           |
| title      | String | Title of the question                        |
| description| String | Detailed description of the question         |
| category   | String | Category of the question (e.g., tuning, repair)|
| userId     | String | ID of the user who posted the question        |
| answers    | Array  | Array of associated answers                  |
| createdAt  | Date   | Date the question was posted                 |

#### Answer
| Property   | Type   | Description                                   |
|------------|--------|-----------------------------------------------|
| id         | String | Unique identifier for the answer             |
| content    | String | The content of the answer                    |
| questionId | String | ID of the question this answer belongs to    |
| userId     | String | ID of the user who posted the answer         |
| upvotes    | Int    | Number of upvotes the answer has received    |
| createdAt  | Date   | Date the answer was posted                   |

### Networking

#### Marketplace
- **[GET] /listings**: Retrieve all listings.
- **[POST] /listings**: Create a new listing.
- **[PUT] /listings/{id}**: Edit a listing.
- **[DELETE] /listings/{id}**: Delete a listing.

#### Forum
- **[GET] /questions**: Retrieve all forum questions.
- **[POST] /questions**: Post a new question.
- **[GET] /questions/{id}**: Retrieve details of a specific question.
- **[POST] /answers**: Post a new answer to a question.
- **[PUT] /answers/{id}/upvote**: Upvote an answer.

#### User
- **[POST] /users**: Create a new user.
- **[GET] /users/{id}**: Retrieve user profile data.
- **[PUT] /users/{id}**: Update user profile information.


## Brief 5 Minute Video Walk-through: https://youtu.be/D8ED8wPUA9I

[![Watch the video](https://img.youtube.com/vi/D8ED8wPUA9I/0.jpg)](https://www.youtube.com/watch?v=D8ED8wPUA9I)
