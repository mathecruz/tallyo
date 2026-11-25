# S3 Bucket
resource "aws_s3_bucket" "tallyo_bucket" {
  bucket        = var.bucket_assets_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "tallyo_bucket" {
  bucket                  = aws_s3_bucket.tallyo_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# IAM Users
resource "aws_iam_user" "tallyo_whatsapp_app" {
  name          = var.tallyo_whatsapp_app_name
  force_destroy = true
}

resource "aws_iam_user" "tallyo_api_app" {
  name          = var.tallyo_api_app_name
  force_destroy = true
}

# IAM Policies

resource "aws_iam_policy" "tallyo_whatsapp_sqs_policy" {
  name = "TallyoWhatsappSQSPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = ["${aws_sqs_queue.incoming_messages.arn}"]
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = ["${aws_sqs_queue.message_processed.arn}"]
      }
    ]
  })
}

resource "aws_iam_policy" "tallyo_api_sqs_policy" {
  name = "TallyoAPISQSPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = ["${aws_sqs_queue.message_processed.arn}"]
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = ["${aws_sqs_queue.incoming_messages.arn}"]
      }
    ]
  })
}

resource "aws_iam_policy" "bucket_read_policy" {
  name        = "TallyoAPIBucketReadAccessPolicy"
  description = "Allows read access to ${var.bucket_assets_name} bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${aws_s3_bucket.tallyo_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "bucket_write_policy" {
  name        = "TallyoWhatsappBucketWriteAccessPolicy"
  description = "Allows write access to ${var.bucket_assets_name} bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject"
        ],
        Resource = "${aws_s3_bucket.tallyo_bucket.arn}/*"
      }
    ]
  })
}

# IAM User Policy Attachments

resource "aws_iam_user_policy_attachment" "attach_bucket_write_policy" {
  user       = aws_iam_user.tallyo_whatsapp_app.name
  policy_arn = aws_iam_policy.bucket_write_policy.arn
}

resource "aws_iam_user_policy_attachment" "attach_sqs_policy" {
  user       = aws_iam_user.tallyo_whatsapp_app.name
  policy_arn = aws_iam_policy.tallyo_whatsapp_sqs_policy.arn
}

resource "aws_iam_user_policy_attachment" "attach_api_bucket_read_policy" {
  user       = aws_iam_user.tallyo_api_app.name
  policy_arn = aws_iam_policy.bucket_read_policy.arn
}

resource "aws_iam_user_policy_attachment" "attach_api_sqs_policy" {
  user       = aws_iam_user.tallyo_api_app.name
  policy_arn = aws_iam_policy.tallyo_api_sqs_policy.arn
}


# SQS Queues
resource "aws_sqs_queue" "incoming_messages" {
  fifo_queue                  = true
  name                        = var.incoming_messages_queue_name
  content_based_deduplication = true
}

resource "aws_sqs_queue" "message_processed" {
  fifo_queue                  = true
  name                        = var.message_processed_queue_name
  content_based_deduplication = true
}
