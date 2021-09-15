
MODEL_DIR = $(abspath $(BUILD_ROOT)/models)
BIN_DICTIONARY = $(MODEL_DIR)/jumandic.bin

JPP_JUMANDIC_RAW = $(JUMANDIC_ROOT)/jumanpp_dic/jumanpp.dic
JPP_JUMANDIC_VERSION = $(JUMANDIC_ROOT)/jumanpp_dic/version

# dictionary

$(JPP_JUMANDIC_RAW) $(JPP_JUMANDIC_VERSION) : $(JUMANDIC_ROOT)/.git/HEAD
	$(MAKE) -C $(JUMANDIC_ROOT) jumanpp

dic : $(JPP_JUMANDIC_RAW)

clean-dic:
	rm -f $(BIN_DICTIONARY) $(JPP_JUMANDIC_RAW)

# training

$(BIN_DICTIONARY) : $(JPP_JUMANDIC_RAW) $(JPP_BOOTSTRAP_BIN)
	mkdir -p $(MODEL_DIR)
	$(JPP_BOOTSTRAP_BIN) \
		--dic-version=$(shell cat $(JPP_JUMANDIC_VERSION)) \
		$(JPP_JUMANDIC_RAW) $(BIN_DICTIONARY)
	touch $(BIN_DICTIONARY)

ifeq ($(TRAIN_MODE),NOTEST)
MODEL_NAME=jumandic-notest
TRAIN_CORPUS=$(TRAIN_FULL_ALL)
else
MODEL_NAME=jumandic
TRAIN_CORPUS=$(MODEL_TRAIN_CORPUS)
endif

NORNN_MODEL = $(MODEL_DIR)/$(MODEL_NAME)-nornn.model
RNN_MODEL = $(MODEL_DIR)/$(MODEL_NAME)-rnn.model

NEPOCHS ?= 12
NITERS ?= 5
MODEL_SIZE ?= 22
SCW_PHI ?= 0.36
SCW_C ?= 0.1465

$(NORNN_MODEL) : $(BIN_DICTIONARY) $(JPP_TRAIN_BIN) $(PARTIAL_TRAIN) $(TRAIN_CORPUS) $(CORPUS_VERSIONS)
	nice -n19 $(JPP_TRAIN_BIN) \
		--corpus $(TRAIN_CORPUS) \
		--partial-corpus $(PARTIAL_TRAIN) \
		--corpus-comment '$(shell cat $(CORPUS_VERSIONS))' \
		--model-input $(BIN_DICTIONARY) \
		--model-output $(NORNN_MODEL) \
		--size $(MODEL_SIZE) \
		--threads $$(( $(CORES) - 1 )) \
		--batch 150000 \
		--max-batch-iters $(NITERS) \
		--max-epochs $(NEPOCHS) \
		--epsilon 1e-7 \
		--scw-c $(SCW_C) \
		--scw-phi $(SCW_PHI) \
		--training-mode=full \
		--beam=5 \
		--gb-left-max=4 --gb-left-min=4 \
		--gb-rcheck-min=1 --gb-rcheck-max=1 \
		--gb-right-min=4 --gb-right-max=4 \
		--gb-first-full

nornn: $(NORNN_MODEL)