import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.notNullValue;

public class PatientIntegrationTest {

    @BeforeAll
    static void setup(){
        RestAssured.baseURI = "http://localhost:4004";
    }

    @Test
    public void shouldReturnPatientsWithValidToken(){

        String loginPayload = """
                {
                "email": "testuser@test.com",
                "password": "password123"
                }
                """;

        String token = given()//Arrange
                .contentType("application/json")
                .body(loginPayload)
                .when() //Act
                .post("/auth/login")
                .then()//Assert
                .statusCode(200)
                .extract()
                .jsonPath()
                .get("token");

        Response response = given()
                .contentType("application/json")
                .header("Authorization", "Bearer " + token)
                .when()
                .get("/api/patients")
                .then()
                .statusCode(200)
                .body("patients", notNullValue())
                .extract().response();

        System.out.println("Patients: " + response.jsonPath().get("patients"));
    }
}
