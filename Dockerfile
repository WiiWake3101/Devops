# Use a lightweight Node.js base image
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Add environment variables for Expo
ENV EXPO_DEVTOOLS_LISTEN_ADDRESS=0.0.0.0

#uncomment and set the following line
#ENV REACT_NATIVE_PACKAGER_HOSTNAME=<ip address of the machine running the container>

# Copy .env file
COPY .env ./

# Copy the rest of the project files
COPY . .

# Expose the necessary Expo ports
EXPOSE 8081 19000 19001 19002

# Start the Expo development server
CMD ["npx", "expo", "start","-c"]