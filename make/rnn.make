RNN_MODEL_NAME := 10m-unk.basep-96-40m-b5-retrain
RNN_MODEL_URL := https://github.com/ku-nlp/jumanpp-jumandic/releases/download/2020.08.12/10m-unk.basep-96-40m-b5-retrain.tar.bz2

RNN_MODEL_DIR = $(BUILD_ROOT)/rnn

RNN_MODEL_PATH := $(RNN_MODEL_DIR)/$(RNN_MODEL_NAME)

$(RNN_MODEL_PATH) :
	mkdir -p $(RNN_MODEL_DIR)
	curl --location $(RNN_MODEL_URL) -o $(RNN_MODEL_PATH).tar.bz2
	cd $(RNN_MODEL_DIR) && tar xjvf $(RNN_MODEL_NAME).tar.bz2

$(RNN_MODEL) : $(NORNN_MODEL) $(RNN_MODEL_PATH)
	$(JPP_TRAIN_BIN) \
		--model-input $(NORNN_MODEL) \
		--model-output $(RNN_MODEL) \
		--rnn-model $(RNN_MODEL_PATH) \
		--rnn-fields=baseform,pos \
		--feature-weight-perceptron=1 \
		--feature-weight-rnn=0.0176 \
		--rnn-nce-bias=5.62844432562 \
		--rnn-unk-constant=-3.4748115191 \
		--rnn-unk-length=-2.92994951022

rnn: $(RNN_MODEL)