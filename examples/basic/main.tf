provider "aws" {
  region = "ap-northeast-1"
}

module "ModuleName" {
  source = "../../"
}
