PROTOS_DIR=./protos
STUBS_CONFIGS_FILE=$(PROTOS_DIR)/stubs/stubs_configs.json
SCRIPTS_DIR=./scripts
TEXT_FILES_DIR=$(SCRIPTS_DIR)/text_files
PYTHON_SCRIPTS_DIR=$(SCRIPTS_DIR)/python

PYTHON_PROTOS_OUTPUT_DIR=./AIaaS_interface
PYTHON_REQUIREMENTS_FILE_PATH=./requirements.txt
PYTHON_STUBS_OUTPUT_DIR=$(PYTHON_PROTOS_OUTPUT_DIR)
PYTHON_STUBS_CONFIGS_CHECKER_SCRIPT=$(PYTHON_SCRIPTS_DIR)/check_stubs_configs.py
PYTHON_STUBS_GENERATOR_SCRIPT=$(PYTHON_SCRIPTS_DIR)/generate_python_stubs_file.py
STUBS_OUTPUT_FILE_PATH=$(PYTHON_STUBS_OUTPUT_DIR)/stubs.py
TEMPLATE_OUTPUT_FILE_PATH=$(TEXT_FILES_DIR)/stubs_py_template.txt



clean:
	@rm -rf $(PYTHON_PROTOS_OUTPUT_DIR)

set_new_version_tag:
	@bash ./scripts/generate_new_version_tag.sh

install_python_requirements:
	pip install -r $(PYTHON_REQUIREMENTS_FILE_PATH)

check_stubs_configs_file:
	python \
		$(PYTHON_STUBS_CONFIGS_CHECKER_SCRIPT) \
		$(STUBS_CONFIGS_FILE) \
		$(PYTHON_PROTOS_OUTPUT_DIR) \
		$(PROTOS_DIR)

generate_python_protos: clean install_python_requirements
	@mkdir $(PYTHON_PROTOS_OUTPUT_DIR)
	@find $(PROTOS_DIR) -name "*.proto" \
	-exec python -m grpc_tools.protoc \
	-I$(PROTOS_DIR) \
	--python_out=$(PYTHON_PROTOS_OUTPUT_DIR) \
	--pyi_out=$(PYTHON_PROTOS_OUTPUT_DIR) \
	--grpc_python_out=$(PYTHON_PROTOS_OUTPUT_DIR) {} \;
	bash ./scripts/add_init_files.sh $(PYTHON_PROTOS_OUTPUT_DIR)

generate_python_stubs: generate_python_protos
	python \
		$(PYTHON_STUBS_GENERATOR_SCRIPT) \
		$(STUBS_CONFIGS_FILE) \
		$(PYTHON_STUBS_OUTPUT_DIR) \
		$(STUBS_OUTPUT_FILE_PATH) \
		$(TEMPLATE_OUTPUT_FILE_PATH)
