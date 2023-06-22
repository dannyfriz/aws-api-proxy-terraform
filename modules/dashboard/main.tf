resource "aws_cloudwatch_dashboard" "api_dashboard" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x = 0
        y = 0
        width = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_id, { "stat": "SampleCount", "period": 60 }]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "API Requests",    // Widget displaying API requests metric
          period = 300
        }
      },
      {
        type = "metric"
        x = 6
        y = 0
        width = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "4XXError", "ApiName", var.api_id, { "stat": "SampleCount", "period": 60 }]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "4XX Errors",    // Widget displaying 4XX errors metric
          period = 300
        }
      },
      {
        type = "metric"
        x = 0
        y = 6
        width = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "5XXError", "ApiName", var.api_id, { "stat": "SampleCount", "period": 60 }]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "5XX Errors",    // Widget displaying 5XX errors metric
          period = 300
        }
      },
      {
        type = "metric"
        x = 6
        y = 6
        width = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiName", var.api_id, { "stat": "Average", "period": 60 }]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "Latency",    // Widget displaying latency metric
          period = 300
        }
      },
      {
        type = "metric"
        x = 0
        y = 12
        width = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "IntegrationLatency", "ApiName", var.api_id, { "stat": "Average", "period": 60 }]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "Integration Latency",    // Widget displaying integration latency metric
          period = 300
        }
      },
      {
        type = "metric"
        x = 6
        y = 12
        width = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "CacheHitCount", "ApiName", var.api_id, { "stat": "SampleCount", "period": 60 }],
            ["AWS/ApiGateway", "CacheMissCount", "ApiName", var.api_id, { "stat": "SampleCount", "period": 60 }]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "Cache Hits and Misses",    // Widget displaying cache hits and misses metrics
          period = 300
        }
      },
      {
        type = "metric"
        x = 0
        y = 18
        width = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "TotalErrorRate", "ApiName", var.api_id, { "stat": "Average", "period": 60 }]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "Total Error Rate",    // Widget displaying total error rate metric
          period = 300
        }
      },
      {
        type = "metric"
        x = 6
        y = 18
        width = 6
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_id, { "stat": "Sum", "period": 300 }],
            ["AWS/Lambda", "Duration", "FunctionName", var.lambda_function_name, { "stat": "Average", "period": 300 }]
          ],
          view = "timeSeries",
          stacked = false,
          region = "us-east-1",
          title = "API Requests and Lambda Duration",    // Widget displaying API requests and Lambda duration metrics
          period = 300
        }
      }
      // Add more widgets for other metrics here
    ]
  })
}


resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = var.email_control_center
}

resource "aws_cloudwatch_metric_alarm" "api_requests_high" {
  alarm_name          = "api-requests-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Count"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "5000"
  alarm_description   = "API requests is greater than 5000"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  dimensions = {
    ApiName = var.api_id
  }
}

resource "aws_cloudwatch_metric_alarm" "api_4xx_errors_high" {
  alarm_name          = "api-4xx-errors-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "100"
  alarm_description   = "4XX errors is greater than 100"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  dimensions = {
    ApiName = var.api_id
  }
}

resource "aws_cloudwatch_metric_alarm" "api_5xx_errors_high" {
  alarm_name          = "api-5xx-errors-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "100"
  alarm_description   = "5XX errors is greater than 100"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  dimensions = {
    ApiName = var.api_id
  }
}

resource "aws_cloudwatch_metric_alarm" "api_latency_high" {
  alarm_name          = "api-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Average"
  threshold           = "2000"
  alarm_description   = "API latency is greater than 2000 ms"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  dimensions = {
    ApiName = var.api_id
  }
}

resource "aws_cloudwatch_metric_alarm" "api_integration_latency_high" {
  alarm_name          = "api-integration-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "IntegrationLatency"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Average"
  threshold           = "2000"
  alarm_description   = "API integration latency is greater than 2000 ms"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  dimensions = {
    ApiName = var.api_id
  }
}

resource "aws_cloudwatch_metric_alarm" "api_cache_hits_high" {
  alarm_name          = "api-cache-hits-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CacheHitCount"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "10000"
  alarm_description   = "Cache hits is greater than 10000"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  dimensions = {
    ApiName = var.api_id
  }
}

resource "aws_cloudwatch_metric_alarm" "api_cache_misses_high" {
  alarm_name          = "api-cache-misses-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CacheMissCount"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "10000"
  alarm_description   = "Cache misses is greater than 10000"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  dimensions = {
    ApiName = var.api_id
  }
}

resource "aws_cloudwatch_metric_alarm" "api_total_error_rate_high" {
  alarm_name          = "api-total-error-rate-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TotalErrorRate"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.1"
  alarm_description   = "Total error rate is greater than 0.1"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  dimensions = {
    ApiName = var.api_id
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration_high" {
  alarm_name          = "lambda-duration-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "2000"
  alarm_description   = "Lambda duration is greater than 2000 ms"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarms.arn]
  dimensions = {
    FunctionName = var.lambda_function_name
  }
}
