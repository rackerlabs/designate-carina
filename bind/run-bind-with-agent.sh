#!/bin/bash

slappy -config /etc/slappy/slappy.conf &
named -g -u bind
