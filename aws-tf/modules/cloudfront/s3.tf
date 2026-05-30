resource "aws_s3_bucket" "frontend" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = var.tags
}

# --- Website hosting (fallback when CloudFront is disabled) ---
resource "aws_s3_bucket_website_configuration" "frontend" {
  count  = var.enable_cloudfront ? 0 : 1
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# --- Public access block ---
# When CloudFront is enabled: block all public access (OAC only)
# When CloudFront is disabled: allow public access for S3 website hosting
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = var.enable_cloudfront
  block_public_policy     = var.enable_cloudfront
  ignore_public_acls      = var.enable_cloudfront
  restrict_public_buckets = var.enable_cloudfront
}

# --- Bucket policy: CloudFront OAC ---
resource "aws_s3_bucket_policy" "cloudfront" {
  count  = var.enable_cloudfront ? 1 : 0
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this[0].arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

# --- Bucket policy: public read for S3 website hosting ---
resource "aws_s3_bucket_policy" "public_read" {
  count  = var.enable_cloudfront ? 0 : 1
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

# --- Static files ---
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  content_type = "text/html"

  content = <<-HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Frontend - Play Infra</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: system-ui, -apple-system, sans-serif; background: #0f172a; color: #e2e8f0; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .card { background: #1e293b; border-radius: 12px; padding: 2rem 3rem; text-align: center; box-shadow: 0 4px 24px rgba(0,0,0,0.3); }
        h1 { font-size: 2rem; margin-bottom: 0.5rem; color: #38bdf8; }
        p { color: #94a3b8; margin-bottom: 1rem; }
        .badge { display: inline-block; background: #22c55e; color: #fff; padding: 0.25rem 0.75rem; border-radius: 999px; font-size: 0.875rem; }
        code { background: #334155; padding: 0.125rem 0.5rem; border-radius: 4px; font-size: 0.875rem; }
        .info { margin-top: 1.5rem; font-size: 0.875rem; color: #64748b; }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>Play Infra Frontend</h1>
        <p>Served from <code>S3 + CloudFront</code></p>
        <span class="badge">Static Site Live</span>
        <p class="info">API backend available at <code>/api/</code> via ALB</p>
      </div>
    </body>
    </html>
  HTML

  tags = var.tags
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "error.html"
  content_type = "text/html"

  content = <<-HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>404 - Not Found</title>
      <style>
        body { font-family: system-ui; background: #0f172a; color: #e2e8f0; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .card { text-align: center; }
        h1 { font-size: 4rem; color: #f43f5e; }
        p { color: #94a3b8; }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>404</h1>
        <p>Page not found</p>
      </div>
    </body>
    </html>
  HTML

  tags = var.tags
}
