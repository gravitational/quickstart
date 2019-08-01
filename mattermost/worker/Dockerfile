# Copyright (c) 2015 Spinpunch, Inc. All Rights Reserved.
# See License.txt for license information.
FROM quay.io/gravitational/debian-grande:latest

# Copy over files
RUN apt-get update
RUN apt-get -y install curl
RUN cd /var && curl https://releases.mattermost.com/5.13.2/mattermost-team-5.13.2-linux-amd64.tar.gz | tar -xz

ADD docker-entry.sh /var/mattermost/bin/docker-entry.sh
RUN chmod +x /var/mattermost/bin/docker-entry.sh

# Create default storage directory
RUN mkdir /var/mattermost/data

ENTRYPOINT ["/var/mattermost/bin/docker-entry.sh"]

# Expose port 80
EXPOSE 80
