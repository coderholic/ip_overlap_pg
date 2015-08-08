#!/bin/sh
export POSTGRES_URL=postgresql://postgres@$DB_PORT_5432_TCP_ADDR:$DB_PORT_5432_TCP_PORT/postgres?net_combined

pgloader command.load
