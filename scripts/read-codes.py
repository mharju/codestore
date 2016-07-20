#!/usr/bin/env python

import sys
import argparse
import tty
import termios

def getch():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    return ch


def read_number(total=4, current='', counter=1):
    try:
        m = getch()
        sys.stdout.write(m)

        if m == '\x7f':
            if counter == 1:
                sys.stdout.write("\033[1D")
                return read_number(total, current, counter)

            sys.stdout.write("\033[2D \033[1D")
            return read_number(total, current[:-1], counter-1)
        elif m == '\x03':
            sys.stdout.write("\n\033[0;31mAborted.\033[39;49m\n")
            sys.exit(-1)

        int(m)

        current += m

        if counter < total:
            return read_number(total, current, counter + 1)
        elif counter == total:
            return current
    except ValueError:
        sys.stdout.write("\033[1D \033[1D")
        return read_number(total, current, counter)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('start', metavar='S', type=int, nargs='?', default=1, help='Start value for the counter')
    parser.add_argument('end', metavar='E', type=int, nargs='?', default=301, help='End value for the counter')
    parser.add_argument('-a', '--append', action='store_true', dest='append', help='Store in append mode')
    parser.add_argument('-o', '--output', dest='output_file', default='numbers.txt', help="Store the numbers to the given file")
    args = parser.parse_args()

    f = open(args.output_file,'a' if args.append else 'w')
    for i in range(args.start, args.end):
        sys.stdout.write("\033[0;37m%04d:\033[39;49m " % (i,))
        n = read_number(4)

        sys.stdout.write("\n")
        f.write(n + "\n")

        if i % 5 == 0:
            sys.stdout.write("\n")
