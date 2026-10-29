CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    role ENUM(
        'CUSTOMER',
        'TRANSPORT_OFFICER',
        'DRIVER',
        'MAINTENANCE_OFFICER'
    ) NOT NULL,
    account_status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    country VARCHAR(100),
    address VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE transport_officers (
    officer_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE maintenance_officers (
    maintenance_officer_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE drivers (
    driver_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    nic_number VARCHAR(20) NOT NULL UNIQUE,
    address VARCHAR(255),
    license_number VARCHAR(50) NOT NULL UNIQUE,
    license_expiry_date DATE NOT NULL,
    nic_front_path VARCHAR(255),
    nic_back_path VARCHAR(255),
    license_front_path VARCHAR(255),
    license_back_path VARCHAR(255),
    driver_photo_path VARCHAR(255),
    availability_status ENUM(
        'AVAILABLE', 'ASSIGNED', 'UNAVAILABLE'
    ) DEFAULT 'AVAILABLE',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    registration_number VARCHAR(30) NOT NULL UNIQUE,
    make VARCHAR(80) NOT NULL,
    model VARCHAR(80) NOT NULL,
    vehicle_year YEAR,
    vehicle_type VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    fuel_type VARCHAR(30),
    current_odometer DECIMAL(10,1) DEFAULT 0,
    vehicle_image_path VARCHAR(255),
    status ENUM(
        'AVAILABLE', 'ASSIGNED', 'MAINTENANCE', 'INACTIVE'
    ) DEFAULT 'AVAILABLE',
    purchase_date DATE,
    notes TEXT,
    CHECK (capacity > 0),
    CHECK (current_odometer >= 0)
) ENGINE=InnoDB;

CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    pickup_location VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,
    passenger_count INT NOT NULL,
    trip_type VARCHAR(50) NOT NULL,
    special_requests TEXT,
    total_amount DECIMAL(10,2) DEFAULT 0,
    status ENUM(
        'PENDING', 'APPROVED', 'ASSIGNED',
        'IN_PROGRESS', 'COMPLETED',
        'REJECTED', 'CANCELLED'
    ) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CHECK (passenger_count > 0),
    CHECK (total_amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE trips (
    trip_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    vehicle_id INT NOT NULL,
    driver_id INT NOT NULL,
    trip_status ENUM(
        'ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
    ) DEFAULT 'ASSIGNED',
    start_time DATETIME,
    end_time DATETIME,
    start_odometer DECIMAL(10,1),
    end_odometer DECIMAL(10,1),
    distance DECIMAL(10,1),
    remarks TEXT,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CHECK (start_odometer IS NULL OR start_odometer >= 0),
    CHECK (end_odometer IS NULL OR end_odometer >= 0),
    CHECK (distance IS NULL OR distance >= 0)
) ENGINE=InnoDB;

CREATE TABLE location_records (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT NOT NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    recorded_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trip_id) REFERENCES trips(trip_id)
) ENGINE=InnoDB;

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    payment_reference VARCHAR(100),
    payment_method VARCHAR(50),
    payment_status ENUM(
        'PENDING', 'SUCCESS', 'FAILED', 'CANCELLED'
    ) DEFAULT 'PENDING',
    payment_date DATETIME,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE maintenance_records (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    service_date DATE NOT NULL,
    mileage DECIMAL(10,1) NOT NULL,
    next_service_date DATE,
    next_service_mileage DECIMAL(10,1),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    CHECK (mileage >= 0),
    CHECK (next_service_mileage IS NULL OR next_service_mileage >= 0)
) ENGINE=InnoDB;