# Stone Teste - Configuração do EKS com Terraform

Este repositório contém módulos do Terraform para configurar um cluster EKS na AWS, incluindo todos os recursos necessários como VPC, subnets, e configurações de segurança.

## Estrutura do Repositório

- `modules/`: Contém os módulos do Terraform para configurar o EKS e seus componentes.
    - `eks/`: Configuração do cluster EKS.
    - `vpc/`: Configuração da VPC.
    - `security/`: Configurações de segurança, como grupos de segurança e políticas IAM.
- `environments/`: Configurações específicas para diferentes ambientes (staging e produção).
    - `stgn/`: Configurações para o ambiente de staging.
    - `prod/`: Configurações para o ambiente de produção.
- `main.tf`: Arquivo principal que chama os módulos do Terraform.
- `variables.tf`: Declaração de variáveis utilizadas nos módulos.
- `outputs.tf`: Declaração de outputs do Terraform.

## Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) instalado na máquina.
- [AWS CLI](https://aws.amazon.com/cli/) configurada com as credenciais necessárias.
- Bucket S3 para armazenar o estado do Terraform.
- Tabela DynamoDB para locking do estado.
- Secrets para o GitHub Actions.
- Repo ECR.

## Configuração do Backend do Terraform

Certifique-se de configurar o backend do Terraform para usar S3 para armazenar o estado:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-stone-teste"
    key            = "eks/stone-teste.tfstate"
    dynamodb_table = "terraform-locks"
    region         = "us-east-1"
    encrypt        = true
  }
}
