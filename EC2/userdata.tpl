sudo apt install httpd -y
echo "this is coming from terraform" >> /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd