# How to Deploy

## Commit and Push To Main

```bash
git push origin main
```

## Setup Script

Ensure the deployment script is executable:

```bash
chmod +x ./tool/deploy.sh
```

## To Release

```bash
./tool/deploy.sh v0.0.1
```

## To Update A Release

```bash
./tool/deploy.sh v0.0.1 --replace
```