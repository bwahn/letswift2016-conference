FROM ibmcom/kitura-ubuntu

ENV swift-api 0.1.0

COPY letswift-server /letswift-server

#ADD run_swift_api.sh run_swift_api.sh
#COPY run_swift_api.sh /letswift-server/run_swift_api.sh

EXPOSE 8090 

WORKDIR "/letswift-server"
CMD ["/letswift-server/run_swift_api.sh"]
