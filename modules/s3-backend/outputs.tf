output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = "terraform-state-bucket-goit" 
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = "terraform-locks-goit"
}