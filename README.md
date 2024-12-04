# Color Show

A Zig project for displaying colors using the Kitty graphics protocol.

## Overview

Color Show is a Zig utility that renders solid-color rectangles directly in the terminal using the Kitty graphics protocol. Simply pass hexadecimal color codes as command-line arguments to display vibrant color blocks.

## Features

- Render solid-color rectangles in the terminal
- Uses Kitty graphics protocol for rendering
- Supports any 6-digit hexadecimal color code
- Simple and efficient command-line interface

## Prerequisites

- Zig compiler (version 0.11.0 or later recommended)
- Kitty terminal emulator

## Building the Project

Build the project using Zig's built-in build system:

```bash
# Default build (debug mode)
zig build

# Release build with optimizations
zig build -Doptimize=ReleaseFast

# Different optimization levels
zig build -Doptimize=Debug        # No optimizations, full debug info
zig build -Doptimize=ReleaseSafe  # Optimized with runtime safety checks
zig build -Doptimize=ReleaseFast  # Fastest performance optimizations
zig build -Doptimize=ReleaseSmall # Optimized for minimal binary size
```

## Running the Application

After building, run the application:

```bash
# Run with color codes
zig-out/bin/color-show FF0000 00FF00 0000FF
```

This will display:

- A red rectangle
- A green rectangle
- A blue rectangle

### Input Constraints

- Each color must be a 6-digit hexadecimal color code
- Supports full RGB color range (000000 to FFFFFF)

## Example Usage

```bash
# Display a vibrant orange rectangle
zig-out/bin/color-show FF6600
```

## How It Works

1. Parses hexadecimal color codes from command-line arguments
2. Converts hex codes to RGB values
3. Generates a color matrix
4. Encodes the matrix using Base64
5. Renders the color using Kitty's graphics protocol escape sequences

## Dependencies

- Standard Zig library
- Kitty terminal graphics protocol support

## Error Handling

The program validates:

- Hex color codes are exactly 6 characters
- All characters are valid hexadecimal digits

## Contributing

Contributions are welcome! Please submit a Pull Request or open an Issue.
