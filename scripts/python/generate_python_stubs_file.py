import json
import sys
import re


# global variables
DICT_HOST_KEY = 'host'
DICT_PORT_KEY = 'port'
DICT_STUB_CLASS_KEY = 'stub_class'



class Service:
    def __init__(
        self,
        host: str,
        port: int,
        name: str,
        proto_file_path: str,
        protos_output_folder: str,
    ):
        self.host = host
        self.port = port
        self.name = name
        self.__proto_file_path = proto_file_path
        self.__protos_output_folder = protos_output_folder

        self.module_path: str = None
        self.__generate_module_import_code_str()

    def __generate_module_import_code_str(self) -> None:
        module_path = self.__proto_file_path.replace('/', '.')
        module_path = module_path.replace('.proto', '_pb2_grpc')
        module_path = module_path.replace('protos', self.__protos_output_folder)
        self.module_path = 'from ' + module_path + ' import ' + self.name + 'Stub'



def convert_to_snake_case(string):
    pattern = r'([A-Z])'
    split_string = re.sub(pattern, r'_\1', string).strip('_')
    return split_string.upper()



def generate_stubs_file_code(
    services: list,
    stubs_output_file_path: str,
    template_output_file_path: str,
) -> None:

    # read template file
    stubs_output_template_file = open(template_output_file_path, 'r')
    stubs_output_file_text = stubs_output_template_file.read()
    stubs_output_template_file.close()

    # replace dict keys in get_stub function
    stubs_output_file_text = stubs_output_file_text.replace(
        '$HOST_KEY',
        DICT_HOST_KEY,
    )
    stubs_output_file_text = stubs_output_file_text.replace(
        '$PORT_KEY',
        DICT_PORT_KEY,
    )
    stubs_output_file_text = stubs_output_file_text.replace(
        '$STUB_CLASS_KEY',
        DICT_STUB_CLASS_KEY,
    )

    # import libraries code generation
    default_imports = [
        'grpc',
    ]
    imports_code = ''
    for default_import in default_imports:
        imports_code += f'import {default_import}\n'
    imports_code += '\n'

    for service in services:
        imports_code += service.module_path + '\n'

    stubs_output_file_text = stubs_output_file_text.replace(
        '{{ import libraries code }}',
        imports_code,
    )
    
    # services code generation
    services_code = 'class Services:\n'
    for service in services:
        services_code += f'\t{convert_to_snake_case(service.name)} = {{\n'
        services_code += f'\t\t"{DICT_HOST_KEY}": "{service.host}",\n'
        services_code += f'\t\t"{DICT_PORT_KEY}": {service.port},\n'
        services_code += f'\t\t"{DICT_STUB_CLASS_KEY}": {service.name}Stub,\n'
        services_code += '\t}\n'
    stubs_output_file_text = stubs_output_file_text.replace(
        '{{ Services class code }}',
        services_code,
    )

    # write stubs output file
    stubs_output_file = open(stubs_output_file_path, 'w')
    stubs_output_file.write(stubs_output_file_text)
    stubs_output_file.close()




if __name__ == '__main__':
    print(f'args: {sys.argv}')
    # read arguments
    stubs_configs_file_path = sys.argv[1]
    stubs_output_folder = sys.argv[2]
    protos_output_folder = stubs_output_folder.split('/')[1]
    stubs_output_file_path = sys.argv[3]
    template_output_file_path = sys.argv[4]


    # read stubs configs file
    stubs_json_dict = json.loads(open(stubs_configs_file_path, 'r').read())
    services_configs = stubs_json_dict['services']


    # create services objects
    services = []
    for service in services_configs:
        services.append(
            Service(
                host=service['host'],
                port=service['port'],
                name=service['name'],
                proto_file_path=service['proto_file_path'],
                protos_output_folder=protos_output_folder,
            )
        )

    generate_stubs_file_code(
        services=services,
        stubs_output_file_path=stubs_output_file_path,
        template_output_file_path=template_output_file_path,
    )
