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
          title = "API Requests",
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
          title = "4XX Errors",
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
          title = "5XX Errors",
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
          title = "Latency",
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
          title = "Integration Latency",
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
          title = "Cache Hits and Misses",
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
          title = "Total Error Rate",
          period = 300
        }
      }
      // Agrega más widgets para otras métricas aquí
    ]
  })
}
