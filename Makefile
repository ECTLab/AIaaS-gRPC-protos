PROTOS_DIR=./protos
PYTHON_PROTOS_OUTPUT_DIR=./AIaaS_interface
PYTHON_REQUIREMENTS_FILE_PATH=./requirements.txt
GOLANG_PROTOS_OUTPUT_DIR=./golang

clean:
	rm -rf $(PYTHON_PROTOS_OUTPUT_DIR)
	rm -rf $(GOLANG_PROTOS_OUTPUT_DIR)

set_new_version_tag:
	bash ./scripts/generate_new_version_tag.sh

install_python_requirements:
	pip install -r $(PYTHON_REQUIREMENTS_FILE_PATH)

install_golang_requirements:
	sudo apt-get update && sudo apt-get install -y protobuf-compiler
	go install google.golang.org/protobuf/cmd/protoc-gen-go
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc

generate_python_protos: clean install_python_requirements
	mkdir $(PYTHON_PROTOS_OUTPUT_DIR)
	find $(PROTOS_DIR) -name "*.proto" \
	-exec python -m grpc_tools.protoc \
	-I./protos \
	--python_out=$(PYTHON_PROTOS_OUTPUT_DIR) \
	--pyi_out=$(PYTHON_PROTOS_OUTPUT_DIR) \
	--grpc_python_out=$(PYTHON_PROTOS_OUTPUT_DIR) {} \;
	bash ./scripts/add_init_files.sh $(PYTHON_PROTOS_OUTPUT_DIR)

generate_golang_protos: clean install_golang_requirements
	mkdir $(GOLANG_PROTOS_OUTPUT_DIR)
	find $(PROTOS_DIR) -name "*.proto" \
	-exec protoc \
	-I./protos \
	--go_out=$(GOLANG_PROTOS_OUTPUT_DIR) \
	--go-grpc_out=$(GOLANG_PROTOS_OUTPUT_DIR) {} \;
