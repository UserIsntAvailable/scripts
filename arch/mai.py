#!/usr/bin/python3

# Minimal Arch Installation
#
# This is my custom installation script of Arch Linux. I will recommend reading
# the commands that I'm using before using it, because I hard coded some values
# that you might not need/use. (TODO tags are mostly things that you might need
# to change)

import getpass
import re
import sys
from subprocess import call
from subprocess import check_output
from subprocess import STDOUT as S_STDOUT
from typing import NewType
from typing import Optional

# ----------------------------------- Types -----------------------------------

Err = NewType('Err', str)

# ----------------------------- Utility Functions -----------------------------

def check(args: Iterable[str]) -> bytes:
    return subprocess.check_output(args, stderr=S_STDOUT)

# TODO: Add error handling later. ( I don't know if there is a builtin way of 
# doing this on python. )
def select(choices: list[str]) -> str:
    for i, choice in enumerate(choices):
        print(f"{i}) {choice}")

    return input("?# ")

IWCTL_SEPARATOR = " "
NO_AVAILABLE_PATTERN = re.compile("^No (.+) Available")

def parse_iwctl_output(
    output: bytes,
    columns: int
) -> list[str] | Err:
    output_lines=output.decode()
    output_lines=output_lines[4:-1] # The 4 first lines and last of iwctl are useless.

    if (match:=NO_AVAILABLE_PATTERN.match(outputLines[0])):
        return Err(f"No iwctl {match.group(1)} were found.")

    # Only keep values from the first column. Since the first column can have
    # spaces and the iwctl column separator is also spaces ( WHY? ), I need to
    # substract the values from the others columns.

    return [
        IWCTL_SEPARATOR.join(split[:len(split) - columns - 1]) for split in
        [line.split(IWCTL_SEPARATOR) for line in output_lines]
    ]

# ----------------------------- Section Functions -----------------------------

def iwctl() -> Optional[Err]:
    IWCTL="iwctl"

    match parse_iwctl_output(check((IWCTL, "device", "list")), 5):
        case [*devices]:
            match devices:
                case [dev]:
                    device=dev
                    print(f"Using {dev} as default iwctl device.\n")
                case _:
                    print("Select what network device you want to use?")
                    device = select(devices)
        case Err() as err:
            return err

    call(IWCTL, "station", device, "scan")

    networks_output=check((IWCTL, "station", device, "get-networks", "rssi-dbms"))
    match parse_iwctl_output(networks_output, 3):
        case [*networks]:
            print("Select what network you want to use?")
            ssid=select(networks)
        case Err() as err:
            return err

    passphrase=getpass.getpass("Network passwork: ")

    call(IWCTL, "--passphrase", passphrase, "station", device, "connect", ssid)

    sleep(3)
    call("ping", "-c", "4", "archlinux.org")

# ------------------------------------ Main -----------------------------------

def main(argc: int, argv: list[str]) -> int:
    sections = [
        iwctl
    ]

    # TODO: Print each section name?
    for section in sections:
        if (error:=section()) is not None:
            print(error, file=sys.stderr)
            return -1

    print("Done. You can now reboot.")

    return 0

if __name__ == "__main__":
    argv = sys.argv
    exit(main(len(argv), argv))
