FROM tianon/true

# Add the Chef cookbooks and runtime info to a volume container
COPY zero.rb first-boot.json /tmp/chef/
COPY cookbooks /tmp/chef/cookbooks/

# Create volumes
VOLUME /tmp/chef
