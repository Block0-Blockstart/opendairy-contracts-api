FROM node:16

# Default value for PORT variable
ENV PORT=42002

# Create and set a default directory for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions
WORKDIR /usr/app

# Copy both package.json AND package-lock.json
COPY package*.json ./

# Then feed the node_modules by running npm install
# We do this before copying the rest of the code. This way, docker will cache
# node_modules in a separate layer than the rest of the code, so that the node_modules
# will not be recreated anytime we run docker build (only if package.json or package-lock.json
# have changed).
RUN npm i

# Copy the rest of the app, excluding .dockerignore list
COPY . .

# Expose needed port passed by env vars, or by default 42003
EXPOSE ${PORT}

# Command to run, as a json array
# first value is the executable, others are params
CMD [ "npm", "run", "start" ]