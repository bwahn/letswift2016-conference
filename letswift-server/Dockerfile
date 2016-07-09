FROM ibmcom/kitura-ubuntu

ENV swift-api 0.1.0

COPY letswift-api /letswift-api

#ADD run_swift_api.sh run_swift_api.sh
#COPY run_swift_api.sh /letswift-api/run_swift_api.sh

EXPOSE 6006

WORKDIR "/letswift-api"
CMD ["/letswift-api/run_swift_api.sh"]
