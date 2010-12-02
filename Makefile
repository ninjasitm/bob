APP_NAME = studio
APP_VERSION = 0.0-SNAPSHOT
APP_FULLNAME = $(APP_NAME)-$(APP_VERSION)
APP_DIR = /var/tmp
BUILD_BASE = $(APP_DIR)/build
BUILD_PACKAGE = $(BUILD_BASE)/package
DEPLOY_HOST = teuchi
DEPLOY_PORT = 2218
DEPLOY_BASE = /var/www
DEPLOY_SUBDIR = cliffano.com/studio
DEPLOY_DIR = $(DEPLOY_BASE)/$(DEPLOY_SUBDIR)
TOOL_DIR = $(DEPLOY_BASE)/tool

init:
	echo "B0b shall build."

clean:
	rm -rf $(BUILD_BASE)
	rm -f $(APP_DIR)/nohup.*

dep:
	npm install express ejs

start-dev: clean
	$(TOOL_DIR)/b0b/ghibli.sh $(APP_NAME) $(APP_DIR) start dev

stop:
	$(TOOL_DIR)/b0b/ghibli.sh $(APP_NAME) $(APP_DIR) stop

status:
	$(TOOL_DIR)/b0b/ghibli.sh $(APP_NAME) $(APP_DIR) status
    
package: clean
	mkdir -p $(BUILD_PACKAGE)
	tar --exclude test -X $(TOOL_DIR)/b0b/exclude.txt -cvf $(BUILD_PACKAGE)/$(APP_FULLNAME).tar *
	gzip $(BUILD_PACKAGE)/$(APP_FULLNAME).tar

deploy: package
	ssh -p $(DEPLOY_PORT) $(DEPLOY_HOST) 'cd $(DEPLOY_DIR); rm -rf *;'
	scp -P $(DEPLOY_PORT) $(BUILD_PACKAGE)/$(APP_FULLNAME).tar.gz $(DEPLOY_HOST):$(DEPLOY_DIR)
	ssh -p $(DEPLOY_PORT) $(DEPLOY_HOST) 'cd $(DEPLOY_DIR); gunzip *.tar.gz; tar -xvf *.tar; rm *.tar;'

deploy-r: deploy
	ssh -p $(DEPLOY_PORT) $(DEPLOY_HOST) '$(TOOL_DIR)/b0b/ghibli.sh $(APP_NAME) $(DEPLOY_DIR) stop; $(TOOL_DIR)/b0b/ghibli.sh $(APP_NAME) $(DEPLOY_DIR) start prd;'

.PHONY: init clean dep start-dev stop status package deploy