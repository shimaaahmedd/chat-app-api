# Chat-api app

Chatting API application Using Ruby on Rails

# Overview
* **Users API**: Provides showing all users, getting specific user, showing all chats owned by a user, creation, updating and deleting the user
* **Application API**: Provides creation, updating and getting certain application, showing all applications
* **Chat API**: Provides creation, updating and getting certain chat, showing all chats of specific application, adding users and searching for messages in specific chat
* **Message API**: Provides creation, updating and getting certain message, showing all messages of specific chat

# How to start

To start the app
```
docker-compose up
```
To create database
```
docker-compose run web rake db:create db:migrate
```
You can add ```db:seed``` if you want to create some fake users

# Ports used

* ```3000 -> rails```
* ```9200 -> elasticsearch```
* ```6369 -> redis```
* ```3308 -> mysql```

# Ruby version: 2.6.9
# Rails version: 5.2.8 

# APIs available

## User API

Method | URI
--- | ---
**POST** | `/register`
**PUT** | `/update`
**GET** | `/users`
**GET** | `/users/:id`
**DELETE** | `/delete`
**GET** | `/my_chats`

## For User authentication

Save the token coming from login as it's the authorization header

Method | URI
--- | ---
**POST** | `/login` 
**GET** | `/logout`|

## Application API
Method | URI
--- | ---
**GET** | `/applications/:application_token`
**PUT** | `/applications/:application_token`
**DELETE** | `/applications/:application_token`
**GET** | `/applications`
**POST** | `/applications`|

## Chat API
Method | URI
--- | ---
**GET** | `/applications/:application_app_token/chats`
**POST** | `/applications/:application_app_token/chats`
**GET** | `/applications/:application_app_token/chats/:number`
**DELETE** | `/applications/:application_app_token/chats/:number`
**POST** | `/applications/:application_app_token/chats/:number/add_users`
**GET** | `/applications/:application_app_token/chats/:number/search?search_body={search_body}`

## Message API
Method | URI
--- | ---
**GET** | `/applications/:application_app_token/chats/:chat_number/messages`
**POST** | `/applications/:application_app_token/chats/:chat_number/messages`
**GET** | `/applications/:application_app_token/chats/:chat_number/messages/:number`
**DELETE** | `/applications/:application_app_token/chats/:chat_number/messages/:number`
**PUT** | `/applications/:application_app_token/chats/:chat_number/messages/:number`

# How this works <br />
* **Redis and Sidekiq** is used in Chat/Message creation to provide multiple threads working concurrently using workers to handle receiving 
multiple requests, it's handled using queues, and to avoid race conditions and deadlocks, transaction locks are used to write the correct number of received
messages or chats, chats and messages count are updated right after creation
* **Elasticsearch** is used in searching for messages in specific chat providing edge searching which means type the first characters of a word in any phrase and
all phrases that match will be received

# Testing
* **Jmeter** is used to send multiple requests from different users concurrently using multiple threads we need
* **Postman** collection can be used to as a collection of requests for the whole app


# Examples

**Creating user** 
* Email should be unique

```
curl -X POST "http://localhost:3000/register?user\[first_name\]=mohamed&user\[second_name\]=mostafa&user\[email\]=first_user@gmail.com&user\[password\]=password123&user\[password_confirmation\]=password123"

result:
{
    "email":"first_user@gmail.com",
    "first_name":"mohamed",
    "second_name":"mostafa",
    "token":"eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxM30.hYl-sZtM6SK8j3saGGn8UM_trfV57S0XUMfMT7sQca8"
}

```

**Updating logged in user** (Must have authorization token)
* Updating first name (logged in user only can update his info)

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxM30.hYl-sZtM6SK8j3saGGn8UM_trfV57S0XUMfMT7sQca8" -X PUT "http://localhost:3000/update?user\[first_name\]=ahmed"

result:

{
    "email":"first_user@gmail.com",
    "first_name":"ahmed",
    "second_name":"mostafa"
}

```

**Show all users** (Must have authorization token)
* Any registered user can see all registered users

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxM30.hYl-sZtM6SK8j3saGGn8UM_trfV57S0XUMfMT7sQca8" -X GET "http://localhost:3000/users"

result:

[
    {
        "email":"elana@okeefe.co",
        "first_name":"Chet",
        "second_name":"Effertz"
    },
    {
        "email":"colton@haag.net",
        "first_name":"Cyril",
        "second_name":"Yundt"
    },
    {
        "email":"celena@leuschke.info",
        "first_name":"Antonio",
        "second_name":"King"
    },
    {
        "email":"cyrus@harvey-effertz.biz",
        "first_name":"Barney",
        "second_name":"Brown"
    },
    {
        "email":"first_user@gmail.com",
        "first_name":"ahmed",
        "second_name":"mostafa"
    }
]

```
**Show specific user** (Must have authorization token)
* Any registered user can see any registered user
```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxM30.hYl-sZtM6SK8j3saGGn8UM_trfV57S0XUMfMT7sQca8" -X GET "http://localhost:3000/users/1"

Result:

{
    "email":"delmer_kulas@morar-zboncak.info",
    "first_name":"Vernon",
    "second_name":"Lindgren"
}

```
**Delete logged in user** (Must have authorization token)
* logged in user only can delete his account

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxM30.hYl-sZtM6SK8j3saGGn8UM_trfV57S0XUMfMT7sQca8" -X DELETE "http://localhost:3000/delete"

Result: 

{
    "message": "logged out"
}

```

**Check the chats that belongs to the logged in user** (Must have authorization token)
* logged in user can see his chats
```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X GET "http://localhost:3000/my_chats"

Result: 

[
    {
        "number":1,
        "messages_count":0,
        "application":{
                        "token":"SubAnH53NKC4sR948skr2T1y",
                        "name":"facebook"
                      }
    },
    {
        "number":2,
        "messages_count":0,
        "application":{
                        "token":"SubAnH53NKC4sR948skr2T1y",
                        "name":"facebook"
                      }
    },
    {
        "number":2,
        "messages_count":0,
        "application":{
                        "token":"btLyeAZRyW4pfJHDXehpGnvt",
                        "name":"instagram"
                      }
    }
]

```


**Logging in**

Valid User

```
curl -X POST "http://localhost:3000/login?email=first_user@gmail.com&password=password123"

result:

{
    "email":"first_user@gmail.com",
    "first_name":"ahmed",
    "second_name":"mostafa",
    "token":"eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM"
}

```
Invalid User

```
curl -X POST "http://localhost:3000/login?email=first_user@gmail.com&password=123"

result:

{
    "message":"Authentication Failed"
}

```

**Logging out** (Must have authorization token)

```
curl -X GET "http://localhost:3000/logout"

result:

{
    "message":"logged out"
}

```

**Creating application** (Must have authorization token)

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X POST "http://localhost:3000/applications?application[name]=instagram"

Result:

{
    "token":"xhJvTtoopaTW5ornhSyJc1V2",
    "name":"instagram",
    "chats_count":0
}

```

**Getting all applications** (Must have authorization token)
* Any registered user can see all applications
```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X GET http://localhost:3000/applications

Result:

[
    {
        "token":"SubAnH53NKC4sR948skr2T1y",
        "name":"facebook",
        "chats_count":0
    },
    {
        "token":"xhJvTtoopaTW5ornhSyJc1V2",
        "name":"instagram",
        "chats_count":0
    }
]

```

**Show specific application with its token** (Must have authorization token)
* Any registered user can see any application

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X GET http://localhost:3000/applications/xhJvTtoopaTW5ornhSyJc1V2

Result:

{
    "token":"xhJvTtoopaTW5ornhSyJc1V2",
    "name":"instagram",
    "chats_count":0
}

```

**Edit specific application name** (Must have authorization token)
* Any registered user can edit any application's name
```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X PUT http://localhost:3000/applications/xhJvTtoopaTW5ornhSyJc1V2?application[name]=messenger

Result:

{
    "name":"messenger",
    "token":"xhJvTtoopaTW5ornhSyJc1V2",
    "chats_count":0
}

```

**Delete specific application** (Must have authorization token)
* Any registered user can delete any application
```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X DELETE http://localhost:3000/applications/xhJvTtoopaTW5ornhSyJc1V2

Result:

{
    "message":"Application deleted successfully"
}

```

**Creating chat to specific application** (Must have authorization token)
* Any registered user can create chat

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X POST http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats
```

**Getting all chats of specific application** (Must have authorization token)
* Any registered user can get all chats

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X GET http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats

Result:

[
    {
        "number":1,
        "messages_count":0
    },
    {
        "number":2,
        "messages_count":0
    }
]

```

**Getting specific chat of specific application** (Must have authorization token)
* Only registered user that belong to this chat can see it

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X GET http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1

Result:

[
    {
        "number":1,
        "messages_count":0
    }
]

```

**Deleting specific chat of specific application** (Must have authorization token)
* Only registered user that belong to this chat can delete it

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X DELETE http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1

Result:

{
    "message":"Chat deleted successfully"
}

All chats' number will be rearranged

```

**Add users to specific chat of specific application** (Must have authorization token)
* Only registered user that belong to this chat can add another user
```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X POST http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1/add_users?user_email=valrie.lesch@grady.org

Result:

{
    "message":"User added to chat successfully"
}

```

**Search messages in specific chat** (Must have authorization token)
* Only registered user that belong to this chat can search through it

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X GET http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1/search?search_body=mohamed

Result:

[
    {
        "body":"hi I'm mohamed",
        "number":1
    }
]

```

**Create messages in specific chat** (Must have authorization token)

* Only registered users that belong to this chat can create message
```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X POST "http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1/messages?message[body]=hi+I'm+ahmed"

curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X POST "http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1/messages?message[body]=hi+I'm+mohamed"

curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X POST "http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1/messages?message[body]=how+are+you?"

```

**Show all messages to specific chat** (Must have authorization token)

* Only registered users that belong to this chat can see messages
```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X GET http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1/messages

Results:

[
    {
        "body":"hi I'm ahmed",
        "number":1,
        "user":{
                "first_name":"mohamed",
                "second_name":"mostafa"
                }
    },
    {
        "body":"hi I'm mohamed",
        "number":2,
        "user":{
                "first_name":"mohamed",
                "second_name":"mostafa"
                }
    },
    {
        "body":"how are you?",
        "number":3,
        "user":{
                "first_name":"mohamed",
                "second_name":"mostafa"
               }
    }
]
```

**Show specific message of specific chat**

* Only registered users that belong to this chat can see the message

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X GET http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1/messages/1

Results:

[
    {
        "body":"hi I'm ahmed",
        "number":1,
        "user":{
                "first_name":"mohamed",
                "second_name":"mostafa"
               }
    }
]
```

**Show specific message of specific chat**

* Only registered users that belong to this chat can edit the message

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X PUT "http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1/messages/1?message[body]=editting"

Results:

[
    {
        "body":"editting",
        "number":1,
        "user":{
                "first_name":"mohamed",
                "second_name":"mostafa"
               }
    }
]
```

**Delete specific message of specific chat**

* Only registered users that belong to this chat can delele the message

```
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxNH0.AK_HPNKWySTe3pDLgrul-nu5hYb4w-PMOdU2zFO7EaM" -X DELETE "http://localhost:3000/applications/SubAnH53NKC4sR948skr2T1y/chats/1/messages/1"

Results:

{
    "message":"Message deleted successfully"
}

All messages' number will be rearranged

```