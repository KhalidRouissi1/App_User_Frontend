name: Deploy Frontend

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.EC2_SSH_KEY }}

      - name: Add EC2 Host to known_hosts
        run: |
          mkdir -p ~/.ssh
          ssh-keyscan -H 13.60.80.252 | tee -a ~/.ssh/known_hosts

      - name: Deploy to EC2
        run: |
          ssh ubuntu@13.60.80.252 << 'EOF'
          set -x  # Enable debugging

          # Stop any existing containers to avoid conflicts
          sudo docker stop frontend-app || echo "No running container named frontend-app"
          sudo docker rm frontend-app || echo "No container named frontend-app to remove"

          # Pull the latest Docker image
          sudo docker pull khalidelmodir/frontend:latest

          # Run the new container
          sudo docker run -d --name frontend-app -p 3000:3000 khalidelmodir/frontend:latest

          # Optionally, tail your app logs if you have set up logging
          # sudo docker logs -f frontend-app || echo "No log files found"
          EOF
