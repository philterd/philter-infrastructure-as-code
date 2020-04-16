#!/bin/bash
echo "server.port=8080" | sudo tee -a /opt/philter/application.properties
echo "logging.level.root=INFO" | sudo tee -a /opt/philter/application.properties
echo "model.file=/opt/philter/final-model.pt" | sudo tee -a /opt/philter/application.properties
echo "anonymization.cache.service.redis.enabled=true" | sudo tee -a /opt/philter/application.properties
echo "anonymization.cache.service.redis.host=${cache_host}" | sudo tee -a /opt/philter/application.properties
echo "anonymization.cache.service.redis.port=6379" | sudo tee -a /opt/philter/application.properties
echo "anonymization.cache.service.redis.auth.token=${cache_auth_token}" | sudo tee -a /opt/philter/application.properties
sudo systemctl restart philter.service
sudo systemctl restart philter-ner.service
# TODO: Signal the autoscaling group.