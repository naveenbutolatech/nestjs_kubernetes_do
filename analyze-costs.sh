#!/bin/bash

echo "💰 AWS Cost Analysis"
echo "===================="

# Get current month costs
CURRENT_MONTH=$(date +%Y-%m)
echo "📅 Analyzing costs for: $CURRENT_MONTH"

# Get cost and usage data
aws ce get-cost-and-usage \
  --time-period Start=$CURRENT_MONTH-01,End=$CURRENT_MONTH-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --region us-east-2 \
  --query 'ResultsByTime[0].Groups[*].[Keys[0],Metrics.BlendedCost.Amount]' \
  --output table

echo "✅ Cost analysis complete!"
