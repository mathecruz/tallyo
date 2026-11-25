package dev.matheuscruz.presentation;

import static io.restassured.RestAssured.given;
import static org.assertj.core.api.Assertions.assertThat;

import dev.matheuscruz.domain.Categories;
import dev.matheuscruz.domain.Record;
import dev.matheuscruz.domain.RecordRepository;
import dev.matheuscruz.domain.Transactions;
import dev.matheuscruz.presentation.data.PageRecord;
import dev.matheuscruz.presentation.data.UpdateRecordRequest;
import io.quarkus.narayana.jta.QuarkusTransaction;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.quarkus.test.security.jwt.Claim;
import io.quarkus.test.security.jwt.JwtSecurity;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.math.BigDecimal;
import java.time.LocalDate;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
public class RecordResourceTest {

    static final String USER_ID = "user-1";
    static final String OTHER_USER_ID = "user-2";

    @Inject
    RecordRepository recordRepository;

    @BeforeEach
    @Transactional
    void setUp() {
        recordRepository.deleteAll();
    }

    @Test
    @TestSecurity(user = USER_ID)
    @JwtSecurity(claims = @Claim(key = "upn", value = USER_ID))
    @DisplayName("should update all fields when valid UpdateRecordRequest is provided")
    void should_updateAllFields_when_validUpdateRecordRequestIsProvided() {
        Long id = persistRecord(USER_ID);
        var request = new UpdateRecordRequest(new BigDecimal("99.90"), "Curso de Java", Transactions.OUT,
                Categories.KNOWLEDGE, LocalDate.of(2025, 1, 15));

        given().contentType("application/json").body(request).when().put("/api/records/" + id).then().log()
                .ifValidationFails().statusCode(204);

        Record updated = findById(id);
        assertThat(updated.getAmount()).isEqualByComparingTo("99.90");
        assertThat(updated.getDescription()).isEqualTo("Curso de Java");
        assertThat(updated.getTransaction()).isEqualTo(Transactions.OUT);
        assertThat(updated.getCategory()).isEqualTo(Categories.KNOWLEDGE);
        assertThat(updated.getTransactionDate()).isEqualTo(LocalDate.of(2025, 1, 15));
    }

    @Test
    @TestSecurity(user = USER_ID)
    @JwtSecurity(claims = @Claim(key = "upn", value = USER_ID))
    @DisplayName("should set category to NONE when transaction is changed to IN")
    void should_setCategoryToNone_when_transactionIsChangedToIn() {
        Long id = persistRecord(USER_ID);
        var request = new UpdateRecordRequest(new BigDecimal("10.00"), "Salário", Transactions.IN, Categories.COMFORT,
                LocalDate.of(2025, 1, 15));

        given().contentType("application/json").body(request).when().put("/api/records/" + id).then().log()
                .ifValidationFails().statusCode(204);

        assertThat(findById(id).getCategory()).isEqualTo(Categories.NONE);
    }

    @Test
    @TestSecurity(user = USER_ID)
    @JwtSecurity(claims = @Claim(key = "upn", value = USER_ID))
    @DisplayName("should return Not Found when record belongs to another user")
    void should_returnNotFound_when_recordBelongsToAnotherUser() {
        Long id = persistRecord(OTHER_USER_ID);
        var request = new UpdateRecordRequest(new BigDecimal("99.90"), "Hacked", Transactions.IN, null,
                LocalDate.of(2025, 1, 15));

        given().contentType("application/json").body(request).when().put("/api/records/" + id).then().log()
                .ifValidationFails().statusCode(404);

        assertThat(findById(id).getDescription()).isEqualTo("Mercado");
    }

    @Test
    @TestSecurity(user = USER_ID)
    @JwtSecurity(claims = @Claim(key = "upn", value = USER_ID))
    @DisplayName("should return Bad Request when transaction date is missing")
    void should_returnBadRequest_when_transactionDateIsMissing() {
        Long id = persistRecord(USER_ID);
        var request = new UpdateRecordRequest(new BigDecimal("99.90"), "Mercado", Transactions.OUT,
                Categories.FIXED_COSTS, null);

        given().contentType("application/json").body(request).when().put("/api/records/" + id).then().log()
                .ifValidationFails().statusCode(400);
    }

    @Test
    @DisplayName("should return Unauthorized when user is not authenticated")
    void should_returnUnauthorized_when_userIsNotAuthenticated() {
        var request = new UpdateRecordRequest(new BigDecimal("99.90"), "Mercado", Transactions.OUT,
                Categories.FIXED_COSTS, LocalDate.of(2025, 1, 15));

        given().contentType("application/json").body(request).when().put("/api/records/1").then().log()
                .ifValidationFails().statusCode(401);
    }

    @Test
    @TestSecurity(user = USER_ID)
    @JwtSecurity(claims = @Claim(key = "upn", value = USER_ID))
    @DisplayName("should return the transaction date when records are listed")
    void should_returnTransactionDate_when_recordsAreListed() {
        persistRecord(USER_ID);

        var page = given().queryParam("page", 0).queryParam("limit", 10).when().get("/api/records").then().log()
                .ifValidationFails().statusCode(200).extract().as(PageRecord.class);

        assertThat(page.items()).hasSize(1);
        assertThat(page.items().getFirst().transactionDate()).isEqualTo(LocalDate.of(2024, 12, 31));
    }

    private Long persistRecord(String userId) {
        Record record = new Record.Builder().userId(userId).amount(new BigDecimal("50.00")).description("Mercado")
                .transaction(Transactions.OUT).category(Categories.FIXED_COSTS)
                .transactionDate(LocalDate.of(2024, 12, 31)).build();
        QuarkusTransaction.requiringNew().run(() -> recordRepository.persist(record));
        return record.getId();
    }

    private Record findById(Long id) {
        return QuarkusTransaction.requiringNew().call(() -> recordRepository.findById(id));
    }
}
