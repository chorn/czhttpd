###########################################################
# Stress test file serving. Will be sourced by `stress.sh #
###########################################################

<<EOF > $CONF
MAX_CONN=12
HTTP_KEEP_ALIVE=1
HTTP_TIMEOUT=30
HTTP_RECV_TIMEOUT=5
HTTP_BODY_SIZE=16384
HTTP_CACHE=0
HTML_CACHE=0
EOF

TESTROOT=$root/test.html
restart_server

describe "Default file serving with HTTP keep-alive"
attack -keepalive=true default_keep-alive_file

# Disable keep-alive
<<EOF > $CONF
MAX_CONN=12
HTTP_KEEP_ALIVE=0
HTTP_TIMEOUT=30
HTTP_RECV_TIMEOUT=5
HTTP_BODY_SIZE=16384
HTTP_CACHE=0
HTML_CACHE=0
EOF
reload_conf

describe "Default file serving without HTTP keep-alive"
attack default_no_keep-alive_file

# Single file compress
<<EOF > $CONF
typeset -g COMPRESS=1
typeset -g COMPRESS_TYPES="text/html,text/plain"
typeset -g COMPRESS_LEVEL=6
typeset -g COMPRESS_MIN_SIZE=100
typeset -g COMPRESS_CACHE=0
source $SRC_DIR/modules/compress.sh

MAX_CONN=12
HTTP_KEEP_ALIVE=1
HTTP_TIMEOUT=30
HTTP_RECV_TIMEOUT=5
HTTP_BODY_SIZE=16384
HTTP_CACHE=0
HTML_CACHE=0

EOF
reload_conf

describe "Single file compression"
attack compress_file

# Single file compress with cache
<<EOF > $CONF
typeset -g COMPRESS=1
typeset -g COMPRESS_TYPES="text/html,text/plain"
typeset -g COMPRESS_LEVEL=6
typeset -g COMPRESS_MIN_SIZE=100
typeset -g COMPRESS_CACHE=1
source $SRC_DIR/modules/compress.sh

MAX_CONN=12
HTTP_KEEP_ALIVE=1
HTTP_TIMEOUT=30
HTTP_RECV_TIMEOUT=5
HTTP_BODY_SIZE=16384
HTTP_CACHE=0
HTML_CACHE=1

EOF
reload_conf

describe "Single file compression+cache"
attack compress+cache_file

# Finally
vegeta plot $REPORT_DIR/*_file.bin > $HTML_DIR/file_serving.html
