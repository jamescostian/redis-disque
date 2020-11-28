# Build the disque module
FROM redis:6 as module

RUN apt-get update && apt-get install -y git-core gcc make && rm -rf /var/lib/apt/lists/*

RUN cd / \
  && git clone https://github.com/antirez/disque-module \
  && make -C /disque-module

# Copy the built module and run redis with it
FROM redis:6

ARG REDIS_LIBS_DIR=/usr/lib/redis/modules
ENV REDIS_LIBS_DIR=$REDIS_LIBS_DIR
RUN mkdir -p "$REDIS_LIBS_DIR"
COPY --from=module /disque-module/disque.so $REDIS_LIBS_DIR

# The things set here are all required for disque to work
CMD redis-server --appendonly yes --aof-use-rdb-preamble yes --cluster-enabled yes --loadmodule "$REDIS_LIBS_DIR/disque.so"
