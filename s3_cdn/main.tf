
resource "aws_cloudfront_origin_access_identity" "content_access" {
  comment = "content_access"
}
resource "aws_cloudfront_distribution" "s3-cdn-eks" {
  origin {
    domain_name = lower("${var.name}-manual-content.s3.${var.region}.amazonaws.com")
    #origin_path = "/${var.environment}"
    origin_id   = "S3-${aws_s3_bucket.prod_bucket.bucket}"

    s3_origin_config {
			//http_port              = 80
			//https_port             = 443
			//origin_protocol_policy = "https-only"
			//origin_ssl_protocols   = ["TLSv1","TLSv1.1","TLSv1.2"]
      origin_access_identity = aws_cloudfront_origin_access_identity.content_access.cloudfront_access_identity_path
    }
  }
  
  enabled             = true

  //aliases = ["${var.skilrock_cdn_domain}-${var.environment}.${var.main_domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-${aws_s3_bucket.prod_bucket.bucket}"

    forwarded_values {
      query_string = true
			headers = ["Accept", "Referer", "Authorization", "Content-Type"]
			cookies {
				forward = "all"
			}
    }
		compress = true
		viewer_protocol_policy = "https-only"
  }

  price_class = "PriceClass_All"
  viewer_certificate {
        cloudfront_default_certificate = true
    }
	restrictions {
		geo_restriction {
			restriction_type = "none"
		}
	}
  tags = {
    Name        = "${var.name}-manual-content"
    Environment = var.environment
  }
}

resource "aws_cloudfront_response_headers_policy" "response-headers" {
  name = "response-headers-policy"

  custom_headers_config {
    items {
      header   = "Content-Disposition"
      override = true
      value    = "inline"
    }
  }
}
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::astitva-manual-content/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.content_access.iam_arn}"]
      //identifiers = ["arn:aws:iam::136500915441:root"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::astitva-manual-content"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.content_access.iam_arn}"]
      //identifiers = ["arn:aws:iam::136500915441:root"]
    }
  }

}

resource "aws_s3_bucket" "prod_bucket" {
    bucket = lower("${var.name}-manual-content")
    versioning {
    enabled = true
  }
  tags = {
    Name        = "${var.name}-manual-content"
    Environment = "${var.environment}"
  } 
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
  # depends_on = [
  #   aws_cloudfront_distribution.s3-cdn-eks
  # ]
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.prod_bucket.id
  acl    = "private"
}

resource "aws_iam_policy" "s3-eks-policy" {
  name        = "${var.name}-ks-document-upload-policy-${var.environment}"
  description = "S3 Bucket policy for EKS access"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                 "sns:*",
                 "ses:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "List",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::astitva-manual-content/*"
        }
    ]
})
}