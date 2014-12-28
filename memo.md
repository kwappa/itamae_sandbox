# Itamae Sandbox

## 目標

コマンド一発で[kwappa/ena](https://github.com/kwappa/ena)が動くEC2 インスタンスが立ち上がる

## 作業メモ

### AWSでIAMユーザを作りCredentialsを保存する

* [What Is the AWS Command Line Interface? - AWS Command Line Interface](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
* AWSアカウントを作っておく
* IAMユーザを作る
* Credentialを `~/.aws/credentials` に保存する

```
[#{USER_NAME}]
aws_access_key_id = ********************
aws_secret_access_key = ****************************************
```

### AWS CLIのインストール

* homebrew最高便利

```
% brew install awscli
```

* `brew info awscli` すると便利情報が出るので `.zshrc` に追記しておく

```
Add the following to ~/.zshrc to enable zsh completion:
  source /usr/local/share/zsh/site-functions/_aws
```

* 設定を行うと`~/.aws.config` が生成される
 * リージョン : TOKYO
 * 出力フォーマット : JSON

```
% aws configure
AWS Access Key ID [****************PGHQ]: ********************
AWS Secret Access Key [****************AlnO]: ****************************************
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

### EC2インスタンスを立ち上げる

Officialのチュートリアルをなぞってみる

* [Deploying a Development Environment in Amazon EC2 Using the AWS Command Line Interface - AWS Command Line Interface](http://docs.aws.amazon.com/cli/latest/userguide/tutorial-ec2-ubuntu.html)

#### セキュリティグループを作る

> セキュリティグループは、1 つ以上のインスタンスのトラフィックを制御する仮想ファイアウォールとして機能します。

```
% aws ec2 create-security-group --group-name devenv-sg --description "security group for development environment in EC2"

A client error (UnauthorizedOperation) occurred when calling the CreateSecurityGroup operation: You are not authorized to perform this operation.
```

怒られた。

IAMユーザの詳細から適切な権限を持ったPolicyをAttachする必要がある。ちゃんと運用するなら適切なポリシーを作るべき…だが、とりあえずはPower User Accessにしておく。

```
% aws ec2 create-security-group --group-name devenv-sg --description "security group for development environment in EC2"

{
    "GroupId": "sg-ad9432c8"
}
```

セキュリティグループへのアクセスを許可する。アクセス元のIPを絞るためにCIDRを設定することができるが、とりあえず全開。

```
% aws ec2 authorize-security-group-ingress --group-name devenv-sg --protocol tcp --port 22 --cidr 0.0.0.0/0
```

#### アクセス用キーペアを作る

```
% aws ec2 create-key-pair --key-name devenv-key --query 'KeyMaterial' --output text > devenv-key.pem
% chomod 0400 devenv-key.pem
```

#### インスタンスの起動 / ログイン / 停止

ハマった事柄：

* チュートリアルに乗ってるAMI IDは東京リージョンには存在しない
 * [CentOS.orgが公開しているAMI](http://wiki.centos.org/Cloud/AWS)から[CentOS6 x86_64](https://aws.amazon.com/marketplace/pp/B00NQAYLWO)を使う
* t2.microは仮想化タイプのPVをサポートしてない
 * [仮想化タイプ - Amazon Elastic Compute Cloud](http://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/virtualization_types.html)
 * HVMタイプのAMIを使う
* マーケットプレイスのAMIを使うには利用規約に同意する必要がある
 * [AWS Marketplace: CentOS 6 (x86_64) - with Updates HVM by Centos.org](https://aws.amazon.com/marketplace/ordering/ref=dtl_psb_continue?ie=UTF8&productId=74e73035-3435-48d6-88e0-89cc02ad83ee&region=ap-northeast-1)
 * Manual Launch→Accept Terms

無事に立ち上がるとインスタンスIDが返ってくる。

```
% aws ec2 run-instances --image-id ami-13614b12 --count 1 --instance-type t2.micro --key-name devenv-key --security-groups devenv-sg --query 'Instances[0].InstanceId'
"i-97023f8e"
```

IPアドレスを調べる。

```
% aws ec2 describe-instances --instance-ids i-97023f8e --query 'Reservations[0].Instances[0].PublicIpAddress'
"54.64.93.83"
```

```
% ssh -i devenv-key.pem root@54.64.93.83
```

known hostsに登録するよ、の例の警告が出て、無事ログインできた。

使い終わったら止めておく。

```
% aws ec2 stop-instances --instance-ids i-97023f8e
{
    "StoppingInstances": [
        {
            "InstanceId": "i-97023f8e", 
            "CurrentState": {
                "Code": 64, 
                "Name": "stopping"
            }, 
            "PreviousState": {
                "Code": 16, 
                "Name": "running"
            }
        }
    ]
}
```

### itamaeでnginxをインストールする

* `bundler` で `aws-sdk-core` と `itamae` をinstall
* `aws-sdk-core` でインスタンスIDからIPを取得
* recipeをssh経由で実行
