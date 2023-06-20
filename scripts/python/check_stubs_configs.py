import os
import fnmatch
import sys
import json
import re


def check_config_keys_and_values(service_config: dict) -> None:
    global protos_folder

    required_keys = [
        'name',
        'proto_file_path',
        'host',
        'port',
    ]
    for required_key in required_keys:
        if required_key not in service_config:
            raise Exception(f'{required_key} is required in service config!')
    if len(service_config.keys()) > len(required_keys):
        raise Exception('service config must have only required keys!')

    if type(service_config['name']) != str:
        raise Exception('name must be a string!')
    if type(service_config['proto_file_path']) != str:
        raise Exception('proto_file_path must be a string!')
    if service_config['proto_file_path'].split('/')[0] != protos_folder:
        raise Exception('proto_file_path must be in the protos folder!')

    try:
        proto_file = open(service_config['proto_file_path'], 'r')
    except:
        raise Exception('proto_file_path must be a valid path to a proto file!')

    proto_file_text = proto_file.read()
    if re.search(r'service\s+', proto_file_text) is None:
        raise Exception('proto file must have a service!')
    if re.search(r'service\s+' + service_config['name'] + r'\s*{', proto_file_text) is None:
        raise Exception('proto file must have a service with the same name in service config!')
    proto_file.close()

    if type(service_config['host']) != str:
        raise Exception('host must be a string!')
    if type(service_config['port']) != int:
        raise Exception('port must be an integer!')




if __name__ == '__main__':
    # read arguments
    stubs_configs_file_path = sys.argv[1]
    protos_output_folder = sys.argv[2].split('/')[1]
    protos_folder = sys.argv[3].split('/')[1]
    print(f'protos folder: {protos_folder}')

    # read stubs configs file
    stubs_json_dict = json.loads(open(stubs_configs_file_path, 'r').read())


    services_configs = stubs_json_dict['services']
    if type(services_configs) != list:
        raise Exception('services must be a list of configs!')

    next_port = stubs_json_dict['_comment']['next_port']
    if type(next_port) != int:
        raise Exception('next_port must be an integer!')


    used_ports, implemented_services = [], []
    for service_config in services_configs:
        check_config_keys_and_values(service_config)

        if service_config['port'] < 50051:
            raise Exception('port must be greater than 50051!')
        if service_config['port'] > 50999:
            raise Exception('port must be less than 50999!')
        if service_config['port'] in used_ports:
            raise Exception('port must be unique!')
        if service_config['port'] >= next_port:
            raise Exception('next_port must be updated!')
        used_ports.append(service_config['port'])

        if service_config['name'] in implemented_services:
            raise Exception('service name must be unique!')
        implemented_services.append(service_config['name'])


    proto_files = []
    for root, dirnames, filenames in os.walk(protos_folder):
        for filename in fnmatch.filter(filenames, '*.proto'):
            proto_files.append(os.path.join(root, filename))

    for proto_file in proto_files:
        with open(proto_file, 'r') as f:
            proto_file_text = f.read()
            if 'service' not in proto_file_text:
                continue

            service_name = re.search(r'service\s+(.+)\s*{', proto_file_text).group(1).strip()
            if service_name not in implemented_services:
                raise Exception(f'{service_name} is not added in stubs configs!')


    print('\n\nstubs configs file is valid ✅')
    exit(0)
