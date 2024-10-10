from lxml import etree
import os
from collections import defaultdict
import re
from difflib import SequenceMatcher


def get_function_identifier(source_elem):
    file_name = source_elem.get('file', '')
    start_line = source_elem.get('startline', '')
    end_line = source_elem.get('endline', '')
    return f"{file_name}:{start_line}-{end_line}"


def get_function_content(source_elem):
    return ''.join(source_elem.itertext()).strip()


def get_function_name(content):
    match = re.search(r'function\s+(\w+)', content)
    return match.group(1) if match else None


def remove_comments_and_whitespace(content):
    # 移除单行注释
    content = re.sub(r'//.*', '', content)
    # 移除多行注释
    content = re.sub(r'/\*[\s\S]*?\*/', '', content)
    # 移除空白字符
    content = re.sub(r'\s+', ' ', content).strip()
    return content


def check_function_exists(function_id, function_content, function_name, source_dir, similarity_threshold=0.8):
    file_path, _ = function_id.split(':')
    full_path = os.path.join(source_dir, file_path)
    if not os.path.exists(full_path):
        return False
    with open(full_path, 'r', encoding='utf-8') as f:
        content = f.read()
        if function_name and f"function {function_name}" in content:
            return True
        function_content = remove_comments_and_whitespace(function_content)
        content = remove_comments_and_whitespace(content)
        similarity = SequenceMatcher(None, function_content, content).ratio()
        return similarity >= similarity_threshold


def file_significantly_changed(file_path, base_dir, compare_dir, change_threshold=0.3):
    base_path = os.path.join(base_dir, file_path)
    compare_path = os.path.join(compare_dir, file_path)

    if not os.path.exists(base_path) or not os.path.exists(compare_path):
        return True

    with open(base_path, 'r', encoding='utf-8') as f:
        base_content = remove_comments_and_whitespace(f.read())
    with open(compare_path, 'r', encoding='utf-8') as f:
        compare_content = remove_comments_and_whitespace(f.read())

    similarity = SequenceMatcher(None, base_content, compare_content).ratio()
    return (1 - similarity) > change_threshold


def detect_co_deleted_functions(base_xml, compare_xml, base_source_dir, compare_source_dir, min_function_size=100,
                                co_delete_threshold=4):
    parser = etree.XMLParser(recover=True)
    base_root = etree.parse(base_xml, parser=parser).getroot()
    compare_root = etree.parse(compare_xml, parser=parser).getroot()

    base_clones = {}
    compare_clones = {}

    for class_elem in base_root.findall('class'):
        clone_id = class_elem.get('classid')
        base_clones[clone_id] = [(get_function_identifier(source_elem),
                                  get_function_content(source_elem),
                                  get_function_name(get_function_content(source_elem)))
                                 for source_elem in class_elem.findall('source')]

    for class_elem in compare_root.findall('class'):
        clone_id = class_elem.get('classid')
        compare_clones[clone_id] = [get_function_identifier(source_elem)
                                    for source_elem in class_elem.findall('source')]

    co_deleted_functions = defaultdict(list)

    for clone_id, base_functions in base_clones.items():
        deleted_functions = []
        for func_id, func_content, func_name in base_functions:
            if len(func_content) < min_function_size:
                continue
            file_path = func_id.split(':')[0]
            if file_significantly_changed(file_path, base_source_dir, compare_source_dir):
                if (clone_id not in compare_clones or func_id not in compare_clones[clone_id]) and \
                        not check_function_exists(func_id, func_content, func_name, compare_source_dir):
                    deleted_functions.append(func_id)

        if len(deleted_functions) >= co_delete_threshold:
            co_deleted_functions[clone_id].extend(deleted_functions)

    return co_deleted_functions


# 示例用法
base_xml = r'D:\program\solidity-nicad-master\synthetix\v2.100.0\withsource\type-3-2.xml'
compare_xml = r'D:\program\solidity-nicad-master\synthetix\v2.101.2\withsource\type-3-2.xml'
base_source_dir = r'D:\program\solidity-nicad-master\synthetix\v2.100.0\source-code'
compare_source_dir = r'D:\program\solidity-nicad-master\synthetix\v2.101.2\source-code'

co_deleted_functions = detect_co_deleted_functions(base_xml, compare_xml, base_source_dir, compare_source_dir)

print("Co-deleted functions:")
for clone_id, functions in co_deleted_functions.items():
    print(f"Clone ID {clone_id}:")
    print(f"  {', '.join(functions)}")

total_co_deleted = sum(len(functions) for functions in co_deleted_functions.values())
print(f"\nCo-deleted functions总数: {total_co_deleted}")