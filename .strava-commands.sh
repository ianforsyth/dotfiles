# strava_commands.sh

r() {
    echo "d) Deploy"

    read -k 1 -s option

    case $option in
        d)
            get_service
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

get_service() {
  echo "What service do you want to deploy?"
  echo "com) Comms"
  echo "cow) Cowbell"
  echo "dix) Dixie"

  read -k 3 -s option

  case $option in
      com)
          get_component "comms"
          ;;
      cow)
          get_component "cowbell"
          ;;
      dix)
          get_component "dixie"
          ;;
      *)
          echo "Invalid option"
          ;;
  esac
}

get_component() {
  local service=$1  

  echo "What component do you want to deploy?"
  echo "s) Server"
  echo "c) Command Consumer"
  echo "w) Web"

  read -k 1 -s option

  case $option in
      s)
          get_environment "$service/server"
          ;;
      c)
          get_environment "$service/command-consumer"
          ;;
      w)
          get_environment "$service/web"
          ;;
      *)
          echo "Invalid option"
          ;;
  esac
}

get_environment() {
    local service_and_component=$1  

    echo "What environment do you want to deploy?"
    echo "s) Staging"
    echo "p) Prod"

    read -k 1 -s option

    case $option in
        s)
            echo "psg app $service_and_component/staging deploy"
            ;;
        p)
            echo "psg app $service_and_component/prod deploy"
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

