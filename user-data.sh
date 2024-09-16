#!/bin/bash
# Update the package list
yes | sudo apt-get update

# Install Apache
yes | sudo apt install apache2

# Enable Apache to start on boot
sudo systemctl enable apache2

# Start Apache service
sudo systemctl start apache2

# Install AWS Cloud Watch Agent
sudo wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
sudo mkdir -p /usr/share/collectd/
sudo touch /usr/share/collectd/types.db
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:/alarm/AWS-CWAgentLinConfig -s

# Create a sample e-commerce HTML page
sudo cat << 'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AARTI'S E-SHOP</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .header {
            background-color: #333;
            color: white;
            padding: 1em;
            text-align: center;
        }
        .container {
            padding: 2em;
        }
        .product {
            background-color: white;
            margin: 1em;
            padding: 1em;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .product img {
            max-width: 100%;
        }
        .product h2 {
            margin-top: 0;
        }
        .product p {
            color: #555;
        }
        .product button {
            background-color: #28a745;
            color: white;
            border: none;
            padding: 0.5em 1em;
            border-radius: 5px;
            cursor: pointer;
        }
        .product button:hover {
            background-color: #218838;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Welcome to our Aarti's E-Store</h1>
    </div>
    <div class="container">
        <div class="product">
            <img src="https://www.sagefruit.com/wp-content/uploads/2016/08/breeze2-300x300.png" alt="Royal Apple">
            <h2>Royal Apple</h2>
            <p>This is a great product. You should buy it!</p>
            <button>Add to Cart</button>
        </div>
    </div>
</body>
</html>
EOF

# Restart Apache to apply changes
sudo systemctl restart apache2