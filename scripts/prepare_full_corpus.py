#!/usr/bin/env python3

import sys

WIDE_DOT = '。_。_。_特殊_句点_*_*'

REPLACES = [
    '._._._特殊_句点_*_*', ',_,_,_特殊_読点_*_*', '!_!_!_特殊_記号_*_*', '?_?_?_特殊_記号_*_*',
    '。_。_。_特殊_句点_*_*', '、_、_、_特殊_読点_*_*', '，_，_，_特殊_読点_*_*', '・_・_・_特殊_記号_*_*',
    '…_…_…_特殊_記号_*_*', '．_．_．_特殊_句点_*_*', '･_･_･_特殊_記号_*_*', '？_？_？_特殊_記号_*_*',
    '！_！_！_特殊_記号_*_*'
]  #comment here to stop formatting

FULL2HALF = dict((i + 0xFEE0, i) for i in range(0x21, 0x7F))
FULL2HALF[0x3000] = 0x20

FULL_LOW = 0xFEE0 + 0x21
FULL_HI = 0xFEE0 + 0x7F


def is_full_alpha(word):
    for c in word:
        cord = ord(c)
        if cord < FULL_LOW or cord >= FULL_HI:
            return False
    return True


def halfen(s):
    '''
    Convert full-width characters to ASCII counterpart
    '''
    return str(s).translate(FULL2HALF)

def convert_full_alpha_words(data, number):
    if number % 2 == 0:
        return data

    words = data.split(' ')
    res = []
    for w in words:
        idx = w.find('_')
        surf = w[:idx]
        if is_full_alpha(surf):
            parts = w.split('_')
            res.append("_".join(
                [halfen(parts[0]),
                 halfen(parts[1]),
                 halfen(parts[2])] + parts[3:]))
        else:
            res.append(w)
    return ' '.join(res)


def process(line, comment, number):
    idx = line.rfind(' ')
    if idx == -1:
        print(convert_full_alpha_words(line, number), comment)
        return
    last_word = line[idx + 1:]

    if (last_word != WIDE_DOT):
        print(convert_full_alpha_words(line, number), comment)
        return

    start = line[:idx]

    if number % 2 == 0:
        print(convert_full_alpha_words(start, number), comment)
    else:
        repl_idx = number % len(REPLACES)
        print(convert_full_alpha_words(start, number), REPLACES[repl_idx], comment)

def process_file(fname):
    with open(fname, 'rt', encoding='utf-8') as inf:
        for lineno, line in enumerate(inf):
            line = line.strip()
            commidx = line.find(' #')
            comment = ''
            if commidx != -1:
                comment = line[commidx + 1:]
                line = line[:commidx]

            process(line.strip(), comment, lineno)


def main():
    for fname in sys.argv[1:]:
        process_file(fname)


if __name__ == '__main__':
    main()