GRANT ALL PRIVILEGES ON *.* to 'root'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
CREATE DATABASE `designate` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE `designate_pool_manager` CHARACTER SET utf8 COLLATE utf8_general_ci;
