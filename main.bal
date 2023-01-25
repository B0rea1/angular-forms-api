import ballerina/http;

configurable int port = 8080;

public type User readonly & record {
    string id;
    string email;
    string password;
};

int lastId = 3;
public table<User> key(id) users = table [
    {id: "1", email: "test1@email.com", password: "password_1"},
    {id: "2", email: "test2@email.com", password: "password_2"},
    {id: "3", email: "test3@email.com", password: "password_3"}
];

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:4200"]
    }
}
service / on new http:Listener(port) {
    resource function get users() returns User[] {
        return users.toArray();
    }

    resource function get users/[string id]() returns User|http:NotFound {
        User|error user = users.get(id);

        if user is error {
            return http:NOT_FOUND;
        } else {
            return user;
        }
    }

    resource function post users(@http:Payload record {string email; string password;} user) returns User {
        lastId += 1;
        User newUser = {id: lastId.toString(), email: user.email, password: user.password};
        users.add(newUser);
        return newUser;
    }

    resource function post users/resetPassword(@http:Payload record {string email;} email) returns http:Accepted|http:BadRequest {
        foreach User item in users {
            if item.email == email.email{
                return http:ACCEPTED;
            }
        }

        return http:BAD_REQUEST;
    }

    resource function post auth/login(@http:Payload record {string email; string password;} login) returns http:Ok|http:Unauthorized {
        foreach User item in users {
            if item.email == login.email && item.password == login.password {
                return http:OK;
            }
        }

        return http:UNAUTHORIZED;
    }
}
