PROTOS_DIR=./protos
PYTHON_PROTOS_OUTPUT_DIR=./AIaaS_interface
PYTHON_REQUIREMENTS_FILE_PATH=./requirements.txt


clean:
	rm -rf $(PYTHON_PROTOS_OUTPUT_DIR)

set_new_version_tag:
	bash ./scripts/generate_new_version_tag.sh

install_python_requirements:
	pip install -r $(PYTHON_REQUIREMENTS_FILE_PATH)

generate_python_protos: clean install_python_requirements
	mkdir $(PYTHON_PROTOS_OUTPUT_DIR)
	find $(PROTOS_DIR) -name "*.proto" \
	-exec python -m grpc_tools.protoc \
	-I./protos \
	--python_out=$(PYTHON_PROTOS_OUTPUT_DIR) \
	--pyi_out=$(PYTHON_PROTOS_OUTPUT_DIR) \
	--grpc_python_out=$(PYTHON_PROTOS_OUTPUT_DIR) {} \;
	bash ./scripts/add_init_files.sh $(PYTHON_PROTOS_OUTPUT_DIR)
