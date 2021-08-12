JUMANPP_CXX_FLAGS ?= -march=core2

$(JPP_BOOTSTRAP_BIN) $(JPP_TRAIN_BIN) $(JPP_TEST_BIN) : $(JUMANPP_ROOT)/.git/HEAD
	mkdir -p $(JUMANPP_BIN_DIR)
	cd $(JUMANPP_BIN_DIR) && \
		cmake \
			-DCMAKE_BUILD_TYPE=Release \
			-DCMAKE_CXX_FLAGS='$(JUMANPP_CXX_FLAGS)' \
			$(abspath $(JUMANPP_ROOT)) \
		&& \
		cmake --build . -- -j