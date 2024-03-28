terraform {
  required_version = ">= 1.0.0"
  required_providers {
    genesyscloud = {
      source  = "mypurecloud/genesyscloud",
      version = ">= 1.6.0"
    }
  }
}

provider "genesyscloud" {
  oauthclient_id = "ec17cd8a-8e7a-42eb-a418-646e21d0ef7f"
  oauthclient_secret = "k59X0ldPqmKiusBNJqVteoP3KuKo3QkbqmQ_l2vhw9w"
  aws_region = "us-west-2"
}

resource "genesyscloud_flow" "open_messaging" {
  filepath          = "./flow.yaml"
  file_content_hash = filesha256("./flow.yaml")
  // Example flow configuration using substitutions:
  /*
  inboundCall:
    name: "{{flow_name}}"
    defaultLanguage: "{{default_language}}"
    startUpRef: ./menus/menu[mainMenu]
    initialGreeting:
      tts: "{{greeting}}"
    menus:
      - menu:
          name: Main Menu
          audio:
            tts: You are at the Main Menu, press 9 to disconnect.
          refId: mainMenu
          choices:
            - menuDisconnect:
                name: "{{menu_disconnect_name}}"
                dtmf: digit_9
  */
  // see https://developer.genesys.cloud/devapps/archy/flowAuthoring/lesson_07_substitutions
  // these replace the key-value pairs from the --optionsFile when using the archy CLI
  # substitutions = {
  #   flow_name            = "An example flow"
  #   default_language     = "en-us"
  #   greeting             = "Hello World"
  #   menu_disconnect_name = "Disconnect"
  # }
}

resource "genesyscloud_architect_ivr" "mysimple_ivr" {
  name               = "A simple IVR"
  description        = "A sample IVR configuration"
  dnis               = ["+13129718321", "+13129718321"]  # This needs to be changed
  # open_hours_flow_id = data.genesyscloud_flow.open_messaging.id
  depends_on         = [
    genesyscloud_flow.open_messaging,
  ]
}