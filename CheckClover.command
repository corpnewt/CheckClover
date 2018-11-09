#!/usr/bin/env python
import os, time, sys

def cls():
	os.system('cls' if os.name=='nt' else 'clear')

def grab(prompt):
	if sys.version_info >= (3, 0):
		return input(prompt)
	else:
		return str(raw_input(prompt))

def check_path(path):
    # Loop until we either get a working path - or no changes
    count = 0
    while count < 100:
        count += 1
        if not len(path):
            # We uh.. stripped out everything - bail
            return None
        if os.path.exists(path):
            # Exists!
            return os.path.abspath(path)
        # Check quotes first
        if (path[0] == '"' and path[-1] == '"') or (path[0] == "'" and path[-1] == "'"):
            path = path[1:-1]
            continue
        # Check for tilde
        if path[0] == "~":
            test_path = os.path.expanduser(path)
            if test_path != path:
                # We got a change
                path = test_path
                continue
        # If we have no spaces to trim - bail
        if not (path[0] == " " or path[0] == "  ") and not(path[-1] == " " or path[-1] == " "):
            return None
        # Here we try stripping spaces/tabs
        test_path = path
        t_count = 0
        while t_count < 100:
            t_count += 1
            t_path = test_path
            while len(t_path):
                if os.path.exists(t_path):
                    return os.path.abspath(t_path)
                if t_path[-1] == " " or t_path[-1] == "    ":
                    t_path = t_path[:-1]
                    continue
                break
            if test_path[0] == " " or test_path[0] == " ":
                test_path = test_path[1:]
                continue
            break
        # Escapes!
        test_path = "\\".join([x.replace("\\", "") for x in path.split("\\\\")])
        if test_path != path and not (path[0] == " " or path[0] == "  "):
            path = test_path
            continue
        if path[0] == " " or path[0] == "  ":
            path = path[1:]
    return None


# Default to local file - in case we're in unknown territory
checking = "l"

if not os.name == "nt":
    while True:
        cls()
        menu = grab("Check EFI or local file? (E/L):  ")
        if menu.lower() == "e":
            checking = "e"
            break
        if menu.lower() == "l":
            checking = "l"
            break
        continue

if checking == "e":
    print("Checking for mounted EFI...")
    try:
        volume_list = os.listdir("/Volumes/")
    except:
        print("   Error listing /Volumes/!")
        exit(1)
    efi_list = [x for x in volume_list if x.lower() in ["efi", "esp"]]
    if len(efi_list) == 0:
        print("   EFI not mounted!  Aborting!")
        exit(1)
    if len(efi_list) > 1:
        print("   Multiple EFI/ESP partitions detected!  Aborting!")
        exit(1)
    # Only got one!
    efi = "/Volumes/" + efi_list[0]
    print("   Found ESP at \"{}\"".format(efi))
    print("Verifying structure...")
    c = os.path.join(efi, "EFI/CLOVER/CLOVERX64.efi")
    b = os.path.join(efi, "EFI/BOOT/BOOTX64.efi")
    if not os.path.exists(c):
        if not os.path.exists(b):
            print("   CLOVERX64.efi and BOOTX64.efi not found on EFI!  Aborting!")
            exit(1)
        # Guess we're just getting the BOOTX64.efi
        c = b
else:
    # Getting local file - must be named CLOVERX64.efi or BOOTX64.efi
    while True:
        cls()
        menu = grab("Please drag and drop a CLOVERX64.efi or BOOTX64.efi file:  ")
        path = check_path(menu)
        if path and (os.path.basename(path).lower() in [ "cloverx64.efi", "bootx64.efi" ]):
            # Got it!
            c = path
            break
        print("Either that file doesn't exist - or it's not named CLOVERX64.efi or BOOTX64.efi - try again.")
        time.sleep(3)

# Hex for "Clover revision: "
vers_hex = "Clover revision: ".encode("utf-8")
vers_add = len(vers_hex)
with open(c, "rb") as f:
    s = f.read()
location = s.find(vers_hex)
if location == -1:
    print("Not found!")
print("Found \"{}\" at {}".format(vers_hex.decode("utf-8"), location))
location += vers_add
version = ""
while True:
    try:
        vnum = s[location:location+1].decode("utf-8")
        numtest = int(vnum)
        version += vnum
    except:
        # print("Hit non-number character - breaking...")
        break
    location += 1
if not len(version):
    print("Didn't find a version number!")
    exit(1)
print("\n{}".format("#"*70))
print("Found Clover version {}".format(version).center(70))
print("{}\n\n".format("#"*70))
exit()
