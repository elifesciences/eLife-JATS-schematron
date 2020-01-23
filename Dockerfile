FROM basex/basexhttp:9.2.3

COPY --chown=basex validator/repo /srv/basex/repo
COPY --chown=basex validator/webapp /srv/basex/webapp
COPY validator/saxon9he.jar /usr/src/basex/basex-api/lib/saxon9he.jar
COPY --chown=basex validator/.basex /srv/basex
