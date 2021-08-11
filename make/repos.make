JUMANPP_ROOT ?= $(REPO_ROOT)/jumanpp
JUMANDIC_ROOT ?= $(REPO_ROOT)/jumandic
KYOTO_CORPUS_ROOT ?= $(REPO_ROOT)/kyoto-corpus
LEAD_CORPUS_ROOT ?= $(REPO_ROOT)/lead-corpus
FAIRYMA_CORPUS_ROOT ?= $(REPO_ROOT)/fairyma-corpus
JUMANPP_SCRIPT = $(JUMANPP_ROOT)/script

$(JUMANPP_ROOT)/.git/HEAD $(JUMANPP_SCRIPT) :
	mkdir -p $(JUMANPP_ROOT)
	git clone git@github.com:ku-nlp/jumanpp.git $(JUMANPP_ROOT)

$(JUMANDIC_ROOT)/.git/HEAD :
	mkdir -p $(JUMANDIC_ROOT)
	git clone git@github.com:ku-nlp/jumandic.git $(JUMANDIC_ROOT)

$(LEAD_CORPUS_ROOT)/.git/HEAD :
	mkdir -p $(LEAD_CORPUS_ROOT)
	git clone git@github.com:ku-nlp/kwdlc.git $(LEAD_CORPUS_ROOT)

$(FAIRYMA_CORPUS_ROOT)/.git/HEAD :
	mkdir -p $(FAIRYMA_CORPUS_ROOT)
	git clone git@github.com:FairyDevicesRD/FairyMaCorpus.git $(FAIRYMA_CORPUS_ROOT)

update-repos:
	git -C $(JUMANPP_ROOT) pull
	git -C $(JUMANDIC_ROOT) pull
	git -C $(KYOTO_CORPUS_ROOT) pull
	git -C $(LEAD_CORPUS_ROOT) pull
	git -C $(FAIRYMA_CORPUS_ROOT) pull

jumanpp-repo: $(JUMANPP_ROOT)/.git/HEAD

repos: $(JUMANPP_ROOT)/.git/HEAD $(JUMANDIC_ROOT)/.git/HEAD $(KYOTO_CORPUS_ROOT)/.git/HEAD $(LEAD_CORPUS_ROOT)/.git/HEAD $(FAIRYMA_CORPUS_ROOT)/.git/HEAD