#!/bin/bash
# K8s 节点内存使用率自动调度管理
# 内存 > 85% 则 cordon（禁止调度）
# 内存 < 70% 则 uncordon（恢复调度）

HIGH_THRESHOLD=${HIGH_THRESHOLD:-85}
LOW_THRESHOLD=${LOW_THRESHOLD:-70}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
}

log "开始检查节点内存使用率..."

kubectl top nodes --no-headers | while read node cpu_val cpu_pct mem_val mem_pct; do
    mem_usage=${mem_pct%\%}

    is_cordoned=$(kubectl get node "$node" -o jsonpath='{.spec.unschedulable}')

    if [ "$mem_usage" -gt "$HIGH_THRESHOLD" ]; then
        if [ "$is_cordoned" != "true" ]; then
            kubectl cordon "$node"
            log "⚠️  节点 $node 内存 ${mem_usage}% > ${HIGH_THRESHOLD}%，已设置为不可调度"
        fi
    elif [ "$mem_usage" -lt "$LOW_THRESHOLD" ]; then
        if [ "$is_cordoned" = "true" ]; then
            kubectl uncordon "$node"
            log "✅ 节点 $node 内存 ${mem_usage}% < ${LOW_THRESHOLD}%，已恢复调度"
        fi
    else
        log "ℹ️  节点 $node 内存 ${mem_usage}%，保持当前状态"
    fi
done

log "检查完成"
