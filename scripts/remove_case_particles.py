#!/usr/bin/env python3

import sys

candidates = set(['は_は_は_助詞_副助詞_*_*', 'が_が_が_助詞_格助詞_*_*', 'を_を_を_助詞_格助詞_*_*'])


def main():
    infile = sys.argv[1]
    with open(infile) as inf:
        for lineno, line in enumerate(inf):
            line = line.strip()
            commidx = line.find(' #')
            comment = ''
            if commidx != -1:
                comment = line[commidx + 1:]
                line = line[:commidx]
            parts = line.split(' ')

            result = []

            removed = False
            for p in parts:
                if p not in candidates:
                    result.append(p)
                else:
                    removed = True

            if removed:
                print(' '.join(result), f'{comment}-removed-{lineno}')




if __name__ == '__main__':
    main()