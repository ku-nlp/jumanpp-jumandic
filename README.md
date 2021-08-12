# Descritption

This repository contains a set of scripts to build a ready-to-use
Juman++ model for Jumandic.

## Prerequrements

* Unix environment (on Windows use [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) or [MSYS2/MinGW64](https://www.msys2.org/))
* Juman++ build environment
* Python 3.6+
* Ruby
* Perl
* Configured ssh authorization for github (we will clone several repositories via ssh)
* 32 GB of RAM

### Recommended

* Original texts from Mainichi Shinbun (year 1995) for [Kyoto Corpus](https://github.com/ku-nlp/KyotoCorpus)
(see the page for more information).
Othewise, Juman++ model will be trained only on Leads corpus and will have poor quality.

# How to Use

Run the configuration script: `python3 configure.py`.
It will prompt for the location of Mainichi Shinbun texts.

After that run `make nornn` for training a model without RNN component.
`make rnn` produces the model with RNN component.
The models will be inside the `bld/model` folder.