# Terraform 示例

**本文件由 AI 自动生成 — 模型：GPT-5 mini**

简要说明
本仓库包含若干按云厂商（AWS / GCP）组织的 Terraform 示例，用于演示常见资源的最小配置与使用方式。

模块概览
- `aws/alb/`：ALB、目标组、监听器（含占位证书与子网）。
- `aws/ec2/`：EC2、弹性 IP、安全组、AMI 查询与示例启动脚本占位。
- `gcp/compute/`：GCE 实例、防火墙、静态 IP 与 SSH metadata 示例。
- `gcp/loadbalancing/`：GCP HTTP(S) 负载均衡示例（健康检查、后端、URL map、HTTPS 代理）。

快速上手（3 步）
1. 进入目标目录，例如：
```bash
cd terraform-example/aws/ec2
```
2. 填写 `main.tf` 中的占位值（`profile`/`region`、state 后端、VPC/Subnet ID、证书 ARN 等）。
3. 执行：
```bash
terraform init
terraform plan
terraform apply
```

关键提示
- 示例包含占位符，请务必替换为真实值后再运行。
- 不要将凭据写入代码库；远端 state 请使用受控的 S3/GCS 并开启锁定机制。

运维建议
- 在生产使用远端 state 并启用锁定。  
- 生产变更请先多次 `terraform plan` 并审查差异。  
- 为资源统一打标签以便计费与管理。