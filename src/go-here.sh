#!/bin/sh
#
# Copyright (c) 2019 Alexandru Catrina <alex@codeissues.net>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

export HOMEPAGE=http://github.com/lexndru/go-here
export USER_BIN=$HOME/bin
export GO=$(command -v go)
export GO2=$USER_BIN/go
export GOHERE_NOTICE="Golang's workspace helper installed"

# enable go here
gohere_enable () {
    if [ -z "$HOME" ]; then
        echo "User's home directory is not set in \$PATH"
        exit 1
    fi

    if ! mkdir -p "$USER_BIN"; then
        echo "Cannot create user's private bin directory in $HOME"
        echo "Please check permissions and try again"
        exit 1
    fi

    if [ -f "$USER_BIN/go" ]; then
        if ! tail "$USER_BIN/go" -n 1 | grep "$GOHERE_NOTICE" > /dev/null 2>&1; then
            echo "Aborting because cannot resolve conflict!"
            echo "A script with the name \"go\" already exists in $USER_BIN"
            echo "Please remove this script and try again"
            exit 1
        else
            echo "Go Here is already enabled"
            exit 0
        fi
    fi

    cat > $GO2 2> /dev/null <<EOF
#!/bin/sh
#
# Copyright (c) 2019 Alexandru Catrina <alex@codeissues.net>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

export ERROR='\\033[0;31m'
export RESET='\\033[0m'

if [ ! -f $GO ]; then
    echo "Cannot find golang on system. Please install it."
    exit 1
fi

_here () {
    local cwd="\$(pwd)"
    local gopath="\$GOPATH"
    local prompt="\$PS1"
    local project="\$(basename "\$cwd")"
    if [ -d src ]; then # cwd is at root of project
        mkdir -p bin pkg # required by directory layout
        export GOPATH="\$cwd"
        export PS1="(\$project) \\$ "
    elif [ "x\$project" = "xsrc" ]; then # cwd is src of project
        cd ..
        cwd="\$(pwd)"
        project="\$(basename "\$cwd")"
        mkdir -p bin pkg # required by directory layout
        export GOPATH="\$cwd"
        export PS1="(\$project) \\$ "
    else
        read -p "Use this directory to isolate a Golang project? [yn] " answer
        case "\$answer" in
            Y|y) {
                echo "OK"
                mkdir -p bin pkg src
                _here
            } ;;
            N|n) {
                echo "Bye"
            } ;;
            *) {
                echo "Go here must be launched from project root or project src directory"
                echo "Cannot isolate project"
                exit 1
            }
        esac
    fi
}

case "\$1" in
    here) {
        _here
    } ;;
    *) {
        $GO "\$@"
    }
esac

# $GOHERE_NOTICE on $(date)
EOF

    if [ $? -eq 0 ] && chmod +x "$GO2"; then
        echo "Go Here is now enabled!"
    else
        rm -rf "$GO2" > /dev/null 2>&1
        echo "Cannot enable Go Here"
        echo "Please check permissions and try again"
        exit 1
    fi
}

# disable go here
gohere_disable () {
    if [ -f "$USER_BIN/go" ]; then
        if ! tail "$USER_BIN/go" -n 1 | grep "$GOHERE_NOTICE" > /dev/null 2>&1; then
            echo "Aborting because cannot detect Go Here wrapper!"
            echo "A script with the name \"go\" already exists in $USER_BIN"
            echo "but cannot determine if it's a Go Here script."
            echo "Please manually remove this script on your own risk."
            exit 1
        else
            if rm -f "$USER_BIN/go"; then
                echo "Go Here is now disabled!"
            else
                echo "Cannot disable Go Here"
                echo "Please check permissions and try again"
            fi
        fi
    else
        echo "Go Here is not enabled. Nothing changed."
    fi
}

# check if gohere is enabled
gohere_status () {
    if [ -f "$USER_BIN/go" ]; then
        if tail "$USER_BIN/go" -n 1 | grep "$GOHERE_NOTICE" > /dev/null 2>&1; then
            echo "Go Here is enabled"
            return 0
        fi
    else
        echo "Go Here is NOT enabled"
        return 1
    fi
}

# print help message
help_message () {
    echo "Go Here is a workspace helper for Golang projects"
    echo ""
    echo "The purpose of Go Here is to use \$PWD as \$GOPATH on current shell session and comply with"
    echo "directory layout. The utility creates a wrapper over Go upon activating. The state of the"
    echo "binaries remains unchanged."
    echo ""
    echo "Please report bugs at: $HOMEPAGE"
    echo ""
    echo "Usage:"
    echo "  help        - prints this message"
    echo "  status      - checks if go-here is enabled or not"
    echo "  enable      - activate go-here workspace"
    echo "  disable     - deactivate go-here workspace"
    echo ""
}

# load go here script
if [ $# -gt 0 ]; then
    if [ "x$1" = "xhelp" ]; then
        help_message
    elif [ "x$1" = "xstatus" ]; then
        gohere_status
    elif [ "x$1" = "xenable" ]; then
        gohere_enable
    elif [ "x$1" = "xdisable" ]; then
        gohere_disable
    else
        echo "Unsupported action \"$@\" (try help)"
    fi
else
    help_message
fi
