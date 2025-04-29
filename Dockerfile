FROM node
LABEL authors="Dara"
# update dependencies and install curl
RUN apt update && apt install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*
# Create app directory
WORKDIR /app
# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
# COPY package*.json ./ \
#     ./source ./

# This will copy everything from the source path 
# --more of a convenience when testing locally.
COPY . .
# update each dependency in package.json to the latest version
# Set NPM config for better network resilience
RUN npm config set registry https://registry.npmjs.org/ \
    && npm config set fetch-retries 5 \
    && npm config set fetch-retry-factor 10 \
    && npm config set fetch-retry-mintimeout 20000 \
    && npm config set fetch-retry-maxtimeout 120000

# Install npm-check-updates globally
RUN npm install -g npm-check-updates

# Update package.json with latest dependencies
RUN ncu -u

# Install all dependencies (only once)
RUN npm install

# Install any additional specific packages if needed (optional)
# RUN npm install express babel-cli babel-preset babel-preset-env
# If you are building your code for production
RUN npm ci --only=production
# Bundle app source
COPY . /app
EXPOSE 3000
CMD [ "npm", "start" ]