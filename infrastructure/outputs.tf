output "assets_bucket_name" {
  value = aws_s3_bucket.tallyo_bucket.bucket
}

output "incoming_message_fifo_url" {
  value = aws_sqs_queue.incoming_messages.url
}

output "recognized_message_fifo_url" {
  value = aws_sqs_queue.message_processed.url
}

output "landing_page_bucket_name" {
  value = aws_s3_bucket.landing_page.bucket
}

output "landing_page_cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.landing_page.id
}

output "landing_page_url" {
  value = "https://${var.landing_page_domain}"
}
