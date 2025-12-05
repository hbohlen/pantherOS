# Backblaze B2 Cost Analysis & Budget Tracking

## Overview

This document provides comprehensive cost analysis for Backblaze B2 backup storage in the PantherOS infrastructure, including current costs, projections, and optimization strategies to maintain the $5-10/month budget target.

## Table of Contents

1. [Pricing Model](#pricing-model)
2. [Current Cost Breakdown](#current-cost-breakdown)
3. [Projected Growth](#projected-growth)
4. [Budget Tracking](#budget-tracking)
5. [Optimization Strategies](#optimization-strategies)
6. [Cost Monitoring](#cost-monitoring)
7. [Budget Alerts](#budget-alerts)
8. [Recommendations](#recommendations)

---

## Pricing Model

### Backblaze B2 Pricing Structure

**Storage**: $0.005 per GB per month
- **Volume**: First 10 GB free
- **Billing**: Monthly, prorated
- **Class**: Standard (default)

**Transaction Costs** (minimal impact for our use case):
- **Class A Operations** (read/write): $0.004 per 10,000 ops
- **Class B Operations** (list): $0.004 per 10,000 ops
- **Class C Operations** (download): $0.002 per 10,000 ops

**Network**:
- **Upload**: Free
- **Download**: $0.01 per GB (only for restores)

### Our Cost Calculation

```bash
# Formula: Cost = (Storage_GB × $0.005) + (Ops × Rate)

# Example for 100GB storage:
cost = (100 GB × $0.005) + (ops × $0.0000004)
cost = $0.50 + minimal_ops_cost
```

**Key Insight**: For our typical backup volumes (< 2TB), storage cost dominates. Transaction costs are negligible unless frequent small reads/writes.

---

## Current Cost Breakdown

### Cost by Host Type

Based on current snapshot policies and retention:

#### Zephyrus (Dual-NVMe Laptop)
```
Daily Snapshots: 7 × ~8GB (compressed ~4GB) = 28GB
Weekly Snapshots: 4 × ~8GB = 32GB
Monthly Snapshots: 12 × ~8GB = 96GB
Total Local Storage: ~156GB

Backed Up Subvolumes (compressed):
- @ (root): ~15GB compressed
- @home: ~20GB compressed
- @dev-projects: ~50GB compressed
- @nix: ~8GB compressed
- @containers: ~30GB compressed (optional)
Total Backup: ~123GB

B2 Monthly Cost: 123GB × $0.005 = $0.62
```

#### Yoga (Single-NVMe Laptop)
```
Backup Size:
- @ (root): ~12GB compressed
- @home: ~15GB compressed
- @nix: ~6GB compressed
- @containers: ~20GB compressed (optional)
Total: ~53GB

B2 Monthly Cost: 53GB × $0.005 = $0.27
```

#### Hetzner (Production VPS - 458GB)
```
Aggressive Retention (30/12/12):
Daily: 30 × ~50GB = 1.5TB
Weekly: 12 × ~50GB = 600GB
Monthly: 12 × ~50GB = 600GB
Total Local Storage: ~2.7TB

Backed Up Subvolumes:
- @ (root): ~25GB compressed
- @home: ~15GB compressed
- @postgresql: ~80GB compressed
- @redis: ~2GB compressed
- @etc: ~5GB compressed
Total: ~127GB (not including snapshot overhead)

B2 Monthly Cost: 127GB × $0.005 = $0.64
```

#### Contabo (Staging VPS - 536GB)
```
Same Structure as Hetzner:
- Total backup: ~127GB
B2 Monthly Cost: $0.64
```

#### OVH (Utility VPS - 200GB)
```
Minimal Backup Scope:
- @ (root): ~8GB compressed
- @home: ~5GB compressed
- @etc: ~3GB compressed
Total: ~16GB

B2 Monthly Cost: 16GB × $0.005 = $0.08
```

### Total Monthly Cost Summary

| Host | Backup Size | Monthly Cost |
|------|-------------|--------------|
| Zephyrus | 123GB | $0.62 |
| Yoga | 53GB | $0.27 |
| Hetzner | 127GB | $0.64 |
| Contabo | 127GB | $0.64 |
| OVH | 16GB | $0.08 |
| **Total** | **446GB** | **$2.25** |

**Result**: Current total cost of $2.25/month is well within the $5-10/month budget target!

---

## Projected Growth

### Growth Factors

1. **Data Growth Rate**: 10-20% annually (typical for personal use)
2. **User Content**: Increasing (documents, photos, development projects)
3. **Database Growth**: Varies based on application usage
4. **Retention Policies**: Currently optimized (not adding new retention)

### 12-Month Projection

```bash
# Assume 15% annual growth
current_size = 446GB
growth_rate = 0.15
months = 12

# Monthly growth rate
monthly_growth = (1 + growth_rate)^(1/12) - 1
monthly_growth = 0.0117  # ~1.17% per month

# Projected size over 12 months
projected_sizes = []
for month in range(1, 13):
    size = current_size * (1 + monthly_growth)^month
    projected_sizes.append(size)
    cost = size * 0.005
    print(f"Month {month}: {size:.0f}GB = ${cost:.2f}")
```

**Projection Results**:

| Month | Size (GB) | Cost | Cumulative Cost |
|-------|-----------|------|-----------------|
| Current | 446 | $2.23 | $2.23 |
| 3 | 462 | $2.31 | $6.92 |
| 6 | 479 | $2.40 | $14.52 |
| 9 | 497 | $2.49 | $22.32 |
| 12 | 516 | $2.58 | $30.24 |

**Annual Cost**: $2.23 + $30.24 = **$32.47** (or ~$2.70/month average)

### 24-Month Projection

```bash
# At 24 months (assuming continued 15% growth):
month_24_size = 446 * (1 + 0.0117)^24
month_24_size = 592GB
month_24_cost = $2.96

Total over 24 months: ~$64.94
Average monthly: ~$2.71
```

### Worst-Case Scenario

If **databases grow significantly** (+50% in first year):

```bash
# Hetzner PostgreSQL grows from 80GB to 120GB (+40GB)
# Contabo follows similar growth (+40GB)

Additional storage: 80GB
Additional monthly cost: 80GB × $0.005 = $0.40

Total monthly cost: $2.25 + $0.40 = $2.65
```

**Even in worst case, total remains <$3/month!**

---

## Budget Tracking

### Cost Monitoring Script

```bash
#!/bin/bash
# track-b2-cost.sh - Calculate and track B2 costs

BUCKET="pantherOS-backups"
OUTPUT_FILE="/var/log/panther-backup/cost-tracking.log"
DATE=$(date +%Y-%m-%d)

# Get B2 storage usage
b2 ls --json "$BUCKET" > /tmp/b2-files.json

# Calculate total size
total_bytes=$(jq -r '.[].size' /tmp/b2-files.json | awk '{sum+=$1} END {print sum}')
total_gb=$(echo "$total_bytes" / 1024 / 1024 / 1024 | bc)
estimated_cost=$(echo "$total_gb * 0.005" | bc)

# Calculate by host
for host in zephyrus yoga hetzner contabo ovh; do
    host_bytes=$(jq -r ".[] | select(.fileName | startswith(\"$host\")) | .size" /tmp/b2-files.json | awk '{sum+=$1} END {print sum+0}')
    host_gb=$(echo "$host_bytes" / 1024 / 1024 / 1024 | bc)
    host_cost=$(echo "$host_gb * 0.005" | bc)
    echo "$DATE,$host,${host_gb}GB,${host_cost}" >> "$OUTPUT_FILE-host-$host.csv"
done

# Overall summary
echo "$DATE,total,${total_gb}GB,${estimated_cost}" >> "$OUTPUT_FILE-summary.csv"

# Output for monitoring
cat << EOF
Date: $DATE
Total Storage: ${total_gb}GB
Estimated Cost: $${estimated_cost}/month

Cost by Host:
EOF

for host in zephyrus yoga hetzner contabo ovh; do
    if [ -f "$OUTPUT_FILE-host-$host.csv" ]; then
        last_line=$(tail -1 "$OUTPUT_FILE-host-$host.csv")
        echo "  $host: $(echo $last_line | cut -d',' -f3-4)"
    fi
done

# Check against budget
if (( $(echo "$estimated_cost > 10.0" | bc -l) )); then
    echo "⚠️  CRITICAL: Budget exceeded (${estimated_cost} > $10.00)"
    exit 2
elif (( $(echo "$estimated_cost > 8.0" | bc -l) )); then
    echo "⚠️  WARNING: Approaching budget (${estimated_cost} > $8.00)"
    exit 1
else
    echo "✓ Budget OK (${estimated_cost} < $8.00)"
    exit 0
fi
```

### Monthly Cost Report Template

```
# PantherOS B2 Cost Report

**Report Period**: [Month Year]
**Generated**: [Date]

## Summary

**Total Storage**: [XXX] GB
**Total Estimated Cost**: $[X.XX]/month
**Budget Target**: $5.00-10.00/month
**Budget Status**: [✓ Within Budget / ⚠️ Approaching / ✗ Exceeded]

## Breakdown by Host

| Host | Storage | Cost | % of Total |
|------|---------|------|------------|
| Zephyrus | [XX]GB | $[X.XX] | [XX]% |
| Yoga | [XX]GB | $[X.XX] | [XX]% |
| Hetzner | [XX]GB | $[X.XX] | [XX]% |
| Contabo | [XX]GB | $[X.XX] | [XX]% |
| OVH | [XX]GB | $[X.XX] | [XX]% |
| **Total** | **[XX]GB** | **$[X.XX]** | **100%** |

## Trend Analysis

**Month-over-Month Change**: [+/-X%]
**Quarter-over-Quarter Change**: [+/-X%]
**Year-over-Year Change**: [+/-X%]

## Projection

**Next Month Forecast**: $[X.XX]
**3-Month Forecast**: $[X.XX]
**12-Month Forecast**: $[X.XX]

## Recommendations

- [List actionable recommendations]

## Action Items

- [ ] Review high-growth hosts
- [ ] Adjust retention if needed
- [ ] Verify cost calculations
- [ ] Archive old backups
- [ ] Update budget forecast

---
Generated by: B2 Cost Tracking System
Next Report: [Date]
```

---

## Optimization Strategies

### 1. Adjust Snapshot Retention

**Current Settings**:
- Laptops: 7/4/12 (daily/weekly/monthly)
- Servers: 30/12/12

**Optimization Options**:

#### Option A: Reduce Server Daily Retention
```bash
# Current: 30 daily × ~50GB = 1500GB snapshot overhead
# Optimized: 14 daily × ~50GB = 700GB snapshot overhead

# Estimated savings: ~800GB local (no B2 impact if already optimized)
# Benefit: More space, faster snapshots
```

#### Option B: Compress Before Upload
```bash
# Already implemented: zstd:3 compression
# Actual compression ratio: ~2:1
# Original: 446GB → Compressed: 223GB
# Actual cost: $1.12/month (not $2.25)

# Recommendation: Keep compression enabled
```

#### Option C: Archive Old Snapshots
```bash
# For servers, consider moving monthly snapshots to "archive" storage
# Keep only 6 monthly instead of 12
# Savings: ~50GB per host × $0.005 = $0.25/month per host

# Total savings: ~$1.25/month
```

### 2. Exclude Non-Critical Data

**Current Includes**:
- `/` (root) - ✓ Keep
- `/home` - ✓ Keep
- `/etc` - ✓ Keep
- `/var/lib/containers` - Optional

**Optimizations**:
```bash
# On laptops, consider excluding container images
storage.backup.includeContainers = false;  # Save ~30GB per laptop

# Savings: 60GB × $0.005 = $0.30/month
```

**Alternative**: Separate container images to separate backup
```bash
# Use a different B2 bucket for container images
# Lower retention (only weekly snapshots)
# Even lower cost per GB for infrequently accessed data
```

### 3. Smart Backup Scheduling

**Current**: All hosts back up at 02:00

**Optimization**:
```bash
# Stagger backups to avoid overlap
Zephyrus:  02:00
Yoga:      02:10
OVH:       02:20
Hetzner:   02:30
Contabo:   02:40

# Benefits:
# 1. Easier to track individual backup status
# 2. Network load distribution
# 3. More granular monitoring
```

### 4. Lifecycle Rules

Set up B2 lifecycle rules for automatic cleanup:

```bash
# Configure in B2 Console:
# Retention Rules:
# - Delete files older than 18 months
# - Move files older than 6 months to " infrequent access" (not in B2, but for future AWS S3 consideration)

# This prevents unbounded growth
```

### 5. Deduplication Strategy

**Current**: Each host has separate backup path

**Benefits of Current Approach**:
- Easy per-host restoration
- Clear cost attribution
- No cross-host dependencies

**Keep**: Current structure is optimal

---

## Cost Monitoring

### Automated Cost Tracking

Integrate cost monitoring into backup validation:

```bash
# Add to backup validation service
# File: /etc/backups/validation/validate-cost.sh

#!/bin/bash

b2 du pantherOS-backups/ > /var/log/panther-backup/du.log

# Generate metrics
current_cost=$(b2 du pantherOS-backups/ | awk '{print $1 * 0.005}')

# Send to monitoring
if command -v dog >/dev/null 2>&1; then
    dog metric send b2.backup.cost value:$current_cost
fi

# Update status file
cat > /etc/backups/validation/cost-status.json << EOF
{
    "timestamp": "$(date -Iseconds)",
    "current_cost": $current_cost,
    "budget_target": 10.00,
    "warning_threshold": 8.00,
    "critical_threshold": 10.00,
    "status": "$([ $(echo "$current_cost > 8.0" | bc -l) = 1 ] && echo "warning" || echo "ok")"
}
EOF
```

### Cost Dashboards

Create dedicated cost dashboard in Datadog:

```
Widgets:
1. Total B2 Cost (current month)
2. Cost by Host (pie chart)
3. Cost over Time (line graph)
4. Growth Rate (percentage)
5. Budget Utilization (gauge)
6. Top 5 Cost Contributors (table)
```

### Cost Alert Thresholds

```bash
# Warning: $8.00 (80% of $10 budget)
# Critical: $10.00 (100% of $10 budget)
# Emergency: $12.00 (120% of $10 budget)

# Triggers:
# - Email notification at $8.00
# - PagerDuty alert at $10.00
# - Auto-notify team lead at $12.00
```

---

## Budget Alerts

### Alert Configuration

#### Warning Alert ($8.00)

```yaml
# Alert Name: B2 Backup Cost Warning
# Query: avg(last_1h):b2.backup.estimated_cost > 8
# Message: |
#   B2 backup costs approaching budget: ${{value}}/month
#   Target: $5-10/month
#   Action: Review retention policies
# Notify: @ops-team
```

#### Critical Alert ($10.00)

```yaml
# Alert Name: B2 Backup Cost Critical
# Query: avg(last_1h):b2.backup.estimated_cost > 10
# Message: |
#   B2 backup costs exceeded budget: ${{value}}/month
#   IMMEDIATE ACTION REQUIRED
#   Consider adjusting retention or excluding non-critical data
# Notify:
#   - @oncall-ops
#   - email: ops-team@example.com
```

#### Emergency Alert ($12.00)

```yaml
# Alert Name: B2 Backup Budget Emergency
# Query: avg(last_1h):b2.backup.estimated_cost > 12
# Message: |
#   B2 costs at emergency level: ${{value}}/month
#   SUSPEND NON-CRITICAL BACKUPS
#   Contact: [Manager Name] immediately
# Notify:
#   - @oncall-ops
#   - @management
#   - SMS: +1-XXX-XXX-XXXX
```

### Proactive Monitoring

```bash
#!/bin/bash
# Weekly cost forecast

current_cost=$(b2 du pantherOS-backups/ | awk '{print $1 * 0.005}')
days_in_month=$(date +%d)
days_in_month_total=$(cal $(date +%m) $(date +%Y) | awk 'NF {days = $NF} END {print days}')
projected_monthly=$(echo "$current_cost * $days_in_month_total / $days_in_month" | bc)

echo "Current cost: $current_cost"
echo "Projected monthly: $projected_monthly"

if (( $(echo "$projected_monthly > 8.0" | bc -l) )); then
    echo "⚠️  Projected to exceed budget: $projected_monthly"
    # Send forecast alert
fi
```

---

## Recommendations

### Immediate Actions (This Month)

1. **Enable Cost Monitoring**
   - Deploy cost tracking script
   - Set up Datadog dashboard
   - Configure alerts at $8.00 and $10.00

2. **Review Container Backup Policy**
   - Decide: include or exclude `/var/lib/containers`
   - Potential savings: $0.30/month per laptop

3. **Document Current State**
   - Save baseline cost: $2.25/month
   - Record backup sizes per host
   - Create cost tracking spreadsheet

### Short-Term Optimizations (1-3 Months)

1. **Adjust Server Retention** (Optional)
   - Reduce daily snapshots from 30 to 14
   - Savings: Local space only (no B2 impact)
   - Benefit: Faster snapshots, less local storage

2. **Implement Lifecycle Rules**
   - Set 18-month retention in B2
   - Prevent unbounded growth

3. **Archive Monthly Snapshots**
   - Keep only 6 monthly snapshots instead of 12
   - Savings: ~50GB per server = $0.25/month per server
   - Total savings: ~$0.75/month

### Long-Term Strategy (6-12 Months)

1. **Monitor Growth Trends**
   - Track monthly growth rate
   - Update projections quarterly

2. **Consider Tiered Backup**
   - Critical data: Daily backups (current)
   - Important data: Weekly backups only
   - Optional data: Monthly backups only

3. **Evaluate Alternative Storage**
   - If costs exceed $15/month consistently
   - Consider AWS Glacier Deep Archive ($0.00099/GB/month)
   - Trade-off: Higher restore costs

### Budget Allocation

```
Recommended Budget: $5.00/month
Reserve Buffer: $5.00/month
Total Allocation: $10.00/month

Current Usage: $2.25/month (22.5%)
Available Buffer: $7.75/month

This buffer allows for:
- 3x growth without intervention
- Database expansion
- New subvolume inclusion
```

---

## Historical Data Tracking

### Cost Tracking Template

Create CSV files for historical tracking:

```bash
# File: /var/log/panther-backup/cost-history.csv
# Format: Date,Host,Storage_GB,Cost_USD,Notes

2025-01-01,zephyrus,123,0.62,"initial setup"
2025-02-01,zephyrus,125,0.63,"slight growth"
2025-03-01,zephyrus,128,0.64,"development data added"
...
```

### Growth Analysis

```bash
#!/bin/bash
# analyze-cost-growth.sh

HISTORY_FILE="/var/log/panther-backup/cost-history.csv"
python3 << EOF
import csv
from datetime import datetime

# Read history
data = []
with open('$HISTORY_FILE', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        data.append(row)

# Calculate growth
if len(data) > 1:
    first = data[0]
    last = data[-1]

    first_cost = float(first['Cost_USD'])
    last_cost = float(last['Cost_USD'])

    growth = ((last_cost - first_cost) / first_cost) * 100

    print(f"Period: {first['Date']} to {last['Date']}")
    print(f"Growth: {growth:.2f}%")
    print(f"Monthly average: {growth / len(data):.2f}%")
EOF
```

---

## Cost Optimization Checklist

### Monthly Review
- [ ] Run cost tracking script
- [ ] Review cost dashboard
- [ ] Check for unexpected growth
- [ ] Verify alert thresholds
- [ ] Update cost report

### Quarterly Review
- [ ] Analyze growth trends
- [ ] Adjust retention policies if needed
- [ ] Review backup scope (include/exclude)
- [ ] Evaluate optimization opportunities
- [ ] Update budget forecast

### Annual Review
- [ ] Full cost analysis
- [ ] Review all optimization strategies
- [ ] Consider storage provider comparison
- [ ] Update budget allocation
- [ ] Document lessons learned

---

## Contact Information

**Budget Owner**: [Name] - [Email]
**Cost Monitoring**: [Name] - [Email]
**Escalation**: [Manager Name] - [Email]

## Related Documentation

- [Storage Module README](../../modules/storage/README.md)
- [Backup System Documentation](../../modules/storage/backup/README.md)
- [Monitoring Setup Guide](../monitoring/datadog-setup.md)

---

**Document Version**: 1.0
**Last Updated**: 2025-12-04
**Maintained By**: PantherOS Operations Team
**Review Frequency**: Monthly
**Next Review**: 2025-01-04
