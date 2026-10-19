SELECT 'CREATE DATABASE salon'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'salon')\gexec

\connect salon

CREATE TABLE IF NOT EXISTS customers (
  customer_id SERIAL PRIMARY KEY,
  phone VARCHAR(30) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS services (
  service_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS appointments (
  appointment_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(customer_id),
  service_id INT NOT NULL REFERENCES services(service_id),
  time VARCHAR(30) NOT NULL
);

INSERT INTO services (service_id, name)
VALUES (1, 'cut'), (2, 'color'), (3, 'perm')
ON CONFLICT (service_id) DO NOTHING;

SELECT setval(
  'services_service_id_seq',
  GREATEST((SELECT COALESCE(MAX(service_id), 1) FROM services), 1),
  true
);
