package dev.matheuscruz.presentation.data;

import java.math.BigDecimal;
import java.time.LocalDate;

public record RecordItemResponse(Long id, BigDecimal amount, String description, String transaction, String createdAt,
        String category, LocalDate transactionDate) {
}
