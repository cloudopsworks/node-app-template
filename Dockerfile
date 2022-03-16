##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
FROM node:14-slim
EXPOSE 8081
EXPOSE 8443

# Create app dir
RUN mkdir -p /var/app/
RUN chown -R 1000:1000 /var/app

WORKDIR /usr/src/app
COPY . .
CMD ["npm", "run", "start"] 
