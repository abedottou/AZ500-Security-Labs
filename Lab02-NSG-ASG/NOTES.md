# Lab 02 - Technical Notes

## Key Insight: ASG vs Traditional Approach

**Traditional IP-based filtering problem:**
```bash
# Every time you add a web server, update NSG rules:
Rule 1: Allow 80 to 10.0.0.4
Rule 2: Allow 80 to 10.0.0.5
Rule 3: Allow 80 to 10.0.0.6
# Unmanageable at scale
```

**ASG solution:**
```bash
# One rule covers all current and future web servers:
Rule 1: Allow 80 to myAsgWebServers
# Add 100 new web servers → just assign them to ASG
```

## Common Mistakes Avoided

❌ **Creating NSG per VM** → Management nightmare  
✅ **One NSG per subnet** → Centralized control

❌ **Using source IP filtering for internal traffic** → Brittle  
✅ **Using ASGs for both source and destination** → Flexible

❌ **High priority numbers (1000+)** → Hard to insert new rules  
✅ **Low priority numbers (100, 110, 120)** → Room to add rules between

## Real-World Application

In production environments with hundreds of servers:
- Web tier ASG: 50+ VMs
- App tier ASG: 30+ VMs
- Data tier ASG: 20+ VMs
- Mgmt tier ASG: 10+ VMs

All controlled by ~10 NSG rules instead of 100+ IP-based rules.

## Network Security Engineer → Cloud Perspective

Coming from physical firewalls (Fortinet, Palo Alto):
- **Similar**: ACL logic, priority-based rule processing
- **Different**: Tags instead of zones, software-defined boundaries
- **Better**: Automatic policy application when adding servers# Lab 02 - Technical Notes

## Key Insight: ASG vs Traditional Approach

**Traditional IP-based filtering problem:**
```bash
# Every time you add a web server, update NSG rules:
Rule 1: Allow 80 to 10.0.0.4
Rule 2: Allow 80 to 10.0.0.5
Rule 3: Allow 80 to 10.0.0.6
# Unmanageable at scale
```

**ASG solution:**
```bash
# One rule covers all current and future web servers:
Rule 1: Allow 80 to myAsgWebServers
# Add 100 new web servers → just assign them to ASG
```

## Common Mistakes Avoided

❌ **Creating NSG per VM** → Management nightmare  
✅ **One NSG per subnet** → Centralized control

❌ **Using source IP filtering for internal traffic** → Brittle  
✅ **Using ASGs for both source and destination** → Flexible

❌ **High priority numbers (1000+)** → Hard to insert new rules  
✅ **Low priority numbers (100, 110, 120)** → Room to add rules between

## Real-World Application

In production environments with hundreds of servers:
- Web tier ASG: 50+ VMs
- App tier ASG: 30+ VMs
- Data tier ASG: 20+ VMs
- Mgmt tier ASG: 10+ VMs

All controlled by ~10 NSG rules instead of 100+ IP-based rules.

## Network Security Engineer → Cloud Perspective

Coming from physical firewalls (Fortinet, Palo Alto):
- **Similar**: ACL logic, priority-based rule processing
- **Different**: Tags instead of zones, software-defined boundaries
- **Better**: Automatic policy application when adding servers
