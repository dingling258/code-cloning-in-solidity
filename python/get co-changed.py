from lxml import etree
from collections import defaultdict

def get_function_identifier(source_elem):
    file_name = source_elem.get('file', '')
    start_line = source_elem.get('startline', '')
    end_line = source_elem.get('endline', '')
    return f"{file_name}:{start_line}-{end_line}"

def compare_nicad_xml(base_xml, compare_xml):
    parser = etree.XMLParser(recover=True)
    base_root = etree.parse(base_xml, parser=parser).getroot()
    compare_root = etree.parse(compare_xml, parser=parser).getroot()

    base_functions = {}
    compare_functions = {}
    co_added_functions = defaultdict(list)
    co_changed_functions = defaultdict(list)
    base_clone_clusters = defaultdict(list)

    # 解析基础版本的function和克隆簇
    for class_elem in base_root.findall('class'):
        clone_id = class_elem.get('classid')
        for source_elem in class_elem.findall('source'):
            function_code = ''.join(source_elem.itertext())
            function_id = get_function_identifier(source_elem)
            base_functions[function_id] = (clone_id, function_code)
            base_clone_clusters[clone_id].append(function_id)

    # 解析比较版本的function
    for class_elem in compare_root.findall('class'):
        clone_id = class_elem.get('classid')
        for source_elem in class_elem.findall('source'):
            function_code = ''.join(source_elem.itertext())
            function_id = get_function_identifier(source_elem)
            compare_functions[function_id] = (clone_id, function_code)

    # 计算新增和修改的function
    for function_id, (clone_id, function_code) in compare_functions.items():
        file_name = function_id.split(':')[0]
        if function_id not in base_functions:
            # 查找对应的基础版本克隆簇
            for base_clone_id, base_functions_list in base_clone_clusters.items():
                if any(bf.split(':')[0] == file_name for bf in base_functions_list):
                    co_added_functions[base_clone_id].append(function_id)
                    break
            else:
                # 如果没有找到对应的基础版本克隆簇，创建一个新的克隆簇
                new_clone_id = f"new_clone_{len(co_added_functions)}"
                co_added_functions[new_clone_id].append(function_id)
        else:
            base_clone_id, base_function_code = base_functions[function_id]
            if base_function_code != function_code:
                co_changed_functions[base_clone_id].append((function_id, function_id))

    return co_added_functions, co_changed_functions, base_clone_clusters

# 示例用法
base_xml = r'D:\program\solidity-nicad-master\openzeppelin\openzeppelin-solidity-v4.7.0\withsource\type-3-2.xml'
compare_xml = r'D:\program\solidity-nicad-master\openzeppelin\openzeppelin-solidity-v4.8.0\withsource\type-3-2.xml'
co_added_funcs, co_changed_funcs, base_clone_clusters = compare_nicad_xml(base_xml, compare_xml)

print("Co-added functions:")
for clone_id, added_functions in co_added_funcs.items():
    if clone_id.startswith("new_clone_"):
        print(f"New Clone Cluster:")
        print(f"  {', '.join(added_functions)}")
    else:
        base_function = base_clone_clusters[clone_id][0] if base_clone_clusters[clone_id] else "No base function"
        print(f"Base Clone ID {clone_id}:")
        print(f"  {base_function} : {', '.join(added_functions)}")

print("\nCo-changed functions:")
for clone_id, functions in co_changed_funcs.items():
    print(f"Clone ID {clone_id}:")
    print(f"  {', '.join([f'{old} -> {new}' for old, new in functions])}")

print(f"\nCo-added functions总数: {sum(len(funcs) for funcs in co_added_funcs.values())}")
print(f"Co-changed functions总数: {sum(len(funcs) for funcs in co_changed_funcs.values())}")