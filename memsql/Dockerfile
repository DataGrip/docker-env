FROM memsql/quickstart:minimal-6.0.14
ADD schema.sql /

ENTRYPOINT ["/memsql-entrypoint.sh"]

CMD ["memsqld"]

EXPOSE 3306