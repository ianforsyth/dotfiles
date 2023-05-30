# strava_commands.sh

r() {
    echo "Please select a command to run:"
    echo "1. Deploy"
    # Add more commands as needed

    echo -n "Enter the number of the command: "
    read option

    case $option in
        1)
            ex_deploy
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

ex_deploy() {
    echo "Please select a command to run:"
    echo "1. Deploy"
    # Add more commands as needed

    echo -n "Enter the number of the command: "
    read option

    case $option in
        1)
            echo "Deploy"
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}
