import sys
import os


if __name__ == '__main__':
    init_file_dir = sys.argv[1]

    imports_text = ""
    for file_name in os.listdir(init_file_dir):
        if file_name == '__init__.py':
            continue

        if (
            os.path.isdir(f'{init_file_dir}/{file_name}') or
            (file_name.endswith('.py'))
        ):
            module_name = file_name.split('.')[0]
            imports_text += f'import {module_name}\n'

    init_file_text = open(f'{init_file_dir}/__init__.py', 'r').read()
    init_file_text = init_file_text.replace('{{ sub modules imports }}', imports_text)
    open(f'{init_file_dir}/__init__.py', 'w').write(init_file_text)
