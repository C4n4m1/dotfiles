#!/bin/bash

full_path="$ZED_FILE"
filename_ext=$(basename "$full_path")

filename="${filename_ext%.*}"
extension="${filename_ext##*.}"

echo "[running $filename_ext]"

if [[ "$extension" == "c" ]]; then
    clang -std=c99 -Wall -lm "$full_path" && ./a.out;

elif [[ "$extension" == "py" ]]; then
    python "$full_path";

elif [[ "$extension" == "sh" ]]; then
    sh "$full_path";

elif [[ "$extension" == "pas" ]]; then
    fpc "$full_path" && ./"$filename"

elif [[ "$extension" == "java" ]]; then

    if [[ ! -f  ~/.local/share/runners_data/"$filename_ext" ]]; then
        javac "$filename_ext" && java -cp . "$filename_ext"
        cp "$filename_ext"  ~/.local/share/runners_data/"$filename_ext"
    else
        if diff "$filename_ext" ~/.local/share/runners_data/"$filename_ext" > /dev/null; then
            java -cp . "$filename_ext"
        else
            javac "$filename_ext" && java -cp . "$filename_ext"
            cp "$filename_ext"  ~/.local/share/runners_data/"$filename_ext"
        fi
    fi
# javac "$filename_ext" && java -cp . "$filename_ext"
elif [[ "$extension" == "zig" ]]; then
    zig run "$filename_ext"
elif [[ "$extension" == "qml" ]]; then
    qs -p "$filename_ext"
elif [[ "$extension" == "php" ]]; then
    xdg-open "http://localhost${full_path##/srv/http}"
elif [[ "$extension" == "html" ]]; then
    xdg-open "$full_path"
else
    echo "no"
fi
