# Node Cordon - K8s 节点内存自动调度管理

基于节点内存使用率自动 cordon/uncordon 节点，防止高内存节点继续被调度新 Pod。

## 策略

| 条件 | 动作 |
|------|------|
| 内存 > 85% | cordon（禁止调度） |
| 内存 < 70% | uncordon（恢复调度） |
| 70%~85% 之间 | 保持当前状态 |

## 部署步骤

```bash
# 1. 构建镜像
docker build -t your-registry/node-cordon:latest .
docker push your-registry/node-cordon:latest

# 2. 部署 RBAC
kubectl apply -f namespace.yaml
kubectl apply -f rbac.yaml

# 3. 部署 CronJob（每小时执行）
kubectl apply -f cronjob.yaml
```

## 配置

通过环境变量调整阈值：

- `HIGH_THRESHOLD` - cordon 阈值，默认 85
- `LOW_THRESHOLD` - uncordon 阈值，默认 70

## 前置依赖

- 集群需安装 [metrics-server](https://github.com/kubernetes-sigs/metrics-server)（`kubectl top nodes` 依赖）
