

provider "aws" {
  region = "us-east-1"
  # shared_credentials_file = "path_file_credentials like C:\Users\terraform\.aws\credentials"
  profile = "dev"
}
#### NORTHERN VIRGINIA : us-east-1
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

#### OHIO : us-east-2
provider "aws" {
  region = "us-east-2"
  alias  = "us-east-2"
}

#### NORTHERN CALIFORNIA : us-west-1
provider "aws" {
  region = "us-west-1"
  alias  = "us-west-1"
}

#### OREGON : us-west-2
provider "aws" {
  region = "us-west-2"
  alias  = "us-west-2"
}

#### CANADA : ca-central-1
provider "aws" {
  region = "ca-central-1"
  alias  = "ca-central-1"
}

#### MUMBAI : ap-south-1
provider "aws" {
  region = "ap-south-1"
  alias  = "ap-south-1"
}

//#### OSAKA_LOCAL : ap-northeast-3
provider "aws" {
  region = "ap-northeast-3"
  alias  = "ap-northeast-3"
}

#### SEOUL : ap-northeast-2
provider "aws" {
  region = "ap-northeast-2"
  alias  = "ap-northeast-2"
}

#### SINGAPORE : ap-southeast-1
provider "aws" {
  region = "ap-southeast-1"
  alias  = "ap-southeast-1"
}

#### SYDNEY : ap-southeast-2
provider "aws" {
  region = "ap-southeast-2"
  alias  = "ap-southeast-2"
}

#### TOKYO : ap-northeast-1
provider "aws" {
  region = "ap-northeast-1"
  alias  = "ap-northeast-1"
}


#### FRANKFHURT : eu-central-1
provider "aws" {
  region = "eu-central-1"
  alias  = "eu-central-1"
}

#### IRELAND : eu-west-1
provider "aws" {
  region = "eu-west-1"
  alias  = "eu-west-1"
}

#### LONDON : eu-west-2
provider "aws" {
  region = "eu-west-2"
  alias  = "eu-west-2"
}

//#### MILAN : eu-south-1
provider "aws" {
  region = "eu-south-1"
  alias  = "eu-south-1"
}

#### PARIS : eu-west-3
provider "aws" {
  region = "eu-west-3"
  alias  = "eu-west-3"
}

#### STOCKHOLM : eu-north-1
provider "aws" {
  region = "eu-north-1"
  alias  = "eu-north-1"
}

####  SAO PAULO : sa-east-1
provider "aws" {
  region = "sa-east-1"
  alias  = "sa-east-1"
}
