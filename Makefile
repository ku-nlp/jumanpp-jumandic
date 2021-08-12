mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir $(mkfile_path))

# It is possible to override this
BUILD_ROOT ?= $(abspath $(current_dir)/bld)

# User-provided configuration
ifneq (,$(wildcard $(BUILD_ROOT)/config.make))
include $(wildcard $(BUILD_ROOT)/config.make)
endif

ifneq (,$(wildcard $(current_dir)/config.make))
include $(wildcard $(current_dir)/config.make)
endif

# Default configuration

MODE ?= NORMAL
REPO_ROOT ?= $(abspath $(BUILD_ROOT)/repos)

JUMANPP_BIN_DIR ?= $(BUILD_ROOT)/jpp
CORPORA_DIR ?= $(BUILD_ROOT)/corpora
EVAL_DIR ?= $(BUILD_ROOT)/eval

SCRIPT_DIR := $(abspath $(current_dir)/scripts)
KYOTO_FILTER_SCRIPT := $(SCRIPT_DIR)/filter_kyoto.py
JPP_BOOTSTRAP_BIN ?= $(JUMANPP_BIN_DIR)/src/jumandic/jpp_jumandic_bootstrap
JPP_TRAIN_BIN ?= $(JUMANPP_BIN_DIR)/src/jumandic/jumanpp_v2_train
JPP_TEST_BIN ?= $(JUMANPP_BIN_DIR)/src/jumandic/jumanpp_v2

LC_ALL=en_US.UTF-8
LOCALE=en_US.UTF-8

SHELL=zsh
CORES=$(shell grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu || echo "$$NUMBER_OF_PROCESSORS")

include make/repos.make
include make/corpora.make

# Using full Kyoto Corpus
ifeq (url,$(KYOTO_CORPUS_MODE))
include make/kyoto.url.make
endif

# Restoring full Kyoto Corpus from annotations and Mainichi Shinbun
ifeq (path,$(KYOTO_CORPUS_MODE))
include make/kyoto.path.make
endif

include make/jumanpp.make
include make/train.make
include make/rnn.make