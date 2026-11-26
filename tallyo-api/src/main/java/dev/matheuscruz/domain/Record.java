package dev.matheuscruz.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Objects;
import java.util.Optional;

@Entity
@Table(name = "records")
public class Record {

    public static final ZoneId ZONE = ZoneId.of("America/Sao_Paulo");

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String userId;
    private BigDecimal amount;
    private String description;
    @Enumerated(EnumType.STRING)
    private Transactions transaction;
    @Enumerated(EnumType.STRING)
    private Categories category;
    private Instant createdAt;
    private LocalDate transactionDate;

    protected Record() {
    }

    private Record(String userId, BigDecimal amount, String description, Transactions transaction, Categories category,
            LocalDate transactionDate) {
        this.userId = userId;
        this.amount = amount;
        this.description = description;
        this.transaction = transaction;
        this.category = category;
        this.createdAt = Instant.now();
        this.transactionDate = Optional.ofNullable(transactionDate).orElseGet(() -> LocalDate.now(ZONE));
    }

    public void update(BigDecimal amount, String description, Transactions transaction, Categories category,
            LocalDate transactionDate) {
        this.amount = Objects.requireNonNull(amount, "amount must not be null");
        this.description = Objects.requireNonNull(description, "description must not be null");
        this.transaction = Objects.requireNonNull(transaction, "transaction must not be null");
        this.category = resolveCategory(transaction, category);
        this.transactionDate = Objects.requireNonNull(transactionDate, "transactionDate must not be null");
    }

    private static Categories resolveCategory(Transactions transaction, Categories category) {
        if (transaction == Transactions.IN) {
            return Categories.NONE;
        }
        return Optional.ofNullable(category).orElse(Categories.GENERAL);
    }

    public Long getId() {
        return id;
    }

    public String getUserId() {
        return userId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public String getDescription() {
        return description;
    }

    public Transactions getTransaction() {
        return transaction;
    }

    public Categories getCategory() {
        return Optional.ofNullable(category).orElse(Categories.NONE);
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    /**
     * Records created before this field existed have no transaction date, so they fall back to the creation date.
     */
    public LocalDate getTransactionDate() {
        return Optional.ofNullable(transactionDate).orElseGet(() -> createdAt.atZone(ZONE).toLocalDate());
    }

    public static class Builder {
        private String userId;
        private BigDecimal amount;
        private String description;
        private Transactions transaction;
        private Categories category;
        private LocalDate transactionDate;

        public Builder userId(String userId) {
            this.userId = userId;
            return this;
        }

        public Builder amount(BigDecimal amount) {
            this.amount = amount;
            return this;
        }

        public Builder description(String description) {
            this.description = description;
            return this;
        }

        public Builder transaction(Transactions transaction) {
            this.transaction = transaction;
            return this;
        }

        public Builder category(Categories category) {
            this.category = category;
            return this;
        }

        public Builder transactionDate(LocalDate transactionDate) {
            this.transactionDate = transactionDate;
            return this;
        }

        public Record build() {
            Objects.requireNonNull(userId, "userId must not be null");
            Objects.requireNonNull(amount, "amount must not be null");
            Objects.requireNonNull(description, "description must not be null");
            Objects.requireNonNull(transaction, "transaction must not be null");

            return new Record(userId, amount, description, transaction, resolveCategory(transaction, category),
                    transactionDate);
        }
    }
}
