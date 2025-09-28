# Smart Vehicle Health Monitoring and OTA Update System 🚗

A comprehensive IoT solution for real-time vehicle monitoring with over-the-air updates using ESP32, React Native, and Supabase.

## 🔍 Project Overview

This system provides real-time monitoring of vehicle health metrics including:
- GPS location tracking with trip history
- Temperature and humidity sensing
- IMU (Inertial Measurement Unit) data for motion analysis
- OTA (Over-The-Air) firmware updates for ESP32 devices

## 🛠️ Technology Stack

- **Frontend**: React Native with Expo
- **Backend**: Supabase (PostgreSQL + Real-time API)
- **IoT Hardware**: ESP32 with GPS, DHT22, and MPU6050 sensors
- **DevOps**: Jenkins, Docker, Terraform

## ⚙️ Setup Instructions

### Mobile Application

1. Install dependencies

   ```bash
   npm install
   ```

2. Start the app

   ```bash
   npx expo start
   ```

### ESP32 Hardware Setup

1. **Connect the sensors:**
   - GPS module to pins 16 (RX) and 17 (TX)
   - DHT22 sensor to pin 5
   - MPU6050 to I2C pins (SDA/SCL)

2. **Create and configure `secrets.h` in the Arduino IDE:**
   - In the same folder as your `Devops_1.0.0.ino` file, create a file named `secrets.h`.
   - Add your WiFi SSID, password, Supabase URL, API key, and user ID as shown below:
     ```cpp
     #define WIFI_SSID "your_wifi_ssid"
     #define WIFI_PASSWORD "your_wifi_password"
     #define SUPABASE_URL "your_supabase_url"
     #define SUPABASE_API_KEY "your_supabase_anon_key"
     #define USER_ID "your_user_id"
     ```
   - Save `secrets.h` before compiling and uploading the firmware.

3. **Upload the firmware to ESP32:**
   - Open `Devops_1.0.0.ino` in Arduino IDE.
   - Select the correct board and port.
   - Compile and upload the sketch to your ESP32.

## 🚀 CI/CD Pipeline with Jenkins

This project uses Jenkins for continuous integration and deployment:

- **Automated Testing:**  
  Jenkins runs unit and integration tests on each commit.
- **Mobile App Builds:**  
  Jenkins automates Expo builds for iOS and Android.
- **ESP32 Firmware Verification:**  
  Jenkins compiles and statically analyzes ESP32 firmware.
- **OTA Updates:**  
  Jenkins automates deployment of firmware updates to the S3 bucket.
- **Secrets Management:**  
  Jenkins securely injects Supabase and WiFi credentials into `.env` and `secrets.h` files for builds.

**Jenkins Pipeline Example:**  
See [`Jenkinsfile`](./Jenkinsfile) for the full pipeline.

---

## 🏗️ Infrastructure as Code with Terraform

- **AWS S3 Bucket for Firmware:**  
  Terraform provisions an S3 bucket (`devops-firmware-storage`) for storing ESP32 firmware files, with versioning enabled.
- **IAM User & Policy:**  
  Terraform creates an IAM user and policy for secure firmware upload/download access to the S3 bucket.
- **Supabase Credentials Management:**  
  Supabase project URL and anon key are managed as Terraform variables and outputs, making them available for CI/CD and application configuration.
- **Best Practices:**  
  - All infrastructure code is organized in the `infra/terraform` directory.
  - Sensitive credentials are stored in `terraform.tfvars` (not committed to version control).
  - AWS credentials are managed via environment variables or AWS CLI.

**How to Use:**

1. **Provision Infrastructure:**
   ```sh
   cd infra/terraform
   terraform init
   terraform plan
   terraform apply
   ```


> **Note:**  
> Supabase resources (tables, storage, etc.) are managed via the Supabase dashboard or CLI, as there is no official Terraform provider for Supabase.

## 🔄 DevOps Practices Implemented

- **Infrastructure as Code**: Terraform for Supabase resources
- **Containerization**: Docker for consistent development and testing
- **Monitoring**: Grafana dashboards for system performance
- **Automated Testing**: Jest for frontend, Arduino unit tests for ESP32
- **Security Scanning**: Dependency vulnerability scanning
- **Version Control**: Git with GitHub flow branching strategy

## Environment Configuration (.env)

This application requires a properly configured `.env` file in the root directory. Below is the structure of the `.env` file with the required variables:

```
# Supabase Configuration
EXPO_PUBLIC_SUPABASE_URL=your_supabase_url
EXPO_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Terraform Variable Configuration (`terraform.tfvars`)

Sensitive information such as your Supabase project URL and anon key should be provided to Terraform using a `terraform.tfvars` file.

- **Location:**  
  Create `terraform.tfvars` inside the `infra/terraform` directory.
- **Purpose:**  
  This file supplies sensitive variables to your Terraform configuration without hardcoding them in your `.tf` files.
- **Best Practices:**  
  - Do **not** commit `terraform.tfvars` to version control.
  - Add `terraform.tfvars` to your `.gitignore`.
  - Request the required values from the project administrator if you do not have them.

Terraform will automatically use values from `terraform.tfvars` when you run `terraform plan` or `terraform apply`.

## 🔄 OTA Firmware Upload Script

A Python script (`scripts/upload_firmware.py`) is provided to manage firmware binaries and OTA updates via Supabase.

### Features

- **Automatic Detection**: Finds `.bin` files in the default directory and uploads them.
- **Manual Upload**: Upload a specific binary with version and device type.
- **Version Management**: List, delete, and check firmware versions.
- **Supabase Integration**: Uploads binaries to Supabase Storage and registers metadata in the database.

### Usage

```bash
# Automatic upload of all binaries in the default directory
python scripts/upload_firmware.py

# Manual upload
python scripts/upload_firmware.py upload <binary_path> <version> <device_type> [is_mandatory] [--force]

# List firmware versions
python scripts/upload_firmware.py list [device_type]

# List available binary files
python scripts/upload_firmware.py binaries

# Delete a firmware version
python scripts/upload_firmware.py delete <version> <device_type>

# Delete all firmware versions
python scripts/upload_firmware.py delete --all
```

**Note:**  
- Ensure your `.env` file contains `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_ANON_KEY`.
- The script will look for binaries in `python upload_firmware.py upload "C:\Users\vivek\OneDrive\Documents\Arduino\Devops\build\esp32.esp32.esp32wrover\Devops.ino.bin" 1.0.0 GPS-Tracker false` by default.

## 🛳️ Docker Setup

You can run the React Native Expo development server inside a Docker container for consistent development environments.

### Dockerfile Structure

```dockerfile
# Use a lightweight Node.js base image
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Add environment variables for Expo
ENV EXPO_DEVTOOLS_LISTEN_ADDRESS=0.0.0.0
ENV REACT_NATIVE_PACKAGER_HOSTNAME=192.168.1.100 

# Copy .env file
COPY .env ./

# Copy the rest of the project files
COPY . .

# Expose the necessary Expo ports
EXPOSE 8081 19000 19001 19002

# Start the Expo development server
CMD ["npx", "expo", "start","-c"]
```

### Build the Docker Image

```sh
docker build -t smart-vehicle-app .
```

### Run the Docker Container

```sh
docker run -it --rm -p 8081:8081 -p 19000:19000 -p 19001:19001 -p 19002:19002 --env-file .env smart-vehicle-app
```

- The `--env-file .env` flag ensures your environment variables are loaded.
- The `-p` flags expose the necessary ports for Expo and React Native development.

## Getting Started

1. Clone the repository
2. Create the `.env` file as described above
3. Install dependencies with `npm install`
4. Start the development server with `npx expo start`
2. Create the `.env` file as described above
3. Install dependencies with `npm install`
4. Start the development server with `npx expo start`