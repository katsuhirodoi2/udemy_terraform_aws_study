# Udemy講座「AWS と Terraformで実現するInfrastructure as Code」の成果物

## 構成

![独自構成図](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/assets/50761722/f2a1dc10-cd70-47bc-abc7-51ecccebbf98)

### Udemy講座「AWS と Terraformで実現するInfrastructure as Code」　との違い

* Subnetは3層構造にしている（講座ではpublicとprivateだけだが、本成果物ではpublic、private、secureの3層構造としている）
* Appサーバーからインターネットに出る際は踏み台兼プロキシサーバーを経由するようにしている
* 自宅等からSSHアクセスを許可している（講座ではSSHは使用せずセッションマネージャーからEC2を操作する前提になっている）
* 自宅等からAppサーバーへのアクセスは踏み台兼プロキシサーバー経由としている（anyからの許可をしていない）

## 本リポジトリの流用方法

### 環境構築

1. Udemy講座「[AWS と Terraformで実現するInfrastructure as Code](https://www.udemy.com/course/iac-with-terraform/)」を購入する

2. 本リポジトリをローカル端末にCloneする

3. コード中の固有値を修正する   
   [main.tf](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/main.tf)
   <<<AWSCLIで使用するprofile名>>> ・・・GitHub Actions経由でApplyする場合は、該当行は不要になる可能性あり

   [terraform.tfvars](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/terraform.tfvars)
   <<<許可したい自宅等のIPアドレス1>>>
   <<<許可したい自宅等のIPアドレス2>>>　・・・自宅等のアクセス元が2つ以上ある場合
   <<<取得したドメイン名>>>

   [pr-auto-approve.yml](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/.github/workflows/pr-auto-approve.yml)
   <<<管理者のGitHubユーザー名>>> ・・・GitHubでレビューフローを構築したい場合（[参考記事](https://qiita.com/katsuhirodoi2/items/a3aac8a6f6c5aa33ef63)）

4. Appサーバー用AMIの作成とネームサーバーの設定
   
    4-1. Appサーバーおよび踏み台サーバーへのSSH用公開鍵、秘密鍵を作成する（[参考記事](https://qiita.com/kazokmr/items/754169cfa996b24fcbf5)）

    4-2. 作成したSSH公開鍵および秘密鍵をローカル端末の「terraform/dev/src/」配下に設置（git管理する場合、pemファイルはレポジトリにpushしないように、.gitignoreファイルで制御する（[参考](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/.gitignore#L52)）

    4-3. [auto_scaling.tf](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/auto_scaling.tf)のすべてのコードをコメントアウトする

    4-4. [ec2.tf](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/ec2.tf#L15-L34)の「App Server」セクションのコメントを解除する

    4-5. [data.tf](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/data.tf#L5-L13)の「```data "aws_ami" "app"```」ブロックをコメントアウトする

    4-6. terraform applyする

   ローカル端末からapplyする場合は、ターミナルにてterraform/dev/に移動し、terraform applyする。
   
   GitHub Actions経由でapplyする場合は、Pull requestを出し、mainブランチにマージするなどしてApplyする（ワークフローの参考記事は[こちら](https://qiita.com/katsuhirodoi2/items/a3aac8a6f6c5aa33ef63)）

    4-7. route53に作られたゾーンのNSレコードの情報をドメインレジストラのネームサーバー情報に入力する（これをしないとACM証明書の発行プロセスが進行中のままになる）（[参考記事](https://dev.classmethod.jp/articles/route53-domain-onamae/)）

    4-8. Appサーバー用AMIの作成準備（[Udemy講座「AWS と Terraformで実現するInfrastructure as Code」の環境構築コマンド](https://docs.google.com/spreadsheets/d/1sjobcoAvarcBL3yaYPlGSQzYOpULD2hFfRf5KFNcnac/edit?usp=sharing)の「作業群A」を実施する）

    4-9. 4-8で準備したAppサーバーインスタンス（「${var.project}-${var.environment}-app-server」のAMIを作成する。AMI名は「${var.project}-${var.environment}-app-ami」になるようにする。（変数値部分は[ここ](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/terraform.tfvars#L1-L2)で指定している値）

6. データベースへのデータ投入
   [Udemy講座「AWS と Terraformで実現するInfrastructure as Code」の環境構築コマンド](https://docs.google.com/spreadsheets/d/1sjobcoAvarcBL3yaYPlGSQzYOpULD2hFfRf5KFNcnac/edit?usp=sharing)の「作業群B」を実施する

7. 静的コンテンツの設置

   S3バケット「```"${var.project}-${var.environment}-static-bucket-${random_string.s3_unique_key.result}"```」に、講座で入手する資材「2203-一般公開バケット作成/public」を設置する（変数値部分は[ここ](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/s3.tf#L13C12-L13C99)で指定している値）

8. Appサーバー起動時のアプリケーションファイルの設置

   S3バケット「```"${var.project}-${var.environment}-deploy-bucket-${random_string.s3_unique_key.result}"```」に、講座で入手する資材「2204-プライベートバケット作成/デプロイ用コンテンツ」配下の「tastylog-app-1.8.1.tar.gz」と「latest」を設置する（変数値部分は[ここ](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/s3.tf#L68)で指定している値）

9. オートスケーリングの設定

    9-1. [initialize.sh](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/src/initialize.sh)のBUCKET_NAMEの値を「deply用S3バケット」のバケット名に変更する（本レポジトリに置いているファイルからはコード部分を削除している。実際のコードは、講座を受講して入手する）

    9-2. 4-3でコメントアウトした[auto_scaling.tf](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/auto_scaling.tf)のすべてのコメントを解除する

    9-3. 4-4でコメント解除した[ec2.tf](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/ec2.tf#L15-L34)の「App Server」セクションをコメントアウトする

    9-4. 4-5でコメントアウトした[data.tf](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/data.tf#L5-L13)の「data "aws_ami" "app"」ブロックのコメントを解除する

    9-5. terraform applyする（4-6と同じ要領）

10. 最終動作確認と修正

    10-1. ローカル端末やスマートフォンのブラウザで「https://[ドメイン名]/」にアクセスし、tastyログのサイトがエラーなく表示されることを確認する

    [ドメイン名]は```"${var.project}-${var.environment}.${var.domain}"```が該当する（変数値部分は[ここ](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/cloudfront.tf#L98)で指定している値）

    正常に表示されない場合は、[Udemy講座「AWS と Terraformで実現するInfrastructure as Code」の環境構築コマンド](https://docs.google.com/spreadsheets/d/1sjobcoAvarcBL3yaYPlGSQzYOpULD2hFfRf5KFNcnac/edit?usp=sharing)の「作業群C」を参考に、原因分析や修正を行う

### 環境削除

1. Terraform管理のS3バケットからデータを全て削除する

2. RDSインスタンスを一時停止しているなら開始しておく（RDSインスタンスが起動中の場合は、何もする必要はない）

3. GitHub Actions経由で環境を構築していた場合、バックエンド系の設定にprofileを指定するコード（環境構築手順の3の<<<AWSCLIで使用するprofile名>>>の箇所が該当）を追加する（この変更は、destroy完了後に破棄する前提）

4. RDSの削除保護を解除するコードに変更する（この変更は、destroy完了後に破棄する前提）

    [この部分](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/terraform/dev/rds.tf#L85-L88)の
    ```deletion_protection = true```　と ```skip_final_snapshot = false``` をコメントアウト
    ```#deletion_protection = false``` と ```#skip_final_snapshot = true``` のコメントを解除
   
5. ローカル端末からapplyする（上記、3、4の変更を反映する）

6. ローカル端末から```terraform destroy```する

7. 上記3、4の変更を破棄する（```git checkout -- .```する等）

8. GitHub Actions経由で環境構築（Apply）していた場合、GitHub Actionsで差分検知して、環境が再度作成されないように対処しておく

   例：
   ```git mv terraform/dev/ terraform/__deleted_dev/```し、GitHubに変更を反映しておく。等
   
   [参考例](https://github.com/katsuhirodoi2/udemy_terraform_aws_study/blob/main/.github/workflows/dev_apply.yml#L8)の場合、```paths```が```terraform/dev/**```となっているので、ディレクトリをterraform/__deleted_dev/に変えることで、GitHub Actionsにて差分検知して、applyのワークフローが発火することはなくなるという対策をしている。

## その他

質問、指摘がある場合、

https://twitter.com/katsuhirodoi1

または、このレポジトリへのコメント

にて連絡を願う
