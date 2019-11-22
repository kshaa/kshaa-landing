{ user, group, directory }: ''
    echo "Starting directory permission script"

    user=${user}
    group=${group}
    directory=${directory}

    echo "Allowing everyone read and traverse from '/'  '$directory'" 
    # Relevant - https://unix.stackexchange.com/questions/90590/set-read-and-write-permissions-to-folder-and-all-its-parent-directories
    traverseDirectory=$(dirname "$directory")
    mkdir -p $traverseDirectory
    while [[ $traverseDirectory != / ]]
    do
        chmod a+rx "$traverseDirectory"
        traverseDirectory=$(dirname "$traverseDirectory")
    done

    echo "Making '$user' the owner, '$group' the group of '$directory'"
    chmod -R a+rx "$directory"
    chown -R $user:$group $directory;   
''