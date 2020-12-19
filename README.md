# Rails Engine

## About the Project

Rails Engine is an E-Commerce Application using a service-oriented architecture. The front and back ends of this application are separate and communicate via APIs. The main objective of this project is to expose the data that powers the site through various API endpoints that the front end will consume.

### Learning Goals

* Expose an API
* Test API exposure
* Use serializers to format JSON responses
* Compose advanced ActiveRecord queries to analyze information stored in SQL databases
* Write SQL statements without the assistance of an ORM

### Built With

Ruby 2.5.3

Rails 5.2.4.3

## Getting Started

1. Create a new directory called `rails-engine` (in this directory will live both frontend and backend repos of this project)
2. cd into this directory `cd rails-engine`
3. Fork this repo
4. Run `bundle install`
5. Run `rake db:{create,migrate,seed}`
6. If interested in running the frontend portion of this project in conjunction with the backend then clone this [repo](https://github.com/JesseMellinger/rails_driver) in the `rails-engine` directory
7. Follow the setup instructions in the README file found in the repository
8. In order to view the project in the browser spin up two servers on different ports with the following commands (both commands are preceded by the directories in which they should run):

`rails-engine -> rails s`

`rails_driver -> rails s -p 3001`

## Database Schema









