$(KYOTO_CORPUS_ROOT)/.git/HEAD :
	mkdir -p $(REPO_ROOT)
	git clone git@github.com:ku-nlp/KyotoCorpus.git --depth 1 $(KYOTO_CORPUS_ROOT)
	$(SHELL) $(KYOTO_CORPUS_ROOT)/auto_conv -d $(KYOTO_CORPUS_SRC)

$(KYOTO_KNP_TRAIN) : $(KYOTO_CORPUS_ROOT)/.git/HEAD
	PYTHONUTF8=1 python3 $(KYOTO_FILTER_SCRIPT) \
		--input $(KYOTO_CORPUS_ROOT)/knp \
		--id $(KYOTO_CORPUS_ROOT)/id/train.id \
		--output $(KYOTO_KNP_TRAIN)

$(KYOTO_KNP_TEST) : $(KYOTO_CORPUS_ROOT)/.git/HEAD
	PYTHONUTF8=1 python3 $(KYOTO_FILTER_SCRIPT) \
		--input $(KYOTO_CORPUS_ROOT)/knp \
		--id $(KYOTO_CORPUS_ROOT)/id/test.id \
		--output $(KYOTO_KNP_TEST)

$(KYOTO_VERSION): $(KYOTO_CORPUS_ROOT)/.git/HEAD
	git -C $(KYOTO_CORPUS_ROOT) log \
		--oneline --date=format:%Y%m%d --format=K:%ad-%h --max-count=1 HEAD > $(abspath $(KYOTO_VERSION))