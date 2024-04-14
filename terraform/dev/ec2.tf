# ------------------------
# Key Pair
# ------------------------
resource "aws_key_pair" "keypair" {
  key_name   = "${var.project}-${var.environment}-keypair"
  public_key = file("src/${var.project}-${var.environment}-keypair.pub")

  tags = {
    Name    = "${var.project}-${var.environment}-keypair"
    Project = var.project
    Env     = var.environment
  }
}

# ------------------------
# App Server
# ------------------------
# resource "aws_instance" "app_server" {
#   ami                         = "ami-0bdd30a3e20da30a1"
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.private_subnet_1a.id
#   associate_public_ip_address = false
#   vpc_security_group_ids      = [aws_security_group.app_sg.id]
#   key_name                    = aws_key_pair.keypair.key_name

#   iam_instance_profile = aws_iam_instance_profile.app_server_profile.name

#   tags = {
#     Name    = "${var.project}-${var.environment}-app-server"
#     Project = var.project
#     Env     = var.environment
#     Type    = "app"
#   }
# }

# ------------------------
# Step Server
# ------------------------
resource "aws_instance" "step_server" {
  ami                         = data.aws_ami.step.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_1a.id
  associate_public_ip_address = true
  source_dest_check           = false # NAT機能を持たせるために、インスタンスの送信元/送信先チェックを無効化する
  vpc_security_group_ids      = [aws_security_group.opmng_sg.id]
  key_name                    = aws_key_pair.keypair.key_name

  iam_instance_profile = aws_iam_instance_profile.step_server_profile.name

  tags = {
    Name    = "${var.project}-${var.environment}-step-server"
    Project = var.project
    Env     = var.environment
  }

  user_data = <<-EOF
                #!/bin/bash

                ### MySQLクライアントインストール
                sudo dnf update -y
                sudo dnf -y localinstall  https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
                sudo sed -i 's/gpgcheck=1/gpgcheck=0/' /etc/yum.repos.d/mysql-community.repo
                sudo dnf -y install mysql mysql-community-client
                

                ### NAT機能を持たせるための設定
                # インスタンス内部設定 (net.ipv4.ip_forward)
                sudo sysctl -w net.ipv4.ip_forward=1 | sudo tee -a /etc/sysctl.conf
                
                # Amazon Linux 2023の初期状態ではiptablesは未インストール
                # このため今回はnftablesをインストール
                sudo dnf install -y nftables
                
                # NAT設定追加 : NICデバイス名がeth0ではないので注意。
                sudo nft add table nat
                sudo nft -- add chain nat prerouting { type nat hook prerouting priority -100 \; }
                sudo nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
                sudo nft add rule nat postrouting oifname "$(ip -o link show device-number-0 | awk -F': ' '{print $2}')" masquerade
                
                # NAT設定保存
                sudo nft list table nat | sudo tee /etc/nftables/al2023-nat.nft
                echo 'include "/etc/nftables/al2023-nat.nft"' | sudo tee -a /etc/sysconfig/nftables.conf
                
                # サービス起動＋自動起動設定
                sudo systemctl start nftables
                sudo systemctl enable nftables

              EOF
}
