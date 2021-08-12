#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# This script filters entries from Kyoto Corups by part of IDs

import sys
import argparse
import pathlib

class Extractor(object):
    def __init__(self, args) -> None:
        super().__init__()
        self.ids = set(Extractor._collect_ids(args.id_root, args.ids))
        self.ext = args.ext
        self.collected = set()

    @staticmethod
    def _collect_ids_from_file(path):
        with path.open('rt', encoding='utf-8') as inf:
            return [l.rstrip() for l in inf]

    @staticmethod
    def _collect_ids(root, globs):
        result = []
        for pat in globs:
            ppat = pathlib.Path(pat)
            if ppat.is_absolute():
                ids = Extractor._collect_ids_from_file(ppat)
                result.extend(ids)
            else:
                for p in root.glob(pat):
                    if p.is_file():
                        result.extend(Extractor._collect_ids_from_file(p))
        return result

    def filter_file(self, inf, outf):
        writing = False
        collected = self.collected
        for line in inf:
            if writing and line == "EOS\n":
                outf.write(line)
                writing = False
            elif line.startswith('# S-ID:'):
                hyph = line.find('-', 7)
                if hyph is not None:
                    sid = line[7:hyph]
                    if sid in self.ids:
                        space = line.find(' ', hyph)
                        full_id = line[7:space]
                        if full_id in collected:
                            continue
                        collected.add(full_id)
                        writing = True
                        outf.write(line)

            elif writing:
                outf.write(line)

    def filter_tree(self, root, outf):
        for child in root.iterdir():
            if child.is_file() and child.name.endswith(self.ext):
                with child.open('rt', encoding='utf-8') as inf:
                    self.filter_file(inf, outf)
            elif child.is_dir():
                self.filter_tree(child, outf)


def main():
    oparser = argparse.ArgumentParser()
    oparser.add_argument("--input", dest="input", default="-")
    oparser.add_argument("--output", dest="output", default=None, required=True)
    oparser.add_argument("--id", action="append", dest='ids')
    oparser.add_argument("--id-root", type=pathlib.Path, default=pathlib.Path.cwd())
    oparser.add_argument("--ext", dest="ext", default=".knp")
    opts = oparser.parse_args()

    extrator = Extractor(opts)
    if len(extrator.ids) == 0:
        print("No ids to extract", file=sys.stderr)
        exit(1)

    if opts.output == '-':
        outf = sys.stdout
    else:
        outpath = pathlib.Path(opts.output)
        outpath.parent.mkdir(parents=True, exist_ok=True)
        outf = outpath.open("wt", encoding='utf-8')

    try:
        if opts.input == "-":
            extrator.filter_file(sys.stdin, outf)
        else:
            extrator.filter_tree(pathlib.Path(opts.input), outf)
    finally:
        outf.close()

if __name__ == '__main__':
    main()
