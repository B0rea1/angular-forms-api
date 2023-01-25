import ballerina/http;
import ballerina/test;

http:Client testClient = check new ("http://localhost:8080");

@test:Config {}
public function testGetUsers() returns error? {
    http:Response response = check testClient->get("/users");

    test:assertEquals(response.getJsonPayload(), users.toJson());
}

@test:Config {}
public function testGetUsersId() returns error? {
    http:Response response = check testClient->get("/users/3");

    test:assertEquals(response.getJsonPayload(), users.get("3").toJson());
}

@test:Config {}
public function testPostUsers() returns error? {
    User newUser = {id: "4", email: "test4@gmail.com", password: "password4"};
    http:Response response = check testClient->post("/users", {email: "test4@gmail.com", password: "password4"});

    test:assertEquals(users.get(newUser.id), newUser);
}

@test:Config {}
public function testPostUsersResetPassword() returns error? {
    http:Response response = check testClient->post("/users/resetPassword", {email: "test1@email.com"});
    test:assertEquals(response.statusCode, 202);

    response = check testClient->post("/users/resetPassword", {email: "wrongemail@email.com"});
    test:assertEquals(response.statusCode, 400);
}

@test:Config {}
public function testPostAuthLogin() returns error? {
    http:Response response = check testClient->post("/auth/login", {email: "test1@email.com", password: "password_1"});
    test:assertEquals(response.statusCode, 200);

    response = check testClient->post("/auth/login", {email: "test1@email.com", password: "wrongpassword"});
    test:assertEquals(response.statusCode, 401);

    response = check testClient->post("/auth/login", {email: "wrongemail", password: "password_1"});
    test:assertEquals(response.statusCode, 401);

    response = check testClient->post("/auth/login", {email: "wrongemail", password: "wrongpassword"});
    test:assertEquals(response.statusCode, 401);
}
