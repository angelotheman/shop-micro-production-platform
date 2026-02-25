# Backup and Restore Procedure

## Overview

This document outlines the backup and restore procedures for the ShopMicro platform's stateful components.

---

## PostgreSQL Backup/Restore

### Backup Methods

#### Method 1: Manual PVC Snapshot (Recommended for Kubernetes)

**Create a snapshot of the PostgreSQL volume:**

```bash
# Check the PVC name
kubectl get pvc -n shopmicro

# Create a VolumeSnapshot (requires VolumeSnapshot CRD installed)
kubectl apply -f - <<EOF
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: postgres-backup-$(date +%Y%m%d)
  namespace: shopmicro
spec:
  volumeSnapshotClassName: default
  source:
    persistentVolumeClaimName: postgres-data
EOF
```

#### Method 2: pg_dump (Logical Backup)

```bash
# Exec into postgres pod and run pg_dump
kubectl exec -it postgres-0 -n shopmicro -- pg_dump -U postgres -d shopmicro > backup_$(date +%Y%m%d_%H%M%S).sql

# Or from external machine with network access
pg_dump -h <postgres-service> -U postgres -d shopmicro > backup.sql
```

#### Method 3: Automated Scheduled Backups (Azure)

```bash
# If using Azure managed PostgreSQL, configure automated backups via Azure Portal or CLI
az postgres server backup show --name <server-name> --resource-group <rg-name> --backup-name <backup-name>
```

---

### Restore Procedures

#### Restore from PVC Snapshot

```bash
# 1. Create a new PVC from the snapshot
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-data-restore
  namespace: shopmicro
spec:
  storageClassName: default
  dataSource:
    kind: VolumeSnapshot
    name: postgres-backup-YYYYMMDD
    apiGroup: snapshot.storage.k8s.io
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF

# 2. Update postgres StatefulSet to use new PVC
# (Careful: This requires downtime)
kubectl delete statefulset postgres -n shopmicro
kubectl apply -f k8s/postgres/statefulset-restore.yaml
```

#### Restore from pg_dump

```bash
# 1. Drop existing database (requires downtime)
kubectl exec -it postgres-0 -n shopmicro -- psql -U postgres -c "DROP DATABASE shopmicro;"
kubectl exec -it postgres-0 -n shopmicro -- psql -U postgres -c "CREATE DATABASE shopmicro;"

# 2. Restore from backup file
kubectl exec -it postgres-0 -n shopmicro -- psql -U postgres -d shopmicro < backup_YYYYMMDD.sql
```

---

## Redis Backup/Restore

Redis is used as a cache, so backups are **optional** - data can be regenerated.

### Backup (RDB Snapshot)

```bash
# Trigger a background save
kubectl exec -it redis-0 -n shopmicro -- redis-cli BGSAVE

# Copy the dump file
kubectl cp shopmicro/redis-0:/data/dump.rdb ./redis-backup-$(date +%Y%m%d).rdb
```

### Restore

```bash
# Copy backup file to Redis pod
kubectl cp ./redis-backup.rdb shopmicro/redis-0:/data/dump.rdb

# Restart Redis pod to load new data
kubectl rollout restart deployment redis -n shopmicro
```

---

## Backup Schedule Recommendation

| Component | Frequency | Retention |
|-----------|-----------|-----------|
| PostgreSQL | Daily | 7 days |
| Redis | Not required | - |
| Application configs | On change | 30 days |

---

## Disaster Recovery Checklist

1. **Before incident:**
   - [ ] Test restore procedure in dev environment
   - [ ] Document recovery time objective (RTO) - target: 30 minutes
   - [ ] Document recovery point objective (RPO) - target: 24 hours

2. **During incident:**
   - [ ] Assess damage
   - [ ] Decide restore strategy
   - [ ] Execute restore
   - [ ] Verify data integrity

3. **After incident:**
   - [ ] Document lessons learned
   - [ ] Update runbook if needed

---

## Automation Script

For automated backups, create a cron job:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: shopmicro
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: postgres:16
            command:
            - /bin/sh
            - -c
            - |
              pg_dump -h postgres -U postgres shopmicro > /backups/backup_$(date +%Y%m%d_%H%M%S).sql
            volumeMounts:
            - name: backup-volume
              mountPath: /backups
          volumes:
          - name: backup-volume
            persistentVolumeClaimName: backup-pvc
          restartPolicy: OnFailure
```

---

*Last Updated: 2026-02-25*
