# Ubuntu Setup

## Getting Started

1. Clone this repository
    ```sh
    git clone https://github.com/xontab/ubuntu-dev-machine.git
    cd ubuntu-dev-machine
    ```

## Development Setup

1. Open `Terminal` application.

1. Run the following commands:
    ```sh
    bash scripts/dev.sh
    ```

## Windows-like UI

### Fonts
1. Open the following fonts and click on `Install`.
    * [fonts/SFUIDisplay-Regular.otf](./fonts/SFUIDisplay-Regular.otf)
    * [fonts/FiraCodeNerdFont-Retina.ttf](./fonts/FiraCodeNerdFont-Retina.ttf)

1. Run the following commands:
    ```sh
    sudo apt update
    sudo apt install gnome-tweaks -y
    gnome-tweaks
    ```

1. Click on `Fonts`.

1. Configure the following:
    * Interface Text: `SF UI Display Normal` Size `11`
    * Document Text: `SF UI Display Normal` Size `11`
    * Monospace Text: `FiraCode Nerd Font Retina` Size `12`
    * Legacy Window Titles: `SF UI Display Normal` Size `10`

### Extensions

1.  Run the following commands:
    ```sh
    sudo apt update
    sudo apt install gnome-shell-extension-manager -y
    extension-manager
    ```

1. Click on `Browse` and `Install` the following extensions.
    *  ArcMenu (Tip use search keyword `ArcMenu` and sort by `Downloads`)
    *  Dash to Panel (Tip use search keyword `Panel` and sort by `Downloads`)

### ArcMenu

1. Go to the `Installed` tab and click on ⚙️ to configure `ArcMenu`.

1. Switch to `About` tab.

1. Click on `Load` and choose [extensions/ArcMenu](./extensions/ArcMenu) configuration file.

### Dash to Panel

1. Go to the `Installed` tab and click on ⚙️ to configure `Dash to Panel`.

1. Switch to `About` tab.

1. Click on `Import from file` and choose [extensions/DashtoPanel](./extensions/DashtoPanel) configuration file.

