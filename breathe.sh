#!/bin/sh

([[ -f server/breathe.sh ]] && echo "+ server alive") || echo "- no server"
([[ -f client/breathe.sh ]] && echo "+ client alive") || echo "- no client"
([[ -f observer/breathe.sh ]] && echo "+ observer alive") || echo "- no server"
