# Welcome to My SQLite
***

## Task
The challenge is to create a lightweight SQLite-like system that can handle basic SQL operations such as SELECT, INSERT, UPDATE, and DELETE on CSV files.
The goal is to mimic the behavior of SQL requests and execute them on CSV data files, managing tasks such as data retrieval, modification, and deletion.

## Description
The problem is solved by implementing a class, `MySqliteRequest`, which can build and execute SQL-like requests on CSV files. 
The class supports chaining methods to build queries and has methods to handle different SQL operations. A command-line interface (CLI)
is also provided to interact with the system in a user-friendly way, using SQL syntax.

## Installation
To install and set up the project, follow these steps:

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd project
## Usage
You can uncomment the request commands one by one to test them by running the following command:
```
ruby my_sqlite_request.rb
```

To use the CLI and perform SQL-like operations on CSV files, run the following command:
```
ruby my_sqlite_cli.rb class.db
```
This will launch the CLI where you can enter SQL commands to interact with your CSV files.

Examples
my_sqlite_cli> SELECT * FROM nba_player_data.csv;

my_sqlite_cli> INSERT INTO nba_player_data.csv VALUES ('Saminu Isah', 1990, 2000, 'F', '6-8', 220, '1970', 'Example University');

my_sqlite_cli> UPDATE nba_player_data.csv SET college = 'New University' WHERE name = 'Forest Able';

my_sqlite_cli> quit

### The Core Team


<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering Schools Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px' /></span>
