FROM ifnazar/sybase_15_7

#COPY init1.sql /sybase/init1.sql
#COPY init2.sql /sybase/init2.sql
#COPY init3.sql /sybase/init3.sql
# COPY entrypoint.sh /
ADD entrypoint.sh /

RUN chmod +x /entrypoint.sh
#WORKDIR /sybase/

EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]

#CMD /sybase/start >> /dev/null
