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

