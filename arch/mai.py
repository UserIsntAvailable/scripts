#!/usr/bin/python3

# Mininal Arch Installation
#
# This is my custom installation script of Arch Linux. I will recommend reading
# the commands that Im using before using it, because I hard coded some values
# that you might not need/use. (todo tags are mostly things that you might
# need to change)

import sys


def main(argc: int argv: list[str]) -> int:
    return 0


if __name__ == "__main__":
    argv = sys.argv
    exit(main(len(argv), argv))
