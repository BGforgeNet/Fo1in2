#!/bin/bash

windows_pwd="$(pwd | sed -re 's!^/([A-Za-z])/!\U\1:/!g')/"
compile_exe="$(pwd)/Tools/sFall_ScriptEditor/resources/compile.exe"
scripts_dir="$(pwd)/Fallout2/Fallout1in2/Mapper/source/scripts"
bytecode_dir="$(pwd)/Fallout2/Fallout1in2/mods/fo1_base/scripts"

option_bytecode=0

for option in "$@"; do
    [ "$option" == "--bytecode" ] && option_bytecode=1
done

# output grouping, for GitHub Actions
# regular echo when running on local
function group_start()
{
    if [ -n "$GITHUB_ACTIONS" ]; then
       echo "::group::$@"
    else
       echo "$@"
    fi
}

# output grouping, for GitHub Actions
# no-op when running on local
function group_end()
{
    if [ -n "$GITHUB_ACTIONS" ]; then
       echo "::endgroup::"
    fi
}

# sanity checks
if   [ ! -f "$compile_exe" ]; then
     echo "[ERROR] Cannot find compiler : $compile_exe"
     exit 1
elif [ ! -x "$compile_exe" ]; then
     echo "[ERROR] Cannot run compiler"
     exit 1
elif [ ! -d "$scripts_dir" ]; then
     echo "[ERROR] Cannot find scripts directory : $scripts_dir"
     exit 1
elif [ ! -d "$bytecode_dir" ]; then
     echo "[ERROR] Cannot find bytecode directory : $bytecode_dir"
     exit 1
fi

num_errors=0
num_warnings=0

echo Compiling...

    # /c/repo/path/to/scripts/sub/dir/script.ssl
for ssl_full in $scripts_dir/**/*.[Ss][Ss][Ll]; do
    # /c/repo/path/to/scripts/sub/dir
    ssl_dir=$(dirname "$ssl_full")
    # sub/dir/script.ssl
    ssl_show=$(echo "$ssl_full" | sed -e "s!^$scripts_dir/!!")
    # script.ssl
    ssl_file=$(basename "$ssl_full")
    # script.int
    int_file=$(echo "$ssl_file" | sed -e 's!\.[Ss][Ss][Ll]$!\.int!')
    # script.ssl.log
    log_file="$ssl_file.log"

    ssl_result=

    # ssl compiler is too dumb to understand paths and always checks current directory
    cd "$ssl_dir"
    $compile_exe -q -l -p -s -O2 "$ssl_file" -o "$int_file" > "$log_file"

    # remove unwanted lines from log
    sed -i '/^$/d' $log_file
    sed -i '/^Compiling /d' $log_file
    sed -i '/THERE WERE ERRORS/d' $log_file

    # convert absolute paths to relative
    sed -i "s!$windows_pwd!!g" $log_file

    # pass #1
    # guess result -- does bytecode exists?
    if [ ! -f "$int_file" ]; then
       ssl_result=ERROR
       num_errors=$((num_errors+1))
    else
       if [ $option_bytecode -eq 1 ]; then
          mv $int_file $bytecode_dir/$int_file
       else
         rm $int_file
       fi
       ssl_result=WARNING
    fi

    # pass #2
    # confirm result -- does log exists and is not empty?
    if [ -s "$log_file" ]; then
       log_msg="$ssl_result $ssl_show"

       if [ "$ssl_result" == "ERROR" ]; then
          echo $log_msg
          cat $log_file
       else
          num_warnings=$((num_warnings+1))

          # group scripts with warnings only
          group_start $log_msg
          cat $log_file
          group_end
       fi
    fi

    rm "$log_file"
done

str_ok=" OK"
str_errors=
str_warnings=

if [ $num_errors -ge 1 ]; then
   str_ok=
   str_errors=" ERRORS:$num_errors"
fi
if [ $num_warnings -ge 1 ]; then
   str_ok=
   str_warnings=" WARNINGS:$num_warnings"
fi

echo Compiling...${str_ok}${str_errors}${str_warnings}

exit $num_errors