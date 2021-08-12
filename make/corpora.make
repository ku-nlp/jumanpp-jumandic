$(CORPORA_DIR):
	mkdir -p $(CORPORA_DIR)


# Leads corpus

LEADS_TRAIN=$(CORPORA_DIR)/train.leads.fmrp
LEADS_TEST=$(CORPORA_DIR)/test.leads.fmrp
LEADS_TEST_MRP=$(CORPORA_DIR)/test.leads.mrp
LEADS_TEST_IDRAW=$(CORPORA_DIR)/test.leads.idraw
LEADS_TEST_AUTO=$(EVAL_DIR)/test.leads.auto.mrp
LEADS_TEST_ACC=$(EVAL_DIR)/test.leads.auto.acc
LEADS_VERSION=$(CORPORA_DIR)/version.leads

$(CORPORA_DIR)/leads/all.files: $(LEAD_CORPUS_ROOT)/.git/HEAD
	mkdir -p $(CORPORA_DIR)/leads
	cd $(LEAD_CORPUS_ROOT) && ls -1 knp/*/*.knp > $(abspath $(CORPORA_DIR)/leads/all.files)

$(CORPORA_DIR)/leads/train.files: $(LEAD_CORPUS_ROOT)/.git/HEAD $(CORPORA_DIR)/leads/all.files
	grep -vFf $(LEAD_CORPUS_ROOT)/id/test.id $(CORPORA_DIR)/leads/all.files > $(CORPORA_DIR)/leads/train.files

$(CORPORA_DIR)/leads/test.files: $(LEAD_CORPUS_ROOT)/.git/HEAD $(CORPORA_DIR)/leads/all.files
	grep -Ff $(LEAD_CORPUS_ROOT)/id/test.id $(CORPORA_DIR)/leads/all.files > $(CORPORA_DIR)/leads/test.files

$(LEADS_TRAIN): $(LEAD_CORPUS_ROOT)/.git/HEAD $(JUMANPP_SCRIPT) $(CORPORA_DIR)/leads/train.files
	mkdir -p $(CORPORA_DIR)/leads/train
	cat $(CORPORA_DIR)/leads/train.files | xargs -n1 -I % cp $(LEAD_CORPUS_ROOT)/% $(CORPORA_DIR)/leads/train
	cat $(CORPORA_DIR)/leads/train/* | \
		ruby $(JUMANPP_SCRIPT)/corpus2train.rb --disablePOSchange \
		> $(LEADS_TRAIN)

$(LEADS_TEST): $(LEAD_CORPUS_ROOT)/.git/HEAD $(JUMANPP_SCRIPT) $(CORPORA_DIR)/leads/test.files
	mkdir -p $(CORPORA_DIR)/leads/test
	cat $(CORPORA_DIR)/leads/test.files | xargs -n1 -I % cp $(LEAD_CORPUS_ROOT)/% $(CORPORA_DIR)/leads/test
	cat $(CORPORA_DIR)/leads/test/* | \
		ruby $(JUMANPP_SCRIPT)/corpus2train.rb --disablePOSchange \
		> $(LEADS_TEST)

$(LEADS_VERSION) : $(LEAD_CORPUS_ROOT)/.git/HEAD $(CORPORA_DIR)
	git -C $(LEAD_CORPUS_ROOT) log \
		--oneline --date=format:%Y%m%d --format=L:%ad-%h --max-count=1 HEAD > $(abspath $(LEADS_VERSION))

leads: $(LEADS_VERSION) $(LEADS_TEST) $(LEADS_TRAIN)

# Kyoto Corpus

KYOTO_KNP_TRAIN=$(CORPORA_DIR)/kyoto/train.knp
KYOTO_KNP_TEST=$(CORPORA_DIR)/kyoto/test.knp
KYOTO_TRAIN=$(CORPORA_DIR)/train.kyoto.fmrp
KYOTO_TEST=$(CORPORA_DIR)/test.kyoto.fmrp
KYOTO_TEST_MRP=$(CORPORA_DIR)/test.kyoto.mrp
KYOTO_TEST_IDRAW=$(CORPORA_DIR)/test.kyoto.idraw
KYOTO_TEST_AUTO=$(EVAL_DIR)/test.kyoto.auto.mrp
KYOTO_TEST_ACC=$(EVAL_DIR)/test.kyoto.auto.acc
KYOTO_VERSION=$(CORPORA_DIR)/version.kyoto

ifneq ($(KYOTO_CORPUS_MODE),none)

$(KYOTO_TRAIN): $(KYOTO_CORPUS_ROOT)/.git/HEAD $(JUMANPP_SCRIPT) $(KYOTO_KNP_TRAIN)
	ruby $(JUMANPP_SCRIPT)/corpus2train.rb --disablePOSchange \
	> $(KYOTO_TRAIN) < $(KYOTO_KNP_TRAIN)

$(KYOTO_TEST): $(KYOTO_CORPUS_ROOT)/.git/HEAD $(JUMANPP_SCRIPT) $(KYOTO_KNP_TEST)
	ruby $(JUMANPP_SCRIPT)/corpus2train.rb --disablePOSchange \
	> $(KYOTO_TEST) < $(KYOTO_KNP_TEST)

else

$(KYOTO_TRAIN):
	touch $(KYOTO_TRAIN)

$(KYOTO_TEST):
	touch $(KYOTO_TEST)

$(KYOTO_VERSION):
	touch $(KYOTO_VERSION)

endif

kyoto: $(KYOTO_TRAIN) $(KYOTO_TEST) $(KYOTO_VERSION)

# augmented corpora

TRAIN_FULL_ALL=$(CORPORA_DIR)/train.concat.fmrp

$(TRAIN_FULL_ALL): $(LEADS_TRAIN) $(KYOTO_TRAIN)
	cat $^ > $@

MODEL_TRAIN_CORPUS=$(CORPORA_DIR)/full.aug.fmrp

$(MODEL_TRAIN_CORPUS) : $(KYOTO_TRAIN) $(KYOTO_TEST) $(LEADS_TRAIN) $(LEADS_TEST)
	cat $^ > $(CORPORA_DIR)/full.no-aug.fmrp
	PYTHONUTF8=1 python3 $(SCRIPT_DIR)/remove_case_particles.py $(CORPORA_DIR)/full.no-aug.fmrp > $(CORPORA_DIR)/full.no-case.fmrp
	PYTHONUTF8=1 python3 $(SCRIPT_DIR)/prepare_full_corpus.py $(CORPORA_DIR)/full.no-aug.fmrp $(CORPORA_DIR)/full.no-case.fmrp > $(MODEL_TRAIN_CORPUS)

mdl_train_full: $(MODEL_TRAIN_CORPUS)

# partially-annotated training data


FAIRYMA_TSV = $(CORPORA_DIR)/fairyma.tsv
FAIRYMA_TRAIN = $(CORPORA_DIR)/fairyma.jpp2part
PARTIAL_TRAIN = $(CORPORA_DIR)/train.jpp2part
FAIRYMA_VERSION = $(CORPORA_DIR)/version.fairyma
PARTIAL_ANNOTATED_FILE = $(CORPORA_DIR)/partial.jpp2part

$(FAIRYMA_TSV) : $(CORPORA_DIR) $(FAIRYMA_CORPUS_ROOT)/.git/HEAD
	cd $(FAIRYMA_CORPUS_ROOT)/corpus && \
		cat original/misc.tsv wikipedia/manual/data.tsv wikipedia/confusing-jumanpp/*.tsv > $(abspath $(FAIRYMA_TSV))

$(FAIRYMA_VERSION) : $(FAIRYMA_CORPUS_ROOT)/.git/HEAD
	git -C $(FAIRYMA_CORPUS_ROOT) log --oneline --date=format:%Y%m%d --format=F:%ad-%h --max-count=1 HEAD > $(abspath $(FAIRYMA_VERSION))

$(FAIRYMA_TRAIN) : $(FAIRYMA_TSV) $(JUMANPP_SCRIPT)
	PYTHONUTF8=1 python3 $(JUMANPP_SCRIPT)/corpus/fairy2jpppart.py --input $(FAIRYMA_TSV) > $(FAIRYMA_TRAIN)

ifneq ($(PARTIAL_ANNOTATED_URL),)
$(PARTIAL_ANNOTATED_FILE):
	curl --location -o $(PARTIAL_ANNOTATED_FILE) $(PARTIAL_ANNOTATED_URL)

partial-update:
	curl --location -o $(PARTIAL_ANNOTATED_FILE) $(PARTIAL_ANNOTATED_URL)

.PHONY: partial-update
else
$(PARTIAL_ANNOTATED_FILE):
	touch $(PARTIAL_ANNOTATED_FILE)
endif

$(PARTIAL_TRAIN) : $(FAIRYMA_TRAIN) $(JUMANPP_SCRIPT) $(PARTIAL_ANNOTATED_FILE)
	cat $(JUMANPP_ROOT)/sample/sample.jppv2part $(PARTIAL_ANNOTATED_FILE) $(FAIRYMA_TRAIN) > $(PARTIAL_TRAIN)

# versions

CORPUS_VERSIONS := $(CORPORA_DIR)/version.corpora

$(CORPUS_VERSIONS) : $(KYOTO_VERSION) $(LEADS_VERSION) $(FAIRYMA_VERSION)
	paste -d ' ' $^ > $@

corpora: $(KYOTO_TRAIN) $(KYOTO_TEST) $(LEADS_TRAIN) $(LEADS_TEST) $(TRAIN_FULL_ALL) $(MODEL_TRAIN_CORPUS) $(PARTIAL_TRAIN)