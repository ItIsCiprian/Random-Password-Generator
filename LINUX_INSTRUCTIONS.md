# Building and Running the Linux Application

This document provides instructions on how to build and run the Linux version of the Random Password Generator application.

## Prerequisites

Before you begin, ensure you have the following dependencies installed:

*   **Flutter SDK:** Make sure you have the Flutter SDK installed and configured correctly.
*   **C++ Compiler and Build Tools:** The application requires a C++ compiler and specific build tools.

### Installation on Debian/Ubuntu

```bash
sudo apt update
sudo apt install cmake ninja-build clang
```

### Installation on Arch Linux

```bash
sudo pacman -Syu
sudo pacman -S cmake ninja clang
```

## Building the Application

1.  Navigate to the `password_generator_app` directory:

    ```bash
    cd password_generator_app
    ```

2.  Build the Linux application:

    ```bash
    flutter build linux
    ```

    This command will create an executable file in the `build/linux/x64/release/bundle/` directory.

## Running the Application

You can run the application from the root of the project directory with the following command:

```bash
./password_generator_app/build/linux/x64/release/bundle/password_generator_app
```
