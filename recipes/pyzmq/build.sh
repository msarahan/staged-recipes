#!/bin/bash

export DYLD_LIBRARY_PATH="$PREFIX/lib:$DYLD_LIBRARY_PATH"

"$PYTHON" setup.py configure --zmq "$PREFIX"

"$PYTHON" setup.py install

if [ $ANA_PY == 27 ]; then
    rm $SP_DIR/zmq/asyncio.py
    rm $SP_DIR/zmq/auth/asyncio.py
    rm $SP_DIR/zmq/tests/_test_asyncio.py
fi
