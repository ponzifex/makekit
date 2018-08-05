## MakeKit CLI

The MakeKit CLI (Command Line Interface) `mk` provides the following commands:

#### `mk clean [<CONFIG>] [-C] [-M]`

Removes the directory (including the configuration and the built binaries) of the build configuration specified by `BUILD_TYPE`.

If `<CONFIG>` is not specified, the command removes the build directory of *ALL* build configurations.

#### `mk commands [<CONFIG>] [-X <TARGETS>]`

Lists the actual commands which are used to build the specified configuration `<CONFIG>`. `<TARGETS>` is a string with the list of exclusive targets.

If `<CONFIG>` is not specified, it defaults to `Release`.

#### `mk config [<CONFIG>] [-T <TOOLCHAIN>]`

Creates a build system configuration for the specified `<CONFIG>`. If it has been already created, then this command will refresh it. This command is also required when files has been added or removed from the source.

If `<CONFIG>` is not specified, it defaults to `Release`.

#### `mk deps [<CONFIG>]`

Lists the dependencies of `<CONFIG>` build, which are available only after a successful `make` command.

If `<CONFIG>` is not specified, it defaults to `Release`.

#### `mk help`

Outputs the list of available commands and their basic descriptions.

#### `mk host`

Outputs the [*target triple*](https://clang.llvm.org/docs/CrossCompilation.html#target-triple) of the host machine.

#### `mk make [<CONFIG>] [-X <TARGETS | TARGET^>] [-C [-T <TOOLCHAIN>]] `

Creates or refreshes the build configuration specified by `<CONFIG>` and executes it, i.e. it starts the build process.

The compiler/linker output can be very verbose when it encounters a lot of warnings and/or errors, which could overflow the buffer of your command line terminal - in this case you start to lose your oldest output lines to favor newer ones. To avoid this, you can redirect the command line output to a file (say `log.txt`) whose size is limited only by the data drive. This can be done by using the redirection operator `>>` as simply as `mk make <CONFIG> >> log.txt`, which will overwrite the file every time you issue the command - if you just want to append to it use `>` instead of `>>`.

If `BUILD_TYPE` is not specified, it defaults to `Release`.

#### `mk reconfig [<CONFIG>] [-T <TOOLCHAIN>]`

Removes the build configuration of the specified `CONFIG` and re-creates it from scratch. The built binaries remain untouched. This command is recommended if `CMakeLists.txt` has been changed.

If `<CONFIG>` is not specified, it defaults to `Release`.

#### `mk refresh [<CONFIG>]`

Refreshes an existing build configuration `<CONFIG>`.
This command is useful for refreshing the build configuration if the source tree has been changed by adding or removing files.

If `<CONFIG>` is not specified, it defaults to `Release`.

#### `mk remake [<CONFIG>] [-X <TARGET[^]>] [-C [-T <TOOLCHAIN>]]`

Removes all prebuilt binaries of the build configuration specified by `<CONFIG>` and rebuilds them.

If `<CONFIG>` is not specified, it defaults to `Release`.

#### `mk version`

Outputs the version of the `mk` CLI (command line interface).

## Build configurations

All default CMake `BUILD_TYPE`s are available:

| BUILD_TYPE     | Description                                       | clang flags       | clang-cl flags                     |
|:---------------|:--------------------------------------------------|:------------------|:-----------------------------------|
| None           |                                                   |                   | `/DWIN32 /D_WINDOWS /W3 /GR /EHsc` |
| Debug          | Debug build, no optimization                      | `-g`              | `/MDd /Zi /Ob0 /Od /RTC1`          |
| Release        | Release build, full optimization                  | `-O3 -DNDEBUG`    | `/MD /O2 /Ob2 /DNDEBUG`            |
| RelWithDebInfo | Release build, optimization with debug symbols    | `-O2 -g -DNDEBUG` | `/MD /Zi /O2 /Ob1 /DNDEBUG`        |
| MinSizeRel     | Release build, optimization for small binary size | `-Os -DNDEBUG`    | `/MD /O1 /Ob1 /DNDEBUG`            |

Custom build types are also available and can be configured in `CustomBuilds.cmake`.