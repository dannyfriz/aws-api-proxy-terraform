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
