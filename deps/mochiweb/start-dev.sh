#!/bin/sh
exec erl \
    -pa ebin deps/*/ebin \
    -boot start_sasl \
    -sname mochiweb_dev \
    -s mochiweb \
    -s reloader
