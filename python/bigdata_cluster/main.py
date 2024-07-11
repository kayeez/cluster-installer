

import os


if __name__ == '__main__':
    with open(os.path.join('data', 'bigdata_env.sh'), 'r') as reader:
        content = reader.read()
        print(content)
