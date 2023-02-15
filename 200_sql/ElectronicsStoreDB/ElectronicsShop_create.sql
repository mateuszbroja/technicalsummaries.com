CREATE TABLE categories (
	category_id INT IDENTITY (1, 1) PRIMARY KEY,
	category_name VARCHAR (255) NOT NULL
);

CREATE TABLE products (
	product_id INT IDENTITY (1, 1) PRIMARY KEY,
	category_id INT NOT NULL,
	product_name VARCHAR (255) NOT NULL,
	brand VARCHAR (155),
	price DECIMAL (10, 2) NOT NULL,
	FOREIGN KEY (category_id) REFERENCES categories (category_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE customer_addresses (
	address_id INT IDENTITY (1, 1) PRIMARY KEY,
	country VARCHAR (50),
	city VARCHAR (155),
	street VARCHAR (255),
	postal_code VARCHAR (50)
);

CREATE TABLE customers (
	customer_id INT IDENTITY (1, 1) PRIMARY KEY,
	address_id INT NULL,
	first_name VARCHAR (155) NOT NULL,
	last_name VARCHAR (155) NOT NULL,
	phone_number VARCHAR (50),
	email VARCHAR (155) NOT NULL,
	FOREIGN KEY (address_id) REFERENCES customer_addresses (address_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE stores (
	store_id INT IDENTITY (1, 1) PRIMARY KEY,
	store_name VARCHAR (255) NOT NULL,
	country VARCHAR (50),
	city VARCHAR (155),
	street VARCHAR (255),
	postal_code VARCHAR (50),
	store_size INT,
);

CREATE TABLE employees (
	employee_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (50) NOT NULL,
	last_name VARCHAR (50) NOT NULL,
	email VARCHAR (155) NOT NULL,
	phone_number VARCHAR (50),
	start_date DATE NOT NULL,
	end_date DATE
);

CREATE TABLE orders (
	order_id INT IDENTITY (1, 1) PRIMARY KEY,
	store_id INT NOT NULL,
	employee_id INT NOT NULL,		
	customer_id INT,
	order_status tinyint NOT NULL,
	order_date DATETIME NOT NULL,
	shipped_date DATETIME,
	FOREIGN KEY (customer_id) REFERENCES customers (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (store_id) REFERENCES stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (employee_id) REFERENCES employees (employee_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE product_discounts (
	discount_id INT IDENTITY (1, 1) PRIMARY KEY,
	discount DECIMAL (4,2),
	active BINARY (2)
);

CREATE TABLE order_items (
	order_item_id INT IDENTITY (1, 1) PRIMARY KEY,
	order_id INT,
	discount_id INT,
	product_id INT NOT NULL,
	quantity INT NOT NULL,
	FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (discount_id) REFERENCES product_discounts (discount_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
	FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE product_inventories (
	inventory_id INT IDENTITY (1, 1) PRIMARY KEY,
	product_id INT,
	store_id INT,
	quantity INT,
	FOREIGN KEY (store_id) REFERENCES stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);