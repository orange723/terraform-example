# Terraform 示例

本仓库包含按云厂商（AWS / GCP）组织的 Terraform 示例配置，展示常见基础设施资源的最小可运行示例，便于学习与参考。

仓库结构概览
- `aws/alb/`：ALB 示例（包括目标组、监听器、监听规则与示例安全组）。文件中有 VPC/subnet、证书 ARN、S3 backend 等占位。
- `aws/ec2/`：EC2 示例（AMI 查询、实例、安全组、弹性 IP、root 磁盘与 user-data 占位）。
- `gcp/compute/`：GCE 示例（防火墙、静态 IP、VM 实例、metadata/SSH keys），使用 GCS 作为远端 state 的示例。
- `gcp/loadbalancing/`：GCP 负载均衡示例（健康检查、实例组、后端服务、URL map、HTTPS 代理与转发规则），包含证书与全局地址占位。

示例涵盖的要点
- provider 与远端 state 后端配置（AWS 示例使用 `s3` 后端，GCP 示例使用 `gcs` 后端）。
- 常见资源模式：安全组/防火墙、ALB/目标组、虚机创建、静态 IP、负载均衡后端与 URL 映射。
- 如何组织简单的 `main.tf` 文件用于一次性示例，而非完整的生产模块。

使用前的重要提示
- 示例中有大量占位符（空的 `bucket`、`profile`、`region`、资源 ID、证书 ARN 等），请在执行前替换为真实值。
- 不要将凭据或敏感信息提交到仓库，建议使用环境变量、凭证配置文件或密钥管理服务。
- 使用远端 state 时确保对应的 S3/GCS bucket 已存在且 IAM 权限正确。

快速上手（每个模块通用）
1. 进入模块目录，例如：

```bash
cd terraform-example/aws/ec2
```

2. 编辑 `main.tf`，填写 provider/backend 与其它占位值（`profile`、`region`、S3 bucket、VPC/Subnet ID、证书 ARN 等）。

3. 初始化 Terraform：

```bash
terraform init
```

4. 生成计划并查看差异：

```bash
terraform plan
```

5. 应用变更：

```bash
terraform apply
```

模块级注意事项
- `aws/alb/`：请提供正确的 VPC 与 subnet ID，并填写 `certificate_arn`。建议在 S3 state 配置中配合 DynamoDB 实现锁定以防并发写入。
- `aws/ec2/`：将 `user_data_base64` 替换为 `base64encode(file("cloud-init.yaml"))` 或直接使用 `user_data`，并确认实例类型、磁盘大小与网络设置。
- `gcp/compute/`：确认 `provider` 中的 `project`、GCS backend bucket 存在，按需更新 `metadata` 中的 SSH keys。
- `gcp/loadbalancing/`：替换 SSL 证书与全局 IP 占位符，并确保引用的实例或实例组已存在。

安全与运维建议
- 在生产环境使用远端 state。
- 在对生产资源执行 `apply` 前，多次运行并检查 `terraform plan` 的差异。
- 为资源添加一致的标签/label 以便计费与运维管理。