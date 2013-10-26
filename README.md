# luartm

Disclaimer: this is still work in progress. 

luartm is remote table manager for Lua. 

luartm server operates on a Lua table and executes commands from clients. The table is persistent. 

luartm client uses metatables to automagically send requests to server when needed. 

Example of client code: 

```lua
local Client = require "luartm.Client" -- client class

local client = Client{
	host = "127.0.0.1",
	port = 7733
}

client:connect() -- create a client and connect to 127.0.0.1:7733

t = client.table -- get the table handler

t.foo = "bar" -- sends write request to server
t[t] = t -- nesting and shared subtables are supported

print("My name is " .. t.name) -- sends read request to server

client:close() -- closes connection

```

Example of server code: 

```lua
local Server = require "luartm.Server" -- server class

local server = Server{
	host = "127.0.0.1",
	port = 7733,
	filename = "backup.txt"
} -- creates an instance of server. 
-- Server will try to load the table from backup.txt. 
-- All writing operations will be logged there. 

server:start() -- starts server. Never returns (until a really bad error happens)

```

luartm server can talk to several clients at the same time, but the data may become inconsistent if several clients send write requests at the same time. Also, there might be dirty reads when read and write operations happen at the same time. 
