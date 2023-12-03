#!/bin/sh
times=$(date +%Y%m%d_%H%M%S)

sh oracle_check.sh > check_log$times\.log