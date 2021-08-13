#!/usr/bin/env python3

import argparse
from pathlib import Path
import shlex

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument('--kyoto-corpus', help="Path to Mainichi Shinbun data or URL to Full Kyoto Corpus Repository")
    p.add_argument('--rnn-model', type=Path, help="Path to RNN Model file. Will download the model from internet if left empty.")
    p.add_argument('--build-dir', default=Path(__file__).parent / "bld", type=Path, help='Path to build directory (optional)')
    p.add_argument('--partial-data-url', help='URL to download partially annotated data')
    return p.parse_args()

def guess_kyoto_corpus_mode(corpus):
    if len(corpus) == 0:
        print("Kyoto Corpus will be disabled!")
        return "none"
    elif corpus.startswith("https://") or corpus.startswith("git@"):
        print("Full Kyoto Corpus will be cloned from git repo:", corpus)
        return "url"
    else:
        print(f"Contents of {corpus} will be treated as raw Kyoto Corpus files (Mainichi Shinbun 1995 Year)")
        return "path"

def process(args, outf):
    outf.write("# This file is automatically generated by configure.py\n\n")
    kyoto_corpus = args.kyoto_corpus
    if kyoto_corpus is None:
        kyoto_corpus = input("Specify URL of Full Kyoto Corpus or path to Original Texts (Mainichi Shinbun):\n")
    kyoto_corpus_mode = guess_kyoto_corpus_mode(kyoto_corpus)
    outf.write("# Kyoto Corpus\n")
    outf.write(f"KYOTO_CORPUS_MODE ?= {kyoto_corpus_mode}\n")
    outf.write(f"KYOTO_CORPUS_SRC ?= {kyoto_corpus}\n")
    purl = args.partial_data_url
    if purl is None:  # UPDATE ME SEMI-REGULARY
        purl = "https://github.com/ku-nlp/jumanpp-jumandic/releases/download/2020.08.12/partial.jpp2part"
    outf.write(f"PARTIAL_ANNOTATED_URL ?= {shlex.quote(purl)}\n")

def main(args):
    args.build_dir.mkdir(parents=True, exist_ok=True)
    cfg_tmp = args.build_dir / "conf.make.tmp"
    with cfg_tmp.open('wt', encoding='utf-8') as outf:
        process(args, outf)
    cfg_correct = args.build_dir / "config.make"
    if cfg_correct.exists():
        cfg_correct.unlink()
    cfg_tmp.rename(cfg_correct)

if __name__ == "__main__":
    main(parse_args())